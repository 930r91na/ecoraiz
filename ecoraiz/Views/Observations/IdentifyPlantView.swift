import SwiftUI
import UIKit

struct IdentifyPlantView: View {
    @ObservedObject private var classificationService = PlantClassificationService.shared
    
    @State private var selectedImage: UIImage?
    @State private var showCameraSheet = false
    @State private var showPhotoLibrarySheet = false
    @State private var detectedPlant: InvasivePlant?
    @State private var showingAlert = false
    @State private var hasIdentified = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title and instructions
                if !hasIdentified {
                    Text("Identificar Planta")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Toma o selecciona una foto de la planta que deseas identificar")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if hasIdentified && detectedPlant != nil {
                    // Show results header
                    Text("Planta Identificada")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Card view for detected plant
                    PlantCardView(plant: detectedPlant!)
                        .padding(.horizontal)
                    
                    // Identification details and options
                    VStack(alignment: .leading, spacing: 15) {
                        if let result = classificationService.classificationResult,
                           let details = result.details {
                            // Description section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descripción:")
                                    .font(.headline)
                                
                                Text(details.description)
                                    .font(.body)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Control methods
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Métodos de control:")
                                    .font(.headline)
                                
                                ForEach(details.controlMethods.prefix(2), id: \.self) { method in
                                    HStack(alignment: .top) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 8))
                                            .padding(.top, 6)
                                        Text(method)
                                    }
                                }
                                
                                if details.controlMethods.count > 2 {
                                    Text("Ver más...")
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                        .padding(.top, 5)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: {
                        resetIdentification()
                    }) {
                        Text("Identificar Otra Planta")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                    
                } else {
                    // Image preview
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .padding()
                    } else {
                        // Placeholder
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "leaf")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            )
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Button stack
                    HStack(spacing: 30) {
                        Button(action: { showCameraSheet = true }) {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                Text("Cámara")
                            }
                            .frame(width: 120, height: 100)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Button(action: { showPhotoLibrarySheet = true }) {
                            VStack {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 30))
                                Text("Galería")
                            }
                            .frame(width: 120, height: 100)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    
                    // Identify button
                    if selectedImage != nil {
                        Button(action: identifyImage) {
                            if classificationService.isProcessing {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Analizando...")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.7))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            } else {
                                Text("Identificar Planta")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        }
                        .disabled(classificationService.isProcessing)
                        .padding(.vertical)
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
        .takePhoto(isPresented: $showCameraSheet) { image in
            if let image = image {
                self.selectedImage = image
                self.hasIdentified = false
            }
        }
        .pickPhoto(isPresented: $showPhotoLibrarySheet) { image in
            if let image = image {
                self.selectedImage = image
                self.hasIdentified = false
            }
        }
        // Add the alert for displaying error messages
        .alert(isPresented: $showingAlert) {
            if let error = classificationService.error {
                if error == .lowConfidence, classificationService.classificationResult != nil {
                    return Alert(
                        title: Text("Confianza Baja"),
                        message: Text(error.localizedDescription + "\n¿Deseas ver el resultado de todas formas?"),
                        primaryButton: .default(Text("Ver Resultado")) {
                            processIdentificationResult()
                        },
                        secondaryButton: .cancel()
                    )
                } else {
                    return Alert(
                        title: Text("Error de Identificación"),
                        message: Text(error.localizedDescription),
                        dismissButton: .default(Text("OK"))
                    )
                }
            } else {
                return Alert(
                    title: Text("Error"),
                    message: Text("Ocurrió un error desconocido"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func identifyImage() {
        guard let image = selectedImage else { return }
        
        // Show loading indicator or disable button while processing
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        
        // Process the image with ML model
        classificationService.classifyImage(image)
        
        // Check for errors or low confidence after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if classificationService.error == nil {
                generator.notificationOccurred(.success)
                // No error, process the result
                processIdentificationResult()
            } else if classificationService.error == .lowConfidence {
                generator.notificationOccurred(.warning)
                // Show alert for low confidence
                showingAlert = true
            } else {
                generator.notificationOccurred(.error)
                // Show alert for other errors
                showingAlert = true
            }
        }
    }
    
    private func processIdentificationResult() {
        guard let result = classificationService.classificationResult else { return }
        
        // Convert the classification result to your InvasivePlant model
        let severity: InvasivePlant.Severity
        
        if let details = result.details {
            switch details.invasiveLevel {
            case .low:
                severity = .low
            case .medium:
                severity = .medium
            case .high, .extreme:
                severity = .high
            }
        } else {
            severity = .medium
        }
        
        // Create an InvasivePlant instance
        detectedPlant = InvasivePlant(
            id: UUID().uuidString,
            name: result.plantName,
            scientificName: result.details?.scientificName ?? "Desconocido",
            distance: nil, // No distance information
            severity: severity,
            imageURL: "", // No image URL, we're using the captured image
            accuracyDetection: Double(result.confidence)
        )
        
        // Set hasIdentified to true to show the result view
        hasIdentified = true
    }
    
    private func resetIdentification() {
        selectedImage = nil
        detectedPlant = nil
        hasIdentified = false
        classificationService.classificationResult = nil
        classificationService.error = nil
    }
}

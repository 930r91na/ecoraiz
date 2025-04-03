import SwiftUI
import UIKit

struct IdentifyPlantView: View {
    @ObservedObject private var classificationService = PlantClassificationService.shared
    
    @State private var selectedImage: UIImage?
    @State private var showCameraSheet = false
    @State private var showPhotoLibrarySheet = false
    @State private var potentialPlants: [InvasivePlant] = []
    @State private var showingAlert = false
    @State private var hasIdentified = false
    @State private var navigateToPlantDetail = false
    @State private var selectedPlantForDetail: InvasivePlant?
    
    // For preview testing - set to true to see identified state
    @State private var previewIdentifiedState = false
    
    // Constants for consistent spacing and sizing
    private let spacing: CGFloat = 16
    private let cornerRadius: CGFloat = 12
    private let buttonHeight: CGFloat = 56
    private let imageHeight: CGFloat = 450
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // HEADER SECTION
                        if !hasIdentified && !previewIdentifiedState {
                            VStack(spacing: spacing/2) {
                                Text("Identificar Planta")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            .padding(.top, spacing)
                            .padding(.bottom, spacing)
                        } else {
                            VStack(spacing: spacing/2) {
                                Text("Posible Planta Identificadada")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.top, spacing)
                            .padding(.bottom, spacing)
                        }
                        
                        // IDENTIFICATION RESULTS OR IMAGE SELECTION
                        if (hasIdentified && !potentialPlants.isEmpty) || previewIdentifiedState {
                            plantSelectionView
                                .background(
                                    NavigationLink(
                                        destination: selectedPlantForDetail.map { plant in
                                            Text("Detalle de \(plant.name)")
                                        },
                                        isActive: $navigateToPlantDetail
                                    ) {
                                        EmptyView()
                                    }
                                )
                        } else {
                            imageSelectionView
                        }
                        
                        // Add spacer to push content up
                        Spacer(minLength: 100) // Space for buttons at bottom
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                
                // Bottom buttons container - always at the bottom
                VStack(spacing: spacing) {
                    if ((hasIdentified && !potentialPlants.isEmpty) || previewIdentifiedState) {
                        // Continue button
                        Button(action: resetIdentification) {
                            Text("Identificar Otra Planta")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: buttonHeight)
                                .background(Color.primaryGreen)
                                .cornerRadius(cornerRadius)
                        }
                    } else if selectedImage != nil {
                        // Identify button
                        Button(action: identifyImage) {
                            HStack(spacing: 10) {
                                if classificationService.isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Analizando...")
                                } else {
                                    Image(systemName: "magnifyingglass")
                                    Text("Identificar Planta")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                            .background(classificationService.isProcessing ? Color.primaryGreen.opacity(0.7) : Color.primaryGreen)
                            .cornerRadius(cornerRadius)
                        }
                        .disabled(classificationService.isProcessing)
                        
                        // Camera/Gallery buttons
                        HStack(spacing: spacing) {
                            captureButton(
                                title: "Cámara",
                                icon: "camera.fill",
                                action: { showCameraSheet = true }
                            )
                            
                            captureButton(
                                title: "Galería",
                                icon: "photo.fill",
                                action: { showPhotoLibrarySheet = true }
                            )
                        }
                    } else {
                        // Initial camera/gallery buttons
                        HStack(spacing: spacing) {
                            captureButton(
                                title: "Cámara",
                                icon: "camera.fill",
                                action: { showCameraSheet = true }
                            )
                            
                            captureButton(
                                title: "Galería",
                                icon: "photo.fill",
                                action: { showPhotoLibrarySheet = true }
                            )
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, spacing)
                .background(
                    Rectangle()
                        .fill(Color(.systemBackground))
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemBackground))
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
        .alert(isPresented: $showingAlert) {
            createAlert()
        }
        .onAppear {
            // For preview testing
            #if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                setupPreviewData()
            }
            #endif
        }
    }
    
    // MARK: - Subviews
    
    // View for plant selection cards
    private var plantSelectionView: some View {
        VStack(spacing: spacing) {
            // Plant suggestion cards
            ForEach(previewIdentifiedState ? previewPlants() : potentialPlants) { plant in
                plantCard(for: plant)
            }
        }
    }
    
    // Plant card with image
    private func plantCard(for plant: InvasivePlant) -> some View {
        Button(action: {
            selectedPlantForDetail = plant
            navigateToPlantDetail = true
        }) {
            HStack(alignment: .center, spacing: 12) {
                // Plant image from the captured photo
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                } else {
                    // Fallback image if none available
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(30)
                        .foregroundColor(Color.primaryGreen)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
                
                // Plant information
                VStack(alignment: .leading, spacing: 6) {
                    // Plant name
                    Text(plant.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Scientific name
                    Text(plant.scientificName)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.bottom, 2)
                    
                    // Severity level with dot
                    HStack(spacing: 4) {
                        Circle()
                            .fill(plant.severity.color)
                            .frame(width: 8, height: 8)
                        
                        Text("Nivel de invasión: ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(plant.severity.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(plant.severity.color)
                    }
                    
                    // Confidence indicator
                    if let accuracy = plant.accuracyDetection {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("Confianza: ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(accuracy * 100))%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(getConfidenceColor(accuracy))
                            }
                            
                            // Confidence bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background track
                                    Capsule()
                                        .frame(height: 4)
                                        .foregroundColor(Color.gray.opacity(0.2))
                                    
                                    // Filled portion
                                    Capsule()
                                        .frame(width: geometry.size.width * CGFloat(accuracy), height: 4)
                                        .foregroundColor(getConfidenceColor(accuracy))
                                }
                            }
                            .frame(height: 4)
                        }
                    }
                }
                .padding(.vertical, 12)
                
                // Chevron indicator to show card is tappable
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.trailing, 4)
            }
            .padding(.leading, 12)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.primaryGreen.opacity(0.2), lineWidth: 1)
            )
            .contentShape(Rectangle()) // Makes entire area tappable
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling
    }
    
    // Helper to get color based on confidence
    private func getConfidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.9 {
            return .green
        } else if confidence >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    // View for image selection only
    private var imageSelectionView: some View {
        VStack(spacing: spacing) {
            // Image preview with better aspect ratio control
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                } else {
                    // Styled placeholder with same dimensions
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: imageHeight)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            VStack(spacing: spacing) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color.primaryGreen.opacity(0.7))
                                Text("Selecciona o toma una foto")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("Las fotos claras mejoran la precisión")
                                    .font(.subheadline)
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                        )
                }
            }
            .padding(.vertical, spacing/2)
        }
    }
    
    // Helper function for creating a capture button
    private func captureButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundColor(Color.primaryGreen)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.primaryGreen.opacity(0.1))
            .cornerRadius(cornerRadius)
        }
    }
    
    // MARK: - Preview Helpers
    
    private func setupPreviewData() {
        // Set to true to preview the identified state
        previewIdentifiedState = true
        
        // If we want to test with an actual image
        if selectedImage == nil {
            // Use a system image as placeholder
            if let image = UIImage(systemName: "leaf.fill") {
                let size = CGSize(width: 800, height: 800)
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                image.draw(in: CGRect(origin: .zero, size: size))
                selectedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
    }
    
    private func previewPlants() -> [InvasivePlant] {
        return [
            InvasivePlant(
                id: UUID().uuidString,
                name: "Lirio acuático",
                scientificName: "Eichhornia crassipes",
                distance: nil,
                severity: .high,
                imageURL: "",
                accuracyDetection: 0.94,
                problem: "Bloquea la luz del agua, reduce el oxígeno y afecta la fauna acuática.",
                alternativeUses: [
                    "Compostaje: Rica en nitrógeno, puede convertirse en fertilizante.",
                    "Filtro de agua: Se ha usado en algunos sistemas de tratamiento de aguas residuales.",
                    "Artesanías: Sus fibras pueden trenzarse para hacer canastos o alfombras."
                ],
                eliminationMethods: [
                    "Retirarla manualmente del agua y dejarla secar completamente antes de desechar.",
                    "No dejar fragmentos en el agua, ya que puede regenerarse rápidamente."
                ]
            ),
            InvasivePlant(
                id: UUID().uuidString,
                name: "Caña común",
                scientificName: "Arundo donax",
                distance: nil,
                severity: .medium,
                imageURL: "",
                accuracyDetection: 0.76,
                problem: "Crece rápidamente en ríos y arroyos, desplazando especies nativas.",
                alternativeUses: [
                    "Construcción: Se puede usar como material para hacer cercas, techos, y muebles rústicos.",
                    "Instrumentos musicales: Se usa para fabricar flautas y cañas de saxofón.",
                    "Biomasa: Se puede secar y usar como leña o material de compostaje."
                ],
                eliminationMethods: [
                    "Cortar la planta lo más bajo posible y quitar los rizomas (raíces).",
                    "Secar completamente antes de desechar.",
                    "No quemar cerca de cuerpos de agua, ya que sus semillas pueden dispersarse."
                ]
            ),
            InvasivePlant(
                id: UUID().uuidString,
                name: "Madre de miles",
                scientificName: "Kalanchoe daigremontiana",
                distance: nil,
                severity: .low,
                imageURL: "",
                accuracyDetection: 0.62,
                problem: "Se reproduce muy rápido, cada hoja produce nuevas plántulas.",
                alternativeUses: [
                    "Planta medicinal: Algunas culturas la usan para tratar heridas y quemaduras.",
                    "Planta ornamental: Si se controla bien, puede mantenerse en macetas sin riesgo de invasión."
                ],
                eliminationMethods: [
                    "Arrancar toda la planta, asegurándose de eliminar sus pequeñas plántulas.",
                    "No tirarla al compost ni a la tierra, ya que puede volver a crecer fácilmente."
                ]
            )
        ]
    }
    
    // MARK: - Functionality
    
    private func createAlert() -> Alert {
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
        
        // Create an InvasivePlant instance for the main result
        let mainPlant = InvasivePlant(
            id: UUID().uuidString,
            name: result.plantName,
            scientificName: result.details?.scientificName ?? "Desconocido",
            distance: nil,
            severity: severity,
            imageURL: "",
            accuracyDetection: Double(result.confidence), problem: nil,
            alternativeUses: [], eliminationMethods: []
            
        )
        
        // In a real app, we would get alternative suggestions from the model
        // For now, we'll generate some fake alternatives with lower confidence
        potentialPlants = createPotentialPlants(mainPlant: mainPlant)
        
        // Set hasIdentified to true to show the result view
        hasIdentified = true
    }
    
    // Helper to create multiple potential plants (would be replaced with actual ML results)
    private func createPotentialPlants(mainPlant: InvasivePlant) -> [InvasivePlant] {
        // Start with the main plant
        var plants = [mainPlant]
        
        // In a real app, these would come from the model's top-N predictions
        // For now, we'll simulate with some predefined options
        // This would be replaced with actual alternative results from your model
        
        // Only add alternatives if we have a main classification
        if let mainConfidence = mainPlant.accuracyDetection, mainConfidence < 0.95 {
            // Add some alternative plants with lower confidence
            let alternatives = [
                ("Caña común", "Arundo donax", InvasivePlant.Severity.medium, max(0.2, mainConfidence - 0.2)),
                ("Madre de miles", "Kalanchoe daigremontiana", InvasivePlant.Severity.low, max(0.1, mainConfidence - 0.3))
            ]
            
            for (name, scientificName, severity, confidence) in alternatives {
                plants.append(InvasivePlant(
                    id: UUID().uuidString,
                    name: name,
                    scientificName: scientificName,
                    distance: nil,
                    severity: severity,
                    imageURL: "",
                    accuracyDetection: confidence,
                    problem: nil,
                    alternativeUses: nil,
                    eliminationMethods: nil,
                ))
            }
        }
        
        // Sort by confidence (highest first)
        return plants.sorted { ($0.accuracyDetection ?? 0) > ($1.accuracyDetection ?? 0) }
    }
    
    private func resetIdentification() {
        selectedImage = nil
        potentialPlants = []
        hasIdentified = false
        classificationService.classificationResult = nil
        classificationService.error = nil
        
        // For previews, make sure we reset our preview state too
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            previewIdentifiedState = false
        }
        #endif
    }
}

// MARK: - Previews

#Preview("Normal State") {
    IdentifyPlantView()
}

#Preview("Identified State") {
    IdentifyPlantView(previewIdentifiedState: true)
}

// Initializer for preview
extension IdentifyPlantView {
    init(previewIdentifiedState: Bool = false) {
        self._previewIdentifiedState = State(initialValue: previewIdentifiedState)
    }
}

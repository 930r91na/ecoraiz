import SwiftUI
import UIKit
import CoreML
import Vision

struct IdentifyPlantView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PlantIdentificationViewModel()
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                headerView
                
                // Image selection area
                
                // Results area (shown when an image is selected)
                if viewModel.selectedImage != nil {
                    
                } else {
                    instructionsView
                }
                
                Spacer()
            }
            .navigationTitle("Identificar Planta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .takePhoto(isPresented: $showCamera) { image in
                if let image = image {
                    viewModel.selectedImage = image
                    viewModel.analyzeImage()
                }
            }
            .pickPhoto(isPresented: $showPhotoLibrary) { image in
                if let image = image {
                    viewModel.selectedImage = image
                    viewModel.analyzeImage()
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Toma una foto o selecciona una imagen de una planta para identificarla")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    
    
    // MARK: - Instructions View
    private var instructionsView: some View {
        VStack(spacing: 16) {
            Text("¿Cómo identificar una planta?")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 12) {
                instructionRow(number: "1", text: "Toma una foto clara de la planta")
                instructionRow(number: "2", text: "Enfoca las hojas, flores o características distintivas")
                instructionRow(number: "3", text: "Evita sombras o reflejos excesivos")
                instructionRow(number: "4", text: "Intenta tomar la foto con buena iluminación")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
            )
            .padding(.horizontal)
        }
    }
    
    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

// MARK: - Result Card View
struct ResultCard: View {
    let result: PlantIdentificationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.plantName)
                    .font(.headline)
                
                Spacer()
                
                if result.isInvasive {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text("Invasiva")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.1))
                    )
                }
            }
            
            if let scientificName = result.scientificName {
                Text(scientificName)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
            }
            
            // Confidence bar
            HStack {
                Text("Coincidencia:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(confidenceColor)
                            .frame(width: geometry.size.width * result.confidence, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text("\(Int(result.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var confidenceColor: Color {
        if result.isInvasive {
            return result.confidence > 0.7 ? Color.red : Color.orange
        } else {
            return result.confidence > 0.7 ? Color.green : Color.blue
        }
    }
}

// MARK: - Model
struct PlantIdentificationResult: Identifiable {
    let id = UUID()
    let plantName: String
    let scientificName: String?
    let confidence: Double
    let isInvasive: Bool
}

// MARK: - View Model
class PlantIdentificationViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var identificationResults: [PlantIdentificationResult] = []
    @Published var isAnalyzing: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private var model: VNCoreMLModel?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            // Load your specific ML model here
            if let modelURL = Bundle.main.url(forResource: "ecoraiz", withExtension: "mlmodelc") {
                model = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            } else {
                errorMessage = "No se pudo encontrar el modelo de ML"
                showError = true
            }
        } catch {
            errorMessage = "Error al cargar el modelo: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func analyzeImage() {
        guard let image = selectedImage, let model = model else {
            errorMessage = "No hay imagen seleccionada o el modelo no está cargado"
            showError = true
            return
        }
        
        isAnalyzing = true
        identificationResults = []
        
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            isAnalyzing = false
            errorMessage = "No se pudo procesar la imagen"
            showError = true
            return
        }
        
        // Create a Vision request with the model
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                
                if let error = error {
                    self?.errorMessage = "Error en análisis: \(error.localizedDescription)"
                    self?.showError = true
                    return
                }
                
                // Process the results
                if let results = request.results as? [VNClassificationObservation] {
                    self?.processClassificationResults(results)
                }
            }
        }
        
        // Perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            isAnalyzing = false
            errorMessage = "Error al realizar análisis: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func processClassificationResults(_ results: [VNClassificationObservation]) {
        // Process top 3 results
        let topResults = results.prefix(3)
        
        // Here you would map your model's outputs to your app's data model
        // This is a simplified example - you'll need to customize based on your model's output
        
        var plantResults: [PlantIdentificationResult] = []
        
        for result in topResults {
            // Parse the identifier from your model's output
            // This is just an example - adapt to your model's specific output format
            let resultComponents = result.identifier.split(separator: ",")
            let plantName = String(resultComponents.first ?? "Desconocido")
            
            // Determine if the plant is invasive (this logic would be specific to your app)
            // For example, you might have a list of known invasive species to check against
            let isInvasive = checkIfInvasive(plantName: plantName)
            
            // Create a result object
            let plantResult = PlantIdentificationResult(
                plantName: plantName,
                scientificName: extractScientificName(from: result.identifier),
                confidence: Double(result.confidence),
                isInvasive: isInvasive
            )
            
            plantResults.append(plantResult)
        }
        
        self.identificationResults = plantResults
    }
    
    private func extractScientificName(from identifier: String) -> String? {
        // This is just an example - adapt to your model's specific output format
        let components = identifier.split(separator: ",")
        if components.count > 1 {
            return String(components[1]).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
    
    private func checkIfInvasive(plantName: String) -> Bool {
        let knownInvasiveSpecies = [
            "Lirio acuático", "Muérdago", "Pasto Buffel", "Eucalipto",
            "Casuarina", "Carrizo gigante", "Árbol de las lluvias",
            "Kalanchoe", "Piracanto", "Arundo"
        ]
        
        return knownInvasiveSpecies.contains {
            plantName.lowercased().contains($0.lowercased())
        }
    }
}

#Preview {
    IdentifyPlantView()
}

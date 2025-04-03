import SwiftUI
import CoreML
import Vision

class PlantClassificationService: ObservableObject {
    static let shared = PlantClassificationService()
    @Published var classificationResult: ClassificationResult?
    @Published var isProcessing = false
    @Published var error: ClassificationError?
    
    private let confidenceThreshold: Float = 0.7
    
    // MARK: - Classification Result Types
    
    struct ClassificationResult {
        let plantName: String
        let confidence: Float
        let isInvasive: Bool
        let details: PlantDetails?
    }
    
    enum ClassificationError: Error, LocalizedError {
        case modelNotFound
        case processingFailed
        case lowConfidence
        case unknownPlant
        
        var errorDescription: String? {
            switch self {
            case .modelNotFound:
                return "No se pudo cargar el modelo de clasificación."
            case .processingFailed:
                return "Error al procesar la imagen."
            case .lowConfidence:
                return "No se pudo identificar la planta con suficiente confianza."
            case .unknownPlant:
                return "Planta no reconocida en nuestra base de datos."
            }
        }
    }
    
    // Helper function to format model output to display name
    private func formatPlantName(_ modelLabel: String) -> String {
        // Convert "Plant_Name_Images" to "Plant Name"
        return modelLabel
            .replacingOccurrences(of: "_Images", with: "")
            .replacingOccurrences(of: "_", with: " ")
    }
    
    // MARK: - Public Methods
    
    func classifyImage(_ image: UIImage) {
        self.isProcessing = true
        self.error = nil
        self.classificationResult = nil
        
        // Debug print to check if we get here
        print("Starting classification process")
        
        // Create Vision request
        do {
            // Attempt to load model
            guard let modelURL = Bundle.main.url(forResource: "ecoraiz", withExtension: "mlmodelc") else {
                // If compiled model not found, try to find uncompiled model
                print("Couldn't find compiled model, looking for uncompiled model")
                guard let _ = Bundle.main.url(forResource: "ecoraiz", withExtension: "mlmodel") else {
                    print("Model file not found")
                    self.isProcessing = false
                    self.error = .modelNotFound
                    return
                }
                
                // If we get here, the model exists but isn't compiled yet
                // This should only happen in development
                self.isProcessing = false
                self.error = .modelNotFound
                return
            }
            
            print("Model found, creating VNCoreMLModel")
            let model = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
                self?.processClassificationResults(request: request, error: error)
            }
            
            // Image processing options
            request.imageCropAndScaleOption = .centerCrop
            
            // Simplified approach - just use the image directly
            let ciImage = CIImage(image: image) ?? CIImage(cgImage: image.cgImage!)
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            print("Performing Vision request")
            try handler.perform([request])
        } catch {
            print("Classification error: \(error)")
            self.isProcessing = false
            self.error = .processingFailed
        }
    }
    
    // MARK: - Private Methods
    
    private func processClassificationResults(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isProcessing = false
            
            // Handle potential errors
            if let error = error {
                print("Vision error: \(error)")
                self.error = .processingFailed
                return
            }
            
            // Get classification results
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                print("No classification results found")
                self.error = .processingFailed
                return
            }
            
            print("Top result: \(topResult.identifier) with confidence \(topResult.confidence)")
            
            // Check confidence threshold
            if topResult.confidence < self.confidenceThreshold {
                print("Low confidence: \(topResult.confidence)")
                self.error = .lowConfidence
                // Still provide the result even if confidence is low
                self.processPlantIdentification(name: topResult.identifier, confidence: topResult.confidence)
                return
            }
            
            // Process valid classification
            self.processPlantIdentification(name: topResult.identifier, confidence: topResult.confidence)
        }
    }
    
    private func processPlantIdentification(name: String, confidence: Float) {
        print("Processing plant: \(name)")
        
        // Try to find the plant in our database
        let plantDetails = plantDatabase[name]
        
        // Check if it's a known invasive plant
        let isInvasive = plantDetails != nil
        print("Is invasive: \(isInvasive)")
        
        // Create result with formatted display name
        self.classificationResult = ClassificationResult(
            plantName: formatPlantName(name),
            confidence: confidence,
            isInvasive: isInvasive,
            details: plantDetails
        )
        
        // If plant wasn't in our database, set error
        if !isInvasive {
            print("Unknown plant")
            self.error = .unknownPlant
        }
    }
}

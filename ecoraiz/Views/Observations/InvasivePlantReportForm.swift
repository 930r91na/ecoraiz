import SwiftUI
import MapKit
import CoreLocation

// MARK: - Report Model
struct PlantReport: Identifiable, Codable {
    var id = UUID()
    let plantName: String
    let scientificName: String?
    let description: String
    let location: ReportLocation
    let images: [UUID] // Reference to saved image files
    let reportDate: Date
    let userId: String
    let status: ReportStatus
    
    struct ReportLocation: Codable {
        let latitude: Double
        let longitude: Double
        let locationName: String
    }
    
    enum ReportStatus: String, Codable {
        case pending = "Pendiente"
        case verified = "Verificado"
        case inProgress = "En Progreso"
        case resolved = "Resuelto"
    }
}

// MARK: - Report Service
class ReportService: ObservableObject {
    static let shared = ReportService()
    
    @Published var userReports: [PlantReport] = []
    @Published var isSubmitting = false
    @Published var submissionError: Error?
    
    // Demo user ID - in a real app, this would come from authentication
    private let currentUserId = UUID().uuidString
    
    // Submit a new report
    func submitReport(plantName: String, scientificName: String?, description: String,
                     location: PlantReport.ReportLocation, images: [UIImage],
                     completion: @escaping (Result<PlantReport, Error>) -> Void) {
        
        self.isSubmitting = true
        
        // Simulate networking delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Save images and get references
            let imageIds = self.saveImages(images)
            
            // Create report
            let report = PlantReport(
                plantName: plantName,
                scientificName: scientificName,
                description: description,
                location: location,
                images: imageIds,
                reportDate: Date(),
                userId: self.currentUserId,
                status: .pending
            )
            
            // Add to local collection
            self.userReports.append(report)
            
            // In a real app, we would send this to a server
            // For now, we'll just simulate success
            self.isSubmitting = false
            completion(.success(report))
        }
    }
    
    // Save images to local storage and return references
    private func saveImages(_ images: [UIImage]) -> [UUID] {
        // In a real app, we would save the images to disk or cloud storage
        // For this demo, we'll just return dummy UUIDs
        return images.map { _ in UUID() }
    }
}

// MARK: - Report Form View
struct ReportFormView: View {
    // Input from plant identification
    let identifiedPlant: PlantClassificationService.ClassificationResult
    let plantImage: UIImage?
    
    // Form state
    @State private var additionalImages: [UIImage] = []
    @State private var description: String = ""
    @State private var showImagePicker = false
    @State private var showCamera = false
    
    // Services
    @ObservedObject private var locationManager = LocationManager()
    @ObservedObject private var reportService = ReportService.shared
    
    // UI state
    @State private var showingSubmissionAlert = false
    @State private var submissionSuccess = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), // Mexico City default
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Presentation mode for dismissing
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Reportar Planta Invasora")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                // Plant Information Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Información de la Planta")
                        .font(.headline)
                    
                    HStack {
                        Text("Nombre:")
                            .fontWeight(.medium)
                        Text(identifiedPlant.plantName)
                    }
                    
                    if let details = identifiedPlant.details {
                        HStack {
                            Text("Nombre científico:")
                                .fontWeight(.medium)
                            Text(details.scientificName)
                                .italic()
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Images Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Imágenes")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Main identified image
                            if let plantImage = plantImage {
                                Image(uiImage: plantImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(10)
                                    .clipped()
                            }
                            
                            // Additional images
                            ForEach(additionalImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(10)
                                    .clipped()
                            }
                            
                            // Add image button
                            Button(action: {
                                showImagePicker = true
                            }) {
                                VStack {
                                    Image(systemName: "plus")
                                        .font(.system(size: 30))
                                    Text("Agregar Imagen")
                                        .font(.caption)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Location Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ubicación")
                        .font(.headline)
                    
                    // Simplified location section
                    if locationManager.location == nil {
                        Button("Habilitar ubicación") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    } else {
                        Text("Ubicación actual")
                            .padding(.bottom, 5)
                        
                        Map(coordinateRegion: $mapRegion, showsUserLocation: true, userTrackingMode: .constant(.follow))
                            .frame(height: 200)
                            .cornerRadius(10)
                            .onAppear {
                                if let location = locationManager.location {
                                    mapRegion = MKCoordinateRegion(
                                        center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                    )
                                }
                            }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Descripción")
                        .font(.headline)
                    
                    Text("Describe el entorno, aproximadamente cuántas plantas hay, y cualquier información adicional relevante.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Submit Button
                Button(action: submitReport) {
                    if reportService.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Enviar Reporte")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(reportService.isSubmitting || description.isEmpty)
                .opacity(reportService.isSubmitting || description.isEmpty ? 0.6 : 1)
            }
            .padding()
        }
        .navigationBarTitle("Nuevo Reporte", displayMode: .inline)
        .alert(isPresented: $showingSubmissionAlert) {
            if submissionSuccess {
                return Alert(
                    title: Text("Reporte Enviado"),
                    message: Text("Tu reporte ha sido enviado correctamente y será revisado por el equipo."),
                    dismissButton: .default(Text("OK")) {
                        // Dismiss both this view and the plant result view
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            } else {
                return Alert(
                    title: Text("Error"),
                    message: Text("No se pudo enviar el reporte. Por favor intenta nuevamente."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .pickMultiplePhotos(isPresented: $showImagePicker) { images in
            self.additionalImages.append(contentsOf: images)
        }
        .takePhoto(isPresented: $showCamera) { image in
            if let image = image {
                self.additionalImages.append(image)
            }
        }
    }
    
    private func submitReport() {
        guard let location = locationManager.location else {
            // Handle no location available
            return
        }
        
        // Create location object - using simplified location data
        let reportLocation = PlantReport.ReportLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            locationName: "Mi ubicación" // Simplified since your manager doesn't have locationName
        )
        
        // Gather all images
        var allImages: [UIImage] = []
        if let plantImage = plantImage {
            allImages.append(plantImage)
        }
        allImages.append(contentsOf: additionalImages)
        
        // Submit the report
        reportService.submitReport(
            plantName: identifiedPlant.plantName,
            scientificName: identifiedPlant.details?.scientificName,
            description: description,
            location: reportLocation,
            images: allImages
        ) { result in
            switch result {
            case .success(_):
                submissionSuccess = true
            case .failure(_):
                submissionSuccess = false
            }
            showingSubmissionAlert = true
        }
    }
}

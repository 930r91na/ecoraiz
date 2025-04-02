import SwiftUI
import MapKit
import PhotosUI
import CoreML

struct CreateObservationView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Variables
    @State private var speciesGuess: String = ""
    @State private var description: String = ""
    @State private var selectedDate = Date()
    @State private var location: CLLocationCoordinate2D?
    @State private var locationName: String = ""
    @State private var isLocationPrivate: Bool = false
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedPhotos: [UIImage] = []
    @State private var showingSpeciesIdentification = false
    @State private var tags: String = ""
    @State private var isProcessingImage = false
    @State private var suggestedSpecies: [(name: String, confidence: Double)] = []
    @State private var showCalendar = false
    
    // MARK: - Location Manager for current location
    @ObservedObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Photos Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fotos")
                            .font(.headline)
                        
                        PhotosGridView(
                            selectedPhotos: $selectedPhotos,
                            showingImagePicker: $showingImagePicker,
                            showingCamera: $showingCamera,
                            isProcessingImage: $isProcessingImage,
                            onImageAdded: identifySpeciesFromImage
                        )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Species Information Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("¿Qué planta observaste?")
                            .font(.headline)
                        
                        TextField("Nombre o especie", text: $speciesGuess)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        if !suggestedSpecies.isEmpty {
                            Text("Especies sugeridas por la IA:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                            
                            ForEach(suggestedSpecies, id: \.name) { suggestion in
                                Button(action: {
                                    speciesGuess = suggestion.name
                                }) {
                                    HStack {
                                        Text(suggestion.name)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        // Show confidence percentage
                                        Text("\(Int(suggestion.confidence * 100))%")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                        
                                        if suggestion.name == speciesGuess {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                                .padding(.leading, 5)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(suggestion.name == speciesGuess ? Color.green.opacity(0.1) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Date Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Fecha y Hora")
                                .font(.headline)
                            
                            Spacer()
                            
                            // Toggle calendar button
                            Button(action: {
                                withAnimation {
                                    showCalendar.toggle()
                                }
                            }) {
                                HStack {
                                    Text(showCalendar ? "Ocultar calendario" : "Mostrar calendario")
                                        .font(.subheadline)
                                    
                                    Image(systemName: showCalendar ? "chevron.up" : "chevron.down")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        // Date selected display
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            
                            Text(formatDate(selectedDate))
                                .font(.subheadline)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .onTapGesture {
                            withAnimation {
                                showCalendar.toggle()
                            }
                        }
                        
                        // Calendar - only shown when expanded
                        if showCalendar {
                            DatePicker("", selection: $selectedDate)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()
                                .padding(.vertical, 5)
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Location Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ubicación")
                            .font(.headline)
                        
                        HStack {
                            TextField("Lugar", text: $locationName)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            Button(action: useCurrentLocation) {
                                Image(systemName: "location.fill")
                                    .padding()
                                    .background(Color.primaryGreen)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        // Mini map preview
                        if let location = location {
                            let region = MKCoordinateRegion(
                                center: location,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                            
                            Map(coordinateRegion: .constant(region), annotationItems: [MapPin(coordinate: location)]) { pin in
                                MapAnnotation(coordinate: pin.coordinate) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title)
                                }
                            }
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding(.vertical, 5)
                            
                            Toggle("Mantener ubicación privada", isOn: $isLocationPrivate)
                                .padding(.vertical, 5)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Descripción")
                            .font(.headline)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .padding(5)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Etiquetas (separadas por comas)")
                            .font(.headline)
                        
                        TextField("Ej: parque, ciudad, raro", text: $tags)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Nueva Observación")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveObservation()
                    }
                    .fontWeight(.bold)
                    .disabled(speciesGuess.isEmpty || selectedPhotos.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoPicker(selectedPhotos: $selectedPhotos, onCompletion: { didAddImage in
                    if didAddImage {
                        identifySpeciesFromImage()
                    }
                })
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(onImageCaptured: { image in
                    if let image = image {
                        selectedPhotos.append(image)
                        identifySpeciesFromImage()
                    }
                })
            }
            .onAppear {
                // Initialize with current location if available
                if let currentLocation = locationManager.location?.coordinate {
                    location = currentLocation
                    reverseGeocode(coordinate: currentLocation)
                }
            }
        }
        .overlay(
            // Loading overlay when processing image
            isProcessingImage ?
                ZStack {
                    Color.black.opacity(0.5)
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Identificando especie...")
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                }
                .edgesIgnoringSafeArea(.all) : nil
        )
    }
    
    // MARK: - Helper Functions
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX") // Spanish locale
        return formatter.string(from: date)
    }
    
    private func useCurrentLocation() {
        if let currentLocation = locationManager.location?.coordinate {
            location = currentLocation
            reverseGeocode(coordinate: currentLocation)
        }
    }
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                locationName = "Ubicación desconocida"
                return
            }
            
            // Build location name
            var components: [String] = []
            
            if let name = placemark.name {
                components.append(name)
            }
            
            if let locality = placemark.locality {
                components.append(locality)
            }
            
            if let adminArea = placemark.administrativeArea {
                components.append(adminArea)
            }
            
            locationName = components.joined(separator: ", ")
        }
    }
    
    private func identifySpeciesFromImage() {
        guard !selectedPhotos.isEmpty else { return }
        
        isProcessingImage = true
        
        // In a real implementation, here you would:
        // 1. Convert your UIImage to a CVPixelBuffer or MLMultiArray
        // 2. Pass it to your Core ML model
        // 3. Process the results
        
        // Simulated CreateML plant identification model results
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Simulated model output with confidence scores
            suggestedSpecies = [
                (name: "Lirio acuático (Eichhornia crassipes)", confidence: 0.87),
                (name: "Muérdago (Psittacanthus calyculatus)", confidence: 0.72),
                (name: "Caña común (Arundo donax)", confidence: 0.68),
                (name: "Acacia (Acacia dealbata)", confidence: 0.53)
            ].sorted(by: { $0.confidence > $1.confidence })
            
            // Auto-select the top suggestion
            if let topSuggestion = suggestedSpecies.first {
                speciesGuess = topSuggestion.name
            }
            
            isProcessingImage = false
        }
        
        // Real CreateML implementation would look something like:
        /*
        guard let firstImage = selectedPhotos.first,
              let resizedImage = resizeImage(firstImage, targetSize: CGSize(width: 224, height: 224)),
              let buffer = buffer(from: resizedImage) else {
            isProcessingImage = false
            return
        }
        
        do {
            // Load your model
            let model = try PlantIdentificationModel() // Your actual model name
            
            // Make prediction
            let prediction = try model.prediction(image: buffer)
            
            // Process results
            let classifications = prediction.classLabelProbs.sorted { $0.value > $1.value }
            
            DispatchQueue.main.async {
                // Map to your data structure
                suggestedSpecies = classifications.prefix(4).map { (name: $0.key, confidence: $0.value) }
                
                // Auto-select the top suggestion
                if let topSuggestion = suggestedSpecies.first {
                    speciesGuess = topSuggestion.name
                }
                
                isProcessingImage = false
            }
        } catch {
            print("Error making prediction: \(error)")
            isProcessingImage = false
        }
        */
    }
    
    private func saveObservation() {
        // Here we would prepare the data and make the API request
        // This is a simplified example that would need to be implemented with actual API calls
        
        let observation = ObservationData(
            speciesGuess: speciesGuess,
            observedOn: selectedDate,
            description: description,
            placeGuess: locationName,
            latitude: location?.latitude,
            longitude: location?.longitude,
            geoprivacy: isLocationPrivate ? "private" : "open",
            tagList: tags
            // In a real app, we would also include photos data
        )
        
        print("Saving observation: \(observation)")
        
        // After successful save
        dismiss()
    }
    
    // MARK: - Core ML Helper Methods (for implementation with real ML model)
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(image.size.width),
            Int(image.size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer)
        
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

// MARK: - Supporting Views and Models

struct PhotosGridView: View {
    @Binding var selectedPhotos: [UIImage]
    @Binding var showingImagePicker: Bool
    @Binding var showingCamera: Bool
    @Binding var isProcessingImage: Bool
    var onImageAdded: () -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if selectedPhotos.isEmpty {
                HStack(spacing: 20) {
                    Button(action: { showingCamera = true }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.title)
                            Text("Cámara")
                                .font(.caption)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button(action: { showingImagePicker = true }) {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                            Text("Galería")
                                .font(.caption)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.vertical)
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<selectedPhotos.count, id: \.self) { index in
                        Image(uiImage: selectedPhotos[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                Button(action: {
                                    selectedPhotos.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.7)))
                                }
                                .padding(5),
                                alignment: .topTrailing
                            )
                    }
                    
                    // Add Photo button
                    Button(action: { showingImagePicker = true }) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.title)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedPhotos: [UIImage]
    var onCompletion: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // No limit
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            let didAddImage = !results.isEmpty
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self?.parent.selectedPhotos.append(image)
                            }
                        }
                    }
                }
            }
            
            parent.onCompletion(didAddImage)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.onImageCaptured(image)
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageCaptured(nil)
            picker.dismiss(animated: true)
        }
    }
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct ObservationData {
    let speciesGuess: String
    let observedOn: Date
    let description: String
    let placeGuess: String
    let latitude: Double?
    let longitude: Double?
    let geoprivacy: String
    let tagList: String
}

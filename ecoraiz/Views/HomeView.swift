import SwiftUI
import MapKit
import CoreLocation

struct HomeView: View {
    // MARK: - Properties
    @EnvironmentObject private var vm: LocationsViewModel
    // Estados de la vista
    @State private var showSearchField: Bool = false
    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []
    @FocusState private var isSearchFocused: Bool
    @State private var currentLocationName: String = ""
    @State private var previousCenter: CLLocationCoordinate2D?
    // Bottom sheet y FAB
    @State private var sheetHeight: CGFloat = 180
    @State private var isDragging: Bool = false
    @State private var showCreateObservationView: Bool = false
    @State private var showIdentifyPlantView: Bool = false
    @State private var showMenuBubble: Bool = false
    
    // Constantes de layout
    let maxWidthForIpad: CGFloat = 700
    let minHeight: CGFloat = 60
    let maxHeight: CGFloat = 600
    let fabSize: CGFloat = 56
    let fabBottom: CGFloat = 20
    
    // MARK: - Body
    var body: some View {
        ZStack {
            mapLayer
                .ignoresSafeArea()
                .padding(.bottom, 0)
            
            VStack(spacing: 0) {
                header
                    .padding()
                    .frame(maxWidth: maxWidthForIpad)
                
                if showSearchField && !searchResults.isEmpty {
                    searchResultsList
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .frame(maxWidth: maxWidthForIpad)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
                // Bottom draggable sheet
                bottomSheet
            }
            
            // Floating Action Button - conditionally shown based on sheet height
            if sheetHeight < 300 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        ZStack(alignment: .bottomTrailing) {
                            // Menu bubble (appears when FAB is clicked)
                            if showMenuBubble {
                                menuBubble
                                    .offset(y: -fabSize - 20) // Position above the FAB with some spacing
                                    .transition(.opacity)
                            }
                            
                            // FAB Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showMenuBubble.toggle()
                                }
                            }) {
                                Image(systemName: showMenuBubble ? "xmark" : "plus")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: fabSize, height: fabSize)
                                    .background(Color.primaryGreen)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, sheetHeight + fabBottom)
                }
            }
        }
        
        //todo check something weird he added
        
        // MARK: Sheets
        .sheet(isPresented: $showCreateObservationView) {
            CreateObservationView()
                    .onDisappear {
                        showMenuBubble = false
                    }
        }
        .sheet(isPresented: $showIdentifyPlantView) {
            IdentifyPlantView()
                    .onDisappear {
                        showMenuBubble = false
                    }
        }
        .onChange(of: searchText) { newValue in
            if !newValue.isEmpty {
                searchForLocations()
            } else {
                searchResults = []
            }
        }
        .onAppear {
            updateCurrentLocationName(from: vm.mapRegion.center)
            previousCenter = vm.mapRegion.center
        }
        // Use a timer to check for map region changes
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            let currentCenter = vm.mapRegion.center
            if let prev = previousCenter,
               abs(prev.latitude - currentCenter.latitude) > 0.001 ||
               abs(prev.longitude - currentCenter.longitude) > 0.001 {
                updateCurrentLocationName(from: currentCenter)
                previousCenter = currentCenter
            }
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: $vm.mapRegion,
            showsUserLocation: true,
            annotationItems: vm.nearbyInvasiveObservations
        ) { observation in
            MapAnnotation(coordinate: observation.coordinate ?? .init(latitude: 0, longitude: 0)) {
                if let coord = observation.coordinate {
                    ObservationMapAnnotationView()
                        .shadow(radius: 3)
                        .onTapGesture {
                            handleAnnotationTap(observation: observation, coordinate: coord)
                        }
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    
    // MARK: - Menu Bubble
    private var menuBubble: some View {
        VStack(spacing: 12) {
            // Identify Invasive Plant Option
            Button(action: {
                showIdentifyPlantView = true
                showMenuBubble = false
            }) {
                menuBubbleItem(
                    iconName: "leaf.fill",
                    title: "Identificar Planta Invasora",
                    backgroundColor: Color.primaryGreen.opacity(0.9)
                )
            }
            
            // New Observation Option
            Button(action: {
                showCreateObservationView = true
                showMenuBubble = false
            }) {
                menuBubbleItem(
                    iconName: "plus.viewfinder",
                    title: "Nueva Observación",
                    backgroundColor: Color.primaryGreen.opacity(0.9)
                )
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .frame(width: 250)
    }
    
    // Helper for Menu Bubble items
    private func menuBubbleItem(iconName: String, title: String, backgroundColor: Color) -> some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Title
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }
    
    // MARK: - Bottom Sheet
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            // Handle
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 40, height: 5)
                Spacer()
            }
            .padding(.top, 12)
            
            // Header
            HStack {
                Text("Plantas Invasoras Cercanas")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 5)
                
                Spacer()
                Text("\(vm.nearbyInvasiveObservations.count)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(
                        vm.nearbyInvasiveObservations.isEmpty ? Color.gray : Color.primaryGreen
                    ))
                    .padding()
            }
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(vm.orderedNearbyObservations) { observation in
                            ObservationCardView(observation: observation)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .frame(maxHeight: sheetHeight) // Adjust for header height

            
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .frame(height: sheetHeight)
        .frame(maxWidth: .infinity)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    let newHeight = sheetHeight - value.translation.height
                    
                    // Limit height between min and max
                    if newHeight > minHeight && newHeight < maxHeight {
                        sheetHeight = newHeight
                    }
                }
                .onEnded { value in
                    isDragging = false
                    let velocity = value.predictedEndLocation.y - value.location.y
                    
                    // Snap to positions based on velocity and position
                    withAnimation(.spring()) {
                        if velocity > 100 || sheetHeight < minHeight + (maxHeight - minHeight) / 2 {
                            // Snap to minimum height
                            sheetHeight = minHeight
                        } else {
                            // Snap to maximum height
                            sheetHeight = maxHeight
                        }
                    }
                    
                    // Hide menu bubble when sheet is dragged
                    if showMenuBubble {
                        withAnimation {
                            showMenuBubble = false
                        }
                    }
                }
        )
        .animation(isDragging ? nil : .spring(), value: sheetHeight)
    }
    
    // MARK: - Search Function
    private func searchForLocations() {
        print("ℹ️ HomeView: Buscando lugares para: '\(searchText)'")
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = vm.mapRegion
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                DispatchQueue.main.async {
                    self.searchResults = []
                }
                return
            }
            DispatchQueue.main.async {
                self.searchResults = response.mapItems
                print("ℹ️ HomeView: Búsqueda encontró \(response.mapItems.count) resultados.")
            }
        }
    }
    
    // MARK: - Funcion handle tap
    private func handleAnnotationTap(observation: Observation, coordinate: CLLocationCoordinate2D) {
        print("ℹ️ HomeView: Tocado pin de observación ID \(observation.id)")
        vm.selectedObservationForDetail = observation
        withAnimation(.spring()) {
            vm.mapRegion.center = coordinate
            vm.mapRegion.span = vm.detailSpan
            if sheetHeight < maxHeight * 0.8 {
                sheetHeight = 300
            }
        }
    }

    // MARK: - Update Current Location Name
    private func updateCurrentLocationName(from coordinate: CLLocationCoordinate2D) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("❌ Error geocoding: \(error?.localizedDescription ?? "Unknown error")")
                self.currentLocationName = "Ubicación Desconocida"
                return
            }
            if let name = placemark.name, !name.contains("Unnamed Road"), name.count < 35 {
                self.currentLocationName = name
            } else if let locality = placemark.locality {
                self.currentLocationName = locality
            } else if let subAdminArea = placemark.subAdministrativeArea {
                self.currentLocationName = subAdminArea
            } else if let adminArea = placemark.administrativeArea {
                self.currentLocationName = adminArea
            } else {
                self.currentLocationName = "Área Desconocida"
            }
            print("ℹ️ Ubicación geocodificada: \(self.currentLocationName)")
        }
    }
    
    
    // MARK: - Navigation to Selected Location
    private func navigateToLocation(_ mapItem: MKMapItem) {
            print("ℹ️ HomeView: Navegando a resultado de búsqueda: \(mapItem.name ?? "...")")
            let coordinate = mapItem.placemark.coordinate
            let newRegion = MKCoordinateRegion(center: coordinate, span: vm.detailSpan)
            self.currentLocationName = mapItem.name ?? "Ubicación Desconocida"
            withAnimation(.easeInOut) {
                vm.mapRegion = newRegion
            }
            previousCenter = coordinate
            showSearchField = false
            searchText = ""
            searchResults = []
            isSearchFocused = false
    }
}
// MARK: Vistas aux
struct ObservationMapAnnotationView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "leaf.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.primaryGreen)
                .padding(6)
                .background(Color(uiColor: .systemBackground).opacity(0.7))
                .clipShape(Circle())
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.primaryGreen)
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -2)
        }
    }
}

struct ObservationDetailSheetView: View {
    let observation: Observation
    
    @Environment(\.openURL) var openURL
    
    // Un ejemplo de formateador
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(observation.taxon?.preferredCommonName?.capitalized
                     ?? observation.taxon?.name
                     ?? observation.speciesGuess?.capitalized
                     ?? "Observación \(observation.id)")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 5)
                
                if let scientificName = observation.taxon?.name,
                   scientificName != observation.taxon?.preferredCommonName {
                    Text(scientificName)
                        .font(.title3)
                        .italic()
                        .foregroundColor(.secondary)
                }
                
                // Imagen (AsyncImage)
                if let imageURLString = observation.photos?.first?.url?.replacingOccurrences(of: "square", with: "medium"),
                   let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(height: 180)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .cornerRadius(10)
                        case .failure:
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                                .foregroundColor(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                }
                
                // Detalles
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Observado: \(formatDateString(observation.observedOnString))")
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Lugar: \(observation.placeGuess ?? "No especificado")")
                    }
                    if let userLogin = observation.user?.login {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Por: \(userLogin)")
                        }
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 5)
                
                // Link a iNaturalist
                if let urlString = observation.uri, let url = URL(string: urlString) {
                    Button {
                        openURL(url)
                    } label: {
                        HStack {
                            Text("Ver en iNaturalist")
                            Image(systemName: "arrow.up.right.square")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    .padding(.top)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func formatDateString(_ dateString: String?) -> String {
        // Ejemplo simple
        guard let ds = dateString else { return "N/A" }
        // Si viene en formato ISO, parsearlo:
        // ...
        return ds
    }
}


// MARK: - View Components
extension HomeView {
    private var header: some View {
        VStack(spacing: 0) {
            if showSearchField {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search location...", text: $searchText)
                        .focused($isSearchFocused)
                        .font(.subheadline)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                    
                    Button {
                        showSearchField = false
                        searchText = ""
                        searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
                .padding(.bottom, 5)
                .onAppear {
                    isSearchFocused = true
                }
            } else {
                // Location Title Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSearchField = true
                    }
                }) {
                    Text(currentLocationName)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .overlay(alignment: .trailing) {
                            Image(systemName: "magnifyingglass")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.trailing, 10)
                        }
                }
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var searchResultsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(searchResults, id: \.self) { item in
                    Button {
                        navigateToLocation(item)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name ?? "Unknown Location")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                if let locality = item.placemark.locality,
                                   let administrativeArea = item.placemark.administrativeArea {
                                    Text("\(locality), \(administrativeArea)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.leading)
                }
            }
            .padding(.vertical, 5)
        }
        .frame(maxHeight: min(CGFloat(searchResults.count * 60 + 10), 300))
    }
}


struct ObservationCardView: View {
    let observation: Observation
    @State private var showPlantDetail: Bool = false
    
    // This property will look up plant details from the taxon ID
    private var matchingPlantDetails: PlantDetails? {
        guard let taxonId = observation.taxon?.id else { return nil }
        
        // Look through plantDatabase to find matching taxonId
        return plantDatabase.values.first(where: { $0.taxonId == taxonId })
    }
    
    var body: some View {
        Button(action: {
            showPlantDetail = true
        }) {
            HStack(spacing: 12) {
                // Image from observation
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                    
                    if let imageURLString = observation.photos?.first?.url?.replacingOccurrences(of: "square", with: "medium"),
                       let imageURL = URL(string: imageURLString) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(.secondary)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "leaf.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green.opacity(0.6))
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Information
                VStack(alignment: .leading, spacing: 4) {
                    Text(observation.taxon?.preferredCommonName?.capitalized
                         ?? observation.taxon?.name
                         ?? observation.speciesGuess?.capitalized
                         ?? "Observación \(observation.id)")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let scientificName = observation.taxon?.name,
                       scientificName != observation.taxon?.preferredCommonName {
                        Text(scientificName)
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        // Date indicator
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(formatDateString(observation.observedOnString))
                                .font(.caption)
                        }
                        .foregroundColor(.primaryGreen)
                        
                        Spacer()
                    }
                    
                    // Location if available
                    if let placeGuess = observation.placeGuess, !placeGuess.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.primaryGreen)
                                .font(.caption2)
                            Text(placeGuess)
                                .lineLimit(1)
                                .font(.caption)
                                .foregroundColor(.primaryGreen)
                        }
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showPlantDetail) {
            if let plantDetails = matchingPlantDetails {
                // Show the PlantDetailSheet with the matching plant details
                PlantDetailSheet(plant: plantDetails)
            } else {
                // Fallback to observation detail if no matching plant
                ObservationDetailSheetView(observation: observation)
            }
        }
    }
    
    // Helper function to format the date string
    private func formatDateString(_ dateString: String?) -> String {
        guard let ds = dateString else { return "N/A" }
        return ds
    }
}

/// Custom pin annotation view
struct LocationMapAnnotationView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.red)
                .background(Color.white)
                .clipShape(Circle())
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.red)
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
                .padding(.bottom, 40)
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(LocationsViewModel(locationManager: LocationManager()))
}

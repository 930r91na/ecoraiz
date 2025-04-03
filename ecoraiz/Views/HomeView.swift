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
    
    @State private var currentLocationName: String = "Cargando mapa..."
    @State private var previousCenter: CLLocationCoordinate2D?
    
    // Bottom sheet y FAB
    @State private var sheetHeight: CGFloat = 180  // Altura inicial
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
        NavigationView {
            ZStack {
                // --- Capa del mapa ---
                mapLayer
                    .ignoresSafeArea()
                    // Un padding opcional inferior para no superponer con el bottom sheet
                    .padding(.bottom, 0)
                
                // --- Contenido superpuesto (header, buscador, bottom sheet) ---
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
                    
                    bottomSheet
                }
                
                // --- FAB y menú flotante (solo se muestra si el sheet está bajo 300 px) ---
                if sheetHeight < 300 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack(alignment: .bottomTrailing) {
                                if showMenuBubble {
                                    menuBubble
                                        .offset(y: -fabSize - 20) // burbuja arriba del FAB
                                        .transition(.opacity)
                                }
                                
                                // Botón principal (FAB)
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
                                        .background(Color.primaryGreen) // tu color
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
            .navigationTitle(currentLocationName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Ejemplo de botón en la barra
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // alguna acción
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            // --- Sheets modales ---
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
            // --- Observa cambios en searchText ---
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    searchForLocations()
                } else {
                    searchResults = []
                }
            }
            // --- onAppear: setea nombre inicial y previousCenter ---
            .onAppear {
                updateCurrentLocationName(from: vm.mapRegion.center)
                previousCenter = vm.mapRegion.center
            }
            // --- Timer para checar cambios en la región del mapa ---
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                let currentCenter = vm.mapRegion.center
                if let prev = previousCenter,
                   abs(prev.latitude - currentCenter.latitude) > 0.001 ||
                   abs(prev.longitude - currentCenter.longitude) > 0.001 {
                    updateCurrentLocationName(from: currentCenter)
                    previousCenter = currentCenter
                }
            }
        } // Fin NavigationView
    }
    
    // MARK: - Mapa
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
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 0) {
            if showSearchField {
                // Campo de búsqueda
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar lugar...", text: $searchText)
                        .focused($isSearchFocused)
                        .font(.subheadline)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                    
                    Button {
                        showSearchField = false
                        searchText = ""
                        searchResults = []
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(.regularMaterial)
                .cornerRadius(8)
                .padding(.bottom, 5)
                .onAppear {
                    isSearchFocused = true
                }
            } else {
                // Botón que muestra el nombre de la ubicación actual
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
                .background(.regularMaterial)
                .cornerRadius(8)
            }
        }
        .background(Color.white.opacity(0.01)) // Para evitar que se vea un recuadro
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Lista de resultados de búsqueda
    private var searchResultsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(searchResults, id: \.self) { item in
                    Button {
                        navigateToLocation(item)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name ?? "Ubicación Desconocida")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                if let locality = item.placemark.locality,
                                   let adminArea = item.placemark.administrativeArea {
                                    Text("\(locality), \(adminArea)")
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
                    Divider().padding(.leading)
                }
            }
            .padding(.vertical, 5)
        }
        .frame(maxHeight: min(CGFloat(searchResults.count * 60 + 10), 300))
    }
    
    // MARK: - Bottom Sheet
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            // Handle (barra para arrastrar)
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 40, height: 5)
                Spacer()
            }
            .padding(.top, 12)
            
            // Contenido
            Group {
                if let observation = vm.selectedObservationForDetail {
                    // Vista de detalle
                    ObservationDetailSheetView(observation: observation)
                        .padding(.top, 5)
                } else {
                    // Vista cuando no hay selección
                    VStack {
                        HStack {
                            Text("Plantas Invasoras Cercanas")
                                .font(.headline)
                            Spacer()
                            Text("\(vm.nearbyInvasiveObservations.count)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(
                                    vm.nearbyInvasiveObservations.isEmpty ? Color.gray : Color.red
                                ))
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        
                        if vm.nearbyInvasiveObservations.isEmpty && !vm.isLoadingInvasives {
                            Text("No se encontraron observaciones de las especies buscadas cerca.")
                                .foregroundColor(.secondary)
                                .padding()
                                .multilineTextAlignment(.center)
                            Spacer()
                        } else if !vm.nearbyInvasiveObservations.isEmpty {
                            Text("Toca un pin en el mapa para ver detalles.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                            Spacer()
                        } else if vm.isLoadingInvasives {
                            Spacer()
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            Spacer(minLength: 0)
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .frame(height: sheetHeight)
        .frame(maxWidth: .infinity)
        .clipped()
        .shadow(color: Color.black.opacity(0.2), radius: 8)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    let newHeight = sheetHeight - value.translation.height
                    if newHeight > minHeight && newHeight < maxHeight {
                        sheetHeight = newHeight
                    }
                }
                .onEnded { value in
                    isDragging = false
                    let velocity = value.predictedEndLocation.y - value.location.y
                    withAnimation(.spring()) {
                        // Decide si colapsar o expandir según la velocidad y posición
                        if velocity > 100 || sheetHeight < minHeight + (maxHeight - minHeight)/2 {
                            sheetHeight = minHeight
                        } else {
                            sheetHeight = maxHeight
                        }
                    }
                    // Si el menú flotante está abierto, se cierra al arrastrar el sheet
                    if showMenuBubble {
                        withAnimation {
                            showMenuBubble = false
                        }
                    }
                }
        )
        .animation(isDragging ? nil : .spring(), value: sheetHeight)
    }
    
    // MARK: - Menú burbuja
    private var menuBubble: some View {
        VStack(spacing: 12) {
            Button(action: {
                showIdentifyPlantView = true
                showMenuBubble = false
            }) {
                menuBubbleItem(
                    iconName: "leaf.fill",
                    title: "Identificar Planta",
                    backgroundColor: Color.primaryGreen.opacity(0.9)
                )
            }
            Button(action: {
                showCreateObservationView = true
                showMenuBubble = false
            }) {
                menuBubbleItem(
                    iconName: "plus.viewfinder",
                    title: "Nueva Observación",
                    backgroundColor: Color.mustardYellow.opacity(0.9)
                )
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .frame(width: 250)
    }
    
    private func menuBubbleItem(iconName: String, title: String, backgroundColor: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
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
    
    // MARK: - Funciones Auxiliares
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

// MARK: - Vistas Auxiliares

/// Pin personalizado
struct ObservationMapAnnotationView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "leaf.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.green)
                .padding(6)
                .background(Color(uiColor: .systemBackground).opacity(0.7))
                .clipShape(Circle())
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.green)
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -2)
        }
    }
}

/// Vista de detalle en el bottom sheet
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

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(LocationsViewModel(locationManager: LocationManager()))
}

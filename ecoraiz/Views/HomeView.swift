import SwiftUI
import MapKit


struct HomeView: View {
    // MARK: - Properties
    @EnvironmentObject private var vm: LocationsViewModel
    @State private var showSearchField: Bool = false
    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []
    @FocusState private var isSearchFocused: Bool
    @State private var currentLocationName: String = ""
    @State private var previousCenter: CLLocationCoordinate2D?
    @State private var sheetHeight: CGFloat = 180 // Initial half-open state
    @State private var isDragging: Bool = false
    @State private var showCreateObservationView: Bool = false
    @State private var showIdentifyPlantView: Bool = false
    @State private var showMenuBubble: Bool = false
    
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
                .padding(.bottom)
            
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
                        
                        ZStack(alignment: .bottom) {
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
        .sheet(item: $vm.sheetLocation, onDismiss: nil) { _ in
            // Sheet content goes here
        }
        .sheet(isPresented: $showCreateObservationView) {
            // This is where you'll present your CreateObservationView
            
        }
        .sheet(isPresented: $showIdentifyPlantView) {
            // This is where you'll present your IdentifyPlantView
            Text("Identificar Planta Invasora View")
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
            currentLocationName = vm.mapLocation.name
            previousCenter = vm.mapRegion.center
        }
        // Use a timer to check for map region changes
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            // Only update if the center coordinates have changed significantly
            if let previous = previousCenter,
               abs(previous.latitude - vm.mapRegion.center.latitude) > 0.001 ||
               abs(previous.longitude - vm.mapRegion.center.longitude) > 0.001 {
                updateCurrentLocationName()
                previousCenter = vm.mapRegion.center
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
                    backgroundColor: Color.green.opacity(0.9)
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
                    backgroundColor: Color.blue.opacity(0.9)
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
                
                Text("\(invasivePlants.count)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.red))
                    .padding(.horizontal)
                    .padding(.top, 5)
            }
            
            // Content
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(invasivePlants) { plant in
                        PlantCardView(plant: plant)
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
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = vm.mapRegion
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                return
            }
            
            self.searchResults = response.mapItems
        }
    }
    
    // MARK: - Update Current Location Name
    private func updateCurrentLocationName() {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: vm.mapRegion.center.latitude,
                                  longitude: vm.mapRegion.center.longitude)
        
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                return
            }
            
            // Choose the most appropriate name for the location
            if let name = placemark.name {
                self.currentLocationName = name
            } else if let locality = placemark.locality {
                self.currentLocationName = locality
            } else if let area = placemark.administrativeArea {
                self.currentLocationName = area
            }
        }
    }
    
    // MARK: - Navigation to Selected Location
    private func navigateToLocation(_ mapItem: MKMapItem) {
        let coordinate = mapItem.placemark.coordinate
        let newRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        // Set the new location name
        self.currentLocationName = mapItem.name ?? "Location"
        
        // Update the map region
        vm.mapRegion = newRegion
        previousCenter = coordinate
        
        // Reset the search UI
        showSearchField = false
        searchText = ""
        isSearchFocused = false
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
            
            if vm.showLocationsList {
                // Original location list functionality
                LocationsListView(
                    locations: vm.locations,
                    selectedLocation: $vm.mapLocation
                )
                .frame(maxHeight: 600)
                .transition(.move(edge: .top).combined(with: .opacity))
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
    
    private var mapLayer: some View {
        Map(coordinateRegion: $vm.mapRegion,
            annotationItems: vm.locations,
            annotationContent: { location in
                MapAnnotation(coordinate: location.coordinates) {
                    LocationMapAnnotationView()
                        .scaleEffect(vm.mapLocation == location ? 1 : 0.7)
                        .shadow(radius: 10)
                        .onTapGesture {
                            vm.showNextLocation(location: location)
                            // Update the current location name when selecting from predefined locations
                            currentLocationName = location.name
                            previousCenter = location.coordinates
                        }
                }
            })
    }
}


// MARK: - Plant Card View
struct PlantCardView: View {
    let plant: InvasivePlant
    
    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                
                Image(systemName: "leaf.fill")
                    .font(.title)
                    .foregroundColor(Color.primaryGreen)
            }
            .frame(width: 80, height: 80)
            
            // Information
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.headline)
                
                Text(plant.scientificName)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
                
                HStack {
                    // Severity indicator
                    Text(plant.severity.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(plant.severity.color.opacity(0.2))
                        .foregroundColor(plant.severity.color)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Distance
                    Text("\(String(format: "%.1f", plant.distance)) km")
                        .font(.caption)
                        .foregroundColor(.secondary)
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

/// List view for displaying all locations
struct LocationsListView: View {
    let locations: [Location]
    @Binding var selectedLocation: Location
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(locations) { location in
                Button {
                    selectedLocation = location
                    dismiss()
                } label: {
                    HStack {
                        if !location.imageNames.isEmpty, let imageName = location.imageNames.first {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.headline)
                            Text(location.cityName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Locations")
    }
}

/// Location Manager class to handle user location
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var location: CLLocation?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
}

#Preview {
    HomeView()
        .environmentObject(LocationsViewModel())
}

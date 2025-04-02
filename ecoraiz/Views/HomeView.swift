import SwiftUI
import MapKit

struct HomeView: View {
    
    // MARK: - Properties
    @EnvironmentObject private var vm: LocationsViewModel
    @State private var showSearchField: Bool = false
    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []
    @FocusState private var isSearchFocused: Bool
    
    let maxWidthForIpad: CGFloat = 700
    
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
            }
        }
        .sheet(item: $vm.sheetLocation, onDismiss: nil) { _ in
            // Sheet content goes here
        }
        .onChange(of: searchText) { newValue in
            if !newValue.isEmpty {
                searchForLocations()
            } else {
                searchResults = []
            }
        }
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
    
    // MARK: - Navigation to Selected Location
    private func navigateToLocation(_ mapItem: MKMapItem) {
        let coordinate = mapItem.placemark.coordinate
        let newRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        vm.mapRegion = newRegion
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
                    Text(vm.mapLocation.name)
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
        .background(.ultraThinMaterial)
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
        .frame(maxHeight: 300)
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
                        }
                }
            })
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

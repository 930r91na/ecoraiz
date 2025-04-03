import SwiftUI
import MapKit

// --- Vista Principal ---
struct CommunityView: View {
    @State private var showingSheet = false
    
    @State private var featuredObservations: [FeaturedEvent] = []
    @State private var isLoadingFeatured = false
    @State private var featuredLoadError: Error? = nil
    
    // Ejemplo de estados para un "Crear Evento"
    @State private var eventName: String = ""
    @State private var date: Date = Date()
    @State private var location: String = ""
    @State private var maxParticipants: Int = 20
    
    @ObservedObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- Sección de Últimas Observaciones ---
                    VStack(alignment: .leading) {
                        Text("Últimas observaciones")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                        
                        if isLoadingFeatured {
                            ProgressView()
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                        } else if let error = featuredLoadError {
                            Text("Error al cargar: \(error.localizedDescription)")
                                .foregroundColor(.red)
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        } else if featuredObservations.isEmpty {
                            Text("No hay observaciones destacadas.")
                                .foregroundColor(.secondary)
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        } else {
                            FeaturedObservationsSection(observations: featuredObservations)
                        }
                    }
                    
                    // --- Sección de Eventos ---
                    Text("Eventos cerca de ti")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    
                    EventsListSection(events: communityEvents)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Comunidad")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSheet) {
                // Opción A: CreateEventView se encarga internamente de su locationManager
                CreateEventView(showingSheet: $showingSheet)
                
                // Opción B (si quisieras pasarle una función):
                // CreateEventView(showingSheet: $showingSheet,
                //                 useCurrentLocation: self.useCurrentLocation)
            }
            .onAppear {
                if featuredObservations.isEmpty && featuredLoadError == nil {
                    loadFeaturedObservations()
                }
            }
        }
    }
    
    // MARK: - Carga de Observaciones
    func loadFeaturedObservations() {
        print("Iniciando carga de observaciones...")
        isLoadingFeatured = true
        featuredLoadError = nil
        
        fetchFeaturedEventsFromINaturalist(placeId: 6793, count: 20) { result in
            DispatchQueue.main.async {
                isLoadingFeatured = false
                switch result {
                case .success(let fetchedEvents):
                    let filteredEvents = fetchedEvents.filter { event in
                        let isDateValid = event.dateTime != "Fecha inválida"
                        let hasGoodTitle = event.title != "Observación sin identificar"
                        let hasGoodDate = event.dateTime != "Fecha desconocida"
                        let hasGoodLocation = event.location != "Ubicación desconocida"
                        let hasImage = event.imageURL != nil && !(event.imageURL ?? "").isEmpty
                        
                        return isDateValid && hasGoodTitle && hasGoodDate && hasGoodLocation && hasImage
                    }
                    self.featuredObservations = filteredEvents
                case .failure(let error):
                    print("Error al cargar: \(error.localizedDescription)")
                    self.featuredLoadError = error
                    self.featuredObservations = []
                }
            }
        }
    }
}

// --- Sección de Observaciones Destacadas ---
struct FeaturedObservationsSection: View {
    let observations: [FeaturedEvent]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(observations) { observation in
                    FeaturedObservationCard(event: observation)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(height: 170)
    }
}

// --- Tarjeta para cada Observación Destacada ---
struct FeaturedObservationCard: View {
    let event: FeaturedEvent
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: event.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 250, height: 150)
                        .background(Color.gray.opacity(0.3))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .frame(width: 250, height: 150)
                        .background(Color.gray.opacity(0.1))
                @unknown default:
                    EmptyView()
                        .frame(width: 250, height: 150)
                }
            }
            .frame(width: 250, height: 150)
            .clipped()
            
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                           startPoint: .center,
                           endPoint: .bottom)
            
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "clock")
                    Text(event.dateTime)
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                
                HStack {
                    Image(systemName: "location.fill")
                    Text(event.location)
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
            }
            .padding()
            
            if let urlString = event.observationURL, let url = URL(string: urlString) {
                Button {
                    openURL(url)
                } label: {
                    Image(systemName: "link.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .frame(width: 250, height: 150)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

// --- Subvista: Sección Lista de Eventos ---
struct EventsListSection: View {
    let events: [CommunityEvent]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(events) { event in
                CommunityEventCard(event: event)
            }
        }
    }
}

struct CommunityEventCard: View {
    let event: CommunityEvent
    @State private var showEventDetails = false
    
    var body: some View {
        Button {
            showEventDetails = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    if event.imageName.hasPrefix("http") {
                        AsyncImage(url: URL(string: event.imageName)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 180)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.3))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 180)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.1))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(event.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }
                    
                    Text(event.status)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(event.statusColor)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .padding(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.darkGreen)
                        .lineLimit(2)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryGreen)
                                Text(event.dateTime)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryGreen)
                                Text(event.location)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.subheadline)
                                .foregroundColor(.primaryGreen)
                            Text("\(event.attendeeCount)")
                                .font(.subheadline)
                                .foregroundColor(.primaryGreen)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.darkGreen.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEventDetails) {
            EventExpandedView(event: event)
        }
    }
}


// --- CreateEventView en nivel superior ---
struct CreateEventView: View {
    @Binding var showingSheet: Bool
    
    @State private var eventName: String = ""
    @State private var date: Date = Date()
    @State private var location: String = ""
    @State private var maxParticipants: Int = 20
    
    // Cada vista maneja su propio LocationManager (o lo recibes por inyección si prefieres)
    @ObservedObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Nombre del Evento
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre del Evento")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("Ingrese el nombre del evento", text: $eventName)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Fecha y Hora
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fecha y Hora")
                            .font(.headline)
                            .foregroundColor(.primary)
                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                            .accentColor(Color.primaryGreen)
                            .padding(5)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Ubicación
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ubicación")
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack {
                            TextField("Ingrese la ubicación del evento", text: $location)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            Button {
                                useCurrentLocation()
                            } label: {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.primaryGreen)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Máximo de Participantes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Máximo de Participantes")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Stepper(value: $maxParticipants, in: 1...100) {
                            Text("\(maxParticipants) participantes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Crear Evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        showingSheet = false
                    }
                    .foregroundColor(Color.primaryGreen)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        // Lógica de creación
                        createEvent()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryGreen)
                    .disabled(eventName.isEmpty || location.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Funciones
    
    private func useCurrentLocation() {
        guard let coordinate = locationManager.location?.coordinate else {
            print("Ubicación actual no disponible")
            return
        }
        reverseGeocode(coordinate: coordinate)
    }
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geoCoder = CLGeocoder()
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(loc) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                location = "Ubicación desconocida"
                return
            }
            var components: [String] = []
            if let name = placemark.name { components.append(name) }
            if let locality = placemark.locality { components.append(locality) }
            if let adminArea = placemark.administrativeArea { components.append(adminArea) }
            
            location = components.joined(separator: ", ")
        }
    }
    
    private func createEvent() {
        print("Evento creado: \(eventName), \(location), \(date), máx \(maxParticipants)")
        showingSheet = false
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

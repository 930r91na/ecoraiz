import SwiftUI

// --- Vista Principal ---
struct CommunityView: View {
    @State private var showingSheet = false // Para mostrar la hoja de creación
    
    // --- Estado para el filtro seleccionado ---
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Indoor Plants", "Outdoor Gardens"]
    
    // --- ESTADO PARA LAS OBSERVACIONES DESTACADAS (desde la API) ---
    @State private var featuredObservations: [FeaturedEvent] = [] // Renombrado para claridad
    
    // --- ESTADO PARA LA CARGA ---
    @State private var isLoadingFeatured = false // Para controlar el ProgressView
    @State private var featuredLoadError: Error? = nil // Para manejar errores (opcional)
    
    
    // --- Datos de Ejemplo para Eventos Comunitarios (se mantienen igual) ---
    let communityEvents: [CommunityEvent] = [
        CommunityEvent(title: "UX Design Meetup", dateTime: "Sat, Feb 15 • 6:30 PM", location: "Creative Hub", imageName: "ux_meetup", status: "Almost Full", statusColor: .orange, organizerName: "David Wilson", organizerAvatar: "avatar_david", attendeeCount: 22),
        CommunityEvent(title: "Tech Startup Networking", dateTime: "Next Week, 7:00 PM", location: "Innovation Center", imageName: "tech_networking", status: "Open", statusColor: .green, organizerName: "Emily Darker", organizerAvatar: "avatar_emily", attendeeCount: 30)
        // Añade más eventos comunitarios si es necesario
    ]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- Sección de Últimas Observaciones (Adaptada para API) ---
                    VStack(alignment: .leading) {
                        Text("Últimas observaciones") // Título actualizado
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                        
                        if isLoadingFeatured {
                            ProgressView() // Muestra un spinner centrado mientras carga
                                .frame(height: 150) // Altura similar a la de las tarjetas
                                .frame(maxWidth: .infinity) // Ocupa el ancho disponible
                        } else if let error = featuredLoadError {
                            // Opcional: Muestra un mensaje de error
                            Text("Error al cargar: \(error.localizedDescription)")
                                .foregroundColor(.red)
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        } else if featuredObservations.isEmpty {
                            // Si no está cargando y está vacío (y sin error)
                            Text("No hay observaciones destacadas.")
                                .foregroundColor(.secondary)
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        } else {
                            // Muestra la sección normal una vez cargados los datos
                            FeaturedObservationsSection(observations: featuredObservations) // Pasa los datos cargados
                        }
                    } // Fin VStack Sección Observaciones
                    
                    
                    // --- Sección de Filtros (sin cambios) ---
                    FilterSection(selectedCategory: $selectedCategory, categories: categories)
                        .padding(.horizontal)
                    
                    // --- Sección de Lista de Eventos Comunitarios (sin cambios) ---
                    EventsListSection(events: communityEvents)
                        .padding(.horizontal)
                    
                } // Fin VStack principal
            } // Fin ScrollView
            .navigationTitle("Plant Community")
            .toolbar {
                // Botón para añadir evento (vuelve a usar showingSheet)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSheet.toggle() // Abre la hoja de creación
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // Hoja para crear evento (se mantiene)
            .sheet(isPresented: $showingSheet) {
                CreateEventView(showingSheet: $showingSheet)
            }
            // --- LLAMADA A LA API AL APARECER LA VISTA ---
            .onAppear {
                // Solo carga si no se han cargado antes o si hubo error
                if featuredObservations.isEmpty && featuredLoadError == nil {
                    loadFeaturedObservations()
                }
            }
            // Cambia el estilo de la barra de navegación si prefieres el título inline
            // .navigationBarTitleDisplayMode(.inline)
        } // Fin NavigationView
    } // Fin body
    
    // --- Función para cargar los datos ---
    func loadFeaturedObservations() {
        print("Iniciando carga de observaciones...")
        isLoadingFeatured = true
        featuredLoadError = nil
        
        // Pide un poco más de datos para tener margen al filtrar (ej: 20)
        fetchFeaturedEventsFromINaturalist(placeId: 6793, count: 20) { result in
            DispatchQueue.main.async {
                isLoadingFeatured = false
                switch result {
                case .success(let fetchedEvents):
                    // --- FILTRAR RESULTADOS AQUÍ ---
                    let filteredEvents = fetchedEvents.filter { event in
                        // Define qué campos son indispensables.
                        // ¡Asegúrate que estas condiciones coincidan con CÓMO manejas los nulos en el mapeo!
                        // Si tu mapeo convierte nil -> "Ubicación desconocida", debes filtrar por eso.
                        
                        // Ejemplo más estricto: Requiere título no por defecto, fecha válida, lugar válido e imagen
                        let hasGoodTitle = event.title != "Observación sin identificar" && event.title != "Observation" && !event.title.starts(with: "Observación ID:") // Ajusta según tus fallbacks
                        let hasGoodDate = event.dateTime != "Fecha desconocida" && event.dateTime != "Date unknown"
                        let hasGoodLocation = event.location != "Ubicación desconocida" && event.location != "Location unknown"
                        let hasImage = event.imageURL != nil && !(event.imageURL ?? "").isEmpty
                        
                        return hasGoodTitle && hasGoodDate && hasGoodLocation && hasImage
                    }
                    
                    self.featuredObservations = filteredEvents
                    print("Observaciones cargadas: \(fetchedEvents.count), Filtradas y mostradas: \(filteredEvents.count)")
                    
                    if filteredEvents.isEmpty && !fetchedEvents.isEmpty {
                        // Opcional: Informar si todos los resultados fueron filtrados
                        print("Advertencia: Todas las observaciones cargadas fueron filtradas por datos faltantes.")
                        // Podrías incluso asignar un error personalizado aquí para mostrar un mensaje al usuario
                        // self.featuredLoadError = MyCustomError.noValidObservationsFound
                    }
                    
                case .failure(let error):
                    print("Error al cargar observaciones destacadas: \(error.localizedDescription)")
                    self.featuredLoadError = error
                    self.featuredObservations = [] // Limpia en caso de error
                }
            }
        }
    }
    
    // Fin CommunityView
    
    // --- Subvista: Sección Últimas Observaciones ---
    // Renombrada para claridad y adaptada para recibir [FeaturedEvent]
    struct FeaturedObservationsSection: View {
        let observations: [FeaturedEvent]
        
        var body: some View {
            // El VStack que contenía el título ahora está en CommunityView
            // para manejar el estado de carga. Aquí solo mostramos el ScrollView.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(observations) { observation in // Itera sobre las observaciones cargadas
                        FeaturedObservationCard(event: observation) // Usa la tarjeta adaptada
                    }
                }
                .padding(.horizontal) // Padding para que las tarjetas no peguen a los bordes
                .padding(.bottom) // Padding inferior
            }
            .frame(height: 170) // Opcional: Fija una altura para el scroll view si es necesario
        }
    }
    
    // --- Subvista: Tarjeta Observación Destacada ---
    // Renombrada y usa AsyncImage y el botón de enlace
    struct FeaturedObservationCard: View {
        let event: FeaturedEvent // Recibe el modelo adaptado FeaturedEvent
        @Environment(\.openURL) var openURL // Para abrir el hipervínculo
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                // --- Usa AsyncImage para cargar la imagen desde la URL ---
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
                        Image(systemName: "photo.fill") // Placeholder en caso de error
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
                .frame(width: 250, height: 150) // Aplica el frame al contenedor de AsyncImage
                .clipped() // Recorta al frame
                
                // --- Overlay oscuro (igual que antes) ---
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)
                
                // --- Contenido de texto (Usa los campos de FeaturedEvent) ---
                VStack(alignment: .leading) {
                    Text(event.title) // Título (p.ej. nombre especie)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text(event.dateTime) // Fecha observación
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    
                    HStack {
                        Image(systemName: "location.fill")
                        Text(event.location) // Lugar observación
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                }
                .padding()
                
                // --- BOTÓN PARA ABRIR ENLACE (NUEVO) ---
                if let urlString = event.observationURL, let url = URL(string: urlString) {
                    Button {
                        openURL(url) // Acción para abrir el enlace de iNaturalist
                    } label: {
                        Image(systemName: "link.circle.fill") // Icono de enlace
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(8) // Padding para separar de la esquina
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing) // Posición arriba a la derecha
                }
                // --- FIN DEL BOTÓN ---
                
            } // Fin ZStack
            .frame(width: 250, height: 150) // Tamaño total de la tarjeta
            .cornerRadius(12)
            .shadow(radius: 5)
        }
    }
    
    // -- Vista para crear un nuevo evento --
    struct CreateEventView: View {
        @Binding var showingSheet: Bool // Recibe showingSheet como un Binding
        @State private var eventName = ""
        @State private var date = Date()
        @State private var location = ""
        @State private var maxParticipants = 20
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Detalles del Evento")) {
                        TextField("Nombre del evento", text: $eventName)
                        DatePicker("Fecha", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        TextField("Ubicación", text: $location)
                        Stepper("Máximo de participantes: \(maxParticipants)", value: $maxParticipants, in: 1...100)
                    }
                }
                .navigationTitle("Crear Evento")
                .navigationBarItems(
                    leading: Button("Cancelar") {
                        showingSheet = false // Cierra la hoja al tocar "Cancelar"
                    },
                    trailing: Button("Crear") {
                        // Acción para crear el evento
                    }
                )
            }
        }
    }
    
    // --- Subvista: Sección de Filtros ---
    struct FilterSection: View {
        @Binding var selectedCategory: String
        let categories: [String]
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            selectedCategory = category
                            // Aquí podrías añadir lógica real de filtrado si los eventos
                            // comunitarios tuvieran categorías asociadas.
                            print("\(category) selected")
                        } label: {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(selectedCategory == category ? .semibold : .regular) // Resaltar seleccionado
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selectedCategory == category ? Color.green.opacity(0.8) : Color(.systemGray5)) // Color activo más sutil
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .clipShape(Capsule())
                                .animation(.easeInOut(duration: 0.2), value: selectedCategory) // Animación suave
                        }
                        // .buttonStyle(.plain) // Opcional: para evitar efectos de botón por defecto si interfieren
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
    
    // --- Subvista: Sección Lista de Eventos ---
    struct EventsListSection: View {
        let events: [CommunityEvent]
        
        var body: some View {
            VStack(spacing: 20) { // Espacio entre las tarjetas de evento
                ForEach(events) { event in
                    CommunityEventCard(event: event)
                }
            }
        }
    }
    
    // --- Subvista: Tarjeta Evento Comunitario ---
    struct CommunityEventCard: View {
        let event: CommunityEvent
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) { // Sin espacio entre imagen y contenido
                Image(event.imageName) // Imagen del evento
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180) // Altura de la imagen
                    .clipped() // Recorta la imagen
                // .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // Redondea solo arriba si prefieres
                
                // Contenido debajo de la imagen
                VStack(alignment: .leading, spacing: 8) { // Espaciado interno del contenido
                    HStack {
                        Text(event.title)
                            .font(.headline)
                            .lineLimit(1) // Evita que el título ocupe múltiples líneas
                        
                        Spacer() // Empuja el estado a la derecha
                        
                        Text(event.status)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(event.statusColor)
                            .foregroundColor(.white)
                            .cornerRadius(6) // Pequeño radio para la etiqueta de estado
                    }
                    
                    HStack {
                        Image(systemName: "calendar") // SF Symbol
                        Text(event.dateTime)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Color secundario para detalles
                    
                    HStack {
                        Image(systemName: "location.fill") // SF Symbol
                        Text(event.location)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Divider().padding(.vertical, 4) // Separador visual
                    
                    HStack {
                        Image(event.organizerAvatar) // Avatar del organizador
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                        Text(event.organizerName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer() // Empuja los asistentes a la derecha
                        
                        // Placeholder para avatares de asistentes (simplificado)
                        HStack(spacing: -10) { // Spacing negativo para solapar
                            Image(systemName: "person.circle.fill") // Placeholder
                                .resizable().frame(width: 24, height: 24).clipShape(Circle()).foregroundColor(.gray)
                            Image(systemName: "person.circle.fill") // Placeholder
                                .resizable().frame(width: 24, height: 24).clipShape(Circle()).foregroundColor(.gray)
                        }
                        
                        Text("+\(event.attendeeCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding() // Padding para el contenido textual
            }
            .background(Color(.systemGray6)) // Fondo sutil para la tarjeta
            .cornerRadius(12) // Esquinas redondeadas para toda la tarjeta
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Sombra opcional
        }
    }
    
    
    // --- Preview para el Canvas de Xcode ---
    struct CommunityView_Previews: PreviewProvider {
        static var previews: some View {
            CommunityView()
            // Puedes previsualizar en modo oscuro también
            // .preferredColorScheme(.dark)
        }
    }
}

import SwiftUI

// --- Vista Principal ---
struct CommunityView: View {
    @State private var showingSheet = false
    
    // --- Estado para el filtro seleccionado ---
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Indoor Plants", "Outdoor Gardens"]
    
    // --- Datos de Ejemplo ---
    let featuredEvents: [FeaturedEvent] = [
        FeaturedEvent(title: "Urban Jungle Workshop", dateTime: "Tomorrow, 2 PM", location: "Botanical Garden", imageName: "plant_workshop"), // Reemplaza con tus nombres de imagen
        FeaturedEvent(title: "Succulent Care 101", dateTime: "Sat, 10 AM", location: "Greenhouse Hub", imageName: "succulent_care")
        // Añade más eventos destacados
    ]
    
    let communityEvents: [CommunityEvent] = [
        CommunityEvent(title: "UX Design Meetup", dateTime: "Sat, Feb 15 • 6:30 PM", location: "Creative Hub", imageName: "ux_meetup", status: "Almost Full", statusColor: .orange, organizerName: "David Wilson", organizerAvatar: "avatar_david", attendeeCount: 22), // Reemplaza con tus nombres de imagen
        CommunityEvent(title: "Tech Startup Networking", dateTime: "Next Week, 7:00 PM", location: "Innovation Center", imageName: "tech_networking", status: "Open", statusColor: .green, organizerName: "Emily Darker", organizerAvatar: "avatar_emily", attendeeCount: 30)
        // Añade más eventos comunitarios
    ]

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- Sección de Eventos Destacados ---
                    FeaturedEventsSection(events: featuredEvents)
                    
                    // --- Sección de Filtros ---
                    FilterSection(selectedCategory: $selectedCategory, categories: categories)
                        .padding(.horizontal) // Añade padding horizontal a los filtros

                    // --- Sección de Lista de Eventos ---
                    EventsListSection(events: communityEvents)
                        .padding(.horizontal) // Añade padding horizontal a la lista

                }
                // Añade un padding superior para separar del navigation bar si es necesario
                // .padding(.top)
            }
            .navigationTitle("Plant Community") // Título estándar
            .toolbar {
                // Botón estándar en la barra de navegación
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "plus") // Icono estándar de iOS (SF Symbol)
                    }
                }
            }
            .sheet(isPresented: $showingSheet) {
                CreateEventView(showingSheet: $showingSheet) // Pasa showingSheet aquí
            }
            // Cambia el estilo de la barra de navegación si prefieres el título inline
            // .navigationBarTitleDisplayMode(.inline)
        }
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

// --- Subvista: Sección Eventos Destacados ---
struct FeaturedEventsSection: View {
    let events: [FeaturedEvent]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Featured Events")
                .font(.title2) // Tamaño de fuente recomendado para secciones
                .fontWeight(.bold)
                .padding(.horizontal) // Padding estándar horizontal
                .padding(.bottom, 5) // Pequeño espacio antes del scroll view

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) { // Espacio entre tarjetas
                    ForEach(events) { event in
                        FeaturedEventCard(event: event)
                    }
                }
                .padding(.horizontal) // Padding para que las tarjetas no peguen a los bordes
                .padding(.bottom) // Padding inferior para separar de la siguiente sección
            }
        }
    }
}

// --- Subvista: Tarjeta Evento Destacado ---
struct FeaturedEventCard: View {
    let event: FeaturedEvent
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(event.imageName) // Asume que tienes estas imágenes en tus Assets
                .resizable()
                .aspectRatio(contentMode: .fill) // Rellena el espacio disponible
                .frame(width: 250, height: 150) // Tamaño de la tarjeta
                .clipped() // Recorta la imagen al frame

            // Overlay oscuro para mejorar legibilidad del texto
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "clock") // Icono SF Symbol
                    Text(event.dateTime)
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                
                HStack {
                    Image(systemName: "location.fill") // Icono SF Symbol
                    Text(event.location)
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding() // Padding interno para el texto
        }
        .frame(width: 250, height: 150) // Asegura el tamaño del ZStack
        .cornerRadius(12) // Esquinas redondeadas estándar
        .shadow(radius: 5) // Sombra sutil opcional
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
                        // Aquí podrías añadir lógica para filtrar los eventos
                        print("\(category) selected")
                    } label: {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedCategory == category ? Color.green : Color(.systemGray5)) // Color de fondo según selección
                            .foregroundColor(selectedCategory == category ? .white : .primary) // Color de texto según selección
                            .clipShape(Capsule()) // Forma de píldora
                    }
                }
            }
            .padding(.vertical, 5) // Pequeño padding vertical para la sección de filtros
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

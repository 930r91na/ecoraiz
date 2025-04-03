import SwiftUI


struct ProfileView: View {
    var user: User

    let attendedEvents: [CommunityEvent] = [
            // Ejemplo de evento pasado
            CommunityEvent(
                // 'id' puede ser UUID() o un Int/String si viene de una API/DB
                // Opcional si CommunityEvent lo genera automáticamente
                title: "Taller de Jardinería Urbana",
                dateTime: "Sáb, 15 Mar • 10:00 AM", // Fecha pasada
                location: "Vivero Municipal, Ecatepec",
                imageName: "gardener", // Usa nombre de Asset o URL
                status: "Finalizado",              // Estado diferente
                statusColor: .gray,                // Color diferente
                organizerName: "Centro Comunitario",
                organizerAvatar: "gardener",     // Usa nombre de Asset o URL
                attendeeCount: 24
            ),
            // Puedes añadir más eventos CommunityEvent aquí
            CommunityEvent(
                 title: "Limpieza Río Atoyac (Asistido)",
                 dateTime: "Dom, 23 Feb • 8:30 AM", // Fecha pasada
                 location: "Puente de México, Puebla",
                 imageName: "gardener", // Reusa o cambia URL
                 status: "Completado",
                 statusColor: .blue, // Otro color para completado
                 organizerName: "Miguel Ángel Ruiz",
                 organizerAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200", // Reusa o cambia URL
                 attendeeCount: 35
             )
        ]

    // 3. Estado para la hoja de detalles de plantas
    @State private var showingPlantDetailSheet = false
    @State private var selectedPlantDetails: PlantDetails? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) { // Espacio entre secciones principales
                // --- Sección de Perfil ---
                VStack {
                    user.profilePicture
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .padding(.bottom, 5)

                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top) // Añade un poco de espacio arriba

                // --- Sección de Badges/Estadísticas ---
                HStack(alignment: .top, spacing: 20) { // Espacio entre badges
                    BadgeItem(iconName: "trophy", color: .yellow, label: "Plant\nMaster")
                    BadgeItem(iconName: "tree.fill", color: .green, label: "100\nSpecies")
                    BadgeItem(iconName: "star", color: .red, label: "Community\nStar")
                    BadgeItem(iconName: "calendar", color: .blue, label: "Event\nHost")
                }
                .padding(.horizontal) // Padding a los lados de la fila de badges

                // --- Sección Species Tracked ---
                VStack(alignment: .leading, spacing: 15) {
                                    Text("Especies Seguidas")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            // Usamos la lista global `invasivePlants` para este ejemplo
                                            ForEach(invasivePlants) { plant in
                                                PlantCard(plant: plant)
                                                    // 4. Añadir gesto de toque
                                                    .onTapGesture {
                                                        // Buscar y mostrar detalles
                                                        findAndShowPlantDetails(for: plant)
                                                    }
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 5)
                                    }
                                }


                VStack(alignment: .leading, spacing: 15) {
                                    Text("Eventos Asistidos")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal)

                                    // Itera sobre attendedEvents (que ahora son CommunityEvent)
                                    // Y usa CommunityEventCard
                                    ForEach(attendedEvents) { event in // Usa la nueva lista
                                        CommunityEventCard(event: event) // <--- USA CommunityEventCard
                                            .padding(.horizontal) // Padding a los lados de la tarjeta
                                            .id(event.id)
                                    }

                                    // Mensaje si no hay eventos asistidos
                                    if attendedEvents.isEmpty {
                                        Text("No has asistido a eventos recientes.")
                                            .padding(.horizontal)
                                            .foregroundColor(.gray)
                                    }
                                }
                                // -------------------------------------------

                                Spacer()
                            }
                            // Modificador .sheet para detalles de planta (se mantiene)
                            .sheet(isPresented: $showingPlantDetailSheet) {
                                 if let details = selectedPlantDetails {
                                     PlantDetailSheet(plant: details) // Asume que PlantDetailSheet existe
                                 } else {
                                      Text("Error al cargar detalles.").padding()
                                  }
                             }
                        }
                        //.navigationTitle("Perfil") // El título usualmente va en la NavigationView que contiene esta vista
                    }
    // 6. Función auxiliar para buscar detalles de la planta
    // En ProfileView
    private func findAndShowPlantDetails(for plant: InvasivePlant) {
        // Busca los detalles
        if let details = plantDatabase.values.first(where: { $0.name == plant.name }) {
            // Éxito: Guarda los detalles Y activa la hoja
            self.selectedPlantDetails = details
            self.showingPlantDetailSheet = true // <-- Solo se activa si hay 'details'
        } else {
            // Falla: No hagas nada para mostrar la hoja.
            // Opcional: Muestra un mensaje de error o registra el problema.
            print("⚠️ Detalles no encontrados en plantDatabase para: \(plant.name)")
            self.selectedPlantDetails = nil // Asegura que esté limpio
            // NO establezcas showingPlantDetailSheet = true aquí
            // Podrías mostrar una alerta si quieres dar feedback explícito del error.
            // self.showingErrorAlert = true // (Necesitarías añadir estado para la alerta)
        }
    }
}

// --- Componentes Reutilizables ---

// Vista para un item de Badge/Estadística
struct BadgeItem: View {
    let iconName: String
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(Color.primaryGreen)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.15)) // Fondo suave del color
                .clipShape(Circle())

            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineLimit(2) // Asegura que no ocupe demasiado espacio vertical
        }
        .frame(width: 70) // Ancho fijo para cada badge item
    }
}

// Vista para la tarjeta de una planta
struct PlantCard: View {
    let plant: InvasivePlant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Sin espacio entre imagen y texto
            plant.imageURL
                .resizable()
                .scaledToFill() // Llena el espacio manteniendo la proporción
                .frame(width: 150, height: 110) // Tamaño fijo para la imagen
                .clipped() // Recorta la imagen al frame

            HStack {
                Text(plant.name)
                    .font(.headline)
                    .padding([.leading, .vertical], 10) // Padding dentro de la Hstack
                Spacer() // Empuja el chevron a la derecha
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
            .background(Color.white) // Fondo para la parte del texto
        }
        .frame(width: 150) // Ancho total de la tarjeta
        .background(Color(.systemBackground)) // Fondo general por si la imagen no carga
        .cornerRadius(12) // Esquinas redondeadas
        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2) // Sombra suave
    }
}



struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: exampleUsers.first!)
            .previewLayout(.sizeThatFits)
    }
}

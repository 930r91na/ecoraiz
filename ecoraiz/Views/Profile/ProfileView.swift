import SwiftUI

// Estructura para los datos de ejemplo de un evento
struct Event: Identifiable {
    let id = UUID()
    let title: String
    let dateDescription: String
    let participantCount: Int
    let imageName: String
}

struct ProfileView: View {
    var user: User

    let recentEvents: [Event] = [
        Event(title: "Urban Gardening Workshop",
              dateDescription: "Last Sunday",
              participantCount: 24,
              imageName: "event_gardening") // Reemplaza con tu imagen
    ]

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
                        .padding(.horizontal) // Padding solo al título

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(invasivePlants) { plant in
                                PlantCard(plant: plant)
                            }
                        }
                        .padding(.horizontal) // Padding a los lados del contenido scrollable
                        .padding(.bottom, 5) // Pequeño padding inferior para la sombra
                    }
                }

                // --- Sección Recent Events ---
                VStack(alignment: .leading, spacing: 15) {
                    Text("Eventos Asistidos")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal) // Padding solo al título

                    // En este ejemplo solo mostramos uno, pero podrías usar ForEach si tuvieras más
                    if let firstEvent = recentEvents.first {
                         EventCard(event: firstEvent)
                             .padding(.horizontal) // Padding a los lados de la tarjeta de evento
                    } else {
                        Text("No recent events.")
                            .padding(.horizontal)
                            .foregroundColor(.gray)
                    }
                }
                Spacer() // Empuja todo hacia arriba si el contenido es corto
            }
        }
        //.background(Color(.systemGroupedBackground)) // Color de fondo opcional similar a iOS Settings
        //.ignoresSafeArea(edges: .top) // Si quieres que el scroll empiece desde arriba
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
                .foregroundColor(Color.black)
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
            Image(plant.imageURL) // <-- Usa la imagen de la planta
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
            .background(Color(.secondarySystemBackground)) // Fondo para la parte del texto
        }
        .frame(width: 150) // Ancho total de la tarjeta
        .background(Color(.systemBackground)) // Fondo general por si la imagen no carga
        .cornerRadius(12) // Esquinas redondeadas
        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2) // Sombra suave
    }
}

// Vista para la tarjeta de un evento
struct EventCard: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(event.imageName) // <-- Usa la imagen del evento
                .resizable()
                .scaledToFill()
                .frame(height: 180) // Altura de la imagen del evento
                .clipped()

            VStack(alignment: .leading, spacing: 8) { // Espacio entre textos del evento
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2) // Limita a 2 líneas

                HStack {
                    Text(event.dateDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer() // Empuja el número a la derecha
                    HStack(spacing: 4) {
                         Image(systemName: "person.2.fill") // Icono opcional
                             .font(.caption)
                         Text("\(event.participantCount)")
                             .font(.subheadline)
                    }
                    .foregroundColor(.blue) // Color para el contador
                }
            }
            .padding() // Padding alrededor del texto del evento
            .background(Color(.secondarySystemBackground)) // Fondo para el área de texto
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}


struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: exampleUsers.first!)
            .previewLayout(.sizeThatFits)
    }
}

import SwiftUI

// --- VISTA PRINCIPAL (MODIFICADA) ---
struct SheetOfPlants: View {
    // 1. Añade la variable de entorno para poder cerrar la vista
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
            VStack(spacing: 24) {
                // --- HeaderView (ESTÁTICA) ---
                HeaderView(dismissAction: {
                    dismiss()
                })
                .padding(.horizontal)
                .padding(.top) // Añade un poco de espacio en la parte superior si es necesario

                // --- Scrollable Content ---
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) { // Main content stack
                        ImageCareSection()
                        WhatYouCanDoSection()
                        PlantExpertsSection()
                    }
                    .padding(.horizontal) // Padding for the sides of the scroll content
                    .padding(.bottom, 100) // Add bottom padding inside scrollview
                }
                // Para evitar que el contenido de la ScrollView se superponga con el HeaderView
                // puedes añadir un espaciador o un padding en la parte superior de la ScrollView
                // .padding(.top, 60) // Ajusta este valor según la altura de tu HeaderView
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    // --- SUBVISTAS (HeaderView MODIFICADA) ---
    struct HeaderView: View {
        let dismissAction: () -> Void
        let easyCareBackgroundColor = Color(red: 0.0, green: 0.8, blue: 0.0, opacity: 0.15) // Ejemplo de un verde
        var body: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Snake Plant")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Plant Recommendations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer() // Pushes X button to the right
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "bookmark.fill")
                        .padding()
                        .font(.title2)
                        .foregroundStyle(.gray.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundStyle(.blue)
                }
            }
        }
    }

// ... (El resto de tus subvistas: ImageCareSection, WhatYouCanDoSection, etc. permanecen IGUAL)
// Asegúrate de tener imágenes placeholder en tus Assets:
// "snake_plant_placeholder", "zz_plant_placeholder", "pothos_placeholder"

struct ImageCareSection: View {
    let easyCareBackgroundColor = Color(red: 0.0, green: 0.8, blue: 0.0, opacity: 0.15) // Ejemplo de un verde

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                // Puedes usar el mismo color verde del fondo o uno más oscuro si lo prefieres
                .foregroundStyle(Color.green) // O podrías definir un color más oscuro basado en el backgroundColor

            VStack(alignment: .leading, spacing: 8) {
                Text("Easy Care")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(easyCareBackgroundColor)
                    .foregroundStyle(.green)
                    .cornerRadius(15)

                Label("Indirect Light", systemImage: "sun.max")
                Label("Water every 2-3 weeks", systemImage: "drop")
                Label("65-80°F (18-27°C)", systemImage: "thermometer")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

struct WhatYouCanDoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("What You Can Do")
                .font(.title2)
                .fontWeight(.semibold)

            CareBlock(
                icon: "checklist",
                title: "Daily Care",
                description: "Check soil moisture and dust leaves regularly. Place in bright, indirect light.",
                color: .blue
            )
            CareBlock(
                icon: "scissors",
                title: "Maintenance",
                description: "Remove yellow leaves and clean with damp cloth monthly.",
                color: .green
            )
            CareBlock(
                icon: "exclamationmark.triangle",
                title: "Troubleshooting",
                description: "Watch for brown tips (low humidity) or yellow leaves (overwatering).",
                color: .orange
            )
        }
    }
}

struct CareBlock: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
             Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 30) // Ayuda a alinear
                .padding()

            VStack(alignment: .leading) {
                Text(title).fontWeight(.semibold)
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PlantExpertsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Plant Experts")
                .font(.title2)
                .fontWeight(.semibold)

            ExpertRow(
                imageName: "person.crop.circle.fill",
                isSystemImage: true,
                title: "Sarah Johnson",
                subtitle: "Plant Specialist",
                buttonText: "Contact"
            )
            ExpertRow(
                imageName: "house.fill",
                isSystemImage: true,
                title: "Green Thumb Garden Center",
                subtitle: "2.5 miles away",
                buttonText: "Directions"
            )
        }
    }
}

struct ExpertRow: View {
    let imageName: String
    let isSystemImage: Bool
    let title: String
    let subtitle: String
    let buttonText: String

    var body: some View {
        HStack {
            if isSystemImage {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.secondary)
                    .clipShape(Circle())
                    .padding(5)
                    .background(Color.gray.opacity(0.1).clipShape(Circle()))
            } else {
                 Image(imageName) // Asegúrate que esta imagen exista si isSystemImage es false
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading) {
                Text(title).fontWeight(.medium)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Button(buttonText) {
                // Action
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .controlSize(.small)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}



// MARK: - Preview
#Preview {
     // Para previsualizar bien el botón inferior, puedes embeberlo en NavigationStack
     // o simplemente mostrarlo como está.
    SheetOfPlants()
}

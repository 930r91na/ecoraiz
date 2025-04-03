import SwiftUI

struct PlantDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let plant: InvasivePlant
    @State private var isBookmarked: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // --- HeaderView ---
                PlantHeaderView(
                    plant: plant,
                    isBookmarked: $isBookmarked,
                    dismissAction: {
                        dismiss()
                    }
                )
                .padding(.horizontal)
                .padding(.top)
                .background(Color.white)

                // --- Scrollable Content ---
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        PlantImageSection(plant: plant)
                            .padding(.top, 10)
                        
                        PlantProblemSection(plant: plant)
                        
                        if let eliminationMethods = plant.eliminationMethods, !eliminationMethods.isEmpty {
                            PlantEliminationSection(plant: plant)
                        }
                        
                        if let alternativeUses = plant.alternativeUses, !alternativeUses.isEmpty {
                            PlantAlternativeUsesSection(plant: plant)
                        }
                        
                        PlantExpertsSection()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct PlantHeaderView: View {
    let plant: InvasivePlant
    @Binding var isBookmarked: Bool
    let dismissAction: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Text(plant.scientificName)
                    .font(.system(size: 16))
                    .italic()
                    .foregroundColor(.primaryGreen.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    isBookmarked.toggle()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 22))
                        .foregroundColor(.primaryGreen)
                }
                
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.black.opacity(0.7))
                }
            }
        }
        .padding(.bottom, 8)
    }
}

struct PlantImageSection: View {
    let plant: InvasivePlant
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Full-width plant image with gradient overlay
            ZStack(alignment: .bottom) {
                // Plant image
                plant.imageURL
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    
                
                // Gradient overlay at the bottom
                VStack(alignment: .leading, spacing: 4) {
                    // Invasion level label
                    Text("PLANTA INVASORA")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Severity level
                    Text("Nivel \(plant.severity.rawValue)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                plant.severity.color.opacity(0.9),
                                plant.severity.color.opacity(0.7),
                                plant.severity.color.opacity(0)
                            ]
                        ),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            }
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // Accuracy indicator (if available)
            if let accuracy = plant.accuracyDetection {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.primaryGreen)
                        .font(.system(size: 14))
                    
                    Text("Precisión de la detección: \(Int(accuracy * 100))%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.top, 6)
                .padding(.bottom, 2)
            }
        }
        .padding(.horizontal, 2)
    }
}

// Extension to apply rounded corners to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct PlantProblemSection: View {
    let plant: InvasivePlant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.opaqueRed)
                
                Text("El Problema")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
            }
            
            // Problem description
            Text(plant.problem ?? "")
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.opaqueRed.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.opaqueRed.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct PlantAlternativeUsesSection: View {
    let plant: InvasivePlant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.lightGreen)
                
                Text("Usos Alternativos")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
            }
            
            // Uses list
            VStack(spacing: 12) {
                ForEach(plant.alternativeUses ?? [], id: \.self) { use in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.primaryGreen)
                            .frame(width: 24, height: 24)
                        
                        Text(use)
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                    
                    if use != plant.alternativeUses?.last {
                        Divider()
                            .background(Color.lightGreen.opacity(0.3))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.lightGreen.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.lightGreen.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct PlantEliminationSection: View {
    let plant: InvasivePlant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Image(systemName: "trash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                
                Text("Cómo Eliminarla Correctamente")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
            }
            
            // Elimination methods
            VStack(spacing: 12) {
                ForEach(plant.eliminationMethods ?? [], id: \.self) { method in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 24, height: 24)
                            
                            Text("\(plant.eliminationMethods?.firstIndex(of: method).map { $0 + 1 } ?? 0)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        
                        Text(method)
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                    
                    if method != plant.eliminationMethods?.last {
                        Divider()
                            .background(Color.orange.opacity(0.3))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.orange.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct PlantExpertsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.navyBlue)
                
                Text("Expertos en Plantas Invasoras")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
            }
            
            // Expert rows
            VStack(spacing: 12) {
                ExpertRow(
                    imageName: "person.crop.circle.fill",
                    isSystemImage: true,
                    title: "Ana Rodríguez",
                    subtitle: "Especialista en Plantas Invasoras",
                    buttonText: "Contactar"
                )
                
                ExpertRow(
                    imageName: "building.2.fill",
                    isSystemImage: true,
                    title: "Centro Ecológico Nacional",
                    subtitle: "Agencia Gubernamental",
                    buttonText: "Más info"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct ExpertRow: View {
    let imageName: String
    let isSystemImage: Bool
    let title: String
    let subtitle: String
    let buttonText: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Expert image or icon
            if isSystemImage {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.navyBlue)
                    .padding(8)
                  
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            
            // Expert info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.8))
            }
            
            Spacer()
            
            // Contact button
            Button {
                // Action
            } label: {
                Text(buttonText)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.navyBlue)
                    )
                    .foregroundColor(.white)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primaryGreen.opacity(0.2), lineWidth: 1)
        )
    }
}

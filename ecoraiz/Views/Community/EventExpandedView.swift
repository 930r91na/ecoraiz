import SwiftUI

struct EventExpandedView: View {
    let event: CommunityEvent
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                EventHeaderView(event: event)
                
                // Content
                VStack(spacing: 24) {
                    // Date, Time & Location
                    EventDetailsView(event: event)
                    
                    // Organizer Section
                    EventOrganizerView(event: event)
                    
                    // Attendees Section
                    EventAttendeesView(event: event)
                    
                    // Register Button
                    RegisterButtonView()
                }
                .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(
            CloseButtonView(dismiss: dismiss),
            alignment: .topTrailing
        )
    }
}

// MARK: - Subviews

struct EventHeaderView: View {
    let event: CommunityEvent
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Image
            EventHeaderImageView(imageName: event.imageName)
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(
                    colors: [.clear, .black.opacity(0.6)]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            
            // Title and status
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.status)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(event.statusColor)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    
                    Spacer()
                }
                
                Text(event.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
        }
    }
}

struct EventHeaderImageView: View {
    let imageName: String
    
    var body: some View {
        Group {
            if imageName.hasPrefix("http") {
                AsyncImage(url: URL(string: imageName)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.lightGreen.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .tint(Color.primaryGreen)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.lightGreen.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.primaryGreen)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.lightGreen.opacity(0.3))
                    }
                }
            } else {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(height: 240)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

struct EventDetailsView: View {
    let event: CommunityEvent
    
    var body: some View {
        VStack(spacing: 16) {
            // Date and Time
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.primaryGreen)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fecha y Hora")
                        .font(.headline)
                        .foregroundColor(.darkGreen)
                    
                    Text(event.dateTime)
                        .font(.body)
                        .foregroundColor(.primaryGreen)
                }
                
                Spacer()
            }
            
            // Location
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(.primaryGreen)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ubicación")
                        .font(.headline)
                        .foregroundColor(.darkGreen)
                    
                    Text(event.location)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct EventOrganizerView: View {
    let event: CommunityEvent
    @State private var showingCallAlert = false
    
    // You can add a phone number field to your CommunityEvent model
    // For this example, I'll use a placeholder
    let phoneNumber = "222-123-4567" // Replace with actual field from your model
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Organizador")
                .font(.headline)
                .foregroundColor(.darkGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Organizer info row
                HStack(spacing: 16) {
                    // Organizer Avatar
                    OrganizerAvatarView(avatarName: event.organizerAvatar)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.organizerName)
                            .font(.title3)
                            .foregroundColor(.darkGreen)
                        
                        Text("Organizador del Evento")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                // Contact button now below the organizer info
                Button(action: {
                    showingCallAlert = true
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.subheadline)
                        
                        Text("Contactar")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .alert(isPresented: $showingCallAlert) {
                    Alert(
                        title: Text("Llamar a \(event.organizerName)"),
                        message: Text("¿Deseas llamar al número \(phoneNumber)?"),
                        primaryButton: .default(Text("Llamar")) {
                            makePhoneCall(phoneNumber: phoneNumber)
                        },
                        secondaryButton: .cancel(Text("Cancelar"))
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Function to make a phone call
    private func makePhoneCall(phoneNumber: String) {
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
                                          .replacingOccurrences(of: "-", with: "")
        
        if let url = URL(string: "tel://\(cleanedPhoneNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct OrganizerAvatarView: View {
    let avatarName: String
    
    var body: some View {
        Group {
            if avatarName.hasPrefix("http") {
                AsyncImage(url: URL(string: avatarName)) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color.lightGreen.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .tint(Color.primaryGreen)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    case .failure:
                        Circle()
                            .fill(Color.lightGreen.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.primaryGreen)
                            )
                    @unknown default:
                        Circle()
                            .fill(Color.lightGreen.opacity(0.3))
                    }
                }
            } else {
                Image(avatarName)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            }
        }
        .frame(width: 60, height: 60)
    }
}

struct EventAttendeesView: View {
    let event: CommunityEvent
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Participantes")
                    .font(.headline)
                    .foregroundColor(.darkGreen)
                
                Spacer()
                
                Text("\(event.attendeeCount) asistentes")
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
            }
            
            // Mock Attendee Avatars
            HStack(spacing: -8) {
                ForEach(0..<min(5, event.attendeeCount), id: \.self) { _ in
                    Circle()
                        .fill(Color.lightGreen.opacity(0.6))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                
                if event.attendeeCount > 5 {
                    Circle()
                        .fill(Color.primaryGreen)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("+\(event.attendeeCount - 5)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct RegisterButtonView: View {
    var body: some View {
        Button(action: {
            // Register action
        }) {
            Text("Registrarse al Evento")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryGreen)
                .cornerRadius(16)
        }
        .padding(.vertical, 10)
    }
}

struct CloseButtonView: View {
    let dismiss: DismissAction
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "xmark")
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(Color.black.opacity(0.6)))
        }
        .padding(20)
    }
}

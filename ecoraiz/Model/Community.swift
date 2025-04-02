
import SwiftUI
// --- Modelos de Datos (Ejemplo) ---
struct FeaturedEvent: Identifiable {
    let id = UUID()
    let title: String
    let dateTime: String
    let location: String
    let imageName: String
}

struct CommunityEvent: Identifiable {
    let id = UUID()
    let title: String
    let dateTime: String
    let location: String
    let imageName: String
    let status: String
    let statusColor: Color
    let organizerName: String
    let organizerAvatar: String
    let attendeeCount: Int
}

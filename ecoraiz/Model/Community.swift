import SwiftUI
import Foundation // Necesario para UUID y potencialmente Color si no importas SwiftUI

// --- Modelo para la sección superior (Observaciones Destacadas) ---
// Define QUÉ propiedades tendrá, no CÓMO se obtienen.
struct FeaturedEvent: Identifiable { // <-- Asegúrate que conforma a Identifiable
    let id: Int                    // <-- ¡Añadida la propiedad 'id'! (Tipo Int porque viene de iNaturalist)
    let title: String
    let dateTime: String
    let location: String
    let imageURL: String?          // URL de la imagen (opcional porque podría fallar)
    let observationURL: String?    // URL a iNaturalist (opcional)
}

// --- Modelo para la sección inferior (Eventos Comunitarios) ---
// Esta estructura parecía estar bien definida en tu captura.
struct CommunityEvent: Identifiable {
    let id = UUID() // Usar UUID si no tienes un ID único de otra fuente
    let title: String
    let dateTime: String
    let location: String
    let imageName: String // Nombre de imagen local en Assets
    let status: String
    let statusColor: Color // Necesita 'import SwiftUI' o definir tu propio tipo Color Codable
    let organizerName: String
    let organizerAvatar: String // Nombre de imagen local en Assets
    let attendeeCount: Int
}

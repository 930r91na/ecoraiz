import SwiftUI

struct InvasivePlant: Identifiable {
    let id: String
    let name: String
    let scientificName: String
    let distance: Double?
    let severity: Severity
    let imageURL: String
    let accuracyDetection: Double?
    
    enum Severity: String {
        case low = "Baja"
        case medium = "Media"
        case high = "Alta"
        
        var color: Color {
            switch self {
            case .low:
                return .blue
            case .medium:
                return .orange
            case .high:
                return .red
            }
        }
    }
}

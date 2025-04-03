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

struct PlantDetails {
    let name: String
    let scientificName: String
    let invasiveLevel: InvasiveLevel
    let description: String
    let controlMethods: [String]
    let impacts: [String]
}

enum InvasiveLevel: String, CaseIterable {
    case low = "Bajo"
    case medium = "Medio"
    case high = "Alto"
    case extreme = "Extremo"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .extreme: return .red
        }
    }
}

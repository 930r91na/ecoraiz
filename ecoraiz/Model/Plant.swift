import SwiftUI

struct InvasivePlant: Identifiable {
    let id: String
    let name: String
    let scientificName: String
    let distance: Double?
    let severity: Severity
    let imageURL: String
    let accuracyDetection: Double?
    
    // Added fields based on the plant information
    let problem: String?
    let alternativeUses: [String]?
    let eliminationMethods: [String]?
    
    enum Severity: String {
        case low = "Baja"
        case medium = "Media"
        case high = "Alta"
        case extreme = "Extrema" // Added extreme level as it appears in the mock data
        
        var color: Color {
            switch self {
            case .low:
                return .blue
            case .medium:
                return .orange
            case .high:
                return .red
            case .extreme:
                return .purple // Added color for extreme severity
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
    
    let problem: String?
    let alternativeUses: [String]?
    let eliminationMethods: [String]?
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

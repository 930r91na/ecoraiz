import Foundation
import SwiftUI


let invasivePlants = [
    InvasivePlant(id: "1", name: "Lirio acuático", scientificName: "Eichhornia crassipes", distance: 0.5, severity: .high, imageURL: "lirio_acuatico", accuracyDetection: nil),
    InvasivePlant(id: "2", name: "Muérdago", scientificName: "Psittacanthus calyculatus", distance: 1.2, severity: .medium, imageURL: "muerdago", accuracyDetection: nil),
    InvasivePlant(id: "3", name: "Caña común", scientificName: "Arundo donax", distance: 2.3, severity: .low, imageURL: "cana_comun", accuracyDetection: nil)
]

let plantDatabase: [String: PlantDetails] = [
    "Castor_Bean_Images": PlantDetails(
        name: "Castor Tartágo",
        scientificName: "Ricinus communis",
        invasiveLevel: .high,
        description: "Planta de crecimiento rápido con hojas grandes en forma de palma y semillas tóxicas.",
        controlMethods: ["Extracción manual con guantes", "Corte antes de la floración", "Aplicación localizada de herbicidas"],
        impacts: ["Tóxico para humanos y animales", "Desplaza vegetación nativa", "Altera hábitats ribereños"]
    ),
    "Water_Hyacinth_Images": PlantDetails(
        name: "Lirio acuático",
        scientificName: "Eichhornia crassipes",
        invasiveLevel: .extreme,
        description: "Planta acuática flotante con flores moradas y bulbos inflados.",
        controlMethods: ["Extracción mecánica", "Control biológico", "Tratamiento químico controlado"],
        impacts: ["Bloquea cuerpos de agua", "Reduce oxígeno disponible", "Afecta pesca y navegación", "Aumenta evaporación del agua"]
    ),
    // Added other plants from your model's labels
    "Chinaberry_Images": PlantDetails(
        name: "Cinamomo",
        scientificName: "Melia azedarach",
        invasiveLevel: .high,
        description: "Árbol de crecimiento rápido con hojas compuestas y bayas venenosas.",
        controlMethods: ["Tala y remoción de tocones", "Aplicación de herbicidas", "Control de semillas"],
        impacts: ["Tóxico para humanos y animales", "Desplaza especies nativas", "Altera ecosistemas locales"]
    ),
    "Giant_Reed_Images": PlantDetails(
        name: "Caña común",
        scientificName: "Arundo donax",
        invasiveLevel: .extreme,
        description: "Gramínea gigante de crecimiento rápido que puede alcanzar varios metros de altura.",
        controlMethods: ["Remoción mecánica", "Aplicación de herbicidas", "Control de rizomas"],
        impacts: ["Consume grandes cantidades de agua", "Desplaza vegetación nativa", "Aumenta riesgo de incendios"]
    ),
    "Mother_of_Thousands_Images": PlantDetails(
        name: "Madre de miles",
        scientificName: "Kalanchoe daigremontiana",
        invasiveLevel: .medium,
        description: "Suculenta con pequeñas plantulas que se desarrollan en los bordes de las hojas.",
        controlMethods: ["Extracción manual", "Evitar propagación", "Control de suelo"],
        impacts: ["Tóxica para mascotas y ganado", "Invade rápidamente áreas nativas", "Difícil de erradicar"]
    )
]


func generateExampleUsers() -> [User] {
    let usersInfo = [
        (name: "Georgina Zeron", bio: "I love capybaras", email: "capybaraissocool@example.com"),
    ]
    
    var users: [User] = []

    for (index, userInfo) in usersInfo.enumerated() {
        users.append(User(id: UUID(), username: usersInfo[index].name, age: 20 + index, profilePicture: Image("profilePic\(index)"), fullName: userInfo.name, email: userInfo.email, bio: userInfo.bio, location: "Puebla"))
    }

    return users
}
let exampleUsers = generateExampleUsers()

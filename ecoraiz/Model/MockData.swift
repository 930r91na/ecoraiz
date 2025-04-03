import Foundation
import SwiftUI


let invasivePlants = [
    InvasivePlant(id: "1", name: "Lirio acuático", scientificName: "Eichhornia crassipes", distance: 0.5, severity: .high, imageURL: "lirio_acuatico", accuracyDetection: nil),
    InvasivePlant(id: "2", name: "Muérdago", scientificName: "Psittacanthus calyculatus", distance: 1.2, severity: .medium, imageURL: "muerdago", accuracyDetection: nil),
    InvasivePlant(id: "3", name: "Caña común", scientificName: "Arundo donax", distance: 2.3, severity: .low, imageURL: "cana_comun", accuracyDetection: nil)
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

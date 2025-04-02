import Foundation
import SwiftUI

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

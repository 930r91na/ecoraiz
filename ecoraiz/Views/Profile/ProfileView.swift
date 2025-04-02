import SwiftUI

struct ProfileView: View {
    var user: User
   
    var body: some View {
        Text("Hello, Profile!")
    }
}



struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: exampleUsers.first!)
            .previewLayout(.sizeThatFits)
    }
}

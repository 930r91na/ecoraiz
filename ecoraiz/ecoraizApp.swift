import SwiftUI
import MapKit

@main
struct ecoraizApp: App {
    @StateObject private var vm = LocationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationBar()
                .environmentObject(vm)
        }
    }
}

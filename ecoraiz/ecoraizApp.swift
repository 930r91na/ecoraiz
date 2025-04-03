// En ecoraizApp.swift (VERSIÓN CORREGIDA)

import SwiftUI
// import MapKit // No es necesario importar MapKit aquí usualmente

@main
struct ecoraizApp: App {
    // Se eliminará la inicialización directa aquí y se hará desde el init.
    @StateObject private var locationManager: LocationManager
    @StateObject private var vm: LocationsViewModel

    init() {
        // Crea una instancia local del LocationManager
        let lm = LocationManager()
        // Asigna el StateObject usando la instancia local
        _locationManager = StateObject(wrappedValue: lm)
        _vm = StateObject(wrappedValue: LocationsViewModel(locationManager: lm))
        print("ℹ️ ecoraizApp: init completado. ViewModel y LocationManager creados.")
    }

    var body: some Scene {
        WindowGroup {
            NavigationBar()
                .environmentObject(vm)
                .environmentObject(locationManager)
        }
    }
}


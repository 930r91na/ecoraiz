import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func checkAuthorization() {
        print("ℹ️ LocationManager: Verificando autorización...")
        // Actualiza el estado de autorización en el hilo principal
        DispatchQueue.main.async {
            self.authorizationStatus = self.locationManager.authorizationStatus
            if self.authorizationStatus == .notDetermined {
                self.requestPermission()
            } else if self.isAuthorized() {
                self.startUpdatesIfNeeded()
            }
        }
    }

    func requestPermission() {
        print("ℹ️ LocationManager: Solicitando permiso 'When In Use'...")
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatesIfNeeded() {
        if isAuthorized() {
            print("ℹ️ LocationManager: Iniciando actualizaciones de ubicación...")
            locationManager.startUpdatingLocation()
        } else {
            print("⚠️ LocationManager: No se inician updates, permiso no concedido.")
        }
    }

    func stopUpdates() {
        locationManager.stopUpdatingLocation()
    }

    func isAuthorized() -> Bool {
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    // MARK: - Métodos del Delegado

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        // Asegúrate de actualizar en el hilo principal
        DispatchQueue.main.async {
            self.location = newLocation
            print("✅ LocationManager: Ubicación actualizada: \(newLocation.coordinate)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ LocationManager: Error al actualizar la ubicación: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Actualiza la propiedad en el hilo principal
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            print("ℹ️ LocationManager: Nuevo estado de autorización: \(self.authorizationStatus)")
        }
    }
}

import Foundation
import SwiftUI    // Para @Published, ObservableObject, withAnimation
import MapKit     // Para MKCoordinateRegion, CLLocationCoordinate2D
import Combine    // Para AnyCancellable y gestión de LocationManager
import CoreLocation // Para CLLocationCoordinate2D


class LocationsViewModel: ObservableObject {

    // --- Propiedades del Mapa ---
    // Región inicial centrada en Puebla para pruebas
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.0414, longitude: -98.2063),
        span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
    )
    // Span más cercano para cuando se interactúa con un pin
    let detailSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    // --- Propiedades para Observaciones Cercanas de API ---
    @Published var nearbyInvasiveObservations: [Observation] = [] // Guarda las observaciones de la API
    @Published var isLoadingInvasives: Bool = false                  // Estado de carga para UI
    @Published var invasiveLoadError: Error? = nil                   // Para mostrar errores al usuario

    // --- Propiedades de Ubicación ---
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    private let locationManager: LocationManager  // Instancia compartida
    private var cancellables = Set<AnyCancellable>()
    private var didListenForFirstLocation = false // Bandera para evitar múltiples suscripciones

    // --- Configuración para la Búsqueda ---
    let invasiveTaxonIDsForTest = [962637, 64017] // IDs de prueba
    let pueblaCoordinate = CLLocationCoordinate2D(latitude: 19.0414, longitude: -98.2063)
    let searchRadius: Double = 30.0 // en km

    // --- Propiedad para Detalles (para mostrar info en un sheet, por ejemplo) ---
    @Published var selectedObservationForDetail: Observation? = nil

    // MARK: - Inicializador

    /// Inicializador que recibe el LocationManager compartido.
    init(locationManager: LocationManager) {
        print("ℹ️ LocationsViewModel: Inicializando con LocationManager compartido.")
        self.locationManager = locationManager
        setupLocationSubscription()
    }

    // MARK: - Configuración de Subscripciones

    /// Configura la suscripción al estado de autorización y a la ubicación.
    private func setupLocationSubscription() {
        // Suscribirse al estado de autorización
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                self.locationAuthorizationStatus = status
                print("ℹ️ LocationsViewModel: Estado de Auth recibido: \(status)")
                if self.locationManager.isAuthorized() {
                    // Si está autorizado, escucha la primera ubicación y activa updates
                    self.listenForFirstLocation()
                    self.locationManager.startUpdatesIfNeeded()
                } else if status == .notDetermined {
                    print("ℹ️ LocationsViewModel: Permiso no determinado, esperando acción.")
                } else {
                    print("⚠️ LocationsViewModel: Permiso no OK (\(status)), no se buscarán observaciones.")
                    // Limpiar datos si se revoca el permiso
                    self.nearbyInvasiveObservations = []
                    self.isLoadingInvasives = false
                }
            }
            .store(in: &cancellables)

        // Suscribirse a la ubicación para centrar el mapa e iniciar búsqueda (solo una vez)
        listenForFirstLocation()

        // Iniciar la verificación de autorización (solicita permiso si es necesario)
        locationManager.checkAuthorization()
        print("ℹ️ LocationsViewModel: Suscripción a ubicación configurada.")
    }

    /// Escucha sólo la primera ubicación válida para iniciar la búsqueda.
    private func listenForFirstLocation() {
        guard !didListenForFirstLocation else { return }
        didListenForFirstLocation = true

        locationManager.$location
            .compactMap { $0 }  // Ignora valores nulos
            .prefix(1)          // Solo la primera ubicación válida
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self = self else { return }
                print("✅ LocationsViewModel: Ubicación recibida para búsqueda: \(location.coordinate)")
                self.centerMapOn(coordinate: location.coordinate)
                self.loadNearbyObservations(coordinate: location.coordinate)
            }
            .store(in: &cancellables)
    }

    // MARK: - Funciones de Carga de Observaciones

    /// Carga observaciones cercanas usando la ubicación recibida.
    private func loadNearbyObservations(coordinate: CLLocationCoordinate2D) {
        guard !isLoadingInvasives else { return }
        isLoadingInvasives = true
        invasiveLoadError = nil

        fetchObservationsNearbyForTaxa(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: searchRadius,
            taxonIDs: invasiveTaxonIDsForTest
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingInvasives = false
                switch result {
                case .success(let observations):
                    let validObservations = observations.filter { $0.coordinate != nil }
                    self.nearbyInvasiveObservations = validObservations
                    print("✅ LocationsViewModel: Observaciones recibidas: \(observations.count), con coordenadas: \(validObservations.count)")
                case .failure(let error):
                    print("❌ LocationsViewModel: Error al cargar observaciones - \(error.localizedDescription)")
                    self.invasiveLoadError = error
                }
            }
        }
    }

    /// Función de carga de prueba para Puebla.
    func loadNearbyInvasivesForPuebla() {
        guard !isLoadingInvasives else { return }
        print("▶️ LocationsViewModel: Iniciando carga de prueba para Puebla...")
        isLoadingInvasives = true
        invasiveLoadError = nil

        fetchObservationsNearbyForTaxa(
            latitude: pueblaCoordinate.latitude,
            longitude: pueblaCoordinate.longitude,
            radius: searchRadius,
            taxonIDs: invasiveTaxonIDsForTest
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingInvasives = false
                switch result {
                case .success(let observations):
                    let validObservations = observations.filter { $0.coordinate != nil }
                    self.nearbyInvasiveObservations = validObservations
                    print("✅ LocationsViewModel: Prueba Puebla - Observaciones recibidas: \(observations.count), con coordenadas: \(validObservations.count)")
                case .failure(let error):
                    print("❌ LocationsViewModel: Error en prueba Puebla - \(error.localizedDescription)")
                    self.invasiveLoadError = error
                }
            }
        }
    }

    // MARK: - Funciones Auxiliares

    /// Centra el mapa en la coordenada especificada.
    func centerMapOn(coordinate: CLLocationCoordinate2D) {
        print("ℹ️ LocationsViewModel: Centrando mapa en \(coordinate)")
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion(center: coordinate, span: detailSpan)
        }
    }

    /// Solicita el permiso de ubicación.
    func requestLocationPermission() {
        locationManager.requestPermission()
    }
}

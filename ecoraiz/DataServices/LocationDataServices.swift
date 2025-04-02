import Foundation
import MapKit

class LocationsDataService {
    
    static let locations: [Location] = [
        Location(
            name: "Parque Ecológico",
            cityName: "San Miguel de Allende",
            coordinates: CLLocationCoordinate2D(latitude: 20.915, longitude: -100.7436),
            description: "Área afectada por lirio acuático. La comunidad local está trabajando en su control. Este parque ha sido un punto importante para la educación ambiental sobre especies invasoras y el impacto que tienen en los ecosistemas locales.",
            imageNames: [
                "parque_ecologico_1",
                "parque_ecologico_2"
            ],
            link: "https://example.com/parque"
        ),
        Location(
            name: "Presa Allende",
            cityName: "San Miguel de Allende",
            coordinates: CLLocationCoordinate2D(latitude: 20.9062, longitude: -100.7559),
            description: "Gran extensión cubierta por lirio acuático, afectando la pesca local y el riego. La invasión del lirio acuático (Eichhornia crassipes) ha cubierto grandes extensiones de la presa Allende, reduciendo el oxígeno disponible para los peces, bloqueando canales de riego, y aumentando la evaporación del agua.",
            imageNames: [
                "presa_allende_1",
                "presa_allende_2"
            ],
            link: "https://example.com/presa"
        ),
        Location(
            name: "Recta San Pedro Cholula",
            cityName: "San Pedro Cholula",
            coordinates: CLLocationCoordinate2D(latitude: 19.0748, longitude: -98.3039),
            description: "Árboles afectados por muérdago, causando debilitamiento y muerte prematura. El muérdago (Psittacanthus calyculatus) ha infestado árboles nativos y ornamentales, debilitándolos y causando su muerte prematura. Esto afecta la cobertura vegetal, aumenta las islas de calor y reduce los servicios ecosistémicos urbanos.",
            imageNames: [
                "recta_cholula_1",
                "recta_cholula_2"
            ],
            link: "https://example.com/cholula"
        ),
        Location(
            name: "Canal de Xochimilco",
            cityName: "Ciudad de México",
            coordinates: CLLocationCoordinate2D(latitude: 19.2836, longitude: -99.1047),
            description: "Zona de canales afectada por múltiples especies invasoras acuáticas que amenazan el ecosistema tradicional de chinampas. Las especies invasoras acuáticas han alterado el equilibrio ecológico y representan una amenaza para la biodiversidad local y las prácticas agrícolas tradicionales.",
            imageNames: [
                "xochimilco_1",
                "xochimilco_2"
            ],
            link: "https://example.com/xochimilco"
        )
    ]
    
}



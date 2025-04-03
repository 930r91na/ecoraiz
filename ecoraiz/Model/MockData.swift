import Foundation
import SwiftUI


let invasivePlants = [
    InvasivePlant(
        id: "1",
        name: "Lirio acuático",
        scientificName: "Eichhornia crassipes",
        distance: 0.5,
        severity: .extreme,
        imageURL: "lirio_acuatico",
        accuracyDetection: nil,
        problem: "Bloquea la luz del agua, reduce el oxígeno y afecta la fauna acuática.",
        alternativeUses: [
            "Compostaje: Rica en nitrógeno, puede convertirse en fertilizante.",
            "Filtro de agua: Se ha usado en algunos sistemas de tratamiento de aguas residuales.",
            "Artesanías: Sus fibras pueden trenzarse para hacer canastos o alfombras."
        ],
        eliminationMethods: [
            "Retirarla manualmente del agua y dejarla secar completamente antes de desechar.",
            "No dejar fragmentos en el agua, ya que puede regenerarse rápidamente."
        ]
    ),
    InvasivePlant(
        id: "2",
        name: "Muérdago",
        scientificName: "Psittacanthus calyculatus",
        distance: 1.2,
        severity: .medium,
        imageURL: "muerdago",
        accuracyDetection: nil,
        problem: "Parásito que debilita árboles nativos y ornamentales, causando su muerte prematura.",
        alternativeUses: [
            "Medicina tradicional: Usado en algunas preparaciones herbales.",
            "Decoración: En algunas culturas se usa para decoración festiva."
        ],
        eliminationMethods: [
            "Podar la rama infectada al menos 30 cm por debajo del punto de infección.",
            "Quemar o sellar los restos para evitar propagación.",
            "Tratar el árbol con productos específicos para fortalecer su sistema."
        ]
    ),
    InvasivePlant(
        id: "3",
        name: "Caña común",
        scientificName: "Arundo donax",
        distance: 2.3,
        severity: .extreme,
        imageURL: "cana_comun",
        accuracyDetection: nil,
        problem: "Crece rápidamente en ríos y arroyos, desplazando especies nativas.",
        alternativeUses: [
            "Construcción: Se puede usar como material para hacer cercas, techos, y muebles rústicos.",
            "Instrumentos musicales: Se usa para fabricar flautas y cañas de saxofón.",
            "Biomasa: Se puede secar y usar como leña o material de compostaje."
        ],
        eliminationMethods: [
            "Cortar la planta lo más bajo posible y quitar los rizomas (raíces).",
            "Secar completamente antes de desechar.",
            "No quemar cerca de cuerpos de agua, ya que sus semillas pueden dispersarse."
        ]
    )
]


let plantDatabase: [String: PlantDetails] = [
    "Castor_Bean_Images": PlantDetails(
        name: "Castor Tartágo",
        scientificName: "Ricinus communis",
        invasiveLevel: .high,
        description: "Planta de crecimiento rápido con hojas grandes en forma de palma y semillas tóxicas.",
        controlMethods: ["Extracción manual con guantes", "Corte antes de la floración", "Aplicación localizada de herbicidas"],
        impacts: ["Tóxico para humanos y animales", "Desplaza vegetación nativa", "Altera hábitats ribereños"],
        problem: "Es tóxica (sus semillas contienen ricina) y se propaga rápidamente.",
        alternativeUses: [
            "Aceite de ricino (con precaución): Sus semillas producen un aceite usado en productos cosméticos e industriales.",
            "Repelente de plagas: Sus hojas pueden usarse como barrera natural contra insectos."
        ],
        eliminationMethods: [
            "Arrancar desde la raíz, evitando el contacto con sus semillas.",
            "Usar guantes al manipular la planta, ya que puede causar irritación.",
            "No quemar las semillas, ya que liberan sustancias tóxicas."
        ]
    ),
    "Water_Hyacinth_Images": PlantDetails(
        name: "Lirio acuático",
        scientificName: "Eichhornia crassipes",
        invasiveLevel: .extreme,
        description: "Planta acuática flotante con flores moradas y bulbos inflados.",
        controlMethods: ["Extracción mecánica", "Control biológico", "Tratamiento químico controlado"],
        impacts: ["Bloquea cuerpos de agua", "Reduce oxígeno disponible", "Afecta pesca y navegación", "Aumenta evaporación del agua"],
        problem: "Bloquea la luz del agua, reduce el oxígeno y afecta la fauna acuática.",
        alternativeUses: [
            "Compostaje: Rica en nitrógeno, puede convertirse en fertilizante.",
            "Filtro de agua: Se ha usado en algunos sistemas de tratamiento de aguas residuales.",
            "Artesanías: Sus fibras pueden trenzarse para hacer canastos o alfombras."
        ],
        eliminationMethods: [
            "Retirarla manualmente del agua y dejarla secar completamente antes de desechar.",
            "No dejar fragmentos en el agua, ya que puede regenerarse rápidamente."
        ]
    ),
    "Chinaberry_Images": PlantDetails(
        name: "Cinamomo",
        scientificName: "Melia azedarach",
        invasiveLevel: .high,
        description: "Árbol de crecimiento rápido con hojas compuestas y bayas venenosas.",
        controlMethods: ["Tala y remoción de tocones", "Aplicación de herbicidas", "Control de semillas"],
        impacts: ["Tóxico para humanos y animales", "Desplaza especies nativas", "Altera ecosistemas locales"],
        problem: "Árbol invasor que desplaza especies nativas y sus frutos son tóxicos para humanos y animales.",
        alternativeUses: [
            "Madera: Se usa para carpintería y fabricación de muebles.",
            "Plaguicida natural: Sus hojas y frutos pueden usarse como repelente de insectos."
        ],
        eliminationMethods: [
            "Cortar y eliminar raíces para evitar su regeneración.",
            "No quemar ni dejar los frutos expuestos, ya que pueden ser peligrosos para animales y niños."
        ]
    ),
    "Giant_Reed_Images": PlantDetails(
        name: "Caña común",
        scientificName: "Arundo donax",
        invasiveLevel: .extreme,
        description: "Gramínea gigante de crecimiento rápido que puede alcanzar varios metros de altura.",
        controlMethods: ["Remoción mecánica", "Aplicación de herbicidas", "Control de rizomas"],
        impacts: ["Consume grandes cantidades de agua", "Desplaza vegetación nativa", "Aumenta riesgo de incendios"],
        problem: "Crece rápidamente en ríos y arroyos, desplazando especies nativas.",
        alternativeUses: [
            "Construcción: Se puede usar como material para hacer cercas, techos, y muebles rústicos.",
            "Instrumentos musicales: Se usa para fabricar flautas y cañas de saxofón.",
            "Biomasa: Se puede secar y usar como leña o material de compostaje."
        ],
        eliminationMethods: [
            "Cortar la planta lo más bajo posible y quitar los rizomas (raíces).",
            "Secar completamente antes de desechar.",
            "No quemar cerca de cuerpos de agua, ya que sus semillas pueden dispersarse."
        ]
    ),
    "Mother_of_Thousands_Images": PlantDetails(
        name: "Madre de miles",
        scientificName: "Kalanchoe daigremontiana",
        invasiveLevel: .medium,
        description: "Suculenta con pequeñas plantulas que se desarrollan en los bordes de las hojas.",
        controlMethods: ["Extracción manual", "Evitar propagación", "Control de suelo"],
        impacts: ["Tóxica para mascotas y ganado", "Invade rápidamente áreas nativas", "Difícil de erradicar"],
        problem: "Se reproduce muy rápido, cada hoja produce nuevas plántulas.",
        alternativeUses: [
            "Planta medicinal: Algunas culturas la usan para tratar heridas y quemaduras.",
            "Planta ornamental: Si se controla bien, puede mantenerse en macetas sin riesgo de invasión."
        ],
        eliminationMethods: [
            "Arrancar toda la planta, asegurándose de eliminar sus pequeñas plántulas.",
            "No tirarla al compost ni a la tierra, ya que puede volver a crecer fácilmente."
        ]
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

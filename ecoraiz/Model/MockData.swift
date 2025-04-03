import Foundation
import SwiftUI


let invasivePlants = [
    InvasivePlant(
        id: "1",
        name: "Lirio acuático",
        scientificName: "Eichhornia crassipes",
        distance: 0.5,
        severity: .extreme,
        imageURL: Image("lili"),
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
        name: "Castor Tartágo",
        scientificName: "Psittacanthus calyculatus",
        distance: 1.2,
        severity: .medium,
        imageURL: Image("castor"),
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
        name: "Madre de miles",
        scientificName: "Arundo donax",
        distance: 2.3,
        severity: .extreme,
        imageURL: Image("mother"),
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
        taxonId: 56739,
        imageURL: Image("castor"),
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
        taxonId: 962637,
        imageURL: Image("lili"),
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
        taxonId: 53720,
        imageURL: Image("Melialim"),
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
        taxonId: 64017,
        imageURL: Image("reed"),
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
        taxonId: 164327,
        imageURL: Image("mother"),
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


let communityEvents: [CommunityEvent] = [
    CommunityEvent(
        title: "Taller de Identificación de Plantas Invasoras",
        dateTime: "Sáb, 15 Mayo • 10:00 AM",
        location: "Jardín Botánico de Puebla",
        imageName: "https://images.unsplash.com/photo-1520302630591-fd1c66edc19d?q=80&w=600",
        status: "Casi Lleno",
        statusColor: .mustardYellow,
        organizerName: "Dra. Carmen Vázquez",
        organizerAvatar: "https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?q=80&w=200",
        attendeeCount: 18
    ),
    CommunityEvent(
        title: "Limpieza del Río Atoyac",
        dateTime: "Dom, 23 Mayo • 8:30 AM",
        location: "Puente de México, Puebla",
        imageName: "https://www.proceso.com.mx/u/fotografias/m/2025/3/21/f608x342-219487_249210_118.jpg",
        status: "Abierto",
        statusColor: .primaryGreen,
        organizerName: "Miguel Ángel Ruiz",
        organizerAvatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200",
        attendeeCount: 35
    ),
    CommunityEvent(
        title: "Reforestación en Cholula",
        dateTime: "Próx. Semana, 9:00 AM",
        location: "Cerro Zapotecas",
        imageName: "https://informativo217.com/wp-content/uploads/2022/01/IMG-20220113-WA0052.jpg",
        status: "Limitado",
        statusColor: .orange,
        organizerName: "Laura Méndez",
        organizerAvatar: "https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=200",
        attendeeCount: 25
    ),
    CommunityEvent(
        title: "Seminario: Especies Invasoras y Biodiversidad",
        dateTime: "Jue, 27 Mayo • 5:00 PM",
        location: "Universidad Autónoma de Puebla",
        imageName: "https://www.upla.cl/noticias/wp-content/uploads/2024/12/seminario_botanica_5.jpg",
        status: "Gratuito",
        statusColor: .primaryGreen,
        organizerName: "Dr. Javier Morales",
        organizerAvatar: "https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=200",
        attendeeCount: 50
    ),
    CommunityEvent(
        title: "Monitoreo de Aves - Parque Ecológico",
        dateTime: "Sáb, 5 Junio • 7:00 AM",
        location: "Africam Safari, Puebla",
        imageName: "https://vivirenelpoblado.com/wp-content/uploads/Conservación-ciencia.jpg",
        status: "Pocos Lugares",
        statusColor: .opaqueRed,
        organizerName: "Elena Cortés",
        organizerAvatar: "https://images.unsplash.com/photo-1581403341630-a6e0b9d2d257?q=80&w=200",
        attendeeCount: 12
    ),
    CommunityEvent(
        title: "Feria Ambiental de Atlixco",
        dateTime: "Dom, 13 Junio • 11:00 AM",
        location: "Zócalo de Atlixco",
        imageName: "https://vidauniversitaria.uanl.mx/wp-content/uploads/2024/06/feria-ambiental-uanl-sustentable-22.jpg",
        status: "Abierto",
        statusColor: .primaryGreen,
        organizerName: "Ayuntamiento de Atlixco",
        organizerAvatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200",
        attendeeCount: 120
    )
]

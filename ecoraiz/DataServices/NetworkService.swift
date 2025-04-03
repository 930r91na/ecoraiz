// En NetworkService.swift

import Foundation
// import SwiftUI // Probablemente no necesario aquí

// --- Modelo para la UI (Debe estar definido en otro archivo, ej. CommunityView.swift o Models.swift) ---
// Solo como referencia para la función fetch.
/*
struct FeaturedEvent: Identifiable {
    let id: Int
    let title: String
    let dateTime: String
    let location: String
    let imageURL: String?
    let observationURL: String?
}
*/

// --- Enum para Errores de Red ---
enum NetworkError: Error {
    case invalidURL
    case badResponse(statusCode: Int)
    case noData
    case decodingError(Error)
    case mappingError(String) // Puedes usarlo si quieres errores más específicos del mapeo
}

// --- Función para obtener Observaciones y Mapearlas a FeaturedEvent ---
func fetchFeaturedEventsFromINaturalist(placeId: Int, count: Int, completion: @escaping (Result<[FeaturedEvent], Error>) -> Void) {

    // 1. Construir URL (igual que antes)
    var components = URLComponents(string: "https://api.inaturalist.org/v1/observations")!
    components.queryItems = [
        URLQueryItem(name: "place_id", value: "\(placeId)"),
        URLQueryItem(name: "order_by", value: "observed_on"),
        URLQueryItem(name: "order", value: "desc"),
        URLQueryItem(name: "per_page", value: "\(count)"),
        URLQueryItem(name: "photos", value: "true"),
        URLQueryItem(name: "sounds", value: "false"),
        URLQueryItem(name: "quality_grade", value: "research")
    ]

    guard let url = components.url else {
        print("Error: URL inválida")
        completion(.failure(NetworkError.invalidURL))
        return
    }

    print("Solicitando URL: \(url.absoluteString)")

    // 2. Crear Tarea de Red (igual que antes)
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // 3. Manejar Errores Iniciales (igual que antes)
        if let error = error {
            print("Network Error: \(error.localizedDescription)")
            // Asegurar que el completion se llame en el hilo principal si causa updates de UI
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }

        // 4. Validar Respuesta HTTP (igual que antes)
        guard let httpResponse = response as? HTTPURLResponse else {
             print("Network Error: Invalid response type")
             DispatchQueue.main.async { completion(.failure(NetworkError.badResponse(statusCode: -1))) }
             return
         }
         guard (200...299).contains(httpResponse.statusCode) else {
             print("Network Error: Status Code \(httpResponse.statusCode)")
              if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                  print("Error Body: \(errorBody)")
              }
             DispatchQueue.main.async { completion(.failure(NetworkError.badResponse(statusCode: httpResponse.statusCode))) }
             return
         }

        // 5. Validar Datos (igual que antes)
        guard let data = data else {
             DispatchQueue.main.async { completion(.failure(NetworkError.noData)) }
            return
        }

        // 6. Decodificar JSON y Mapear
        do {
            let decoder = JSONDecoder()
            // No necesitas .convertFromSnakeCase si usas CodingKeys en tus modelos

            let observationResponse = try decoder.decode(ObservationResponse.self, from: data)

            // MAPEO: Convertir [Observation] a [FeaturedEvent]
            let featuredEvents = observationResponse.results.compactMap { obs -> FeaturedEvent? in

                // a. Extraer ID
                let id = obs.id

                // b. Extraer Título (con fallbacks)
                 // Asegúrate que tu struct Observation y Taxon en iNaturalistModels.swift estén actualizadas
                let title = obs.taxon?.preferredCommonName ?? obs.taxon?.name ?? obs.speciesGuess ?? "ID: \(id)"

                // c. Extraer y formatear Fecha/Hora
                let dateTime = formatDateString(obs.observedOnString) // Llama a la función auxiliar

                // d. Extraer Ubicación (con fallback)
                let location = obs.placeGuess ?? "Ubicación desconocida"

                // e. Extraer y MODIFICAR URL de Imagen (**CORRECCIÓN DEL TYPO AQUÍ**)
                //    Usamos optional chaining (?) por si photos o url son nil, y ?? para un default si falla la modificación (poco probable)
                let mappedImageURLString = obs.photos?.first?.url?.replacingOccurrences(of: "square", with: "medium")

                // f. Extraer URL de la observación web (opcional)
                let observationURL = obs.uri

                // g. Filtrar si falta imagen (ahora imageURL es opcional en FeaturedEvent)
                 guard mappedImageURLString != nil else {
                     // print("Observación \(id) descartada: Sin URL de foto válida.")
                     return nil
                 }

                // h. Crear el objeto FeaturedEvent
                return FeaturedEvent(id: id,
                                     title: title,
                                     dateTime: dateTime,
                                     location: location,
                                     imageURL: mappedImageURLString, // Ahora sí es String?
                                     observationURL: observationURL)
            }

            print("Mapeo completado. Eventos mapeados y válidos: \(featuredEvents.count) de \(observationResponse.results.count) recibidos.")
            // Llamar al completion en el hilo principal porque actualizará la UI
            DispatchQueue.main.async { completion(.success(featuredEvents)) }

        } catch let decodingError {
            print("---- Decoding Error ----")
            // ... (código de detalle de error de decodificación) ...
            DispatchQueue.main.async { completion(.failure(NetworkError.decodingError(decodingError))) }
        } catch {
            print("Unknown Error during fetch/processing: \(error)")
            DispatchQueue.main.async { completion(.failure(error)) }
        }
    }
    // 7. Iniciar Tarea
    task.resume()
}


// --- Función Auxiliar para Formatear Fecha (CORREGIDA) ---
// (Mantenerla en este archivo o moverla a un archivo de utilidades global)
func formatDateString(_ dateString: String?) -> String {
    guard let dateString = dateString, !dateString.isEmpty else { return "Fecha desconocida" }

    let outputFormatter = DateFormatter()
    outputFormatter.dateStyle = .medium
    outputFormatter.timeStyle = .short
    outputFormatter.locale = Locale(identifier: "es_MX") // O tu locale preferido

    // Intentar primero con ISO8601DateFormatter (maneja offsets y 'Z')
    let isoFormatters = [ISO8601DateFormatter(), ISO8601DateFormatter()]
    isoFormatters[0].formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    isoFormatters[1].formatOptions = [.withInternetDateTime] // Sin segundos fraccionales

    for formatter in isoFormatters {
        if let date = formatter.date(from: dateString) {
            // Determinar si solo tenía fecha para no mostrar hora 00:00
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            if components.hour == 0 && components.minute == 0 && components.second == 0 && !dateString.contains("T") {
                 outputFormatter.timeStyle = .none
            } else {
                 outputFormatter.timeStyle = .short
            }
            return outputFormatter.string(from: date)
        }
    }


    // Si ISO8601 falla, intentar con formatos específicos DateFormatter
    let specificFormatters: [DateFormatter] = [
        { // Formato yyyy-MM-dd HH:mm:ss
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Asume UTC si no se especifica
            return formatter
        }(),
        { // Formato yyyy-MM-dd (solo fecha)
             let formatter = DateFormatter()
             formatter.dateFormat = "yyyy-MM-dd"
             formatter.locale = Locale(identifier: "en_US_POSIX")
             formatter.timeZone = TimeZone(secondsFromGMT: 0)
             return formatter
         }()
        // Puedes añadir más DateFormatters aquí si encuentras otros formatos en la API
    ]

    for formatter in specificFormatters {
        if let date = formatter.date(from: dateString) {
             if formatter.dateFormat == "yyyy-MM-dd" {
                 outputFormatter.timeStyle = .none
             } else {
                 outputFormatter.timeStyle = .short
             }
            return outputFormatter.string(from: date)
        }
    }


    // Fallback si nada funciona
    print("Advertencia: No se pudo formatear la fecha '\(dateString)' con los formatos conocidos.")
    return "Fecha inválida" // O devuelve el string original: dateString
}

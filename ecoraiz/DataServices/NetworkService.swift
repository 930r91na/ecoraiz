// En NetworkService.swift

import Foundation
// import SwiftUI // Probablemente no necesario aquí

// --- Modelos (Definidos en otros archivos) ---
// Asegúrate que FeaturedEvent (Identifiable, con id: Int) y los modelos de iNaturalist
// (ObservationResponse, Observation, Taxon, iNatUser, Photo, GeoJSON) estén definidos
// y accesibles desde aquí.

// --- Enum para Errores de Red ---
enum NetworkError: Error {
    case invalidURL
    case badResponse(statusCode: Int)
    case noData
    case decodingError(Error)
    case mappingError(String)
}

// --- Función para obtener Observaciones Destacadas (Featured) ---
func fetchFeaturedEventsFromINaturalist(placeId: Int, count: Int, completion: @escaping (Result<[FeaturedEvent], Error>) -> Void) {

    var components = URLComponents(string: "https://api.inaturalist.org/v1/observations")!
    components.queryItems = [
        URLQueryItem(name: "place_id", value: "\(placeId)"),
        URLQueryItem(name: "order_by", value: "observed_on"),
        URLQueryItem(name: "order", value: "desc"),
        URLQueryItem(name: "per_page", value: "\(count)"),
        URLQueryItem(name: "photos", value: "true"),
        URLQueryItem(name: "sounds", value: "false"),
        URLQueryItem(name: "quality_grade", value: "research"),
        URLQueryItem(name: "locale", value: "es-MX"),
        URLQueryItem(name: "iconic_taxa", value: "Plantae") // Solo plantas
    ]

    guard let url = components.url else {
        DispatchQueue.main.async { completion(.failure(NetworkError.invalidURL)) }
        return
    }
    print("Solicitando URL (Featured Plants): \(url.absoluteString)")

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
             DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
             DispatchQueue.main.async { completion(.failure(NetworkError.badResponse(statusCode: -1))) }
             return
         }
         guard (200...299).contains(httpResponse.statusCode) else {
              if let data = data, let errorBody = String(data: data, encoding: .utf8) { print("Error Body: \(errorBody)") }
             DispatchQueue.main.async { completion(.failure(NetworkError.badResponse(statusCode: httpResponse.statusCode))) }
             return
         }
        guard let data = data else {
             DispatchQueue.main.async { completion(.failure(NetworkError.noData)) }
            return
        }

        do {
            let decoder = JSONDecoder()
            let observationResponse = try decoder.decode(ObservationResponse.self, from: data)

            let featuredEvents = observationResponse.results.compactMap { obs -> FeaturedEvent? in
                let id = obs.id
                let rawTitle = obs.taxon?.preferredCommonName ?? obs.taxon?.name ?? obs.speciesGuess ?? "ID: \(id)"
                let title = rawTitle.capitalized
                let dateTime = formatDateString(obs.observedOnString) // Usar función auxiliar
                let location = obs.placeGuess ?? "Ubicación desconocida"
                let observationURL = obs.uri
                guard let imageURLString = obs.photos?.first?.url?.replacingOccurrences(of: "square", with: "medium") else {
                    return nil // Necesitamos imagen para eventos destacados
                }

                // Opcional: Filtrar también si la fecha no es válida aquí, además de en el ViewModel
                // guard dateTime != "Fecha inválida" else { return nil }

                return FeaturedEvent(id: id,
                                     title: title,
                                     dateTime: dateTime,
                                     location: location,
                                     imageURL: imageURLString,
                                     observationURL: observationURL)
            }
            DispatchQueue.main.async { completion(.success(featuredEvents)) }

        } catch let decodingError {
            print("---- Decoding Error (Featured) ----\n\(decodingError)\n------------------------")
            if let jsonString = String(data: data, encoding: .utf8) { print("Raw JSON causing error:\n\(jsonString)") }
            DispatchQueue.main.async { completion(.failure(NetworkError.decodingError(decodingError))) }
        } catch {
             DispatchQueue.main.async { completion(.failure(error)) }
         }
    }
    task.resume()
}


// --- Función para obtener Observaciones Cercanas por Taxon ---
func fetchObservationsNearbyForTaxa(
    latitude: Double,
    longitude: Double,
    radius: Double = 30.0,
    taxonIDs: [Int],
    resultsPerPage: Int = 50,
    completion: @escaping (Result<[Observation], Error>) -> Void // Devuelve [Observation]
) {
     guard !taxonIDs.isEmpty else {
         DispatchQueue.main.async { completion(.success([])) }
         return
     }
     let taxonIDString = taxonIDs.map { String($0) }.joined(separator: ",")

     var components = URLComponents(string: "https://api.inaturalist.org/v1/observations")!
     components.queryItems = [
         URLQueryItem(name: "lat", value: "\(latitude)"),
         URLQueryItem(name: "lng", value: "\(longitude)"),
         URLQueryItem(name: "radius", value: "\(radius)"),
         URLQueryItem(name: "taxon_id", value: taxonIDString),
         URLQueryItem(name: "per_page", value: "\(resultsPerPage)"),
         URLQueryItem(name: "photos", value: "true"),
         URLQueryItem(name: "order", value: "desc"),
         URLQueryItem(name: "order_by", value: "observed_on"),
         URLQueryItem(name: "locale", value: "es-MX")
     ]

     guard let url = components.url else {
         DispatchQueue.main.async { completion(.failure(NetworkError.invalidURL)) }
         return
     }
     print("Solicitando URL (Nearby Taxa): \(url.absoluteString)")

     let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // ... (Manejo de errores y validación de respuesta, similar a la otra función) ...
         if let error = error { /* ... */ DispatchQueue.main.async { completion(.failure(error)) }; return }
         guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { /* ... */ DispatchQueue.main.async { completion(.failure(NetworkError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1))) }; return }
         guard let data = data else { /* ... */ DispatchQueue.main.async { completion(.failure(NetworkError.noData)) }; return }

        do {
            let decoder = JSONDecoder()
            let observationResponse = try decoder.decode(ObservationResponse.self, from: data)

            print("Observaciones cercanas por Taxon recibidas: \(observationResponse.results.count)")
            // Devolver directamente el array de [Observation]
            DispatchQueue.main.async { completion(.success(observationResponse.results)) }

        } catch let decodingError {
             print("---- Decoding Error (Nearby Taxa) ----\n\(decodingError)\n------------------------")
             if let jsonString = String(data: data, encoding: .utf8) { print("Raw JSON causing error:\n\(jsonString)") }
             DispatchQueue.main.async { completion(.failure(NetworkError.decodingError(decodingError))) }
         } catch {
              DispatchQueue.main.async { completion(.failure(error)) }
          }
     }
     task.resume()
 }


// --- Función Auxiliar para Formatear Fecha (CORREGIDA) ---
func formatDateString(_ dateString: String?) -> String {
    guard let dateString = dateString, !dateString.isEmpty else { return "Fecha desconocida" }
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateStyle = .medium
    outputFormatter.timeStyle = .short
    outputFormatter.locale = Locale(identifier: "es_MX")
    
    // 1. Intentar con ISO8601DateFormatter (más robusto para zonas horarias/fracciones)
    let isoFormatter1 = ISO8601DateFormatter()
    isoFormatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = isoFormatter1.date(from: dateString) {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        if components.hour == 0 && components.minute == 0 && components.second == 0 && !dateString.contains("T") { outputFormatter.timeStyle = .none } else { outputFormatter.timeStyle = .short }
        return outputFormatter.string(from: date)
    }
    
    let isoFormatter2 = ISO8601DateFormatter()
    isoFormatter2.formatOptions = [.withInternetDateTime] // Sin fracciones
    if let date = isoFormatter2.date(from: dateString) {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        if components.hour == 0 && components.minute == 0 && components.second == 0 && !dateString.contains("T") { outputFormatter.timeStyle = .none } else { outputFormatter.timeStyle = .short }
        return outputFormatter.string(from: date)
    }
    
    // 2. Si falla ISO8601, intentar con DateFormatter para formatos específicos
    let specificFormatters: [DateFormatter] = [
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Como "2025-04-02 15:34:35"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Asume UTC si no hay zona
            return formatter
        }(),
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd" // Solo fecha
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
    ]
    
    for formatter in specificFormatters {
        if let date = formatter.date(from: dateString) {
            if formatter.dateFormat == "yyyy-MM-dd" { outputFormatter.timeStyle = .none } else { outputFormatter.timeStyle = .short }
            return outputFormatter.string(from: date)
        }
        
    }
    // 3. Fallback si ningún formato funcionó
    print("Advertencia: No se pudo formatear la fecha '\(dateString)' con los formatos conocidos.")
    return "Fecha inválida"
    
}

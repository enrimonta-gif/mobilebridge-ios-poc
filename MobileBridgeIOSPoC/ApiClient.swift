import Foundation

struct PairPayload: Decodable {
    let ok: Bool?
    let storeTitle: String?
    let shopUrl: String?
    let email: String?
    enum CodingKeys: String, CodingKey { case ok; case storeTitle = "store_title"; case shopUrl = "shop_url"; case email }
}

enum MobileBridgeApiError: LocalizedError {
    case invalidURL, invalidResponse, serverStatus(Int)
    var errorDescription: String? {
        switch self { case .invalidURL: return "Pair URL non valido"; case .invalidResponse: return "Risposta non valida"; case .serverStatus(let status): return "Errore HTTP \(status)" }
    }
}

final class MobileBridgeApiClient {
    func fetchPairPayload(from urlString: String) async throws -> PairPayload {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else { throw MobileBridgeApiError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw MobileBridgeApiError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw MobileBridgeApiError.serverStatus(http.statusCode) }
        return try JSONDecoder().decode(PairPayload.self, from: data)
    }
}

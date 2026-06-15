import Foundation

struct PairingPayload: Codable {
    let storeTitle: String
    let shopUrl: String
    let apiUrl: String
    let email: String
    let qrToken: String
    let shopId: Int

    enum CodingKeys: String, CodingKey {
        case storeTitle = "store_title"
        case shopUrl = "shop_url"
        case apiUrl = "api_url"
        case email
        case qrToken = "qr_token"
        case shopId = "shop_id"
    }
}

struct LoginResult: Codable {
    let sessionToken: String
    let expiresAt: String
    let userEmail: String
    let deviceName: String

    enum CodingKeys: String, CodingKey {
        case sessionToken
        case expiresAt
        case userEmail
        case deviceName
    }
}

struct StoreStats: Codable {
    let period: String
    let dateFrom: String
    let dateTo: String
    let days: Int
    let salesTotal: Double
    let ordersCount: Int
    let customersCount: Int
    let productsSoldQty: Int
    let avgOrderValue: Double

    enum CodingKeys: String, CodingKey {
        case period
        case dateFrom
        case dateTo
        case days
        case salesTotal
        case ordersCount
        case customersCount
        case productsSoldQty
        case avgOrderValue
    }
}

struct MobileBridgeSession: Codable {
    var storeTitle: String
    var shopUrl: String
    var apiUrl: String
    var email: String
    var sessionToken: String
    var expiresAt: String
    var deviceUuid: String
    var deviceName: String
}

private struct PairingEnvelope: Decodable {
    let ok: Bool
    let pairing: PairingPayload
    let error: String?
}

private struct LoginEnvelope: Decodable {
    let ok: Bool
    let sessionToken: String?
    let expiresAt: String?
    let user: UserEnvelope?
    let device: DeviceEnvelope?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case ok
        case sessionToken = "session_token"
        case expiresAt = "expires_at"
        case user
        case device
        case error
    }
}

private struct UserEnvelope: Decodable {
    let id: Int?
    let email: String?
}

private struct DeviceEnvelope: Decodable {
    let id: Int?
    let uuid: String?
    let name: String?
}

private struct StatsEnvelope: Decodable {
    let ok: Bool
    let stats: StatsPayload?
    let error: String?
}

private struct StatsPayload: Decodable {
    let period: String?
    let dateFrom: String?
    let dateTo: String?
    let days: Int?
    let salesTotal: Double?
    let ordersCount: Int?
    let customersCount: Int?
    let productsSoldQty: Int?
    let avgOrderValue: Double?

    enum CodingKeys: String, CodingKey {
        case period
        case dateFrom = "date_from"
        case dateTo = "date_to"
        case days
        case salesTotal = "sales_total"
        case ordersCount = "orders_count"
        case customersCount = "customers_count"
        case productsSoldQty = "products_sold_qty"
        case avgOrderValue = "avg_order_value"
    }
}

enum MobileBridgeApiError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverStatus(Int)
    case moduleError(String)
    case missingData(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL non valido"
        case .invalidResponse:
            return "Risposta non valida dal modulo"
        case .serverStatus(let status):
            return "Errore HTTP \(status)"
        case .moduleError(let message):
            return message
        case .missingData(let message):
            return message
        }
    }
}

final class MobileBridgeApiClient {
    func fetchPairing(from pairUrl: String) async throws -> PairingPayload {
        let data = try await getData(from: pairUrl)
        let envelope = try JSONDecoder().decode(PairingEnvelope.self, from: data)

        guard envelope.ok else {
            throw MobileBridgeApiError.moduleError(envelope.error ?? "Pairing non accettato dal modulo")
        }

        return envelope.pairing
    }

    func login(pairing: PairingPayload, deviceUuid: String, deviceName: String) async throws -> LoginResult {
        let url = try buildUrl(
            base: pairing.apiUrl,
            parameters: [
                "call_function": "login",
                "mode": "qr",
                "pair_token": pairing.qrToken,
                "device_uuid": deviceUuid,
                "device_name": deviceName,
                "platform": "ios",
                "app_version": "0.2"
            ]
        )

        let data = try await getData(from: url.absoluteString)
        let envelope = try JSONDecoder().decode(LoginEnvelope.self, from: data)

        guard envelope.ok else {
            throw MobileBridgeApiError.moduleError(envelope.error ?? "Login non accettato dal modulo")
        }

        guard let token = envelope.sessionToken, !token.isEmpty else {
            throw MobileBridgeApiError.missingData("Il modulo non ha restituito il token sessione")
        }

        return LoginResult(
            sessionToken: token,
            expiresAt: envelope.expiresAt ?? "",
            userEmail: envelope.user?.email ?? pairing.email,
            deviceName: envelope.device?.name ?? deviceName
        )
    }

    func getStoreStats(apiUrl: String, sessionToken: String, period: String = "today") async throws -> StoreStats {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "get_store_stats",
                "session_token": sessionToken,
                "period": period
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let envelope = try JSONDecoder().decode(StatsEnvelope.self, from: data)

        guard envelope.ok else {
            throw MobileBridgeApiError.moduleError(envelope.error ?? "Statistiche non disponibili")
        }

        guard let stats = envelope.stats else {
            throw MobileBridgeApiError.missingData("Il modulo non ha restituito le statistiche")
        }

        return StoreStats(
            period: stats.period ?? period,
            dateFrom: stats.dateFrom ?? "",
            dateTo: stats.dateTo ?? "",
            days: stats.days ?? 0,
            salesTotal: stats.salesTotal ?? 0,
            ordersCount: stats.ordersCount ?? 0,
            customersCount: stats.customersCount ?? 0,
            productsSoldQty: stats.productsSoldQty ?? 0,
            avgOrderValue: stats.avgOrderValue ?? 0
        )
    }

    private func getData(from urlString: String, sessionToken: String? = nil) async throws -> Data {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MobileBridgeApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let sessionToken, !sessionToken.isEmpty {
            request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
            request.setValue(sessionToken, forHTTPHeaderField: "X-MobileBridge-Token")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw MobileBridgeApiError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw MobileBridgeApiError.serverStatus(http.statusCode)
        }

        return data
    }

    private func buildUrl(base: String, parameters: [String: String]) throws -> URL {
        guard var components = URLComponents(string: base) else {
            throw MobileBridgeApiError.invalidURL
        }

        var queryItems = components.queryItems ?? []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw MobileBridgeApiError.invalidURL
        }

        return url
    }
}

final class SessionStore {
    private let key = "mobilebridge_ios_session_v0_2"

    func load() -> MobileBridgeSession? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(MobileBridgeSession.self, from: data)
    }

    func save(_ session: MobileBridgeSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    func getOrCreateDeviceUuid() -> String {
        let uuidKey = "mobilebridge_ios_device_uuid"
        if let existing = UserDefaults.standard.string(forKey: uuidKey), !existing.isEmpty {
            return existing
        }
        let uuid = UUID().uuidString.lowercased()
        UserDefaults.standard.set(uuid, forKey: uuidKey)
        return uuid
    }
}

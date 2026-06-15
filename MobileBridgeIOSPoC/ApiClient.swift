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

struct CustomerSummary: Identifiable {
    let idCustomer: Int
    let firstname: String
    let lastname: String
    let fullName: String
    let email: String

    var id: Int { idCustomer }

    var displayName: String {
        if !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fullName
        }
        let joined = "\(firstname) \(lastname)".trimmingCharacters(in: .whitespacesAndNewlines)
        return joined.isEmpty ? "Cliente" : joined
    }
}

struct OrderSummary: Identifiable {
    let idOrder: Int
    let reference: String
    let dateAdd: String
    let payment: String
    let module: String
    let totalPaidTaxIncl: Double
    let totalShippingTaxIncl: Double
    let currentState: Int
    let currentStateName: String
    let currencyIso: String
    let customer: CustomerSummary

    var id: Int { idOrder }
}

struct OrderTotals {
    let productsTaxIncl: Double
    let productsTaxExcl: Double
    let shippingTaxIncl: Double
    let shippingTaxExcl: Double
    let paidTaxIncl: Double
    let paidTaxExcl: Double
}

struct OrderAddress {
    let fullName: String
    let company: String
    let address1: String
    let address2: String
    let postcode: String
    let city: String
    let stateName: String
    let countryName: String
    let phone: String
    let phoneMobile: String

    static let empty = OrderAddress(
        fullName: "",
        company: "",
        address1: "",
        address2: "",
        postcode: "",
        city: "",
        stateName: "",
        countryName: "",
        phone: "",
        phoneMobile: ""
    )

    var displayLines: [String] {
        [
            fullName,
            company,
            address1,
            address2,
            "\(postcode) \(city)".trimmingCharacters(in: .whitespacesAndNewlines),
            stateName,
            countryName,
            phone,
            phoneMobile
        ].filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}

struct OrderLine: Identifiable {
    let rowId = UUID()
    let productId: Int
    let productAttributeId: Int
    let productName: String
    let productReference: String
    let productSupplierReference: String
    let productEan13: String
    let productQuantity: Int
    let unitPriceTaxIncl: Double
    let totalPriceTaxIncl: Double

    var id: UUID { rowId }
}

struct OrderHistoryEntry: Identifiable {
    let rowId = UUID()
    let dateAdd: String
    let idOrderState: Int
    let stateName: String

    var id: UUID { rowId }
}

struct OrderStatus: Identifiable {
    let idOrderState: Int
    let name: String

    var id: Int { idOrderState }
}

struct CarrierSummary: Identifiable {
    let idCarrier: Int
    let name: String

    var id: Int { idCarrier }
}

struct OrderInfo: Identifiable {
    let idOrder: Int
    let reference: String
    let dateAdd: String
    let payment: String
    let module: String
    let currentState: Int
    let currentStateName: String
    let currencyIso: String
    let idCarrier: Int
    let idOrderCarrier: Int
    let carrierName: String
    let trackingNumber: String
    let totals: OrderTotals
    let customer: CustomerSummary
    let invoiceAddress: OrderAddress
    let deliveryAddress: OrderAddress
    let items: [OrderLine]
    let history: [OrderHistoryEntry]

    var id: Int { idOrder }
}

struct CustomerListItem: Identifiable {
    let idCustomer: Int
    let firstname: String
    let lastname: String
    let fullName: String
    let email: String
    let phone: String
    let active: Bool
    let newsletter: Bool
    let dateAdd: String
    let dateUpd: String
    let ordersCount: Int
    let totalPaidTaxIncl: Double
    let lastOrderDate: String

    var id: Int { idCustomer }

    var displayName: String {
        if !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fullName
        }
        let joined = "\(firstname) \(lastname)".trimmingCharacters(in: .whitespacesAndNewlines)
        return joined.isEmpty ? "Cliente" : joined
    }
}

struct ProductSummary: Identifiable {
    let idProduct: Int
    let name: String
    let reference: String
    let supplierReference: String
    let ean13: String
    let upc: String
    let priceTaxExcl: Double
    let priceTaxIncl: Double
    let quantity: Int
    let active: Bool
    let manufacturerName: String
    let imageUrl: String
    let hasCombinations: Bool
    let combinationsCount: Int

    var id: Int { idProduct }
}

struct ProductCombination: Identifiable {
    let idProductAttribute: Int
    let name: String
    let reference: String
    let supplierReference: String
    let ean13: String
    let upc: String
    let priceImpact: Double
    let priceTaxIncl: Double
    let quantity: Int

    var id: Int { idProductAttribute }
}

struct ProductDetail: Identifiable {
    let idProduct: Int
    let name: String
    let descriptionShort: String
    let reference: String
    let supplierReference: String
    let ean13: String
    let upc: String
    let priceTaxExcl: Double
    let priceTaxIncl: Double
    let quantity: Int
    let active: Bool
    let manufacturerName: String
    let imageUrl: String
    let hasCombinations: Bool
    let defaultAttributeId: Int
    let combinations: [ProductCombination]

    var id: Int { idProduct }
}

struct ProductUpdateResult {
    let updatedFields: [String]
    let product: ProductDetail
}

struct LiveCartSummary: Identifiable {
    let idCart: Int
    let idCustomer: Int
    let idGuest: Int
    let customerName: String
    let email: String
    let productsCount: Int
    let productsQty: Int
    let totalTaxIncl: Double
    let currencyIso: String
    let dateAdd: String
    let dateUpd: String
    let isOnline: Bool

    var id: Int { idCart }
}

struct LiveActivityResponse {
    let onlineUsersCount: Int
    let onlineCustomersCount: Int
    let onlineGuestsCount: Int
    let activeCartsCount: Int
    let minutes: Int
    let cartHours: Int
    let carts: [LiveCartSummary]
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
                "app_version": "0.3"
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

    func getOrders(apiUrl: String, sessionToken: String, limit: Int = 30) async throws -> [OrderSummary] {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "get_orders",
                "session_token": sessionToken,
                "limit": "\(limit)"
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Ordini non disponibili")

        let orders = arrayValue(json["orders"])
        return orders.map { parseOrderSummary($0) }
    }

    func getOrderInfo(apiUrl: String, sessionToken: String, orderId: Int) async throws -> OrderInfo {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "get_orders_info",
                "session_token": sessionToken,
                "id_order": "\(orderId)"
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Dettaglio ordine non disponibile")

        let order = dictValue(json["order"])
        if order.isEmpty {
            throw MobileBridgeApiError.missingData("Il modulo non ha restituito il dettaglio ordine")
        }

        return parseOrderInfo(order)
    }

    func getOrderStatuses(apiUrl: String, sessionToken: String) async throws -> [OrderStatus] {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "get_orders_statuses",
                "session_token": sessionToken
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Stati ordine non disponibili")

        return arrayValue(json["statuses"]).map { status in
            OrderStatus(
                idOrderState: intValue(status["id_order_state"]),
                name: stringValue(status["name"])
            )
        }
    }

    func updateOrderState(apiUrl: String, sessionToken: String, orderId: Int, stateId: Int) async throws -> OrderInfo {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "update_order_state",
                "session_token": sessionToken,
                "id_order": "\(orderId)",
                "id_order_state": "\(stateId)"
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Cambio stato non riuscito")

        let order = dictValue(json["order"])
        if order.isEmpty {
            throw MobileBridgeApiError.missingData("Il modulo non ha restituito il dettaglio aggiornato")
        }

        return parseOrderInfo(order)
    }

    func getCarriers(apiUrl: String, sessionToken: String) async throws -> [CarrierSummary] {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "get_carriers",
                "session_token": sessionToken
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Corrieri non disponibili")

        return arrayValue(json["carriers"]).map { parseCarrier($0) }
    }

    func updateOrderTracking(apiUrl: String, sessionToken: String, orderId: Int, carrierId: Int, trackingNumber: String) async throws -> OrderInfo {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "update_order_tracking",
                "session_token": sessionToken,
                "id_order": "\(orderId)",
                "id_carrier": "\(carrierId)",
                "tracking_number": trackingNumber
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Salvataggio tracking non riuscito")

        let order = dictValue(json["order"])
        if order.isEmpty {
            throw MobileBridgeApiError.missingData("Il modulo non ha restituito il dettaglio aggiornato")
        }

        return parseOrderInfo(order)
    }

    func getCustomers(apiUrl: String, sessionToken: String, limit: Int = 50, offset: Int = 0, search: String = "") async throws -> [CustomerListItem] {
        var parameters: [String: String] = [
            "call_function": "get_customers",
            "session_token": sessionToken,
            "limit": "\(limit)",
            "offset": "\(offset)"
        ]
        if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters["search"] = search
        }

        let url = try buildUrl(base: apiUrl, parameters: parameters)
        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Clienti non disponibili")

        return arrayValue(json["customers"]).map { parseCustomerListItem($0) }
    }

    func getProducts(apiUrl: String, sessionToken: String, limit: Int = 50, offset: Int = 0, search: String = "") async throws -> [ProductSummary] {
        var parameters: [String: String] = [
            "call_function": "get_products",
            "session_token": sessionToken,
            "limit": "\(limit)",
            "offset": "\(offset)"
        ]
        if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters["search"] = search
        }

        let url = try buildUrl(base: apiUrl, parameters: parameters)
        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Prodotti non disponibili")

        return arrayValue(json["products"]).map { parseProductSummary($0) }
    }

    func getProductInfo(apiUrl: String, sessionToken: String, productId: Int) async throws -> ProductDetail {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "get_product_info",
                "session_token": sessionToken,
                "id_product": "\(productId)"
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Dettaglio prodotto non disponibile")

        let product = dictValue(json["product"])
        if product.isEmpty {
            throw MobileBridgeApiError.missingData("Il modulo non ha restituito il dettaglio prodotto")
        }

        return parseProductDetail(product)
    }

    func updateProduct(
        apiUrl: String,
        sessionToken: String,
        productId: Int,
        productAttributeId: Int,
        priceTaxIncl: String,
        quantity: String,
        active: Bool?
    ) async throws -> ProductUpdateResult {
        var parameters: [String: String] = [
            "call_function": "update_product",
            "session_token": sessionToken,
            "id_product": "\(productId)",
            "id_product_attribute": "\(productAttributeId)"
        ]

        if !priceTaxIncl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters["price_tax_incl"] = priceTaxIncl
        }

        if !quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters["quantity"] = quantity
        }

        if let active {
            parameters["active"] = active ? "1" : "0"
        }

        let url = try buildUrl(base: apiUrl, parameters: parameters)
        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Salvataggio prodotto non riuscito")

        let product = dictValue(json["product"])
        if product.isEmpty {
            throw MobileBridgeApiError.missingData("Il modulo non ha restituito il prodotto aggiornato")
        }

        let fields: [String]
        if let array = json["updated_fields"] as? [String] {
            fields = array
        } else if let anyArray = json["updated_fields"] as? [Any] {
            fields = anyArray.compactMap { $0 as? String }
        } else {
            fields = []
        }

        return ProductUpdateResult(
            updatedFields: fields,
            product: parseProductDetail(product)
        )
    }

    func getLiveActivity(apiUrl: String, sessionToken: String) async throws -> LiveActivityResponse {
        let url = try buildUrl(
            base: apiUrl,
            parameters: [
                "call_function": "get_live_activity",
                "session_token": sessionToken
            ]
        )

        let data = try await getData(from: url.absoluteString, sessionToken: sessionToken)
        let json = try parseJsonDictionary(data)
        try ensureOk(json, defaultMessage: "Online e carrelli non disponibili")

        let activity = dictValue(json["activity"])
        let carts = arrayValue(activity["carts"]).map { parseLiveCart($0) }

        return LiveActivityResponse(
            onlineUsersCount: intValue(activity["online_users_count"]),
            onlineCustomersCount: intValue(activity["online_customers_count"]),
            onlineGuestsCount: intValue(activity["online_guests_count"]),
            activeCartsCount: intValue(activity["active_carts_count"]),
            minutes: intValue(activity["minutes"], defaultValue: 15),
            cartHours: intValue(activity["cart_hours"], defaultValue: 48),
            carts: carts
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

    private func parseJsonDictionary(_ data: Data) throws -> [String: Any] {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = json as? [String: Any] else {
            throw MobileBridgeApiError.invalidResponse
        }
        return dict
    }

    private func ensureOk(_ json: [String: Any], defaultMessage: String) throws {
        guard boolValue(json["ok"]) else {
            throw MobileBridgeApiError.moduleError(stringValue(json["error"], defaultValue: defaultMessage))
        }
    }

    private func parseOrderSummary(_ dict: [String: Any]) -> OrderSummary {
        OrderSummary(
            idOrder: intValue(dict["id_order"]),
            reference: stringValue(dict["reference"]),
            dateAdd: stringValue(dict["date_add"]),
            payment: stringValue(dict["payment"]),
            module: stringValue(dict["module"]),
            totalPaidTaxIncl: doubleValue(dict["total_paid_tax_incl"]),
            totalShippingTaxIncl: doubleValue(dict["total_shipping_tax_incl"]),
            currentState: intValue(dict["current_state"]),
            currentStateName: stringValue(dict["current_state_name"]),
            currencyIso: stringValue(dict["currency_iso"], defaultValue: "EUR"),
            customer: parseCustomer(dictValue(dict["customer"]))
        )
    }

    private func parseOrderInfo(_ dict: [String: Any]) -> OrderInfo {
        let totals = dictValue(dict["totals"])
        let addresses = dictValue(dict["addresses"])

        return OrderInfo(
            idOrder: intValue(dict["id_order"]),
            reference: stringValue(dict["reference"]),
            dateAdd: stringValue(dict["date_add"]),
            payment: stringValue(dict["payment"]),
            module: stringValue(dict["module"]),
            currentState: intValue(dict["current_state"]),
            currentStateName: stringValue(dict["current_state_name"]),
            currencyIso: stringValue(dict["currency_iso"], defaultValue: "EUR"),
            idCarrier: intValue(dict["id_carrier"]),
            idOrderCarrier: intValue(dict["id_order_carrier"]),
            carrierName: stringValue(dict["carrier_name"]),
            trackingNumber: stringValue(dict["tracking_number"]),
            totals: OrderTotals(
                productsTaxIncl: doubleValue(totals["products_tax_incl"]),
                productsTaxExcl: doubleValue(totals["products_tax_excl"]),
                shippingTaxIncl: doubleValue(totals["shipping_tax_incl"]),
                shippingTaxExcl: doubleValue(totals["shipping_tax_excl"]),
                paidTaxIncl: doubleValue(totals["paid_tax_incl"]),
                paidTaxExcl: doubleValue(totals["paid_tax_excl"])
            ),
            customer: parseCustomer(dictValue(dict["customer"])),
            invoiceAddress: parseAddress(dictValue(addresses["invoice"])),
            deliveryAddress: parseAddress(dictValue(addresses["delivery"])),
            items: arrayValue(dict["items"]).map { parseOrderLine($0) },
            history: arrayValue(dict["history"]).map { parseHistoryEntry($0) }
        )
    }

    private func parseCarrier(_ dict: [String: Any]) -> CarrierSummary {
        CarrierSummary(
            idCarrier: intValue(dict["id_carrier"]),
            name: stringValue(dict["name"])
        )
    }

    private func parseCustomerListItem(_ dict: [String: Any]) -> CustomerListItem {
        CustomerListItem(
            idCustomer: intValue(dict["id_customer"]),
            firstname: stringValue(dict["firstname"]),
            lastname: stringValue(dict["lastname"]),
            fullName: stringValue(dict["full_name"]),
            email: stringValue(dict["email"]),
            phone: stringValue(dict["phone"]),
            active: boolValue(dict["active"]),
            newsletter: boolValue(dict["newsletter"]),
            dateAdd: stringValue(dict["date_add"]),
            dateUpd: stringValue(dict["date_upd"]),
            ordersCount: intValue(dict["orders_count"]),
            totalPaidTaxIncl: doubleValue(dict["total_paid_tax_incl"]),
            lastOrderDate: stringValue(dict["last_order_date"])
        )
    }

    private func parseProductSummary(_ dict: [String: Any]) -> ProductSummary {
        ProductSummary(
            idProduct: intValue(dict["id_product"]),
            name: stringValue(dict["name"]),
            reference: stringValue(dict["reference"]),
            supplierReference: stringValue(dict["supplier_reference"]),
            ean13: stringValue(dict["ean13"]),
            upc: stringValue(dict["upc"]),
            priceTaxExcl: doubleValue(dict["price_tax_excl"]),
            priceTaxIncl: doubleValue(dict["price_tax_incl"]),
            quantity: intValue(dict["quantity"]),
            active: boolValue(dict["active"]),
            manufacturerName: stringValue(dict["manufacturer_name"]),
            imageUrl: stringValue(dict["image_url"]),
            hasCombinations: boolValue(dict["has_combinations"]),
            combinationsCount: intValue(dict["combinations_count"])
        )
    }

    private func parseProductDetail(_ dict: [String: Any]) -> ProductDetail {
        ProductDetail(
            idProduct: intValue(dict["id_product"]),
            name: stringValue(dict["name"]),
            descriptionShort: stringValue(dict["description_short"]),
            reference: stringValue(dict["reference"]),
            supplierReference: stringValue(dict["supplier_reference"]),
            ean13: stringValue(dict["ean13"]),
            upc: stringValue(dict["upc"]),
            priceTaxExcl: doubleValue(dict["price_tax_excl"]),
            priceTaxIncl: doubleValue(dict["price_tax_incl"]),
            quantity: intValue(dict["quantity"]),
            active: boolValue(dict["active"]),
            manufacturerName: stringValue(dict["manufacturer_name"]),
            imageUrl: stringValue(dict["image_url"]),
            hasCombinations: boolValue(dict["has_combinations"]),
            defaultAttributeId: intValue(dict["default_attribute_id"]),
            combinations: arrayValue(dict["combinations"]).map { parseProductCombination($0) }
        )
    }

    private func parseProductCombination(_ dict: [String: Any]) -> ProductCombination {
        ProductCombination(
            idProductAttribute: intValue(dict["id_product_attribute"]),
            name: stringValue(dict["name"]),
            reference: stringValue(dict["reference"]),
            supplierReference: stringValue(dict["supplier_reference"]),
            ean13: stringValue(dict["ean13"]),
            upc: stringValue(dict["upc"]),
            priceImpact: doubleValue(dict["price_impact"]),
            priceTaxIncl: doubleValue(dict["price_tax_incl"]),
            quantity: intValue(dict["quantity"])
        )
    }

    private func parseLiveCart(_ dict: [String: Any]) -> LiveCartSummary {
        LiveCartSummary(
            idCart: intValue(dict["id_cart"]),
            idCustomer: intValue(dict["id_customer"]),
            idGuest: intValue(dict["id_guest"]),
            customerName: stringValue(dict["customer_name"]),
            email: stringValue(dict["email"]),
            productsCount: intValue(dict["products_count"]),
            productsQty: intValue(dict["products_qty"]),
            totalTaxIncl: doubleValue(dict["total_tax_incl"]),
            currencyIso: stringValue(dict["currency_iso"], defaultValue: "EUR"),
            dateAdd: stringValue(dict["date_add"]),
            dateUpd: stringValue(dict["date_upd"]),
            isOnline: boolValue(dict["is_online"])
        )
    }

    private func parseCustomer(_ dict: [String: Any]) -> CustomerSummary {
        CustomerSummary(
            idCustomer: intValue(dict["id_customer"]),
            firstname: stringValue(dict["firstname"]),
            lastname: stringValue(dict["lastname"]),
            fullName: stringValue(dict["full_name"]),
            email: stringValue(dict["email"])
        )
    }

    private func parseAddress(_ dict: [String: Any]) -> OrderAddress {
        if dict.isEmpty {
            return .empty
        }

        return OrderAddress(
            fullName: stringValue(dict["full_name"]),
            company: stringValue(dict["company"]),
            address1: stringValue(dict["address1"]),
            address2: stringValue(dict["address2"]),
            postcode: stringValue(dict["postcode"]),
            city: stringValue(dict["city"]),
            stateName: stringValue(dict["state_name"]),
            countryName: stringValue(dict["country_name"]),
            phone: stringValue(dict["phone"]),
            phoneMobile: stringValue(dict["phone_mobile"])
        )
    }

    private func parseOrderLine(_ dict: [String: Any]) -> OrderLine {
        OrderLine(
            productId: intValue(dict["product_id"]),
            productAttributeId: intValue(dict["product_attribute_id"]),
            productName: stringValue(dict["product_name"]),
            productReference: stringValue(dict["product_reference"]),
            productSupplierReference: stringValue(dict["product_supplier_reference"]),
            productEan13: stringValue(dict["product_ean13"]),
            productQuantity: intValue(dict["product_quantity"]),
            unitPriceTaxIncl: doubleValue(dict["unit_price_tax_incl"]),
            totalPriceTaxIncl: doubleValue(dict["total_price_tax_incl"])
        )
    }

    private func parseHistoryEntry(_ dict: [String: Any]) -> OrderHistoryEntry {
        OrderHistoryEntry(
            dateAdd: stringValue(dict["date_add"]),
            idOrderState: intValue(dict["id_order_state"]),
            stateName: stringValue(dict["state_name"])
        )
    }

    private func dictValue(_ value: Any?) -> [String: Any] {
        if let dict = value as? [String: Any] {
            return dict
        }
        if let dict = value as? NSDictionary {
            var result: [String: Any] = [:]
            dict.forEach { key, value in
                if let key = key as? String {
                    result[key] = value
                }
            }
            return result
        }
        return [:]
    }

    private func arrayValue(_ value: Any?) -> [[String: Any]] {
        if let array = value as? [[String: Any]] {
            return array
        }
        if let array = value as? [Any] {
            return array.compactMap { $0 as? [String: Any] }
        }
        return []
    }

    private func stringValue(_ value: Any?, defaultValue: String = "") -> String {
        if let string = value as? String {
            return string
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return defaultValue
    }

    private func intValue(_ value: Any?, defaultValue: Int = 0) -> Int {
        if let int = value as? Int {
            return int
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        if let string = value as? String, let int = Int(string) {
            return int
        }
        return defaultValue
    }

    private func doubleValue(_ value: Any?, defaultValue: Double = 0) -> Double {
        if let double = value as? Double {
            return double
        }
        if let int = value as? Int {
            return Double(int)
        }
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        if let string = value as? String {
            let normalized = string.replacingOccurrences(of: ",", with: ".")
            if let double = Double(normalized) {
                return double
            }
        }
        return defaultValue
    }

    private func boolValue(_ value: Any?) -> Bool {
        if let bool = value as? Bool {
            return bool
        }
        if let number = value as? NSNumber {
            return number.boolValue
        }
        if let string = value as? String {
            return ["1", "true", "yes", "ok"].contains(string.lowercased())
        }
        return false
    }
}

final class SessionStore {
    private let key = "mobilebridge_ios_session_v0_3"

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

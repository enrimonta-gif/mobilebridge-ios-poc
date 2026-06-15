import SwiftUI
import UIKit
import AVFoundation

private func formatCurrency(_ value: Double, currencyCode: String = "EUR") -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode.isEmpty ? "EUR" : currencyCode
    formatter.locale = Locale(identifier: "it_IT")
    return formatter.string(from: NSNumber(value: value)) ?? String(format: "€ %.2f", value)
}

struct ContentView: View {
    @StateObject private var viewModel = MobileBridgeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.screen {
                case .connect:
                    ConnectView(viewModel: viewModel)
                case .home:
                    HomeView(viewModel: viewModel)
                case .orders:
                    OrdersView(viewModel: viewModel)
                case .orderDetail:
                    OrderDetailView(viewModel: viewModel)
                case .customers:
                    CustomersView(viewModel: viewModel)
                case .products:
                    ProductsView(viewModel: viewModel)
                case .productDetail:
                    ProductDetailView(viewModel: viewModel)
                case .liveActivity:
                    LiveActivityView(viewModel: viewModel)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.screen == .orders ||
                        viewModel.screen == .customers ||
                        viewModel.screen == .products ||
                        viewModel.screen == .liveActivity {
                        Button("Home") {
                            viewModel.goHome()
                        }
                    } else if viewModel.screen == .orderDetail {
                        Button("Ordini") {
                            viewModel.goOrders()
                        }
                    } else if viewModel.screen == .productDetail {
                        Button("Prodotti") {
                            viewModel.goProducts()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.screen != .connect {
                        Button("Esci") {
                            viewModel.logout()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.restoreSessionIfAvailable()
        }
    }
}

private struct ConnectView: View {
    @ObservedObject var viewModel: MobileBridgeViewModel

    var body: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Mobile Bridge iOS")
                    .font(.largeTitle)
                    .bold()

                Text("PoC v0.5: pairing, sessione, home, ordini, clienti, prodotti e online/carrelli.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            TextField("Pair URL", text: $viewModel.pairUrl, axis: .vertical)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .lineLimit(3...6)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Button {
                viewModel.isPairingScannerPresented = true
            } label: {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scansiona QR del modulo")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.bordered)

            Button {
                Task { await viewModel.connect() }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                    Text("Collega")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.pairUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)

            StatusBox(title: "Stato", message: viewModel.status)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $viewModel.isPairingScannerPresented) {
            BarcodeScannerView(
                guideText: "Inquadra il QR del modulo Mobile Bridge",
                onCode: { code in
                    viewModel.pairUrl = code
                    viewModel.isPairingScannerPresented = false
                    viewModel.status = "QR pairing letto. Collegamento in corso..."
                    Task { await viewModel.connect() }
                },
                onCancel: {
                    viewModel.isPairingScannerPresented = false
                }
            )
            .ignoresSafeArea()
        }
    }
}

private struct HomeView: View {
    @ObservedObject var viewModel: MobileBridgeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let session = viewModel.session {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.storeTitle)
                            .font(.title2)
                            .bold()
                        Text(session.shopUrl)
                            .foregroundStyle(.secondary)
                        Text(session.email)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if let stats = viewModel.stats {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricCard(title: "Vendite oggi", value: formatCurrency(stats.salesTotal))
                        MetricCard(title: "Ordini", value: "\(stats.ordersCount)")
                        MetricCard(title: "Clienti", value: "\(stats.customersCount)")
                        MetricCard(title: "Pezzi venduti", value: "\(stats.productsSoldQty)")
                    }

                    MetricCard(title: "Valore medio ordine", value: formatCurrency(stats.avgOrderValue))
                } else {
                    StatusBox(title: "Dashboard", message: viewModel.status)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    HomeButton(title: "Ordini", systemImage: "shippingbox") {
                        Task { await viewModel.openOrders() }
                    }
                    HomeButton(title: "Clienti", systemImage: "person.2") {
                        Task { await viewModel.openCustomers() }
                    }
                    HomeButton(title: "Prodotti", systemImage: "cube.box") {
                        Task { await viewModel.openProducts() }
                    }
                    HomeButton(title: "Online / Carrelli", systemImage: "cart") {
                        Task { await viewModel.openLiveActivity() }
                    }
                }

                StatusBox(title: "Nota", message: "Tira verso il basso per aggiornare. Questa è ancora una prova iOS, non la versione completa Android.")
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshStats()
        }
    }
}

private struct OrdersView: View {
    @ObservedObject var viewModel: MobileBridgeViewModel

    var body: some View {
        List {
            LoadingOrEmptySection(isLoading: viewModel.isLoading, isEmpty: viewModel.orders.isEmpty, emptyText: "Nessun ordine caricato.")

            ForEach(viewModel.orders) { order in
                Button {
                    Task { await viewModel.openOrderDetail(order.idOrder) }
                } label: {
                    OrderRow(order: order)
                }
                .buttonStyle(.plain)
            }
        }
        .refreshable {
            await viewModel.loadOrders(force: true)
        }
        .task {
            await viewModel.loadOrders(force: false)
        }
    }
}

private struct CustomersView: View {
    @ObservedObject var viewModel: MobileBridgeViewModel

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Cerca cliente", text: $viewModel.customerSearch)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Cerca") {
                        Task { await viewModel.loadCustomers(force: true) }
                    }
                }
            }

            LoadingOrEmptySection(isLoading: viewModel.isLoading, isEmpty: viewModel.customers.isEmpty, emptyText: "Nessun cliente caricato.")

            ForEach(viewModel.customers) { customer in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(customer.displayName)
                            .font(.headline)
                        Spacer()
                        if !customer.active {
                            Text("non attivo")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.thinMaterial)
                                .clipShape(Capsule())
                        }
                    }

                    if !customer.email.isEmpty {
                        Text(customer.email)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Ordini: \(customer.ordersCount)")
                        Spacer()
                        Text(formatCurrency(customer.totalPaidTaxIncl))
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if !customer.lastOrderDate.isEmpty {
                        Text("Ultimo ordine: \(customer.lastOrderDate)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .refreshable {
            await viewModel.loadCustomers(force: true)
        }
        .task {
            await viewModel.loadCustomers(force: false)
        }
    }
}

private struct ProductsView: View {
    @ObservedObject var viewModel: MobileBridgeViewModel

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Cerca prodotto / EAN", text: $viewModel.productSearch)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Cerca") {
                        Task { await viewModel.loadProducts(force: true) }
                    }
                }
            }

            LoadingOrEmptySection(isLoading: viewModel.isLoading, isEmpty: viewModel.products.isEmpty, emptyText: "Nessun prodotto caricato.")

            ForEach(viewModel.products) { product in
                Button {
                    Task { await viewModel.openProductDetail(product.idProduct) }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        ProductThumb(urlString: product.imageUrl)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(product.name.isEmpty ? "Prodotto" : product.name)
                                    .font(.headline)
                                    .lineLimit(2)
                                Spacer()
                                Text(formatCurrency(product.priceTaxIncl))
                                    .font(.headline)
                            }

                            if !product.reference.isEmpty {
                                Text(product.reference)
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Text("Qty \(product.quantity)")
                                Spacer()
                                Text(product.active ? "Attivo" : "Non attivo")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            if !product.ean13.isEmpty {
                                Text("EAN \(product.ean13)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
        .refreshable {
            await viewModel.loadProducts(force: true)
        }
        .task {
            await viewModel.loadProducts(force: false)
        }
    }
}


private struct ProductDetailView: View {
    @ObservedObject var viewModel: MobileBridgeViewModel

    var body: some View {
        Group {
            if let product = viewModel.selectedProductDetail {
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 14) {
                                ProductThumbLarge(urlString: product.imageUrl)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(product.name.isEmpty ? "Prodotto" : product.name)
                                        .font(.title2)
                                        .bold()

                                    if !product.reference.isEmpty {
                                        Text(product.reference)
                                            .foregroundStyle(.secondary)
                                    }

                                    if !product.manufacturerName.isEmpty {
                                        Text(product.manufacturerName)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()
                            }

                            HStack {
                                Text(product.active ? "Attivo" : "Non attivo")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.thinMaterial)
                                    .clipShape(Capsule())

                                if product.hasCombinations {
                                    Text("\(product.combinations.count) combinazioni")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.thinMaterial)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        DetailSection(title: "Modifica veloce") {
                            if product.hasCombinations && !product.combinations.isEmpty {
                                HStack {
                                    Text("Combinazione")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 110, alignment: .leading)

                                    Menu {
                                        Button("Prodotto base") {
                                            viewModel.selectProductAttribute(0)
                                        }

                                        ForEach(product.combinations) { combination in
                                            Button(combination.name.isEmpty ? "#\(combination.idProductAttribute)" : combination.name) {
                                                viewModel.selectProductAttribute(combination.idProductAttribute)
                                            }
                                        }
                                    } label: {
                                        Text(viewModel.selectedProductCombinationName())
                                            .lineLimit(1)
                                    }

                                    Spacer()
                                }
                            }

                            HStack(alignment: .center) {
                                Text("Prezzo IVA")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 110, alignment: .leading)

                                TextField("Prezzo IVA incl.", text: $viewModel.productPriceDraft)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack(alignment: .center) {
                                Text("Quantità")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 110, alignment: .leading)

                                TextField("Quantità", text: $viewModel.productQuantityDraft)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                            }

                            Toggle("Prodotto attivo", isOn: $viewModel.productActiveDraft)

                            Button {
                                Task { await viewModel.saveProduct() }
                            } label: {
                                HStack {
                                    if viewModel.isSavingProduct {
                                        ProgressView()
                                    }
                                    Text("Salva prodotto")
                                        .bold()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.isSavingProduct)
                        }

                        DetailSection(title: "Dati prodotto") {
                            DetailLine(label: "ID", value: "\(product.idProduct)")
                            DetailLine(label: "EAN", value: product.ean13)
                            DetailLine(label: "UPC", value: product.upc)
                            DetailLine(label: "Rif.", value: product.reference)
                            DetailLine(label: "Rif. forn.", value: product.supplierReference)
                            DetailLine(label: "Prezzo", value: formatCurrency(product.priceTaxIncl))
                            DetailLine(label: "Quantità", value: "\(product.quantity)")
                        }

                        if !product.descriptionShort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            DetailSection(title: "Descrizione breve") {
                                Text(product.descriptionShort)
                                    .font(.subheadline)
                            }
                        }

                        if !product.combinations.isEmpty {
                            DetailSection(title: "Combinazioni") {
                                ForEach(product.combinations) { combination in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(combination.name.isEmpty ? "#\(combination.idProductAttribute)" : combination.name)
                                                .bold()
                                            Spacer()
                                            Text("Qty \(combination.quantity)")
                                        }

                                        if !combination.reference.isEmpty {
                                            Text(combination.reference)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Text(formatCurrency(combination.priceTaxIncl))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 6)

                                    if combination.id != product.combinations.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.reloadSelectedProduct()
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(viewModel.status)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct ProductThumbLarge: View {
    let urlString: String

    var body: some View {
        if !urlString.isEmpty, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            Image(systemName: "cube.box")
                .font(.largeTitle)
                .frame(width: 96, height: 96)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}


private struct LiveActivityView: View {
    @ObservedObject var viewModel: MobileBridgeViewModel

    var body: some View {
        List {
            if let activity = viewModel.liveActivity {
                Section("Online ultimi \(activity.minutes) minuti") {
                    HStack {
                        Text("Utenti online")
                        Spacer()
                        Text("\(activity.onlineUsersCount)")
                            .bold()
                    }
                    HStack {
                        Text("Clienti")
                        Spacer()
                        Text("\(activity.onlineCustomersCount)")
                    }
                    HStack {
                        Text("Ospiti")
                        Spacer()
                        Text("\(activity.onlineGuestsCount)")
                    }
                    HStack {
                        Text("Carrelli aperti")
                        Spacer()
                        Text("\(activity.activeCartsCount)")
                            .bold()
                    }
                }

                Section("Carrelli ultime \(activity.cartHours) ore") {
                    if activity.carts.isEmpty {
                        Text("Nessun carrello recente.")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(activity.carts) { cart in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(cart.customerName.isEmpty ? "Ospite" : cart.customerName)
                                    .font(.headline)
                                Spacer()
                                if cart.isOnline {
                                    Text("online")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.thinMaterial)
                                        .clipShape(Capsule())
                                }
                            }

                            if !cart.email.isEmpty {
                                Text(cart.email)
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Text("Carrello #\(cart.idCart)")
                                Spacer()
                                Text(formatCurrency(cart.totalTaxIncl, currencyCode: cart.currencyIso))
                                    .bold()
                            }

                            Text("\(cart.productsQty) pezzi · \(cart.productsCount) prodotti · aggiornato \(cart.dateUpd)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            } else {
                LoadingOrEmptySection(isLoading: viewModel.isLoading, isEmpty: true, emptyText: "Nessun dato online/carrelli caricato.")
            }
        }
        .refreshable {
            await viewModel.loadLiveActivity(force: true)
        }
        .task {
            await viewModel.loadLiveActivity(force: false)
        }
    }
}

private struct OrderRow: View {
    let order: OrderSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("#\(order.idOrder)")
                    .font(.headline)
                Text(order.reference)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formatCurrency(order.totalPaidTaxIncl, currencyCode: order.currencyIso))
                    .font(.headline)
            }

            Text(order.customer.displayName)
                .font(.subheadline)

            HStack {
                Text(order.currentStateName.isEmpty ? "Stato non disponibile" : order.currentStateName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())

                Spacer()

                Text(order.dateAdd)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct OrderDetailView: View {
    @ObservedObject var viewModel: MobileBridgeViewModel

    var body: some View {
        Group {
            if let order = viewModel.selectedOrderInfo {
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Ordine #\(order.idOrder)")
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                Text(formatCurrency(order.totals.paidTaxIncl, currencyCode: order.currencyIso))
                                    .font(.title2)
                                    .bold()
                            }

                            Text(order.reference)
                                .foregroundStyle(.secondary)

                            Text(order.currentStateName.isEmpty ? "Stato non disponibile" : order.currentStateName)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        DetailSection(title: "Stato ordine") {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(order.currentStateName.isEmpty ? "Stato non disponibile" : order.currentStateName)
                                        .font(.headline)
                                    Text("Stato attuale")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if viewModel.orderStatuses.isEmpty {
                                    Button("Carica stati") {
                                        Task { await viewModel.loadOrderStatusesIfNeeded() }
                                    }
                                } else {
                                    Menu {
                                        ForEach(viewModel.orderStatuses) { status in
                                            Button(status.name) {
                                                Task { await viewModel.changeSelectedOrderStatus(status.idOrderState) }
                                            }
                                            .disabled(status.idOrderState == order.currentState)
                                        }
                                    } label: {
                                        Text(viewModel.isUpdatingOrderState ? "Aggiorno..." : "Cambia")
                                    }
                                    .disabled(viewModel.isUpdatingOrderState)
                                }
                            }

                            if viewModel.isUpdatingOrderState {
                                ProgressView()
                            }
                        }

                        DetailSection(title: "Cliente") {
                            DetailLine(label: "Nome", value: order.customer.displayName)
                            DetailLine(label: "Email", value: order.customer.email)
                        }

                        DetailSection(title: "Tracciabilità") {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Corriere")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 90, alignment: .leading)

                                    if viewModel.carriers.isEmpty {
                                        Button(order.carrierName.isEmpty ? "Carica corrieri" : order.carrierName) {
                                            Task { await viewModel.loadCarriersIfNeeded() }
                                        }
                                    } else {
                                        Menu {
                                            ForEach(viewModel.carriers) { carrier in
                                                Button(carrier.name) {
                                                    viewModel.selectedCarrierId = carrier.idCarrier
                                                }
                                            }
                                        } label: {
                                            Text(viewModel.selectedCarrierName(fallback: order.carrierName))
                                        }
                                    }

                                    Spacer()
                                }

                                HStack(alignment: .center) {
                                    Text("Tracking")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 90, alignment: .leading)

                                    TextField("Numero tracking", text: $viewModel.trackingDraft)
                                        .textInputAutocapitalization(.characters)
                                        .autocorrectionDisabled()
                                        .textFieldStyle(.roundedBorder)
                                }

                                Button {
                                    viewModel.isTrackingScannerPresented = true
                                } label: {
                                    HStack {
                                        Image(systemName: "barcode.viewfinder")
                                        Text("Scansiona barcode tracking")
                                            .bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)

                                Button {
                                    Task { await viewModel.saveTracking() }
                                } label: {
                                    HStack {
                                        if viewModel.isSavingTracking {
                                            ProgressView()
                                        }
                                        Text("Salva corriere/tracking")
                                            .bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(viewModel.isSavingTracking)
                            }
                        }

                        DetailSection(title: "Totali") {
                            DetailLine(label: "Prodotti", value: formatCurrency(order.totals.productsTaxIncl, currencyCode: order.currencyIso))
                            DetailLine(label: "Spedizione", value: formatCurrency(order.totals.shippingTaxIncl, currencyCode: order.currencyIso))
                            DetailLine(label: "Pagato", value: formatCurrency(order.totals.paidTaxIncl, currencyCode: order.currencyIso))
                        }

                        DetailSection(title: "Indirizzo consegna") {
                            AddressLines(address: order.deliveryAddress)
                        }

                        DetailSection(title: "Prodotti") {
                            ForEach(order.items) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text("\(item.productQuantity)x")
                                            .bold()
                                        Text(item.productName)
                                        Spacer()
                                        Text(formatCurrency(item.totalPriceTaxIncl, currencyCode: order.currencyIso))
                                            .bold()
                                    }

                                    if !item.productReference.isEmpty {
                                        Text(item.productReference)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    if !item.productEan13.isEmpty {
                                        Text("EAN \(item.productEan13)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 6)

                                if item.id != order.items.last?.id {
                                    Divider()
                                }
                            }
                        }

                        DetailSection(title: "Storico stato") {
                            ForEach(order.history) { entry in
                                HStack {
                                    Text(entry.stateName)
                                    Spacer()
                                    Text(entry.dateAdd)
                                        .foregroundStyle(.secondary)
                                }
                                .font(.subheadline)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.reloadSelectedOrder()
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(viewModel.status)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            await viewModel.loadOrderStatusesIfNeeded()
            await viewModel.loadCarriersIfNeeded()
        }
        .sheet(isPresented: $viewModel.isTrackingScannerPresented) {
            BarcodeScannerView(
                guideText: "Inquadra il barcode dell’etichetta",
                onCode: { code in
                    viewModel.trackingDraft = code
                    viewModel.isTrackingScannerPresented = false
                    viewModel.status = "Barcode letto: \(code)"
                },
                onCancel: {
                    viewModel.isTrackingScannerPresented = false
                }
            )
            .ignoresSafeArea()
        }
    }
}

private struct ProductThumb: View {
    let urlString: String

    var body: some View {
        if !urlString.isEmpty, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Image(systemName: "cube.box")
                .frame(width: 56, height: 56)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

private struct HomeButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
        }
        .buttonStyle(.bordered)
    }
}

private struct LoadingOrEmptySection: View {
    let isLoading: Bool
    let isEmpty: Bool
    let emptyText: String

    var body: some View {
        if isEmpty {
            Section {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(emptyText)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct DetailLine: View {
    let label: String
    let value: String

    var body: some View {
        if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            HStack(alignment: .top) {
                Text(label)
                    .foregroundStyle(.secondary)
                    .frame(width: 90, alignment: .leading)
                Text(value)
                Spacer()
            }
        }
    }
}

private struct AddressLines: View {
    let address: OrderAddress

    var body: some View {
        if address.displayLines.isEmpty {
            Text("Non disponibile")
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(address.displayLines, id: \.self) { line in
                    Text(line)
                }
            }
        }
    }
}

private struct StatusBox: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct BarcodeScannerView: UIViewControllerRepresentable {
    let guideText: String
    let onCode: (String) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.guideText = guideText
        controller.onCode = onCode
        controller.onCancel = onCancel
        return controller
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
    }
}

final class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var guideText: String = "Inquadra il codice"
    var onCode: ((String) -> Void)?
    var onCancel: (() -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var didReadCode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureCamera()
        configureOverlay()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func configureCamera() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            showMessage("Fotocamera non disponibile")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            guard captureSession.canAddInput(videoInput) else {
                showMessage("Input fotocamera non disponibile")
                return
            }
            captureSession.addInput(videoInput)

            let metadataOutput = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(metadataOutput) else {
                showMessage("Scanner barcode non disponibile")
                return
            }
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            let supportedTypes: [AVMetadataObject.ObjectType] = [
                .ean8,
                .ean13,
                .code128,
                .code39,
                .code93,
                .upce,
                .qr,
                .pdf417
            ]
            metadataOutput.metadataObjectTypes = supportedTypes.filter { metadataOutput.availableMetadataObjectTypes.contains($0) }

            let layer = AVCaptureVideoPreviewLayer(session: captureSession)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            view.layer.insertSublayer(layer, at: 0)
            previewLayer = layer

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        } catch {
            showMessage("Errore fotocamera: \(error.localizedDescription)")
        }
    }

    private func configureOverlay() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Chiudi", for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        closeButton.layer.cornerRadius = 12
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeScanner), for: .touchUpInside)
        view.addSubview(closeButton)

        let guide = UILabel()
        guide.text = guideText
        guide.textColor = .white
        guide.textAlignment = .center
        guide.font = UIFont.preferredFont(forTextStyle: .headline)
        guide.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        guide.layer.cornerRadius = 12
        guide.clipsToBounds = true
        guide.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guide)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            guide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            guide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            guide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            guide.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func showMessage(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func closeScanner() {
        captureSession.stopRunning()
        onCancel?()
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !didReadCode else { return }

        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = object.stringValue,
            !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }

        didReadCode = true
        captureSession.stopRunning()
        onCode?(code)
    }
}


@MainActor
final class MobileBridgeViewModel: ObservableObject {
    enum Screen {
        case connect
        case home
        case orders
        case orderDetail
        case customers
        case products
        case productDetail
        case liveActivity
    }

    @Published var screen: Screen = .connect
    @Published var pairUrl: String = ""
    @Published var isPairingScannerPresented = false
    @Published var status: String = "Incolla il Pair URL del modulo e premi Collega."
    @Published var isLoading = false
    @Published var session: MobileBridgeSession?
    @Published var stats: StoreStats?
    @Published var orders: [OrderSummary] = []
    @Published var selectedOrderInfo: OrderInfo?
    @Published var orderStatuses: [OrderStatus] = []
    @Published var isUpdatingOrderState = false
    @Published var carriers: [CarrierSummary] = []
    @Published var selectedCarrierId: Int = 0
    @Published var trackingDraft: String = ""
    @Published var isSavingTracking = false
    @Published var isTrackingScannerPresented = false
    @Published var customers: [CustomerListItem] = []
    @Published var products: [ProductSummary] = []
    @Published var selectedProductDetail: ProductDetail?
    @Published var selectedProductAttributeId: Int = 0
    @Published var productPriceDraft: String = ""
    @Published var productQuantityDraft: String = ""
    @Published var productActiveDraft: Bool = true
    @Published var isSavingProduct = false
    @Published var liveActivity: LiveActivityResponse?
    @Published var customerSearch: String = ""
    @Published var productSearch: String = ""

    private let api = MobileBridgeApiClient()
    private let store = SessionStore()

    var navigationTitle: String {
        switch screen {
        case .connect:
            return "Collega shop"
        case .home:
            return "Mobile Bridge"
        case .orders:
            return "Ordini"
        case .orderDetail:
            return "Dettaglio ordine"
        case .customers:
            return "Clienti"
        case .products:
            return "Prodotti"
        case .productDetail:
            return "Dettaglio prodotto"
        case .liveActivity:
            return "Online / Carrelli"
        }
    }

    func restoreSessionIfAvailable() async {
        guard session == nil, let saved = store.load() else { return }
        session = saved
        screen = .home
        status = "Sessione recuperata."
        await refreshStats()
    }

    func connect() async {
        isLoading = true
        status = "Lettura pairing..."
        defer { isLoading = false }

        do {
            let pairing = try await api.fetchPairing(from: pairUrl)
            status = "Pairing OK. Login iOS..."

            let deviceUuid = store.getOrCreateDeviceUuid()
            let login = try await api.login(
                pairing: pairing,
                deviceUuid: deviceUuid,
                deviceName: UIDevice.current.name
            )

            let newSession = MobileBridgeSession(
                storeTitle: pairing.storeTitle,
                shopUrl: pairing.shopUrl,
                apiUrl: pairing.apiUrl,
                email: login.userEmail,
                sessionToken: login.sessionToken,
                expiresAt: login.expiresAt,
                deviceUuid: deviceUuid,
                deviceName: login.deviceName
            )

            store.save(newSession)
            session = newSession
            screen = .home
            status = "Collegato. Carico dashboard..."
            await refreshStats()
        } catch {
            status = "Errore: \(error.localizedDescription)"
        }
    }

    func refreshStats() async {
        guard let session else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            stats = try await api.getStoreStats(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                period: "today"
            )
            status = "Dashboard aggiornata."
        } catch {
            status = "Errore dashboard: \(error.localizedDescription)"
        }
    }

    func openOrders() async {
        screen = .orders
        await loadOrders(force: orders.isEmpty)
    }

    func loadOrders(force: Bool) async {
        guard let session else { return }
        if !force && !orders.isEmpty { return }

        isLoading = true
        status = "Carico ordini..."
        defer { isLoading = false }

        do {
            orders = try await api.getOrders(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                limit: 30
            )
            status = "Ordini aggiornati."
        } catch {
            status = "Errore ordini: \(error.localizedDescription)"
        }
    }

    func openOrderDetail(_ orderId: Int) async {
        guard let session else { return }
        selectedOrderInfo = nil
        screen = .orderDetail
        isLoading = true
        status = "Carico dettaglio ordine..."
        defer { isLoading = false }

        do {
            let info = try await api.getOrderInfo(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                orderId: orderId
            )
            selectedOrderInfo = info
            syncTrackingDraft(from: info)
            status = "Dettaglio ordine caricato."
        } catch {
            status = "Errore dettaglio ordine: \(error.localizedDescription)"
        }
    }

    func reloadSelectedOrder() async {
        guard let orderId = selectedOrderInfo?.idOrder else { return }
        await openOrderDetail(orderId)
    }

    func loadOrderStatusesIfNeeded() async {
        guard orderStatuses.isEmpty, let session else { return }

        do {
            orderStatuses = try await api.getOrderStatuses(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken
            )
        } catch {
            status = "Errore stati ordine: \(error.localizedDescription)"
        }
    }

    func changeSelectedOrderStatus(_ stateId: Int) async {
        guard let session, let currentOrder = selectedOrderInfo else { return }
        guard currentOrder.currentState != stateId else { return }

        isUpdatingOrderState = true
        status = "Cambio stato ordine..."
        defer { isUpdatingOrderState = false }

        do {
            let updated = try await api.updateOrderState(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                orderId: currentOrder.idOrder,
                stateId: stateId
            )

            selectedOrderInfo = updated
            syncTrackingDraft(from: updated)
            updateOrderSummaryFromInfo(updated)
            status = "Stato ordine aggiornato."
        } catch {
            status = "Errore cambio stato: \(error.localizedDescription)"
        }
    }

    func loadCarriersIfNeeded() async {
        guard carriers.isEmpty, let session else { return }

        do {
            carriers = try await api.getCarriers(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken
            )
        } catch {
            status = "Errore corrieri: \(error.localizedDescription)"
        }
    }

    func selectedCarrierName(fallback: String) -> String {
        if let carrier = carriers.first(where: { $0.idCarrier == selectedCarrierId }) {
            return carrier.name
        }

        if !fallback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fallback
        }

        return "Seleziona"
    }

    func saveTracking() async {
        guard let session, let currentOrder = selectedOrderInfo else { return }

        let carrierId = selectedCarrierId > 0 ? selectedCarrierId : currentOrder.idCarrier
        guard carrierId > 0 else {
            status = "Seleziona un corriere prima di salvare."
            return
        }

        isSavingTracking = true
        status = "Salvo tracking..."
        defer { isSavingTracking = false }

        do {
            let updated = try await api.updateOrderTracking(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                orderId: currentOrder.idOrder,
                carrierId: carrierId,
                trackingNumber: trackingDraft
            )

            selectedOrderInfo = updated
            syncTrackingDraft(from: updated)
            updateOrderSummaryFromInfo(updated)
            status = "Corriere/tracking salvati."
        } catch {
            status = "Errore tracking: \(error.localizedDescription)"
        }
    }

    private func syncTrackingDraft(from order: OrderInfo) {
        selectedCarrierId = order.idCarrier
        trackingDraft = order.trackingNumber
    }

    private func updateOrderSummaryFromInfo(_ updated: OrderInfo) {
        if let index = orders.firstIndex(where: { $0.idOrder == updated.idOrder }) {
            orders[index] = OrderSummary(
                idOrder: updated.idOrder,
                reference: updated.reference,
                dateAdd: updated.dateAdd,
                payment: updated.payment,
                module: updated.module,
                totalPaidTaxIncl: updated.totals.paidTaxIncl,
                totalShippingTaxIncl: updated.totals.shippingTaxIncl,
                currentState: updated.currentState,
                currentStateName: updated.currentStateName,
                currencyIso: updated.currencyIso,
                customer: updated.customer
            )
        }
    }

    func openCustomers() async {
        screen = .customers
        await loadCustomers(force: customers.isEmpty)
    }

    func loadCustomers(force: Bool) async {
        guard let session else { return }
        if !force && !customers.isEmpty { return }

        isLoading = true
        status = "Carico clienti..."
        defer { isLoading = false }

        do {
            customers = try await api.getCustomers(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                limit: 50,
                search: customerSearch
            )
            status = "Clienti aggiornati."
        } catch {
            status = "Errore clienti: \(error.localizedDescription)"
        }
    }

    func openProducts() async {
        screen = .products
        await loadProducts(force: products.isEmpty)
    }

    func loadProducts(force: Bool) async {
        guard let session else { return }
        if !force && !products.isEmpty { return }

        isLoading = true
        status = "Carico prodotti..."
        defer { isLoading = false }

        do {
            products = try await api.getProducts(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                limit: 50,
                search: productSearch
            )
            status = "Prodotti aggiornati."
        } catch {
            status = "Errore prodotti: \(error.localizedDescription)"
        }
    }

    func openProductDetail(_ productId: Int) async {
        guard let session else { return }

        selectedProductDetail = nil
        screen = .productDetail
        isLoading = true
        status = "Carico dettaglio prodotto..."
        defer { isLoading = false }

        do {
            let detail = try await api.getProductInfo(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                productId: productId
            )

            selectedProductDetail = detail
            syncProductDrafts(from: detail)
            status = "Dettaglio prodotto caricato."
        } catch {
            status = "Errore prodotto: \(error.localizedDescription)"
        }
    }

    func reloadSelectedProduct() async {
        guard let productId = selectedProductDetail?.idProduct else { return }
        await openProductDetail(productId)
    }

    func selectProductAttribute(_ attributeId: Int) {
        selectedProductAttributeId = attributeId
        guard let product = selectedProductDetail else { return }

        if let combination = product.combinations.first(where: { $0.idProductAttribute == attributeId }) {
            productPriceDraft = String(format: "%.2f", combination.priceTaxIncl)
            productQuantityDraft = "\(combination.quantity)"
        } else {
            productPriceDraft = String(format: "%.2f", product.priceTaxIncl)
            productQuantityDraft = "\(product.quantity)"
        }
    }

    func selectedProductCombinationName() -> String {
        guard let product = selectedProductDetail else { return "Prodotto base" }

        if selectedProductAttributeId == 0 {
            return "Prodotto base"
        }

        if let combination = product.combinations.first(where: { $0.idProductAttribute == selectedProductAttributeId }) {
            return combination.name.isEmpty ? "#\(combination.idProductAttribute)" : combination.name
        }

        return "Seleziona"
    }

    func saveProduct() async {
        guard let session, let product = selectedProductDetail else { return }

        isSavingProduct = true
        status = "Salvo prodotto..."
        defer { isSavingProduct = false }

        do {
            let result = try await api.updateProduct(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken,
                productId: product.idProduct,
                productAttributeId: selectedProductAttributeId,
                priceTaxIncl: productPriceDraft,
                quantity: productQuantityDraft,
                active: productActiveDraft
            )

            selectedProductDetail = result.product
            syncProductDrafts(from: result.product)
            updateProductSummaryFromDetail(result.product)
            status = result.updatedFields.isEmpty ? "Prodotto salvato." : "Prodotto salvato: \(result.updatedFields.joined(separator: ", "))"
        } catch {
            status = "Errore salvataggio prodotto: \(error.localizedDescription)"
        }
    }

    private func syncProductDrafts(from product: ProductDetail) {
        if product.hasCombinations && product.defaultAttributeId > 0 {
            selectedProductAttributeId = product.defaultAttributeId
        } else {
            selectedProductAttributeId = 0
        }

        if let combination = product.combinations.first(where: { $0.idProductAttribute == selectedProductAttributeId }) {
            productPriceDraft = String(format: "%.2f", combination.priceTaxIncl)
            productQuantityDraft = "\(combination.quantity)"
        } else {
            productPriceDraft = String(format: "%.2f", product.priceTaxIncl)
            productQuantityDraft = "\(product.quantity)"
        }

        productActiveDraft = product.active
    }

    private func updateProductSummaryFromDetail(_ detail: ProductDetail) {
        if let index = products.firstIndex(where: { $0.idProduct == detail.idProduct }) {
            products[index] = ProductSummary(
                idProduct: detail.idProduct,
                name: detail.name,
                reference: detail.reference,
                supplierReference: detail.supplierReference,
                ean13: detail.ean13,
                upc: detail.upc,
                priceTaxExcl: detail.priceTaxExcl,
                priceTaxIncl: detail.priceTaxIncl,
                quantity: detail.quantity,
                active: detail.active,
                manufacturerName: detail.manufacturerName,
                imageUrl: detail.imageUrl,
                hasCombinations: detail.hasCombinations,
                combinationsCount: detail.combinations.count
            )
        }
    }

    func openLiveActivity() async {
        screen = .liveActivity
        await loadLiveActivity(force: liveActivity == nil)
    }

    func loadLiveActivity(force: Bool) async {
        guard let session else { return }
        if !force && liveActivity != nil { return }

        isLoading = true
        status = "Carico online/carrelli..."
        defer { isLoading = false }

        do {
            liveActivity = try await api.getLiveActivity(
                apiUrl: session.apiUrl,
                sessionToken: session.sessionToken
            )
            status = "Online/carrelli aggiornati."
        } catch {
            status = "Errore online/carrelli: \(error.localizedDescription)"
        }
    }

    func goHome() {
        screen = .home
    }

    func goOrders() {
        screen = .orders
    }

    func goProducts() {
        screen = .products
    }

    func logout() {
        store.clear()
        session = nil
        stats = nil
        orders = []
        selectedOrderInfo = nil
        orderStatuses = []
        carriers = []
        selectedCarrierId = 0
        trackingDraft = ""
        isTrackingScannerPresented = false
        customers = []
        products = []
        selectedProductDetail = nil
        selectedProductAttributeId = 0
        productPriceDraft = ""
        productQuantityDraft = ""
        productActiveDraft = true
        liveActivity = nil
        isPairingScannerPresented = false
        screen = .connect
        status = "Sessione rimossa. Incolla un nuovo Pair URL."
    }
}

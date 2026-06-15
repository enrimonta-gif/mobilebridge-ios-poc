import SwiftUI
import UIKit

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
                }
            }
            .navigationTitle(viewModel.screen == .connect ? "Collega shop" : "Mobile Bridge")
            .toolbar {
                if viewModel.screen == .home {
                    ToolbarItem(placement: .navigationBarTrailing) {
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

                Text("PoC v0.2: incolla il Pair URL del modulo PrestaShop. L'app legge il pairing, fa login QR e salva la sessione.")
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

                Button {
                    Task { await viewModel.refreshStats() }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                        }
                        Text("Aggiorna dati")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading)
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshStats()
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "€ %.2f", value)
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

@MainActor
final class MobileBridgeViewModel: ObservableObject {
    enum Screen {
        case connect
        case home
    }

    @Published var screen: Screen = .connect
    @Published var pairUrl: String = ""
    @Published var status: String = "Incolla il Pair URL del modulo e premi Collega."
    @Published var isLoading = false
    @Published var session: MobileBridgeSession?
    @Published var stats: StoreStats?

    private let api = MobileBridgeApiClient()
    private let store = SessionStore()

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

    func logout() {
        store.clear()
        session = nil
        stats = nil
        screen = .connect
        status = "Sessione rimossa. Incolla un nuovo Pair URL."
    }
}

import SwiftUI

struct ContentView: View {
    @State private var pairURL = ""
    @State private var status = "Proof of concept iOS"
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Mobile Bridge").font(.largeTitle).bold()
                    Text("Primo test iOS: pairing URL e chiamata base verso il modulo PrestaShop.").foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading)
                TextField("Pair URL dal modulo", text: $pairURL, axis: .vertical)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .padding().background(.thinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                Button { Task { await testConnection() } } label: {
                    HStack { if isLoading { ProgressView() }; Text("Test collegamento").bold() }
                        .frame(maxWidth: .infinity).padding()
                }.buttonStyle(.borderedProminent).disabled(pairURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                VStack(alignment: .leading, spacing: 8) { Text("Stato").font(.headline); Text(status).foregroundStyle(.secondary) }
                    .frame(maxWidth: .infinity, alignment: .leading).padding().background(.thinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                Spacer()
            }.padding().navigationTitle("Home")
        }
    }
    @MainActor private func testConnection() async {
        isLoading = true; defer { isLoading = false }
        do { let result = try await MobileBridgeApiClient().fetchPairPayload(from: pairURL); status = "Risposta modulo OK: \(result.storeTitle ?? "negozio rilevato")" }
        catch { status = "Errore test: \(error.localizedDescription)" }
    }
}

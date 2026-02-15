import SwiftUI

struct ContentView: View {
    @State private var rateText = "Tap to load rate"
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Currency Budget")
                .font(.largeTitle)
                .bold()

            Text(rateText)
                .font(.title3)
                .monospacedDigit()

            if isLoading {
                ProgressView()
            }

            Button(isLoading ? "Loading..." : "Refresh Rate") {
                Task {
                    isLoading = true
                    await loadRate()
                    isLoading = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)

            Text("Source: Frankfurter API")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .task {
            await loadRate()
        }
    }

    func loadRate() async {
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=USD&to=EUR") else {
            rateText = "Bad URL"
            return
        }

        do {
            try? await Task.sleep(nanoseconds: 700_000_000) // optional delay

            let (data, _) = try await URLSession.shared.data(from: url)

            let result = try JSONDecoder().decode(FrankfurterResponse.self, from: data)

            if let eur = result.rates["EUR"] {
                rateText = String(format: "1 USD = %.4f EUR", eur)
            } else {
                rateText = "Rate not found"
            }
        }
        catch {
            rateText = "Error loading rate"
            print("DEBUG error:", error)
        }
    }
}

struct FrankfurterResponse: Codable {
    let amount: Double?
    let base: String?
    let date: String?
    let rates: [String: Double]
}

#Preview {
    ContentView()
}

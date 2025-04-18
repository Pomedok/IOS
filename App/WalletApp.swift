import SwiftUI

@main
struct WalletApp: App {
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            if let phoneNumber = UserDefaultsManager.phoneNumber, TokenManager.isValid {
                MainView()
                    .onAppear {
                        authenticateUser(phoneNumber: phoneNumber)
                    }
            } else {
                LoginView()
            }
        }
        .overlay {
            if let error = appState.errorMessage {
                ErrorView(message: error) {
                    appState.errorMessage = nil
                    authenticateUser(phoneNumber: UserDefaultsManager.phoneNumber ?? "")
                }
            }
        }
    }
    
    private func authenticateUser(phoneNumber: String) {
        Task {
            do {
                let persons = try await APIClient().authPerson(phoneNumber: phoneNumber, token: TokenManager.token)
                guard let person = persons.first else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Персона не знайдена"])
                }
                appState.person = person
                
                let wallets = try await APIClient().getEWalletInfo(posCode: "cf0b743d84f443e4ace4c4e45b45fdbd", cardNumber: nil, token: TokenManager.token)
                appState.wallets = wallets
            } catch {
                appState.errorMessage = error.localizedDescription
            }
        }
    }
}

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var person: Person?
    @Published var wallets: [eWallet] = []
    @Published var errorMessage: String?
    
    private init() {}
    
    func reset() {
        person = nil
        wallets = []
        errorMessage = nil
    }
}

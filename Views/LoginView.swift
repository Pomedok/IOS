import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var phoneNumber = ""
    @State private var isButtonVisible = false
    @State private var isFieldVisible = false
    
    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Login.Title")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textColor)
                
                TextField("Login.PhonePlaceholder", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                    .foregroundColor(Theme.textColor)
                    .background(Theme.cardBackgroundColor)
                    .opacity(isFieldVisible ? 1 : 0)
                    .offset(y: isFieldVisible ? 0 : 20)
                
                Button(action: {
                    HapticFeedback.play(.medium)
                    handleLogin()
                }) {
                    Text("Login.Button")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryColor)
                        .cornerRadius(8)
                }
                .opacity(isButtonVisible ? 1 : 0)
                .offset(y: isButtonVisible ? 0 : 20)
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                isFieldVisible = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                isButtonVisible = true
            }
        }
    }
    
    private func handleLogin() {
        guard !phoneNumber.isEmpty else {
            appState.errorMessage = "Error.EmptyPhone"
            return
        }
        
        Task {
            do {
                let persons = try await APIClient().authPerson(phoneNumber: phoneNumber, token: TokenManager.token)
                guard let person = persons.first else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error.NoPerson"])
                }
                appState.person = person
                UserDefaultsManager.phoneNumber = phoneNumber
                
                let wallets = try await APIClient().getEWalletInfo(posCode: "cf0b743d84f443e4ace4c4e45b45fdbd", cardNumber: nil, token: TokenManager.token)
                appState.wallets = wallets
            } catch {
                appState.errorMessage = error.localizedDescription
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState.shared)
    }
}

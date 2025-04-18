import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var transactions: [Transaction] = []
    
    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(transactions, id: \.billID) { transaction in
                        HStack {
                            Text(transaction.date)
                                .font(.system(size: 16))
                                .foregroundColor(Theme.textColor)
                            Spacer()
                            Text(String(format: "%.2f", transaction.sum))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.textColor)
                        }
                        .padding()
                        .background(Theme.cardBackgroundColor)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Tab.History")
            .onAppear {
                loadTransactions()
            }
        }
    }
    
    private func loadTransactions() {
        guard let wallet = appState.wallets.first else { return }
        Task {
            do {
                let transactions = try await APIClient().getTransactions(
                    posCode: "cf0b743d84f443e4ace4c4e45b45fdbd",
                    cardID: wallet.magneticCardID,
                    token: TokenManager.token
                )
                self.transactions = transactions
            } catch {
                appState.errorMessage = error.localizedDescription
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(AppState.shared)
    }
}

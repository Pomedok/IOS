import SwiftUI
import CoreImage.CIFilterBuiltins

struct CardDetailView: View {
    let wallet: eWallet
    @State private var qrImage: Image?
    @State private var isCardVisible = false
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Text(String(format: "%.2f", wallet.paySum))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(wallet.paySum >= 0 ? .green : .red)
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(height: 200)
                .padding(.horizontal, 16)
                .scaleEffect(isCardVisible ? 1 : 0.8)
                .opacity(isCardVisible ? 1 : 0)
                
                Button(action: {
                    HapticFeedback.play(.medium)
                    generateQRCode()
                }) {
                    Text("Card.QRButton")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryColor)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                
                if let qrImage = qrImage {
                    qrImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .animation(.easeInOut(duration: 0.3), value: qrImage)
                }
                
                Spacer()
            }
        }
        .navigationTitle(wallet.userName ?? "")
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isCardVisible = true
            }
        }
    }
    
    private func generateQRCode() {
        Task {
            do {
                let code = try await APIClient().getTemporaryCode(
                    posCode: "cf0b743d84f443e4ace4c4e45b45fdbd",
                    cardID: wallet.magneticCardID,
                    token: TokenManager.token
                )
                guard let image = generateQRCodeImage(from: code.code) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error.QRGeneration"])
                }
                qrImage = Image(uiImage: image)
            } catch {
                appState.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func generateQRCodeImage(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        guard let ciImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        return UIImage(ciImage: scaledImage)
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(wallet: eWallet(
            eWalletID: 1,
            eWalletCode: "123",
            magneticCardID: 1,
            loyaltyProgramName: nil,
            userName: "Шарапов Олександр",
            mobilePhone: nil,
            discGroupID: nil,
            isBonusProgram: false,
            isDiscountProgram: false,
            bonusStatusName: nil,
            bonusBalance: 0,
            accumulatedBonuses: 0,
            discountStatusName: nil,
            discountPriceListCode: nil,
            discountTransactionsSum: 0,
            servioSynkCode: nil,
            companyAccount: nil,
            magneticCardShortNumber: nil,
            permanentComment: nil,
            magneticCardFullNumber: nil,
            bonusSum: 0,
            paySum: -100,
            credit: 0,
            accumulation: 0,
            isPayCard: false,
            extraMoneySum: 0,
            isSmartCard: false,
            shortCode: nil,
            dayLimit: 0,
            weekLimit: 0,
            monthLimit: 0,
            yearLimit: 0,
            usePayLimits: false
        ))
        .environmentObject(AppState.shared)
    }
}

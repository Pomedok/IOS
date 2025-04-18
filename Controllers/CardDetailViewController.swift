@objc func showQRCode() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
    Task {
        do {
            let code = try await APIClient().getTemporaryCode(
                posCode: "cf0b743d84f443e4ace4c4e45b45fdbd",
                cardID: wallet.magneticCardID,
                token: TokenManager.token
            )
            let qrImage = generateQRCode(from: code.code)
            qrImageView.image = qrImage
        } catch {
            showError("Ошибка генерации QR-кода", retryAction: { self.showQRCode() })
        }
    }
}

func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: .ascii)
    let filter = CIFilter(name: "CIQRCodeGenerator")
    filter?.setValue(data, forKey: "inputMessage")
    guard let ciImage = filter?.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledImage = ciImage.transformed(by: transform)
    return UIImage(ciImage: scaledImage)
}

import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Button(action: {
                    HapticFeedback.play(.light)
                    retryAction()
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                    }
                }) {
                    Text("Retry.Button")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.primaryColor)
                        .padding(.vertical, 8)
                }
            }
            .padding()
            .background(Theme.cardBackgroundColor)
            .cornerRadius(12)
            .shadow(radius: 4)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 50)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = true
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(message: "Помилка мережі", retryAction: {})
    }
}

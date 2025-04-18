import UIKit

struct HapticFeedback {
    enum Style {
        case light, medium, heavy
    }
    
    static func play(_ style: Style) {
        let generator = UIImpactFeedbackGenerator(style: {
            switch style {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            }
        }())
        generator.impactOccurred()
    }
}

import SwiftUI

struct Theme {
    static let primaryColor = Color(.systemBlue)
    static let backgroundColor = Color { colorScheme in
        colorScheme == .dark ? Color(hex: "#1C2526") : .white
    }
    static let textColor = Color { colorScheme in
        colorScheme == .dark ? .white : .black
    }
    static let secondaryTextColor = Color { colorScheme in
        colorScheme == .dark ? .gray : .gray
    }
    static let cardBackgroundColor = Color { colorScheme in
        colorScheme == .dark ? Color(hex: "#2C3E50") : Color(hex: "#F5F5F5")
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .init(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            opacity: 1
        )
    }
}

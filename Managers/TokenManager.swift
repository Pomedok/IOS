import Foundation

class TokenManager {
    static let shared = TokenManager()
    
    private var currentToken: Token?
    
    func getValidToken() async throws -> Token {
        if let token = currentToken, token.isValid {
            print("TokenManager: Используется существующий токен: \(token.token)")
            return token
        }
        
        print("TokenManager: Запрашиваем новый токен")
        let newToken = try await APIClient().authenticate(termID: "f5319bad34397", code: "09042025")
        
        if !newToken.error.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: newToken.error])
        }
        
        currentToken = newToken
        print("TokenManager: Новый токен получен: \(newToken.token)")
        return newToken
    }
}

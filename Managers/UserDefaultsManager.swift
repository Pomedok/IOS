import Foundation

class UserDefaultsManager {
    private let phoneNumberKey = "phoneNumber"
    
    func savePhoneNumber(_ phoneNumber: String) {
        UserDefaults.standard.set(phoneNumber, forKey: phoneNumberKey)
    }
    
    func getPhoneNumber() -> String? {
        return UserDefaults.standard.string(forKey: phoneNumberKey)
    }
    
    func clearPhoneNumber() {
        UserDefaults.standard.removeObject(forKey: phoneNumberKey)
    }
}

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate: Приложение запущено")
        UserDefaults.standard.removeObject(forKey: "token")
        print("AppDelegate: Токен очищен")
        return true
    }
}

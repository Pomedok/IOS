import UIKit

class MainViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cardsVC = CardsViewController()
        cardsVC.title = "Карты"
        cardsVC.tabBarItem = UITabBarItem(title: "Карты", image: UIImage(systemName: "creditcard"), tag: 0)
        
        let historyVC = HistoryViewController()
        historyVC.title = "История"
        historyVC.tabBarItem = UITabBarItem(title: "История", image: UIImage(systemName: "clock"), tag: 1)
        
        let profileVC = ProfileViewController()
        profileVC.title = "Профиль"
        profileVC.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person"), tag: 2)
        
        let settingsVC = SettingsViewController()
        settingsVC.title = "Настройки"
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 3)
        
        let controllers = [cardsVC, historyVC, profileVC, settingsVC].map { UINavigationController(rootViewController: $0) }
        self.viewControllers = controllers
        
        print("MainViewController: Таб-бар настроен с \(controllers.count) вкладками")
    }
}

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        print("SceneDelegate: Начало инициализации сцены")
        
        window = UIWindow(windowScene: windowScene)
        print("SceneDelegate: Инициализация окна")
        
        // Проверяем, сохранен ли номер телефона
        if let savedPhoneNumber = UserDefaultsManager().getPhoneNumber() {
            print("SceneDelegate: Найден сохраненный номер телефона: \(savedPhoneNumber)")
            
            Task {
                do {
                    let token = try await TokenManager.shared.getValidToken()
                    let persons = try await APIClient().authPerson(phoneNumber: savedPhoneNumber, token: token.token)
                    
                    if let person = persons.first {
                        print("SceneDelegate: Персона найдена: \(person.personID)")
                        AppState.shared.person = person
                        
                        let eWallets = try await APIClient().getEWalletInfo(posCode: AppState.shared.posCode, cardNumber: nil, token: token.token)
                        AppState.shared.eWallets = eWallets
                        print("SceneDelegate: Карты загружены: \(eWallets.count)")
                        
                        for wallet in eWallets {
                            let transactions = try await APIClient().getTransactions(posCode: AppState.shared.posCode, cardID: wallet.magneticCardID, token: token.token)
                            AppState.shared.transactions[wallet.magneticCardID] = transactions
                            
                            for transaction in transactions {
                                let billDetails = try await APIClient().getBillDetail(posCode: AppState.shared.posCode, billID: String(transaction.billID), token: token.token)
                                AppState.shared.billDetails[transaction.billID] = billDetails
                            }
                        }
                        
                        if let cardID = eWallets.first?.magneticCardID {
                            let tempCode = try await APIClient().getTemporaryCode(posCode: AppState.shared.posCode, cardID: cardID, token: token.token)
                            AppState.shared.temporaryCode = tempCode
                        }
                        
                        // Переходим к главному экрану
                        let mainVC = MainViewController()
                        window?.rootViewController = mainVC
                    } else {
                        // Показываем экран входа
                        let loginVC = LoginViewController()
                        let navController = UINavigationController(rootViewController: loginVC)
                        window?.rootViewController = navController
                        print("SceneDelegate: Пользователь не найден, показан LoginViewController")
                    }
                } catch {
                    print("SceneDelegate: Ошибка: \(error)")
                    // Показываем экран входа в случае ошибки
                    let loginVC = LoginViewController()
                    let navController = UINavigationController(rootViewController: loginVC)
                    window?.rootViewController = navController
                    print("SceneDelegate: Показан LoginViewController из-за ошибки")
                }
            }
        } else {
            // Номер телефона не сохранен, показываем экран входа
            let loginVC = LoginViewController()
            let navController = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = navController
            print("SceneDelegate: Номер телефона не сохранен, показан LoginViewController")
        }
        
        window?.makeKeyAndVisible()
    }
}

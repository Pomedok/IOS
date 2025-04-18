import UIKit

class SettingsViewController: UIViewController {
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Выйти", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.setTitleColor(.red, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func logoutTapped() {
        AppState.shared.person = nil
        AppState.shared.eWallets = []
        AppState.shared.transactions = [:]
        AppState.shared.billDetails = [:]
        AppState.shared.temporaryCode = nil
        UserDefaultsManager().clearPhoneNumber()
        
        print("SettingsViewController: Пользователь вышел")
        
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
}

import UIKit

class LoginViewController: UIViewController {
    private let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.keyboardType = .phonePad
        tf.placeholder = "Введите номер телефона (например, 0636504018)"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Войти", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Вход"
        
        print("LoginViewController: Экран загружен")
        
        setupViews()
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.addSubview(phoneTextField)
        view.addSubview(loginButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            phoneTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            phoneTextField.widthAnchor.constraint(equalToConstant: 250),
            phoneTextField.heightAnchor.constraint(equalToConstant: 40),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
        ])
    }
    
    @objc private func loginTapped() {
        guard let phoneNumber = phoneTextField.text, phoneNumber.count >= 10 else {
            showAlert(message: "Введите корректный номер телефона (например, 0636504018)")
            return
        }
        
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "+380", with: "")
        print("LoginViewController: Попытка входа с номером \(cleanedPhoneNumber)")
        
        loginButton.isEnabled = false
        activityIndicator.startAnimating()
        
        Task {
            defer {
                loginButton.isEnabled = true
                activityIndicator.stopAnimating()
            }
            
            do {
                let token = try await TokenManager.shared.getValidToken()
                let persons = try await APIClient().authPerson(phoneNumber: cleanedPhoneNumber, token: token.token)
                
                if let person = persons.first {
                    AppState.shared.person = person
                    UserDefaultsManager().savePhoneNumber(cleanedPhoneNumber)
                    
                    let eWallets = try await APIClient().getEWalletInfo(posCode: AppState.shared.posCode, cardNumber: nil, token: token.token)
                    AppState.shared.eWallets = eWallets
                    
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
                    
                    print("LoginViewController: Успешный вход, переход к MainViewController")
                    let mainVC = MainViewController()
                    navigationController?.pushViewController(mainVC, animated: true)
                } else {
                    print("LoginViewController: Пользователь не найден")
                    showAlert(message: "Пользователь не найден")
                }
            } catch {
                print("LoginViewController: Ошибка входа: \(error)")
                showAlert(message: "Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

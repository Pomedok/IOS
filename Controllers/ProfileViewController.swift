import UIKit

class ProfileViewController: UIViewController {
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let phoneLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        updateProfile()
    }
    
    private func setupViews() {
        view.addSubview(nameLabel)
        view.addSubview(phoneLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            phoneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateProfile() {
        if let person = AppState.shared.person {
            nameLabel.text = "\(person.firstName) \(person.lastName) \(person.middleName ?? "")"
            phoneLabel.text = "Телефон: \(UserDefaultsManager().getPhoneNumber() ?? "Не указан")"
            print("ProfileViewController: Профиль обновлен для PersonID: \(person.personID)")
        } else {
            nameLabel.text = "Профиль не найден"
            phoneLabel.text = ""
            print("ProfileViewController: Пользователь не найден")
        }
    }
}

import UIKit

class HistoryViewController: UIViewController {
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var transactions: [Transaction] {
        return AppState.shared.transactions.values.flatMap { $0 }.sorted { $0.date > $1.date }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        print("HistoryViewController: Загружено транзакций: \(transactions.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        let transaction = transactions[indexPath.row]
        
        let dateText = transaction.date
        let sumText = String(format: "%.2f", transaction.sum)
        cell.textLabel?.text = "Дата: \(dateText) | Сумма: \(sumText)"
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = transactions[indexPath.row]
        let billDetails = AppState.shared.billDetails[transaction.billID] ?? []
        
        let detailText = billDetails.map { "\($0.name): \($0.quantity) x \($0.price)" }.joined(separator: "\n")
        let alert = UIAlertController(title: "Детали счета", message: detailText.isEmpty ? "Нет деталей" : detailText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        print("HistoryViewController: Выбрана транзакция с BillID: \(transaction.billID)")
    }
}

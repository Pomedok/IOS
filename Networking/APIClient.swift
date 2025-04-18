import Foundation

class APIClient {
    private let baseURL = "http://servio.enjoyfb.com:32895"

    private let customDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm" // Изменяем формат
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Авторизация терминала
    func authenticate(termID: String, code: String) async throws -> Token {
        guard let url = URL(string: "\(baseURL)/POSExternal/Authenticate") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "TermID": termID,
            "Code": code
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("APIClient: HTTP Status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("APIClient: Ответ сервера: \(responseString)")
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(customDateFormatter)
            let token = try decoder.decode(Token.self, from: data)
            return token
        } else {
            throw URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"
            ])
        }
    }

    // MARK: - Авторизация персоны по номеру телефона
    func authPerson(phoneNumber: String, token: String) async throws -> [Person] {
        guard let url = URL(string: "\(baseURL)/POSExternal/AuthPerson") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "AccessToken")

        let body: [String: Any] = [
            "PhoneNumber": phoneNumber,
            "UsePassword": 0
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("APIClient: HTTP Status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("APIClient: Ответ сервера: \(responseString)")
            }

            let result = try JSONDecoder().decode(AuthPersonResponse.self, from: data)

            if !result.error.isEmpty {
                throw NSError(domain: "", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: result.error
                ])
            }

            return result.persons ?? []
        } else {
            throw URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"
            ])
        }
    }

    // MARK: - Получение информации о картах
    func getEWalletInfo(posCode: String, cardNumber: String?, token: String) async throws -> [eWallet] {
        guard let url = URL(string: "\(baseURL)/POSExternal/Get_eWallet_Info") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "AccessToken")

        var body: [String: Any] = [
            "POSCode": posCode,
            "PersonID": AppState.shared.person?.personID ?? 0
        ]
        if let cardNumber = cardNumber {
            body["CardNumber"] = cardNumber
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("APIClient: HTTP Status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("APIClient: Ответ сервера: \(responseString)")
            }

            let result = try JSONDecoder().decode(eWalletResponse.self, from: data)

            if !result.error.isEmpty {
                throw NSError(domain: "", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: result.error
                ])
            }

            return result.eWallets ?? []
        } else {
            throw URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"
            ])
        }
    }

    // MARK: - Получение транзакций
    func getTransactions(posCode: String, cardID: Int, token: String) async throws -> [Transaction] {
        guard let url = URL(string: "\(baseURL)/POSExternal/GetTransaction") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "AccessToken")

        let body: [String: Any] = [
            "POSCode": posCode,
            "CardID": cardID
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("APIClient: HTTP Status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("APIClient: Ответ сервера: \(responseString)")
            }

            let result = try JSONDecoder().decode(TransactionsResponse.self, from: data)

            if !result.error.isEmpty {
                throw NSError(domain: "", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: result.error
                ])
            }

            return result.transactions ?? []
        } else {
            throw URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"
            ])
        }
    }

    // MARK: - Получение деталей счета
    func getBillDetail(posCode: String, billID: String, token: String) async throws -> [BillItem] {
        guard let url = URL(string: "\(baseURL)/POSExternal/GetBillDetail") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "AccessToken")

        let body: [String: Any] = [
            "POSCode": posCode,
            "BillID": billID
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("APIClient: HTTP Status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("APIClient: Ответ сервера: \(responseString)")
            }

            let result = try JSONDecoder().decode(BillDetailResponse.self, from: data)

            if !result.error.isEmpty {
                throw NSError(domain: "", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: result.error
                ])
            }

            return result.billItems ?? []
        } else {
            throw URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"
            ])
        }
    }

    // MARK: - Получение временного кода (QR-кода)
    func getTemporaryCode(posCode: String, cardID: Int, token: String) async throws -> TemporaryCode {
        guard let url = URL(string: "\(baseURL)/POSExternal/GetTemporaryCode") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "AccessToken")

        let body: [String: Any] = [
            "POSCode": posCode,
            "CardID": cardID
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("APIClient: HTTP Status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("APIClient: Ответ сервера: \(responseString)")
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(customDateFormatter)
            let result = try decoder.decode(TemporaryCode.self, from: data)
            return result
        } else {
            throw URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"
            ])
        }
    }
}

// MARK: - Структуры данных для API-ответов

struct Token: Codable {
    let token: String
    let error: String
    let valid: Date

    enum CodingKeys: String, CodingKey {
        case token = "Token"
        case error = "Error"
        case valid = "Valid"
    }

    var isValid: Bool {
        return Date() < valid
    }
}

struct AuthPersonResponse: Codable {
    let error: String
    let persons: [Person]?

    enum CodingKeys: String, CodingKey {
        case error = "Error"
        case persons = "Persons"
    }
}

struct Person: Codable {
    let personID: Int
    let firstName: String
    let lastName: String
    let middleName: String?
    let birthDate: String?
    let edited: String?
    let created: String?
    let sex: Int?

    enum CodingKeys: String, CodingKey {
        case personID = "PersonID"
        case firstName = "FirstName"
        case lastName = "LastName"
        case middleName = "MiddleName"
        case birthDate = "BirthDate"
        case edited = "Edited"
        case created = "Created"
        case sex = "Sex"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let personIDString = try container.decode(String.self, forKey: .personID)
        guard let personIDInt = Int(personIDString) else {
            throw DecodingError.dataCorruptedError(forKey: .personID, in: container, debugDescription: "PersonID must be a valid integer")
        }
        self.personID = personIDInt

        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        self.birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate)
        self.edited = try container.decodeIfPresent(String.self, forKey: .edited)
        self.created = try container.decodeIfPresent(String.self, forKey: .created)
        self.sex = try container.decodeIfPresent(Int.self, forKey: .sex)
    }
}

struct eWalletResponse: Codable {
    let error: String
    let eWallets: [eWallet]?

    enum CodingKeys: String, CodingKey {
        case error = "Error" // Исправлено на "Error"
        case eWallets
    }
}

struct eWallet: Codable {
    let eWalletID: Int
    let eWalletCode: String
    let magneticCardID: Int
    let loyaltyProgramName: String?
    let userName: String?
    let mobilePhone: String?
    let discGroupID: Int?
    let isBonusProgram: Bool
    let isDiscountProgram: Bool
    let bonusStatusName: String?
    let bonusBalance: Double
    let accumulatedBonuses: Double
    let discountStatusName: String?
    let discountPriceListCode: String?
    let discountTransactionsSum: Double
    let servioSynkCode: String?
    let companyAccount: String?
    let magneticCardShortNumber: String?
    let permanentComment: String?
    let magneticCardFullNumber: String?
    let bonusSum: Double
    let paySum: Double
    let credit: Double
    let accumulation: Double
    let isPayCard: Bool
    let extraMoneySum: Double
    let isSmartCard: Bool
    let shortCode: String?
    let dayLimit: Double
    let weekLimit: Double
    let monthLimit: Double
    let yearLimit: Double
    let usePayLimits: Bool

    enum CodingKeys: String, CodingKey {
        case eWalletID = "eWalletID"
        case eWalletCode = "eWalletCode"
        case magneticCardID = "MagneticCardID"
        case loyaltyProgramName = "LoyaltyProgramName"
        case userName = "UserName"
        case mobilePhone = "MobilePhone"
        case discGroupID = "DiscountGroupID"
        case isBonusProgram = "IsBonusProgram"
        case isDiscountProgram = "IsDiscountProgram"
        case bonusStatusName = "BonusStatusName"
        case bonusBalance = "BonusBalance"
        case accumulatedBonuses = "AccumulatedBonuses"
        case discountStatusName = "DiscountStatusName"
        case discountPriceListCode = "DiscountPriceListCode"
        case discountTransactionsSum = "DiscountTransactionsSum"
        case servioSynkCode = "ServioSynkCode"
        case companyAccount = "CompanyAccount"
        case magneticCardShortNumber = "MagneticCardShortNumber"
        case permanentComment = "PermanentComment"
        case magneticCardFullNumber = "MagneticCardFullNumber"
        case bonusSum = "BonusSum"
        case paySum = "PaySum"
        case credit = "Credit"
        case accumulation = "Accumulation"
        case isPayCard = "IsPayCard"
        case extraMoneySum = "ExtraMoneySum"
        case isSmartCard = "IsSmartCard"
        case shortCode = "ShortCode"
        case dayLimit = "DayLimit"
        case weekLimit = "WeekLimit"
        case monthLimit = "MonthLimit"
        case yearLimit = "YearLimit"
        case usePayLimits = "UsePayLimits"
    }
}

struct TransactionsResponse: Codable {
    let error: String
    let transactions: [Transaction]?

    enum CodingKeys: String, CodingKey {
        case error = "Error" // Исправляем на "Error"
        case transactions = "Items" // Исправляем на "Items"
    }
}

struct Transaction: Codable {
    let billID: Int
    let date: String
    let sum: Double

    enum CodingKeys: String, CodingKey {
        case billID = "BillID"
        case date = "Date"
        case sum = "Sum"
    }
}

struct BillDetailResponse: Codable {
    let error: String
    let billItems: [BillItem]?

    enum CodingKeys: String, CodingKey {
        case error = "Error"
        case billItems = "BillItems"
    }
}

struct BillItem: Codable {
    let name: String
    let quantity: Double
    let price: Double

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case quantity = "Quantity"
        case price = "Price"
    }
}

struct TemporaryCode: Codable {
    let code: String
    let validUntil: Date

    enum CodingKeys: String, CodingKey {
        case code = "TemporaryCode"
        case validUntil = "TemporaryCodeDateTo"
    }
}

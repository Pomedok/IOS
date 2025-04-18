import Foundation

class AppState {
    static let shared = AppState()
    
    var person: Person?
    var eWallets: [eWallet] = []
    var transactions: [Int: [Transaction]] = [:] // [magneticCardID: [Transaction]]
    var billDetails: [Int: [BillItem]] = [:] // [billID: [BillItem]]
    var temporaryCode: TemporaryCode?
    
    let posCode = "cf0b743d84f443e4ace4c4e45b45fdbd"
}

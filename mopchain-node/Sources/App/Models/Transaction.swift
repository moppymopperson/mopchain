import Foundation

/**
 Represents a single transaction on the network. Transactions must be uniquely
 identifiable, so a timestamp is included to ensure that repeated transactions
 can be distinguished.
 
 Identical transactions that happened at the exact same time are not considered.
 */
struct Transaction: Codable, Equatable {
    let from: String            /// The sender
    let to: String              /// The recipient
    let amount: Double          /// The amount of the transaction
    let fee: Double             /// Some fee added to the transaction
    let type: TransactionType   /// The type of transaction made
    let timestamp: Double       /// Unix timestamp
    
    /**
     Create a new `Transaction`.
     
     Do not use this if you want to modify an existing transaction, as the time
     stamp will be wrong. Instead, use one of the `changing` methods.
     */
    init(from: String, to: String, amount:Double, fee:Double, type:TransactionType) {
        self.from = from
        self.to = to
        self.amount = amount
        self.fee = fee
        self.type = type
        self.timestamp = Date().timeIntervalSince1970
    }
    
    /** Specifies the different types of `Transaction`s. */
    enum TransactionType:String, Codable {
        case domestic
        case internation
    }
    
    /**
     Returns a new `Transaction`, identical to the old one except for an
     updated fee
     */
    func changing(fee: Double) -> Transaction {
        return Transaction(from: from, to: to, amount: amount, fee: fee, type: type)
    }
}

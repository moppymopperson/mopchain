/**
 A simple example of a smart contract that adds a feed based on if the transaction
 is domestic or international.
 */
struct FeeContract: Contract {
    
    /** Applies a fee to each transaction based on the country */
    func apply(to transaction: Transaction) -> Transaction {
        let rate:Double = {
            switch  transaction.type {
            case .domestic: return 0.05
            case .internation: return 0.10
            }
        }()
        
        return transaction.changing(fee: transaction.amount * rate)
    }
}

/**
 Conform to this protocol to create "Smart Contracts" like Ethereum has.
 */
protocol Contract: Codable {
    
    /**
     Contracts will be applied to `Transactions` before they are added into a
     block and mined. Here is your chance to perform some kind of processing on
     the transaction and update it.
     */
    func apply(to transaction:Transaction) -> Transaction
}

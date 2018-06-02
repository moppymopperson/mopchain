import Crypto

/**
 Represents one block in the `BlockChain`
 
 Here it is implemented as an immutable structure, which means it cannot have
 recursive references to other `Block`s. A block can have more than one
 `Transaction`, but that requires carefully keeping track of which transactions
 have made it into a block and which haven't. To avoid that complexity we just
 use single `Transaction` blocks in this project.
 */
struct Block: Codable {
    
    let transactions:[Transaction]  /// All the transactions in this `Block`
    let previousHash:String         /// The hash of the previous block
    let hash:String                 /// The hash of this block
    let nonce:Int                   /// The nonce used to generate the block hash
    let index:Int                   /// The index of the block in the chain
    
    /** Create a new `Block` */
    init(idx:Int, trans:[Transaction], prevHash: String, seed:Int = 0) {
        transactions = trans
        previousHash = prevHash
        nonce = seed
        index = idx
        
        let data = try! JSONEncoder().encode(transactions)
        let transactionString = String(data: data, encoding: .utf8)!
        let key = String(index) + previousHash
            + String(nonce) + transactionString
        hash = key.sha1Hash()
    }
    
    /** Add new transactions to a block */
    func add(newTransactions: [Transaction]) -> Block {
        return Block(idx: index,
                     trans: transactions + newTransactions,
                     prevHash: previousHash)
    }
    
    /** A unique string representing this block. Used as input for SHA1 */
    private func key() -> String {
        let data = try! JSONEncoder().encode(transactions)
        let transactionString = String(data: data, encoding: .utf8)!
        return String(index) + previousHash
            + String(nonce) + transactionString
    }
}

fileprivate extension String {
    
    /** Hash a string with SHA 1 */
    func sha1Hash() -> String {
        let hashData = try! SHA1.hash(self)
        return String(data: hashData, encoding: .utf8)!
    }
}



/**
 A immutable blockchain model with support for smart contracts. The immutability
 is fine for a toy project like this, but it would be bad news for a large
 blockchain.
 
 Because I tried to make the `Block`s with immutable structs, creating a linked
 list wasn't possible. Instead I had to store an array of `Block`s here in the
 `Blockchain`. I would use classes if I had to do this over.
 */
struct Blockchain: Codable {
    
    /** The blocks of transactions making up the blockchain */
    let blocks:[Block]
    
    /** Smart contracts to be applied to each transaction as they are added */
    let contracts:[Contract] = [FeeContract()]
    
    /** Create a new block chain with a genesis block */
    init(genesisTransactions:[Transaction]) {
        let candidate = Block(idx: 0, trans: genesisTransactions, prevHash: "00000")
        let provenBlock = Blockchain.proveWork(candidate)
        blocks = [provenBlock]
    }
    
    /** Clone from the blocks of an existing chain */
    init(blocks:[Block]) {
        self.blocks = blocks
    }
    
    /** Determines which properties get serialized and deserialized */
    private enum CodingKeys: String, CodingKey {
        case blocks
    }
    
    /**
     Add a block to the chain using proof of work.
     
     - Note: Smart contracts are applied to all transactions before adding them
     to the block.
     */
    func addBlock(transactions:[Transaction]) -> Blockchain {
        let modifiedTransactions = transactions.map(applyContracts)
        let candidateBlock = Block(idx: blocks.count,
                                   trans: modifiedTransactions,
                                   prevHash: blocks.last!.hash)
        let provenBlock = Blockchain.proveWork(candidateBlock)
        return Blockchain(blocks: blocks + [provenBlock])
    }
    
    /** Check the hashes of all the blocks to make sure the chain is indeed valid */
    func validate() -> Bool {
        // TODO: Check the hashes
        return true
    }
    
    /** Applies each of the contracts in order to the `Transaction` */
    private func applyContracts(transaction: Transaction) -> Transaction {
        var trans = transaction
        for contract in contracts {
            trans = contract.apply(to: trans)
        }
        return trans
    }
    
    /** Search for a nonce that results in a hash starting with zeros */
    private static func proveWork(_ block:Block) -> Block {
        var candidate = block
        while !candidate.hash.hasPrefix("00") {
            print("Nonce: \(candidate.nonce)")
            candidate = Block(idx: candidate.index,
                              trans: candidate.transactions,
                              prevHash: candidate.previousHash,
                              seed: candidate.nonce + 1)
        }
        return candidate
    }
}


import Vapor

/**
 A service that can be spun up on any thread to handle tasks related to the
 blockchain.
 
 Vapor is meant to be stateless, but we're forcing it to hold the blockchain in
 memory here and share that one instance across all requests threads. There should
 really be some access control of some kind here. A better solution would be to
 store the blockchain in a database that can handle access from multiple threads.
 */
final class BlockchainService: Service {
    
    /**
     This is how we make sure that the existing blockchain is used instead of
     creating a new one when a container makes a new block chain service. I'm
     not a fan of singletons, but I'll let it slide for toy projects.
     */
    static private let shared = BlockchainService()
    
    /** Create the chain along with the genesis block */
    private var chain = Blockchain(genesisTransactions: [
        Transaction(from: "A", to: "B", amount: 100, fee: 0, type: .domestic)
        ])
    
    /**
     Add a transaction onto the chain (via mining). The success callback will
     fire only if this `Node` completes mining before a valid solution is
     received from another `Node`.
     
     When mining is complete, we check to see if the new chain is longer than
     the stored chain. If it is, we update the chain. If it is not, that means
     that another `Peer` mined the block before us, so we throw away our work.
     
     - Seealso: `receiveChain`
     */
    func addTransaction(_ transaction: Transaction, success: (Blockchain)->()) {
        let newChain = chain.addBlock(transactions: [transaction])
        if newChain.blocks.count > chain.blocks.count {
            chain = newChain
            success(newChain)
        }
    }
    
    /**
     Process a proposed blockchain solution from another node. If the blockchain
     they propose is longer than ours, and it's valid, then we keep it.
     */
    func receiveChain(_ proposedChain:Blockchain, accepted: ()->()) {
        guard proposedChain.validate() && proposedChain.blocks.count > chain.blocks.count
            else { return }
        chain = proposedChain
        accepted()
    }
    
    /** Determines if a Transaction is new or if it has been seen before */
    func hasSeen(_ transaction: Transaction) -> Bool {
        return chain.blocks.flatMap{$0.transactions}.contains(transaction)
    }
}

/** Make `BlockchainService` registerable as a `Service` */
extension BlockchainService: ServiceType {
    
    static var serviceSupports: [Any.Type] {
        return [BlockchainService.self]
    }
    
    static func makeService(for worker: Container) throws -> BlockchainService {
        return BlockchainService.shared
    }
}

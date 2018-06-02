import Vapor

/**
 Handles requests related to `Transaction`s.
 */
final class TransactionController {
    
    /**
     Users as well as other `Peer`s on the network send `Transaction`s to this
     endpoint to get them added into the block chain.
     
     Before we begin mining, we first forward the `Transaction` off to a few
     `Peer`s, and they each do the same. In this way, the `Transaction` spreads
     across the network and can be mined silmultaneously by a many nodes.
     
     We need to check that each transaction we receive is new, so we ignore any
     that have been seen by the block service. This could include any transactions
     that were successfully mined by somebody else on the network before the
     transaction propogated to this node, or transactions that we're currently
     mining.
     */
    func processTransaction(_ req: Request) throws -> HTTPResponseStatus {
        guard validatePublicKey(req) else { return .unauthorized }
        let peerService = try req.make(PeerService.self)
        let blockService = try req.make(BlockchainService.self)
        let transaction = try! JSONDecoder().decode(Transaction.self, from: req.http.body.data!)
        guard !blockService.hasSeen(transaction) else { return .ok }
        
        // TODO: Make this async, handle errors
        try peerService.propogateTransaction(transaction, on: req)
        blockService.addTransaction(transaction) { chain in
            try! peerService.propogateChain(chain, on: req)
        }
        
        return .ok
    }
    
    /**
     Ensure that the person submitting this request is the owner of the
     sender's wallet.
     
     They must provide
     1. Their public key
     2. The transaction they want to post
     3. The same transaction, but encrypted with their private key
     
     if decrypt(message: encrypted, with: publicKey) == transaction, then and
     only then do we let the message be added to the ledger.
     */
    private func validatePublicKey(_ req: Request) -> Bool {
        // TODO:
        return true
    }
}

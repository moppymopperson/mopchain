import Vapor

/** Handles requesets related to the block chain */
final class BlockchainController {
    
    /**
     Each time a peer successfully mines a block they will send the (entire)
     newly minted chain to this endpoint.
     
     - note: If the chain gets to be more than a few megabytes this will quickly
     become problematic. Good thing this is just for fun!
     */
    func receive(_ req: Request) throws -> HTTPStatus {
        let chain = try JSONDecoder().decode(Blockchain.self, from: req.http.body.data!)
        let peerService = try req.make(PeerService.self)
        let blockService = try req.make(BlockchainService.self)
        blockService.receiveChain(chain) {
           try! peerService.propogateChain(chain, on: req)
        }
        return .ok
    }
}

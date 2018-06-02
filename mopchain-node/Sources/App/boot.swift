import Vapor

/**
 As soon as the server boots up, we do few things. All are performed
 synchronously and will prevent the node from launching if they fail.
 
 1. Get a list of peers on the network from the hub server
 2. Register a new node on the network
 3. Alert the peers about the new hub
 
 All of these should be performed in a more robust and distributed manner
 if you wish to build a real blockchain service.
 */
public func boot(_ app: Application) throws {
    let logger = try app.make(Logger.self)
    logger.info("Booting...")
    
    logger.info("Retrieving list of peers from hub server...")
    let peerService = try app.make(PeerService.self)
    let peers = try peerService.fetchNetworkPeersFromHub(in: app).wait()
    logger.info("Got peers: \(peers)")
    
    logger.info("Registering node with hub server...")
    let status = try peerService.registerSelfOnHub(on: app).wait()
    switch status {
    case .ok:   logger.info("Registered successfully!")
    default:    logger.error("Failed to register with hub server!")
    }

    logger.info("Alerting peers to presence...")
    let db = try app.requestPooledConnection(to: .sqlite).wait()
    peerService.registerSelfWithPeers(in: db) { peer, status in
        logger.info("Registered with peer at " + peer.hostname + ":\(peer.port)" + " with status: \(status.reasonPhrase)")
    }
}

import Vapor
import FluentSQLite

/**
 Performs all work related to managing `Peers` and information about them.
 */
final class PeerService: Service {
    
    /** Address of the hub server */
    private let hubHostname = "localhost"
    
    /** Port the hub server is running on */
    private let hubPort = 3000
    
    /** Manually add a peer */
    func addPeer(_ peer: Peer, on worker: Request) throws -> Future<Peer> {
        return peer.save(on: worker)
    }
    
    /** Anychronously fetch all the peers from the hub server */
    func fetchNetworkPeersFromHub(in container: Container) throws -> Future<[Peer]> {
        return try container.client().send(.GET, to: "http://localhost:3000/nodes").flatMap({ response in
            return try response.content.decode([Peer].self)
        })
    }
    
    /** Register this node on the hub server so other nodes can find it */
    func registerSelfOnHub(on worker: Worker) throws -> Future<HTTPStatus> {
        let body = HTTPBody(data: try! JSONEncoder().encode(["address": "http://localhost:8080"]))
        let headers = HTTPHeaders([("Content-Type", "application/json")])
        let request = HTTPRequest(method: .POST, url: "/nodes", headers: headers, body: body)
        return HTTPClient.connect(hostname: hubHostname, port: hubPort, on: worker).flatMap{ client in
            return client.send(request)
        }.map({$0.status})
    }
    
    /** Alert each known `Peer`s about the existnce of this node. The callback will fire once for each `Peer` */
    func registerSelfWithPeers(in db: SQLiteConnection, _ callback: @escaping (Peer, HTTPStatus) -> Void) {
        let body = HTTPBody(data: try! JSONEncoder().encode(["address": "http://localhost:8080"]))
        let headers = HTTPHeaders([("Content-Type", "application/json")])
        let request = HTTPRequest(method: .POST, url: "/register", headers: headers, body: body)
        _ = db.query(Peer.self).all().map { peers in
            peers.forEach{ peer in
                _ = HTTPClient.connect(hostname: peer.hostname, on: db).flatMap{  client in
                    return client.send(request)
                }.map{ response in
                    callback(peer, response.status)
                }
            }
        }
    }
    
    /**
     Call this method once mining a `Block` completes to propagate the `Block`
     to other `Peer`s on the network. This is an integral part of the concensus
     algorithm.
     */
    func propogateChain(_ chain: Blockchain, on container: Container) throws {
        _ = try selectRandomPeers(number: 3, on: container).map { peers in
            
        }
    }
    
    /**
     Pass a `Transaction` to a group of `Peers`. Each `Peer` will in turn forward
     it on to its own peers until it spreads across the network.
     
     This could easily result in an infintely escalating number of requests, so
     when we receive a `Transaction` we don't propogate it if it has been seen
     already.
     */
    func propogateTransaction(_ transaction: Transaction, on container: Container) throws {
        _ = try selectRandomPeers(number: 3, on: container).map { peers in
            peers.map{ self.sendTransaction(transaction, to: $0, on: container) }
        }
    }
    
    /** Sends a `Transaction` to a single `Peer` */
    func sendTransaction(_ transaction: Transaction, to peer: Peer, on container: Container) -> Future<HTTPResponseStatus> {
        let headers = HTTPHeaders([("Content-Type", "application/json")])
        let body = HTTPBody(data: try! JSONEncoder().encode(transaction))
        let request = HTTPRequest(method: .POST, url: peer.address + "/transaction", headers: headers, body: body)
        return try! container.client().send(Request(http: request, using: container)).map { response in
            return response.http.status
        }
    }
    
    /** Sends a `Blockchain` to a single `Peer` */
    func sendBlockchain(_ chain: Blockchain, to peer: Peer, on container: Container) -> Future<HTTPResponseStatus> {
        let headers = HTTPHeaders([("Content-Type", "application/json")])
        let body = HTTPBody(data: try! JSONEncoder().encode(chain))
        let request = HTTPRequest(method: .POST, url: peer.address + "/chain", headers: headers, body: body)
        return try! container.client().send(Request(http: request, using: container)).map { response in
            return response.http.status
        }
    }
    
    /**
     Selects a random subgroup of `Peer`s. If fewer are available than are asked
     for, then a smaller number than number may be returned.
     */
    private func selectRandomPeers(number: Int, on container: Container) throws -> Future<[Peer]> {
        return container.withPooledConnection(to: .sqlite) { db  in
            return db.query(Peer.self).all()
        }.map { peers in
            guard number < peers.count else { return peers }
            
            // TODO: Make this psuedorandom
            return Array(peers[..<number])
        }
    }
}

/** Make `PeerService` registerable as a `Service` */
extension PeerService: ServiceType {
    
    static var serviceSupports: [Any.Type] {
        return [PeerService.self]
    }
    
    static func makeService(for worker: Container) throws -> PeerService {
        return PeerService()
    }
}


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

    /** Anychronously fetch all the peers from the hub server */
    func fetchNetworkPeersFromHub(in container: Container) throws -> Future<[Peer]> {
        return try container.client().send(.GET, to: "http://localhost:3000/nodes").flatMap({ response in
            return try response.content.decode([Peer].self)
        })
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


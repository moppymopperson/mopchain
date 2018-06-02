import Vapor
import FluentSQLite

/** Represents a peer on the MopChain network */
struct Peer: SQLiteModel, Content, Parameter, Migration {
    
    /** Autopopulated upon insertion. Vapor requires it be mutable. */
    var id: Int?
    
    /** Address the `Peer` is running on */
    let hostname: String
    
    /** Port the `Peer` is running on */
    let port: Int
    
    /** Full address of the `Peer` */
    var address: String {
        return "http://\(hostname):\(port)"
    }
    
    /** Prevent creation of duplicate `Peers` */
    func willCreate(on connection: SQLiteConnection) throws -> EventLoopFuture<Peer> {
        return try connection.query(Peer.self).filter(\Peer.address == address).first().map({ peer in
            if peer != nil { throw Abort(.alreadyReported, reason: "Peer already registered")}
        }).transform(to: self)
    }
}

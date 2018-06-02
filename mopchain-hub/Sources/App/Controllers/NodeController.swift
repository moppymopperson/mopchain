import Vapor

/** Basic CRUD operations for `Node`s. */
struct NodeController {
    
    /** Fetch all `Nodes` */
    func index(_ req: Request) throws -> Future<[Node]> {
        let logger = try req.make(Logger.self)
        logger.info("Received request to for all Node records")
        return Node.query(on: req).all()
    }
    
    /** Create a new `Node` entry in the database */
    func create(_ req: Request) throws -> Future<Node> {
        let logger = try req.make(Logger.self)
        logger.info("Received request to register new node")
        return try req.content.decode(Node.self).flatMap({ node in
            logger.info("Registering a new node at \(node.address)")
            return node.save(on: req)
        })
    }
    
    /** Delete a parameterized `Node` */
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let logger = try req.make(Logger.self)
        logger.info("Received request to delete a Node")
        return try req.parameters.next(Node.self).flatMap { node -> Future<Void> in
            logger.info("Deleting node at \(node.address)")
            return node.delete(on: req)
        }.transform(to: .ok)
    }
}

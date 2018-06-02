import Vapor

/**
 Our simple implementation just has two endpoint. One for receiving `Transaction`s
 that still need to be mined and one for receiving updates to the blockchain when
 another node successfully mines a block.
 */
public func routes(_ router: Router) throws {

    router.get("Hello") { req in
        return "Testing..."
    }
}

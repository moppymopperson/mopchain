import Vapor

/** Register application's routes */
public func routes(_ router: Router) throws {
    
    // Any Zelda fans out there?
    router.get("/secret") { req in return "It's a secret to everybody." }

    // Setup the `Node` controller
    let nodeController = NodeController()
    router.get("nodes", use: nodeController.index)
    router.post("nodes", use: nodeController.create)
    router.delete("nodes", Node.parameter, use: nodeController.delete)
}

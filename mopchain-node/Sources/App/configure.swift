import FluentSQLite
import Vapor

/** Called before node  initializes. */
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    // Register providers first
    try services.register(FluentSQLiteProvider())
    
    // Register routes
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Catch errors and convert to HTTP responses
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    
    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)
    
    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Peer.self, database: .sqlite)
    services.register(migrations)

    // Setup `PeerService`
    let peerService = PeerService()
    services.register(peerService)
}

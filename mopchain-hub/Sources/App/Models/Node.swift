//
//  Node.swift
//  App
//
//  Created by Erik Hornberger on 2018/05/29.
//

import Vapor
import FluentSQLite

/**
 Represents a node on the blockchain network. The server keeps a list of
 these nodes and distributes it to new nodes that join the network.
 */
struct Node: SQLiteModel, Content, Parameter, Migration {
    
    /** Autopopulated upon insertion. Vapor requires it be mutable. */
    var id: Int?
    
    /** The IP address and port of the `Node` */
    let address: String
    
    /** Initialize using a URL containing the `Node`'s IP address */
    init(address: String) {
        self.address = address
    }
    
    /** Prevent creation of two nodes with the same address */
//    func willCreate(on connection: SQLiteConnection) throws -> EventLoopFuture<Node> {
//        return try connection.query(Node.self).filter(\Node.address == address).first().map({ node in
//            if node != nil { throw Abort(HTTPResponseStatus.alreadyReported) }
//        }).transform(to: self)
//    }
}

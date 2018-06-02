# MopChain

> `MopChain` is a simplistic blockchain and client that I built to solidify my understanding of how blockchains and consensus algorithms work. It was an excellent way to determine where I needed to learn more and what I had a good grasp on already.

### Learning Goals

I used this project as an opportunity to kill a few birds with one stone by trying out a handful of frameworks and paradigms that I had been curious about.

1.  Blockchain as a data structure
2.  Server side Swift using Vapor
3.  Immutable models
4.  Functional programming principles

## Design Choices

#### Block Chain

I started by building out the blockchain model first. To keep the scope of the project manageable, I opted to just store the entire blockchain in memory. No database. I used immutable `struct`s for almost everything. I am happy with how this part of the project came out. Using immutable models removed the complexity of need getters and setters with difference access permissions, which I liked a lot. It was also nice not having to think too much about how a consumer could put an object into an inconsistent state or how to ensure thread safety. You get all of that for free just by using immutable pass-by-value structs.

It does create a lot of overhead though, because the entire block chain needs to be copied each time a new block is added. Not tenable for even a modestly sized blockchain. Value-typed structs also cannot be used to make linked lists, for obvious reasons. Representing the blockchain as a tree instead of an array of blocks would be a more nuanced solution. If I had it do over I would probably leave `Transaction`s immutable, but I would makes `Block`s and the `Blockchain` pass-by-reference.

#### Server

The server was written with Vapor. I had some trouble with Vapor because there aren’t many resources for it when you get stuck. I ran into a bug in its database framework, Fluent, that currently prevents this project from working fully. Vapor is built for multithreading with statelessness and scalability in mind. I like its services model a lot, but it didn’t play very well with the blockchain models I had already completed. In particular, I couldn’t find way that I really like to ensure that all threads had access to the blockchain without using a singleton. Using classes instead of structs would have helped here, but thread-safety is still a concern.

#### Peer Discovery

Nodes on the network must be able to find one another. BitCoin uses a multitiered approach with a variety of fallbacks.

I just built a quick and dirty server that hosts of a list of known peers. Each time a `Node` joins the network, it registers itself on the hub server and announces it existence to other nodes. Beyond that the hub isn’t used. This is fine for my project, but it’s a single point of failure and would be inappropriate for a realistic blockchain.

#### Transaction Propagation

Similarly to discovering peers, each node must have a way to find about transactions that enter the network at other nodes.

Each node has an endpoint for accepting transactions. When a node receives a transaction it passes the transaction to 3 other nodes on the network and then begins mining. The 3 nodes it passed the transaction to will do the same, until every node on the network knows about the transaction. To prevent exponential growth and repeated emitting of transactions, nodes do not reemit any transaction they have seen before.

Using this system, it is possible for a transaction stop being forwarded before it spreads across the whole network, but the odds are low enough that it’s not a big deal for toy projects like this one.

#### Solution Propagation

After a node has fulfilled its responsibility to broadcast new transactions to its peers, it begins mining a new `Block`. Each block just has 1 transaction. I didn’t want to deal with the complexity of queuing and dequeuing transactions and trying to keep track of which have and haven’t made it into the block chain yet. When a node completes mining a block, it adds it to the chain. If no other solutions have been proposed by other nodes during the course of mining, the node accepts its own solution and broadcasts it to a small number of peers. Those peers verify the work and forward the blockchain on again. The entire blockchain is sent, not just the most recent block. This is inefficient, but reduces the complexity of the checks that have to be made.

#### User Validation

We need to ensure that user A cannot post a transaction to send herself money out of user B’s account?

This is done with asymmetric private key cryptography. It has not been implemented yet. The gist is that in order to add a transaction to the network, the user must provide an unencrypted transaction, an encrypted version of the transaction created with their private key, and their public key.

If the public key can be used to decrypt the encrypted transaction, and it matches the original unencrypted transaction, and the public key belongs to the transaction’s sender, then and only then do we allow that transaction onto the blockchain.

#### Possible Improvements

1.  The blockchain should be stored in a database so that it can get bigger than the available memory and to make it thread safe
2.  More robust peer discovering and propagation algorithms would be nice
3.  Nodes don’t currently halt mining when they receive a solution from the network. Consensus would be reached faster if they did

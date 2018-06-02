# MopChain Hub

This is a simple central tracker for MopChain nodes. This server's sole responsibility is to maintain a list of nodes and distribute them to new peers that join the network.

When a node spins up it connects to this server, registers itself, and receives a list of peers on the network. The
server does not need to distribute information about new peers to existing peers. Nodes take care of that themselves.

### Caveats 

Real blockchains use much more sophisticated methods of peer discovery. MopChain is just an exploratory project for my own amusement, so this is sufficient. In practice this kind of system would be a terrible idea because

1. There is a single point of failure
    - If the server goes down, the nodes can't find each other anymore
2. There is no authentication of any kind
    - Anybody can just send a request and delete all records of the nodes
3. There is no protection again registering the same node multiple times or creating other conflicting entries
    - We don't even validate the addresses

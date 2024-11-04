# Matter Tunnel Blockchain Repo

## Structure

Add image later.
![alt](https://)

The system consists of 4 Orderer nodes, 2 Peer nodes, and 2 user nodes. The user nodes can be implemented either as middleware servers or end systems.

## Build Network

### Prerequisite

Docker must be pre-installed

### Code

With this code, you can build a network that supports BFT:

```
cd fabric-network
./network.sh up -bft
```

You can use the following code to delete docker containers:

```
./network.sh down
```

# Matter Tunnel Blockchain Repo

## Structure

![블록체인의 구조를 나타낸 그림](https://github.com/user-attachments/assets/581d2f4a-1f6f-4820-baf5-e8949f4c86c6)

The system consists of 4 Orderer nodes, 2 Peer nodes, and 3 user nodes. User nodes can communicate with the blockchain through a gateway or directly using gRPC.

## Build Network

### Prerequisite

Docker must be pre-installed

### Code

With this code, you can build a network that supports BFT:

```
cd fabric-network
./network.sh up createChannel -c mychannel -ca

```

You can use the following code to delete docker containers:

```
./network.sh down
```

easy start with dummy data:

```
cd fabric-network
chmod 777 ./easy_start.sh
./easy_start.sh
```

# Matter Tunnel Blockchain Repo

## Structure

![블록체인의 구조를 나타낸 그림](https://private-user-images.githubusercontent.com/69969001/382725936-79efa5b2-8bba-4c90-8176-cbaf6f2a0697.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MzIxNzUxNzQsIm5iZiI6MTczMjE3NDg3NCwicGF0aCI6Ii82OTk2OTAwMS8zODI3MjU5MzYtNzllZmE1YjItOGJiYS00YzkwLTgxNzYtY2JhZjZmMmEwNjk3LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDExMjElMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQxMTIxVDA3NDExNFomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTFlMzk1Zjg2YjZmZjZmMTI5NzU3NWVkZjU3MmQzNWY2MDg1MTA1NjVkNDRiZjFjZmI0NTA4OTNlNmM0NmRlOGImWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.VtyX9W-OqRUsGkOKPRscWVvATcbQGo730Wjbl6dN5TY)

The system consists of 4 Orderer nodes, 2 Peer nodes, and 2 user nodes. The user nodes can be implemented either as middleware servers or end systems like dashboard.

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

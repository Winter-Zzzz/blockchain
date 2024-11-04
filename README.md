# Matter Tunnel Blockchain Repo

## Structure

Add image later.
![alt](https://private-user-images.githubusercontent.com/69969001/382725936-79efa5b2-8bba-4c90-8176-cbaf6f2a0697.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MzA3MTc0NDcsIm5iZiI6MTczMDcxNzE0NywicGF0aCI6Ii82OTk2OTAwMS8zODI3MjU5MzYtNzllZmE1YjItOGJiYS00YzkwLTgxNzYtY2JhZjZmMmEwNjk3LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDExMDQlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQxMTA0VDEwNDU0N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTgyZjc2NGEzOWRjZmIxZDBhNjA0Y2JmNDM4ZGQwNGU5NTE5MzYxNzRkZmE5Y2MwZTQzOWZkMzBiMDBhOTliMWMmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.oCbjuRITL8pp8cI0p3PRKBX-DjeN-ZRmwgeQgHHa8aE)

The system consists of 4 Orderer nodes, 2 Peer nodes, and 2 user nodes. The user nodes can be implemented either as middleware servers or end systems like dashboard.

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

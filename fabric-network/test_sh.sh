#!/bin/bash

# 네트워크 설정이 완료되어 있어야 합니다!

# # 환경변수 설정
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# 체인코드 배포
# ./network.sh deployCC -ccn matter-tunnel -ccp ../matter_tunnel/chaincode/ -ccl go

# pk 등록
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Register","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","98dcbf440bb33c006f64a4a3937d2aee2b323abc4e002a1914ee9a399e83311d79a60f0681d53be08c17fc3c6abc90bd79896c92cda35c8e0fd0035dbb022101"]}'
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Register","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","1b2a02c81bac64cfc07027002de637bac1e5b43a140d0ff284df33982b29fbae7d1721dabe4384c403ad732f6ff0a795559467e57d4d9d038afcce053f15c1ce"]}'

# 등록된 PK 조회
# peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetRegisteredPKs","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d"]}'
# peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetRegisteredPKs","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7"]}'

# 트랜젝션 전송 alice to bob
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","d865063d1cb8870d2130e1780190838875d4a49ad17f405c9f6d78035e3df38fed84368ddbd394a7293240f6508306d079363620e8bbb47a105b6a6f4c001e2868696869000000000000000000000000000003750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946bf0f3f670000000090968c3bc13aa16a6409ccb7af4f29b4e2dca13718fda9cc21f5eb5db606a163"]}'

# 트랜젝션 확인 bob
# peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetCurrentTransaction","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7"]}'

# 포맷
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"","Args":["",""]}'

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
./network.sh deployCC -ccn matter-tunnel -ccp ../matter_tunnel/chaincode/ -ccl go
echo "chaincode deploy complete"
echo "================================================="

# 테스트 실행
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Register","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","98dcbf440bb33c006f64a4a3937d2aee2b323abc4e002a1914ee9a399e83311d79a60f0681d53be08c17fc3c6abc90bd79896c92cda35c8e0fd0035dbb022101"]}'

# 등록된 PK 조회
peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetRegisteredPKs","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d"]}'

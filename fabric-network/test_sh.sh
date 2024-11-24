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

# alice가 디바이스의 pk 등록
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Register","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","0416aff5eac4d87f90173b5547d32b85c8f18650e64dd7a1fbf4344603c3d6383fbf233feb8bf8093f641037bf28409c1bd0fc5058787186977b42ddbbe6b2012a","780cfef11c7119933d1757e27f840d18b5df1f96a04733eeecf1e86447382e0044179f1cd46d4270e2ad4a1c47d56b7a633b4c8e6a842ff41fc743799cb0c2af"]}'

# 등록된 PK 조회
# peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetRegisteredPKs","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d"]}'

# setup 트랜젝션 전송 alice to device
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["0416aff5eac4d87f90173b5547d32b85c8f18650e64dd7a1fbf4344603c3d6383fbf233feb8bf8093f641037bf28409c1bd0fc5058787186977b42ddbbe6b2012a","96da99d6fe25fe3431fcbe6e091c6c00833e15ff1be6757fb336c586cbe7af04033a8046a8329a06683a41b9ed6a67d291d6a85a5b9daf9a999a0caf5a090d6173657475700000000000000000000000000003750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d94632d14267000000001a6140514b8e8a134bccf753db97b24f5240289a6a9ef4f216f7b905749c8bcf494e01749c2d60f7991c60071c918024cba37cf96edbb2fb2a9d28c292a4f7eb"]}'

# setup 성공 확인
# peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetRegisteredPKs","Args":["0416aff5eac4d87f90173b5547d32b85c8f18650e64dd7a1fbf4344603c3d6383fbf233feb8bf8093f641037bf28409c1bd0fc5058787186977b42ddbbe6b2012a"]}'

# on 트랜젝션 전송 alice to device
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["0416aff5eac4d87f90173b5547d32b85c8f18650e64dd7a1fbf4344603c3d6383fbf233feb8bf8093f641037bf28409c1bd0fc5058787186977b42ddbbe6b2012a","6dcdf316f49ae0b7483ab06ba66bcab20cea29dff4e452b605d9728791c4ffaeb1ee798be6bef4cd7caf0d4b17ac1d2f1aacec8d44b7c450212d26ff905abcd06f6e0000000000000000000000000000000003750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d9463cd2426700000000b2bca8de40e07ebb579384d5613adb9c4bfa32e463c70e38633b56078f419760"]}'

# colorChange 트랜젝션 전송 alice to device
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["0416aff5eac4d87f90173b5547d32b85c8f18650e64dd7a1fbf4344603c3d6383fbf233feb8bf8093f641037bf28409c1bd0fc5058787186977b42ddbbe6b2012a","4990aeb238210e3d64ab61c077073447b9c361f40a23188e45396c1c5f65274d2311a87dd4edc721fae63034bdf89dc8e7ec9c4cbd2d8eb8da76721252ffcc83636f6c6f724368616e67650000000000000003750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946add6426700000000a5148d65e12b90e8e311178af342454432cfc96532421d1136b24383fb1b804e"]}'

# 모든 트랜젝션 출력
# peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetAllTransactions","Args":[]}'

# 게이트웨이
# (cd ../matter_tunnel/application_gateway && go run .)

# 포맷
# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"","Args":["",""]}'

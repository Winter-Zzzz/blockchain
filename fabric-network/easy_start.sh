#!/bin/bash

# 네트워크 재시작
./network.sh down
./network.sh up createChannel -c mychannel -ca

# 환경변수 설정
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

./network.sh deployCC -ccn matter-tunnel -ccp ../matter_tunnel/chaincode/ -ccl go

# pk 등록
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Register","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","98dcbf440bb33c006f64a4a3937d2aee2b323abc4e002a1914ee9a399e83311d79a60f0681d53be08c17fc3c6abc90bd79896c92cda35c8e0fd0035dbb022101"]}'
sleep 2
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Register","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","1b2a02c81bac64cfc07027002de637bac1e5b43a140d0ff284df33982b29fbae7d1721dabe4384c403ad732f6ff0a795559467e57d4d9d038afcce053f15c1ce"]}'
sleep 2

# 등록된 PK 조회
peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetRegisteredPKs","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d"]}'
sleep 1
peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetRegisteredPKs","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7"]}'
sleep 1
# 더미 트랜젝션 전송 alice to bob

# 트랜젝션 전송 alice to bob
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","d865063d1cb8870d2130e1780190838875d4a49ad17f405c9f6d78035e3df38fed84368ddbd394a7293240f6508306d079363620e8bbb47a105b6a6f4c001e2868696869000000000000000000000000000003750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946bf0f3f670000000090968c3bc13aa16a6409ccb7af4f29b4e2dca13718fda9cc21f5eb5db606a163"]}'
sleep 1
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","0c19abe86dcdd8e7cc25263491ff9a66b003183a8ca67f2e3c637cecc4c11e14a834b3200636051fae613b4a7b78cf9c20f58152501bc71a270509eebac855e373657475700000000000000000000000000003750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d9467e074367000000002e39ccf9ea8885bebd1f2804eb72c2d1928099d14cf6e3c29281a4c8e881df7b752b28d38270f1d3094e480fa5047969"]}'
sleep 1
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","7e3564d819a9de38f5847250ba0971c4d29f783fedee8d93248c7fee3c93378d783c37b51c43c78b1a5c8930c0923ecd2d7e869c63acf0b6f767053ce9c2062868656c6c6f626f620000000000000000000003750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946a70743670000000080c1d285a5005fb30eeb8cbac074fe1cdc5f04fd659141baeaa97049f66febdd"]}'
sleep 1

# 트랜젝션 전송 bob to alice
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","9b0f94a19836ee82746a4c094186c81d07f21fd3fbca6b778f90524d792422dbe314a0a9cad325827a6ce1c76cdfc1ee4d2ce5707d9475876b9c9b2b2ab11469666565646261636b0000000000000000000003992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7ef61f406700000000cdc0e8c45ab4267ef221cfc143beb9a5f202357a9a638ffe74f1097d84b83a0d"]}'
sleep 1
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","701d9b9ff3f0f40476cd8c17532335a0d29ad1fb97cca0d8eee3e731d57c79f95ad7a4760e08dbe1bf8425de0185f645578aacfe8e25beae7f29eac22948be76776f726c640000000000000000000000000003992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7ed9074367000000007a89612b3e613e36ef5e3b90386efbddf67bad22b65a3312c6b47c146f8214ab"]}'
sleep 1
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n matter-tunnel --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Queuing","Args":["04750bfae2e57e7160cb5ead399ab37afdb4a1451a0b96b08764296dbe8490d946f1312034836474ccf7070b44d3e98f03dca538d148aff42fce155f58243de60d","02aa618d67c1a16c75dbf0a5a80bcf40c2233ec65f35c55545e69649f7674f2c5415e834e654c3fc0caa208e93217a55f0eefdc8833cfdeb89c0c474b09b261b68656c6c6f0000000000000000000000000003992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7eea0743670000000007eb5a2b3b7bf0e796c6316a4b6337936a2807c1bbfadd5f54688d237cdb0b5b"]}'
sleep 1

# 트랜젝션 확인 bob
peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetCurrentTransaction","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7"]}'
sleep 1

# 트랜젝션 확인 bob-index
peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetTransaction","Args":["04992a9a2eb063fc4cd45c5b67a1aecebcb87ea8358de73eef0ccf7d58c3c3ff7e382661df97cdfa48fede1ad2b767b95268bc810e11637234bb353085e37c32c7","2"]}'
sleep 1

# 모든 트랜젝션 출력
peer chaincode query -C mychannel -n matter-tunnel -c '{"function":"GetAllTransactions","Args":[]}'
sleep 1

# 게이트웨이
(cd ../matter_tunnel/application_gateway && go run .)

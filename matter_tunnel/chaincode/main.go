package main

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/big"
	"strings"

	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

type RegisteredPK struct {
	PublicKey string `json:"public_key"`
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
}

func verifySignature(publicKeyHex string, message string, signatureHex string) (bool, error) {
	// Decode the public key from hex
	pubKeyBytes, err := hex.DecodeString(publicKeyHex)
	if err != nil {
		return false, fmt.Errorf("failed to decode public key: %v", err)
	}

	// Parse the uncompressed public key
	x := new(big.Int).SetBytes(pubKeyBytes[1:33])
	y := new(big.Int).SetBytes(pubKeyBytes[33:])

	pubKey := &ecdsa.PublicKey{
		Curve: elliptic.P256(),
		X:     x,
		Y:     y,
	}

	// Create message hash
	msgHash := sha256.Sum256([]byte(message))

	// Decode signature
	sigBytes, err := hex.DecodeString(signatureHex)
	if err != nil {
		return false, fmt.Errorf("failed to decode signature: %v", err)
	}

	// Split signature into r and s
	r := new(big.Int).SetBytes(sigBytes[:32])
	s := new(big.Int).SetBytes(sigBytes[32:])

	// Verify the signature
	return ecdsa.Verify(pubKey, msgHash[:], r, s), nil
}

// aPK 에 bPK 를 등록합니다.
func (s *SmartContract) Register(ctx contractapi.TransactionContextInterface, aPK string, bPK string, sign string) error {
	// Verify the signature
	isValid, err := verifySignature(aPK, bPK, sign)
	if err != nil {
		return fmt.Errorf("failed to verify signature: %v", err)
	}
	if !isValid {
		return fmt.Errorf("invalid signature")
	}

	// Get the registered PKs for aPK
	registeredPKsKey := fmt.Sprintf("registered_%s", aPK)
	registeredPKsBytes, err := ctx.GetStub().GetState(registeredPKsKey)

	var registeredPKs []RegisteredPK
	if err != nil {
		return fmt.Errorf("failed to read registered PKs: %v", err)
	}

	// If there are existing registered PKs, unmarshal them
	if registeredPKsBytes != nil {
		err = json.Unmarshal(registeredPKsBytes, &registeredPKs)
		if err != nil {
			return fmt.Errorf("failed to unmarshal registered PKs: %v", err)
		}

		// Check if bPK is already registered
		for _, pk := range registeredPKs {
			if pk.PublicKey == bPK {
				return fmt.Errorf("public key %s is already registered", bPK)
			}
		}
	}

	// Add the new public key to the registered list
	registeredPKs = append(registeredPKs, RegisteredPK{PublicKey: bPK})

	// Marshal and store the updated registered PKs
	registeredPKsBytes, err = json.Marshal(registeredPKs)
	if err != nil {
		return fmt.Errorf("failed to marshal registered PKs: %v", err)
	}

	err = ctx.GetStub().PutState(registeredPKsKey, registeredPKsBytes)
	if err != nil {
		return fmt.Errorf("failed to store registered PKs: %v", err)
	}

	return nil
}

func (s *SmartContract) GetRegisteredPKs(ctx contractapi.TransactionContextInterface, pk string) ([]RegisteredPK, error) {
	registeredPKsKey := fmt.Sprintf("registered_%s", pk)
	registeredPKsBytes, err := ctx.GetStub().GetState(registeredPKsKey)

	if err != nil {
		return nil, fmt.Errorf("failed to read registered PKs: %v", err)
	}

	var registeredPKs []RegisteredPK
	if registeredPKsBytes == nil {
		return registeredPKs, nil
	}

	err = json.Unmarshal(registeredPKsBytes, &registeredPKs)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal registered PKs: %v", err)
	}

	return registeredPKs, nil
}

func (s *SmartContract) isRegistered(ctx contractapi.TransactionContextInterface, srcPK string, destPK string) (bool, error) {
	registeredPKsKey := fmt.Sprintf("registered_%s", destPK)
	registeredPKsBytes, err := ctx.GetStub().GetState(registeredPKsKey)
	if err != nil {
		return false, err
	}

	if registeredPKsBytes == nil {
		return false, nil
	}

	var registeredPKs []RegisteredPK
	err = json.Unmarshal(registeredPKsBytes, &registeredPKs)
	if err != nil {
		return false, err
	}

	for _, pk := range registeredPKs {
		if pk.PublicKey == srcPK {
			return true, nil
		}
	}

	return false, nil
}

func (s *SmartContract) getCurrentIndex(ctx contractapi.TransactionContextInterface, pk string) (uint64, error) {
	indexKey := fmt.Sprintf("index_%s", pk)
	indexBytes, err := ctx.GetStub().GetState(indexKey)
	if err != nil {
		return 0, err
	}

	if indexBytes == nil {
		return 0, nil
	}

	var index uint64
	err = json.Unmarshal(indexBytes, &index)
	if err != nil {
		return 0, err
	}

	return index, nil
}

func (s *SmartContract) incrementIndex(ctx contractapi.TransactionContextInterface, pk string) (uint64, error) {
	currentIndex, err := s.getCurrentIndex(ctx, pk)
	if err != nil {
		return 0, err
	}

	newIndex := currentIndex + 1
	indexBytes, err := json.Marshal(newIndex)
	if err != nil {
		return 0, err
	}

	indexKey := fmt.Sprintf("index_%s", pk)
	err = ctx.GetStub().PutState(indexKey, indexBytes)
	if err != nil {
		return 0, err
	}

	return newIndex, nil
}

func extractFunctionName(txData []byte) string {
	// Function name is first 18 bytes, trim nulls
	funcName := string(txData[:18])
	return strings.TrimRight(funcName, "\x00")
}

func (s *SmartContract) Queuing(ctx contractapi.TransactionContextInterface, destPK string, transaction string) error {
	// Decode transaction from hex
	txBytes, err := hex.DecodeString(transaction)
	if err != nil {
		return fmt.Errorf("failed to decode transaction: %v", err)
	}

	// Split signature (first 64 bytes) and transaction data
	if len(txBytes) < 64 {
		return fmt.Errorf("transaction too short")
	}
	signature := txBytes[:64]
	txData := txBytes[64:]

	// Extract compressed public key from transaction data (after 18 bytes function name)
	if len(txData) < 51 { // 18 (function name) + 33 (compressed public key)
		return fmt.Errorf("transaction data too short")
	}
	compressedPubKey := txData[18:51]

	// Convert compressed public key to uncompressed form
	curve := elliptic.P256()
	x, y := elliptic.UnmarshalCompressed(curve, compressedPubKey)
	if x == nil {
		return fmt.Errorf("invalid public key")
	}

	uncompressedPubKey := make([]byte, 65)
	uncompressedPubKey[0] = 0x04
	x.FillBytes(uncompressedPubKey[1:33])
	y.FillBytes(uncompressedPubKey[33:])
	srcPK := hex.EncodeToString(uncompressedPubKey)

	// Verify signature
	txDataHex := hex.EncodeToString(txData)
	signatureHex := hex.EncodeToString(signature)
	isValid, err := verifySignature(srcPK, txDataHex, signatureHex)
	if err != nil {
		return fmt.Errorf("failed to verify signature: %v", err)
	}
	if !isValid {
		return fmt.Errorf("invalid signature")
	}

	// Check if source is registered for destination
	funcName := extractFunctionName(txData)
	if funcName != "setup" {
		isRegistered, err := s.isRegistered(ctx, srcPK, destPK)
		if err != nil {
			return fmt.Errorf("failed to check registration: %v", err)
		}
		if !isRegistered {
			return fmt.Errorf("source public key not registered for destination")
		}
	}

	// Get and increment index
	newIndex, err := s.incrementIndex(ctx, destPK)
	if err != nil {
		return fmt.Errorf("failed to increment index: %v", err)
	}

	// Store transaction data (without signature) using index
	txKey := fmt.Sprintf("%s_%d", destPK, newIndex)
	err = ctx.GetStub().PutState(txKey, txData)
	if err != nil {
		return fmt.Errorf("failed to store transaction: %v", err)
	}

	return nil
}

func (s *SmartContract) GetTransaction(ctx contractapi.TransactionContextInterface, pk string, index uint64) (string, error) {
	txKey := fmt.Sprintf("%s_%d", pk, index)
	txBytes, err := ctx.GetStub().GetState(txKey)
	if err != nil {
		return "", fmt.Errorf("failed to read transaction: %v", err)
	}

	if txBytes == nil {
		return "", fmt.Errorf("transaction not found")
	}

	return hex.EncodeToString(txBytes), nil
}

func (s *SmartContract) GetCurrentTransaction(ctx contractapi.TransactionContextInterface, pk string) (string, error) {
	currentIndex, err := s.getCurrentIndex(ctx, pk)
	if err != nil {
		return "", fmt.Errorf("failed to get current index: %v", err)
	}

	if currentIndex == 0 {
		return "", fmt.Errorf("no transactions found")
	}

	return s.GetTransaction(ctx, pk, currentIndex)
}

func main() {
	chaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
		fmt.Printf("Error creating chaincode: %v", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincode: %v", err)
	}
}

package main

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
	"math/big"
)

// SmartContract provides functions for managing transactions
type SmartContract struct {
	contractapi.Contract
}

// Transaction represents the data structure for storing transaction data
type Transaction struct {
	Data  string `json:"data"`
	Index uint64 `json:"index"`
}

// RegisteredPK represents a public key that is registered to send transactions
type RegisteredPK struct {
	PublicKey string `json:"public_key"`
}

// InitLedger initializes the ledger with empty data
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
}

// verifySignature verifies an ECDSA signature
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

// Register registers a public key that can send transactions to another public key
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

// GetRegisteredPKs gets all registered public keys for a given public key
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

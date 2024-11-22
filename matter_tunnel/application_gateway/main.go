package main

import (
	"crypto/x509"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path"
	"time"

	"github.com/gorilla/mux"
	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
	"github.com/hyperledger/fabric-protos-go-apiv2/gateway"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/status"
)

const (
	mspID        = "Org1MSP"
	cryptoPath   = "../../fabric-network/organizations/peerOrganizations/org1.example.com"
	certPath     = cryptoPath + "/users/User1@org1.example.com/msp/signcerts"
	keyPath      = cryptoPath + "/users/User1@org1.example.com/msp/keystore"
	tlsCertPath  = cryptoPath + "/peers/peer0.org1.example.com/tls/ca.crt"
	peerEndpoint = "localhost:7051"
	gatewayPeer  = "peer0.org1.example.com"
)

type BlockchainServer struct {
	contract *client.Contract
}

type RegisterRequest struct {
	PublicKey1 string `json:"publicKey1"`
	PublicKey2 string `json:"publicKey2"`
	Sign       string `json:"sign"`
}

type QueuingRequest struct {
	PublicKey string `json:"publicKey"`
	TX        string `json:"tx"`
}

func main() {
	// Blockchain 연결 설정
	clientConnection := newGrpcConnection()
	defer clientConnection.Close()

	id := newIdentity()
	sign := newSign()

	gw, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(clientConnection),
		client.WithEvaluateTimeout(5*time.Second),
		client.WithEndorseTimeout(15*time.Second),
		client.WithSubmitTimeout(5*time.Second),
		client.WithCommitStatusTimeout(1*time.Minute),
	)
	if err != nil {
		panic(fmt.Errorf("failed to connect to gateway: %w", err))
	}
	defer gw.Close()

	channelName := "mychannel"
	if cname := os.Getenv("CHANNEL_NAME"); cname != "" {
		channelName = cname
	}

	chaincodeName := "matter-tunnel"
	if ccname := os.Getenv("CHAINCODE_NAME"); ccname != "" {
		chaincodeName = ccname
	}

	network := gw.GetNetwork(channelName)
	contract := network.GetContract(chaincodeName)

	server := &BlockchainServer{
		contract: contract,
	}

	// Router 설정
	r := mux.NewRouter()
	r.HandleFunc("/register", server.handleRegister).Methods("POST")
	r.HandleFunc("/queuing", server.handleQueuing).Methods("POST")
	r.HandleFunc("/getRegisteredPKs/{publicKey}", server.handleGetRegisteredPKs).Methods("GET")
	r.HandleFunc("/getAllTransactions", server.handleGetAllTransactions).Methods("GET")
	r.HandleFunc("/getTransaction", server.handleGetTransaction).Methods("GET")
	r.HandleFunc("/getCurrentTransaction/{publicKey}", server.handleGetCurrentTransaction).Methods("GET")

	// 서버 시작
	log.Printf("Server starting on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}

func (s *BlockchainServer) handleRegister(w http.ResponseWriter, r *http.Request) {
	var req RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	_, err := s.contract.SubmitTransaction("Register", req.PublicKey1, req.PublicKey2, req.Sign)
	if err != nil {
		handleErrorResponse(w, err)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "success"})
}

func (s *BlockchainServer) handleQueuing(w http.ResponseWriter, r *http.Request) {
	var req QueuingRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	_, err := s.contract.SubmitTransaction("Queuing", req.PublicKey, req.TX)
	if err != nil {
		handleErrorResponse(w, err)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "success"})
}

func (s *BlockchainServer) handleGetRegisteredPKs(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	publicKey := vars["publicKey"]

	result, err := s.contract.EvaluateTransaction("GetRegisteredPKs", publicKey)
	if err != nil {
		handleErrorResponse(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(result)
}

func (s *BlockchainServer) handleGetAllTransactions(w http.ResponseWriter, r *http.Request) {
	result, err := s.contract.EvaluateTransaction("GetAllTransactions")
	if err != nil {
		handleErrorResponse(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(result)
}

func (s *BlockchainServer) handleGetTransaction(w http.ResponseWriter, r *http.Request) {
	publicKey := r.URL.Query().Get("publicKey")
	index := r.URL.Query().Get("index")

	if publicKey == "" || index == "" {
		http.Error(w, "Missing publicKey or index parameter", http.StatusBadRequest)
		return
	}

	result, err := s.contract.EvaluateTransaction("GetTransaction", publicKey, index)
	if err != nil {
		handleErrorResponse(w, err)
		return
	}

	w.Header().Set("Content-Type", "text/plain")
	w.Write(result)
}

func (s *BlockchainServer) handleGetCurrentTransaction(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	publicKey := vars["publicKey"]

	result, err := s.contract.EvaluateTransaction("GetCurrentTransaction", publicKey)
	if err != nil {
		handleErrorResponse(w, err)
		return
	}

	w.Header().Set("Content-Type", "text/plain")
	w.Write(result)
}

func handleErrorResponse(w http.ResponseWriter, err error) {
	statusErr := status.Convert(err)
	errorResponse := make(map[string]interface{})
	errorResponse["error"] = statusErr.Message()

	details := statusErr.Details()
	if len(details) > 0 {
		var errorDetails []map[string]string
		for _, detail := range details {
			if d, ok := detail.(*gateway.ErrorDetail); ok {
				errorDetails = append(errorDetails, map[string]string{
					"address": d.Address,
					"mspId":   d.MspId,
					"message": d.Message,
				})
			}
		}
		errorResponse["details"] = errorDetails
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusInternalServerError)
	json.NewEncoder(w).Encode(errorResponse)
}

// 기존의 helper 함수들은 그대로 유지
func newGrpcConnection() *grpc.ClientConn {
	certificate, err := loadCertificate(tlsCertPath)
	if err != nil {
		panic(err)
	}

	certPool := x509.NewCertPool()
	certPool.AddCert(certificate)
	transportCredentials := credentials.NewClientTLSFromCert(certPool, gatewayPeer)

	connection, err := grpc.Dial(peerEndpoint, grpc.WithTransportCredentials(transportCredentials))
	if err != nil {
		panic(fmt.Errorf("failed to create gRPC connection: %w", err))
	}

	return connection
}

func newIdentity() *identity.X509Identity {
	certificatePEM, err := readFirstFile(certPath)
	if err != nil {
		panic(fmt.Errorf("failed to read certificate file: %w", err))
	}

	certificate, err := identity.CertificateFromPEM(certificatePEM)
	if err != nil {
		panic(err)
	}

	id, err := identity.NewX509Identity(mspID, certificate)
	if err != nil {
		panic(err)
	}

	return id
}

func newSign() identity.Sign {
	files, err := os.ReadDir(keyPath)
	if err != nil {
		panic(fmt.Errorf("failed to read private key directory: %w", err))
	}
	privateKeyPEM, err := os.ReadFile(path.Join(keyPath, files[0].Name()))
	if err != nil {
		panic(fmt.Errorf("failed to read private key file: %w", err))
	}

	privateKey, err := identity.PrivateKeyFromPEM(privateKeyPEM)
	if err != nil {
		panic(err)
	}

	sign, err := identity.NewPrivateKeySign(privateKey)
	if err != nil {
		panic(err)
	}

	return sign
}

func loadCertificate(certPath string) (*x509.Certificate, error) {
	certificatePEM, err := os.ReadFile(certPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read certificate file: %w", err)
	}
	return identity.CertificateFromPEM(certificatePEM)
}

func readFirstFile(dirPath string) ([]byte, error) {
	dir, err := os.Open(dirPath)
	if err != nil {
		return nil, err
	}

	fileNames, err := dir.Readdirnames(1)
	if err != nil {
		return nil, err
	}

	return os.ReadFile(path.Join(dirPath, fileNames[0]))
}

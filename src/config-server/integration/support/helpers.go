package support

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

const DbEnvVar = "DB"
const ServerStartTimeout = 10

var HTTPSClient = createHTTPSClient()

func UnmarshalJSONString(requestBody io.ReadCloser) map[string]interface{} {
	var f interface{}

	if err := json.NewDecoder(requestBody).Decode(&f); err != nil {
		panic("String provided cannot be decoded as JSON")
	}

	return f.(map[string]interface{})
}

func ParseCertString(certString string) (*x509.Certificate, error) {
	block, _ := pem.Decode([]byte(certString))
	crt, err := x509.ParseCertificate(block.Bytes)
	return crt, err
}

func ValidToken() string {
	tokenPath := pathForAsset("uaa.token")
	dat, err := os.ReadFile(tokenPath)

	if err != nil {
		panic(err.Error())
	}

	return string(dat)
}

func ConfigForDb() string {
	return fmt.Sprintf("support/assets/config.%s.json", os.Getenv(DbEnvVar))
}

func SetupDB(w io.Writer) {
	const dbName = "config_server"

	const mysqlUser = "root"
	const mysqlPass = "password"

	dbType := os.Getenv(DbEnvVar)
	switch dbType {
	case "memory":
		// no-op
	case "mysql":
		dropDbArgs := []string{"-u", mysqlUser, fmt.Sprintf("-p%s", mysqlPass), "-e", fmt.Sprintf("drop database if exists %s;", dbName)}
		err := exec.Command("mysql", dropDbArgs...).Run()
		if err != nil {
			message := fmt.Sprintf("Failed to run: mysql %s; %s", strings.Join(dropDbArgs, " "), err.Error())
			_, _ = w.Write([]byte(message)) //nolint:errcheck
			panic(message)
		}

		createDbArgs := []string{"-u", mysqlUser, fmt.Sprintf("-p%s", mysqlPass), "-e", fmt.Sprintf("create database if not exists %s;", dbName)}
		err = exec.Command("mysql", createDbArgs...).Run()
		if err != nil {
			message := fmt.Sprintf("Failed to run: mysql %s; %s", strings.Join(createDbArgs, " "), err.Error())
			_, _ = w.Write([]byte(message)) //nolint:errcheck
			panic(message)
		}
	case "postgresql":
		dropDbArgs := []string{"--if-exists", "-U", "postgres", dbName}
		err := exec.Command("dropdb", dropDbArgs...).Run()
		if err != nil {
			message := fmt.Sprintf("Failed to run: dropdb %s; %s", strings.Join(dropDbArgs, " "), err.Error())
			_, _ = w.Write([]byte(message)) //nolint:errcheck
			panic(message)
		}

		createDbArgs := []string{"-U", "postgres", dbName}
		err = exec.Command("createdb", createDbArgs...).Run()
		if err != nil {
			message := fmt.Sprintf("Failed to run: createdb %s; %s", strings.Join(createDbArgs, " "), err.Error())
			_, _ = w.Write([]byte(message)) //nolint:errcheck
			panic(message)
		}
	default:
		message := fmt.Sprintf("Unexpect DB value: '%s'", dbType)
		_, _ = w.Write([]byte(message)) //nolint:errcheck
		panic(message)
	}
}

func WaitForServerToStart() {
	for i := 0; i < ServerStartTimeout; i++ {
		resp, err := SendGetRequestByID("1")
		if err == nil && resp.StatusCode == 404 {
			return
		}

		time.Sleep(time.Second)
	}

	panic(fmt.Sprintf("Could not start config server in %d seconds", ServerStartTimeout))
}

func pathForAsset(fileName string) string {
	assetsDir, err := filepath.Abs("support/assets")
	if err != nil {
		panic(err.Error())
	}

	return filepath.Join(assetsDir, fileName)
}

func createHTTPSClient() *http.Client {
	sslCertPath := pathForAsset("ssl.crt")
	sslKeyPath := pathForAsset("ssl.key")
	rootCAPath := pathForAsset("ssl_root_ca.crt")

	cert, err := tls.LoadX509KeyPair(sslCertPath, sslKeyPath)
	if err != nil {
		panic(err.Error())
	}

	// Load CA cert
	caCert, err := os.ReadFile(rootCAPath)
	if err != nil {
		panic(err.Error())
	}
	caCertPool := x509.NewCertPool()
	caCertPool.AppendCertsFromPEM(caCert)

	// Setup HTTPS client
	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{cert},
		RootCAs:      caCertPool,
	}
	tlsConfig.BuildNameToCertificate() //nolint:staticcheck
	transport := &http.Transport{TLSClientConfig: tlsConfig}

	client := &http.Client{Transport: transport}

	return client
}

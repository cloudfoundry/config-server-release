package integration_test

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"github.com/onsi/gomega/gexec"

	"testing"
)

var (
	pathToConfigServer string
)

func TestIntegrationTests(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "IntegrationTests Suite")
}

var _ = SynchronizedBeforeSuite(func() []byte {
	configServerPath, err := gexec.Build("github.com/cloudfoundry/config-server")
	Expect(err).NotTo(HaveOccurred())
	return []byte(configServerPath)
}, func(data []byte) {
	pathToConfigServer = string(data)
})

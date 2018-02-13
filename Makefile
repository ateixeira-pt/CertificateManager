
# ==============================================================================
# Define Base MakeFile Variables
# ==============================================================================

# Phony Entry, This Prevents Make From Picking The Wrong Stuff
.PHONY: help ca_gen_key ca_gen client_gen_key client_sign_key client_gen

# Set The Help As A Default Target
.DEFAULT_GOAL := help

# ==============================================================================
# Developer Helpers
# =============================================================================

help: ## Prints This Help File
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ==============================================================================
# CA Helpers
# =============================================================================

ca_gen_key: ## Generate CA Private Key
	openssl genrsa -des3 -out cert/ca.key 4096

ca_gen: ca_gen_key ## Generate CA File
	openssl req -new -x509 -days 7304 -key cert/ca.key -out cert/ca.crt

# ==============================================================================
# Client Helpers
# =============================================================================

client_gen_key: ## Generate Client Private Key
	openssl genrsa -des3 -out cert/client/client.key 4096

client_sign_key: client_gen_key ## Sign Client Private Key
	openssl req -new -key cert/client/client.key -out cert/client/client.csr
	openssl x509 -req -days 3652 -in cert/client/client.csr -CA cert/ca.crt -CAkey cert/ca.key -set_serial 01 -out cert/client/client.crt
	rm cert/client/client.csr

client_gen: client_sign_key ## Generate Multiple Certifcates
	openssl pkcs12 -export -clcerts -in cert/client/client.crt -inkey cert/client/client.key -out cert/client/client.p12
	openssl pkcs12 -in cert/client/client.p12 -out cert/client/client.pem -clcerts
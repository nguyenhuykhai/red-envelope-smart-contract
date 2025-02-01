# Makefile
-include .env

# Deploy to Anvil
deploy-anvil:
	@echo "Loading .env file..."
	@export $$(cat .env | xargs)
	@echo "ANVIL_URL: ${ANVIL_URL}"
	@echo "PRIVATE_KEY: ${PRIVATE_KEY}"
	@forge script script/Deploy.s.sol --rpc-url ${ANVIL_URL} --private-key ${ANVIL_PRIVATE_KEY} --broadcast

deploy-sepolia:
	@echo "Loading .env file..."
	@export $$(cat .env | xargs)
	@echo "SEPOLIA_URL: ${SEPOLIA_URL}"
	@echo "SEPOLIA_PRIVATE_KEY: ${SEPOLIA_PRIVATE_KEY}"
	@forge script script/Deploy.s.sol --rpc-url ${SEPOLIA_URL} --private-key ${SEPOLIA_PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}

deploy-kaia:
	@echo "Loading .env file..."
	@export $$(cat .env | xargs)
	@echo "KAIA_URL: ${KAIA_URL}"
	@echo "KAIA_PRIVATE_KEY: ${KAIA_PRIVATE_KEY}"
	@forge script script/Deploy.s.sol --rpc-url ${KAIA_URL} --private-key ${KAIA_PRIVATE_KEY}

deploy-kaia-contract:
	@echo "Loading .env file..."
	@export $$(cat .env | xargs)
	@echo "KAIA_URL: ${KAIA_URL}"
	@echo "KAIA_PRIVATE_KEY: ${KAIA_PRIVATE_KEY}"
	@forge create --rpc-url ${KAIA_URL} --private-key ${KAIA_PRIVATE_KEY} src/RedEnvelope.sol:RedEnvelope --broadcast

verify-kaia-contract:
	@echo "Loading .env file..."
	@export $$(cat .env | xargs)
	@echo "KAIA_URL: ${KAIA_URL}"
	@echo "KAIA_PRIVATE_KEY: ${KAIA_PRIVATE_KEY}"
	@forge verify-contract 0xe30606e7de5945f507a80c5245fe74fc2882df5b src/RedEnvelope.sol:RedEnvelope --chain-id 1001 --verifier sourcify  --verifier-url https://sourcify.dev/server/



print-vars:
	@echo "ANVIL_URL: ${ANVIL_URL}"
	@echo "PRIVATE_KEY: ${PRIVATE_KEY}"

interact-anvil:
	@echo "Loading .env file..."
	@export $$(cat .env | xargs)
	@echo "ANVIL_URL: ${ANVIL_URL}"
	@echo "PRIVATE_KEY: ${PRIVATE_KEY}"
	@forge script script/RedEnvelope.s.sol:RedEnvelopeScript --rpc-url ${ANVIL_URL} --private-key ${ANVIL_PRIVATE_KEY} --broadcast
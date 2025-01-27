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

print-vars:
	@echo "ANVIL_URL: ${ANVIL_URL}"
	@echo "PRIVATE_KEY: ${PRIVATE_KEY}"

interact-anvil:
	@echo "Loading .env file..."
	@export $$(cat .env | xargs)
	@echo "ANVIL_URL: ${ANVIL_URL}"
	@echo "PRIVATE_KEY: ${PRIVATE_KEY}"
	@forge script script/RedEnvelope.s.sol:RedEnvelopeScript --rpc-url ${ANVIL_URL} --private-key ${ANVIL_PRIVATE_KEY} --broadcast
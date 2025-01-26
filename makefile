# Makefile
-include .env

# Deploy to Anvil
deploy-anvil:
	@echo "Loading .env file..."
	@export $$(cat .env | xargs)
	@echo "ANVIL_URL: ${ANVIL_URL}"
	@echo "PRIVATE_KEY: ${PRIVATE_KEY}"
	@forge script script/Deploy.s.sol --rpc-url ${ANVIL_URL} --private-key ${ANVIL_PRIVATE_KEY} --broadcast

print-vars:
	@echo "ANVIL_URL: ${ANVIL_URL}"
	@echo "PRIVATE_KEY: ${PRIVATE_KEY}"

# Deploy and verify on a live network
#deploy:
#	@source ./env && forge script script/DeployAndVerify.s.sol --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast
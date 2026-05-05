all: azure-image

azure-image: ## build azure devops agent
	@echo "build azure image locally"
	nix build .#azure-image --impure --json --no-link --print-build-logs | jq -r \".[0].outputs.out\"

remote: ## build the azure image remotely
	@echo "build azure image on my x86_64-linux box"
	nix build .#azure-image --impure --json --no-link --print-build-logs --eval-store auto --store ssh-ng://rudesome@192.168.99.186 --system 'x86_64-linux'

develop: ## nix develop shell
	@echo "start developer shell with required dependencies"
	nix develop

.PHONY: help
help:  ## this help messages
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'


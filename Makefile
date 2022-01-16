REGISTRY=ghcr.io/jnavarrof
APP=docker-trivy-scan-example
VERSION ?= $(shell cat VERSION)

.PHONY: help
help: ## show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | sed -e 's/\(\:.*\#\#\)/\:|/' | \
	fgrep -v fgrep | sed -e 's/\\$$//' | column -t -s '|'

.PHONY: setup
setup: ## Setup your local environment
	@echo "* Preparing environment"
	pre-commit install
	pre-commit autoupdate

.PHONY: build
build: ## Build step
	@echo "* Building image ..."
	docker build -t $(APP):$(VERSION) .

.PHONY: run
run: ## Run container
	@ echo "* Run container"
	docker run -it --rm  $(APP):$(VERSION)

.PHONY: test
test: ## Test image using Trivy
	@echo "* Testing image ..."
	trivy -q --auto-refresh $(APP):$(VERSION) | tee vuln-report.log
	@# Fail if HIGH vulnerabilities detected >0
	@if [ "$$(grep -c 'HIGH: [0-1]' vuln-report.log)" -gt 0 ]; then \
			echo "ERROR! Critical vulnerabilities detected in $(APP):$(VERSION)"; \
			exit 1; \
    fi

.PHONY: push
push:
	docker tag $(APP):$(VERSION) $(REGISTRY)/$(APP):$(VERSION)
	@echo "Push to remote registry: docker push $(REGISTRY)/$(APP):$(VERSION)"

.PHONY: release-patch
release-patch: ## Bump patched version
	$(PIPENV) bumpversion patch

.PHONY: release-minor
release-minor: ## Bump minor version
	$(PIPENV) bumpversion minor

.PHONY: release
release: ## Bump major release
	$(PIPENV) bumpversion major

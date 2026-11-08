.DEFAULT_GOAL := help
TF  := terraform -chdir=terraform
ANS := cd ansible && ansible-playbook

help: ## Show targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-14s %s\n",$$1,$$2}'

fmt: ## Format Terraform
	$(TF) fmt -recursive

lint: ## Run all linters
	$(TF) fmt -check -recursive
	cd terraform && tflint --init && tflint --recursive --config ../.tflint.hcl
	yamllint -c .yamllint ansible .github
	cd ansible && ansible-lint

test: ## Run Molecule tests (needs Docker)
	cd ansible && molecule test

init: ## terraform init
	$(TF) init

plan: init ## terraform plan
	$(TF) plan

up: init ## Provision VMs (writes the Ansible inventory)
	$(TF) apply

deps: ## Install Ansible collections
	cd ansible && ansible-galaxy collection install -r requirements.yml

ping: ## Check SSH connectivity to all nodes
	cd ansible && ansible all -m ansible.builtin.ping

deploy: check-inventory ## Run the full pipeline (baseline, harden, services, audit)
	$(ANS) playbooks/site.yml

harden: check-inventory ## Re-apply hardening only
	$(ANS) playbooks/hardening.yml

audit: check-inventory ## Read-only compliance audit
	$(ANS) playbooks/audit.yml

check-inventory:
	@test -f ansible/inventory/hosts.ini || { echo "ansible/inventory/hosts.ini missing: run 'make up' first."; exit 1; }

down: ## Destroy all VMs
	$(TF) destroy

.PHONY: check-inventory help fmt lint test init plan up deps ping deploy harden audit down

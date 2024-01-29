help:
	@echo "Commands :"
	@echo " - apply: provision infrastructure in hcloud"
	@echo " - destroy: destroy infrastructure in hcloud"
	@echo " - plan: plan infrastructure in hcloud"
	@echo " - proxy: proxies k8s API to port 8001"

init:
	terraform -chdir=./stacks/tambouille/main init

apply: init
	rm -f ~/.ssh/known_hosts
	terraform -chdir=./stacks/tambouille/main apply -auto-approve -var-file="$$USER.tfvars" -target module.marmite
	terraform -chdir=./stacks/tambouille/main apply -auto-approve -var-file="$$USER.tfvars"

plan: init
	terraform -chdir=./stacks/tambouille/main plan -var-file="$$USER.tfvars"

destroy: init
	terraform -chdir=./stacks/tambouille/main destroy -auto-approve -var-file="$$USER.tfvars" -target module.marmite
	terraform -chdir=./stacks/tambouille/main destroy -auto-approve -var-file="$$USER.tfvars"

proxy:
	kubectl --kubeconfig ./var/kube/marmite proxy

marmite:

ustensiles: marmite
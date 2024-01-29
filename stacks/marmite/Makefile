help:
	@echo "Commands :"
	@echo " - apply: provision infrastructure in hcloud"
	@echo " - destroy: destroy infrastructure in hcloud"
	@echo " - plan: plan infrastructure in hcloud"
	@echo " - proxy: proxies k8s API to port 8001"

init:
	terraform init

apply: init
	rm -f ~/.ssh/known_hosts
	terraform apply -auto-approve -var-file="$$USER.tfvars" -target module.marmite
	terraform apply -auto-approve -var-file="$$USER.tfvars"

plan: init
	terraform plan -var-file="$$USER.tfvars"

destroy: init
	terraform destroy -auto-approve -var-file="$$USER.tfvars" -target module.marmite
	terraform destroy -auto-approve -var-file="$$USER.tfvars"

proxy:
	kubectl --kubeconfig ./var/kube/marmite proxy

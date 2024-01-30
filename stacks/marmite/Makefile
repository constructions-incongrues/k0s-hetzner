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
	terraform apply -auto-approve

plan: init
	terraform plan

destroy: init
	terraform destroy -auto-approve

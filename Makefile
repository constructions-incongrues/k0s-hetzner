tambouille:
	terraform -chdir=./stacks/tambouille init -upgrade
	terraform -chdir=./stacks/tambouille apply -var-file=../../var/local.tfvars

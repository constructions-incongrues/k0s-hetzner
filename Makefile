tambouille:
	terraform -chdir=./stacks/tambouille init -upgrade
	terraform -chdir=./stacks/tambouille apply -var-file=../../var/local.tfvars

kubeconfig:
	terraform -chdir=./stacks/marmite output -raw kubeconfig > ./var/kubeconfig

proxy: kubeconfig
	KUBECONFIG=./var/kubeconfig kubectl proxy
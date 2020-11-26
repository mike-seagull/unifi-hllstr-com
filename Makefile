.PHONY: terraform ansible

install-deps:
ifeq (, $(shell which lpass))
ifeq ("iSH", "$(shell uname -v | head -c 3)")
	apk add lastpass-cli
endif
else
	@echo "lpass already installed"
endif
ifeq (, $(shell which ansible))
ifeq ($(shell uname -s),Darwin)
	brew install ansible
endif
ifeq ("iSH", "$(shell uname -v | head -c 3)")
	apk add ansible
endif
else
	@echo "ansible already installed"
endif
ifeq (, $(shell which terraform))
ifeq ($(shell uname -s),Darwin)
	brew tap hashicorp/tap && brew install hashicorp/tap/terraform
endif
ifeq ("iSH", "$(shell uname -v | head -c 3)")
	apk add terraform --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
endif
else
	@echo "terraform already installed"
endif

terraform:
	cd terraform; \
	terraform init; \
	terraform apply -auto-approve -var="hostname=$(HOSTNAME)" -var="displayname=$(DISPLAYNAME)"

secrets:
	@echo $(LASTPASS_MASTER_PASSWORD) | LPASS_DISABLE_PINENTRY=1 lpass login $(LASTPASS_USERNAME)
	@lpass show --quiet cloud_infra --attach att-5460398583978776677-57752 > ./.env
	@lpass show --quiet cloud_infra --attach att-5460398583978776677-88606 > ./terraform/ociconfig.auto.tfvars 
	@lpass logout --force

tf-valid: terraform-validate

terraform-validate:
	cd terraform; \
	terraform init; \
	terraform validate; \
	terraform plan \
		-var "tenancy=$(TERRAFORM_TENANCY)" \
		-var "user=$(TERRAFORM_USER)" \
		-var "fingerprint=$(TERRAFORM_FINGERPRINT)" \
		-var "keypath=$(TERRAFORM_KEYPATH)" \
		-var "subnetid=$(TERRAFORM_SUBNETID)" \
		-var "sshkeyfile=$(TERRAFORM_SSHKEYFILE)" \
		-var "hostname=$(HOSTNAME)" \
		-var "displayname=$(DISPLAYNAME)"
terraform:
	cd terraform; \
	terraform init; \
	terraform apply -auto-approve \
		-var "tenancy=$(TERRAFORM_TENANCY)" \
		-var "user=$(TERRAFORM_USER)" \
		-var "fingerprint=$(TERRAFORM_FINGERPRINT)" \
		-var "keypath=$(TERRAFORM_KEYPATH)" \
		-var "subnetid=$(TERRAFORM_SUBNETID)" \
		-var "sshkeyfile=$(TERRAFORM_SSHKEYFILE)" \
		-var "hostname=$(HOSTNAME)" \
		-var "displayname=$(DISPLAYNAME)"

tf: terraform

terraform-clean:
	cd terraform; \
	terraform destroy -auto-approve \
		-var "tenancy=$(TERRAFORM_TENANCY)" \
		-var "user=$(TERRAFORM_USER)" \
		-var "fingerprint=$(TERRAFORM_FINGERPRINT)" \
		-var "keypath=$(TERRAFORM_KEYPATH)" \
		-var "subnetid=$(TERRAFORM_SUBNETID)" \
		-var "sshkeyfile=$(TERRAFORM_SSHKEYFILE)" \
		-var "hostname=$(HOSTNAME)" \
		-var "displayname=$(DISPLAYNAME)" \
	&& \
	(rm -rf .terraform; \
	rm -rf *.tfstate; \
	rm -rf *.tfstate.*)

tf-clean: terraform-clean
ansible:
	ansible-playbook  --inventory $(DOMAIN), --extra-vars "sshgroup=$(ROLE_SSHGROUP) username=$(ROLE_USERNAME) password=$(ROLE_PASSWORD) domain=$(DOMAIN) email=$(EMAIL)" --user ubuntu --private-key $(HOME)/.ssh/id_rsa unifi.yml

clean: terraform-clean

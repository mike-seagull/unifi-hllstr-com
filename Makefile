.PHONY: terraform ansible

install-deps:
ifeq (, $(shell which ansible))
ifeq ($(shell uname -s),Darwin)
	brew install ansible
endif
ifneq ($(filter %86,$(shell uname -p)),)
	apk add ansible
endif
else
	@echo "Ansible already installed"
endif
ifeq (, $(shell which terraform))
ifeq ($(shell uname -s),Darwin)
	brew tap hashicorp/tap && brew install hashicorp/tap/terraform
endif
ifneq ($(filter %86,$(shell uname -p)),)
	apk add terraform --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
endif
else
	@echo "Terraform already installed"
endif

terraform:
	cd terraform; \
	terraform init; \
	terraform apply -auto-approve -var="hostname=$(HOSTNAME)" -var="displayname=$(DISPLAYNAME)"

tf: terraform

terraform-clean:
	cd terraform; \
	terraform destroy -auto-approve -var="hostname=$(HOSTNAME)" -var="displayname=$(DISPLAYNAME)" && \
	(rm -rf .terraform; \
	rm -rf *.tfstate; \
	rm -rf *.tfstate.*)

tf-clean: terraform-clean
ansible:
	ansible-playbook  --inventory $(DOMAIN), --extra-vars "domain=$(DOMAIN) email=$(EMAIL)" --user ubuntu --private-key $(HOME)/.ssh/id_rsa unifi.yml

clean: terraform-clean
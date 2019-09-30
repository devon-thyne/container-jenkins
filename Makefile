# Will install docker onto clean host and then perform the following configurations:
#     Pass necessary files including terraform configuration to host machine
#     Create new jenkins docker container
#     Pass necessary files to container
#     Create jenkins job and execute it to standup and test terraform configuration
new-host:
	rm -f jenkins-admin-password.txt
	ansible-playbook -i $(host), install-docker.yml
	ansible-playbook -i $(host), config-host.yml

# Assumes docker in already installed on remote host. Only performs the following configurations:
#     Pass necessary files including terraform configuration to host machine
#     Create new jenkins docker container
#     Pass necessary files to container
#     Create jenkins job and execute it to standup and test terraform configuration
existing-host:
	rm -f jenkins-admin-password.txt
	ansible-playbook -i $(host), config-host.yml

# Tells running jenkins docker container previosuly create to destroy terraform configuration
terraform-destroy:
	ansible-playbook -i $(host), destroy-terraform.yml

# Full tear down everthing. Will destroy the terraform configuration and remove docker container from host.
clean:
	ansible-playbook -i $(host), destroy-terraform.yml
	ansible-playbook -i $(host), clean.yml

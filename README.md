# container-jenkins

***

Using an Ansible playbook, this code deploys a jenkinsci/blueocean container on a remote host that runs a Jenkins pipeline to stand up and test a Terraform configuration.

## Objective

Have an ephemeral way to be able to apply and test a Terraform configuration using a Jenkins pipeline with no reliance on existing infrastructure.

## Assumptions

* Local machine with Ansible successfully installed
* Remote machine running RHEL 7.6 with the ability to remote access with an SSH private key.

## Usage Instructions

1 Put a folder in your Terraform configuration directory called `tests/' to house any shell unit test scripts to run against the Terraform configuration.
  ```
  mkdir tests
  ```

2 Clone this repository into directory on your local machine with Terraform configuration (next to the tests/ directory).
  ```
  git clone https://REDACTED/container-jenkins
  ```

3 Suggestion: After cloning the repository, it is advised to go into the `container-jenkins` folder and deleting the `.git` and `.gitignore` files if you wish to check the whole Terraform configuration above into source control. Having these nested git files may lead to submodule problems.
  ```
  sudo rm -R .git
  sudo rm .gitignore
  ```
  
4 From within the `container-jenkins` directory, run appropriate `make` command for your use case.

* On a remote machine that does **not** have Docker installed, to stand up and test your terraform configuration and **also** install Docker run the following make command:
  ```
  make new-host host=<HOSTNAME or IP>
  ```
  
* On a remote machine that **already** has Docker installed, to stand up and test your terraform configuration run the following command:
  ```
  make existing-host host=<HOSTNAME or IP>
  ```
  
5 To loging to the Jenkins server to check on the status of the pipeline execution, please visit the following URL with the same <HOSTNAME or IP> as used above in the `make` command.
  ```
  http://<HOSTNAME or IP>:8080
  ```
  
6 To login to the Jenkins server, please see the contents of the output file already create in the directory on your local machine in the same directory as you ran the `make` command. This contains the admin password for the Jenkins server.
  ```
  cat jenkins-admin-password.txt
  ```
  
At this point, there should be a running dockerized Jenkins server running on your remote host machine with the pipeline execution information for your Terraform configuration. As you make changes to your Terraform, the same `make` command can be run again and again to repeat the process.

## Make Commands

| Command                                      | Description        |
| -------------------------------------------- | ------------------ |
| make new-host host=<HOSTNAME or IP>          | First installed Docker on remote host, then configures it to then run a dockerized Jenkins container and automatically run a pipeline to stand up and test Terraform configuration |
| make existing-host host=<HOSTNAME or IP>     | Configures remote host to run a dockerized Jenkins container and automatically run a pipeline to stand up and test Terraform configuration |
| make terraform-destroy host=<HOSTNAME or IP> | Destroys existing Terraform configuration infrastructure stood up through the above make commands |
| make clean host=<HOSTNAME or IP>             | Destroys existing Terraform configuration infrastructure stood up through the above make commands. Also, remove Docker container and all directories and files copied to remote host, essentially cleaning up host of all changes made by this module |

## File Inventory

| File                    | Description        |
| ----------------------- | ------------------ |
| Dockerfile              | The custom Dockerfile that adds needed layer to base jenkinsci/blueocean Docker image. Ports over necessary files and directories from remote host to Docker container. |
| Makefile                | The Makefile containing the definitions for the `Make Command` defined in the section above. |
| clean.yml               | The Ansible playbook that fully wipes the host machine of any changes made by this module, essentially leaving no trace that this module was ever run against the host after it has run. |
| config-host.yml         | The main Ansible playbook that performs the configuration on the host machine, spins up the Docker container and runs necessary scripts on the Jenkins server after it has finished initializing to run the pipeline. |
| destroy-terraform.sh    | A bash script to get copied to the remote host to help it communicate with its running Docker container to tell it to destroy the Terraform configuration. |
| destroypterraform.yml   | The Ansible playbook to remote execute the destroy-terraform.sh script defined in the row above on the remote host. |
| execute-pipeline.sh     | A bash script to get copied to the remote host to help it commicate to its running Docker container to run the Jenkins pipeline. |
| get-admin-password.sh   | A bash script to get copied to the remote host to help it extract the Jenkins server admin password after it has finished initialization in order to communicate that back to the user for use to authenticate with the now running Jenkins pipeline. |
| install-docker.yml      | The Ansible playbook to install and run Docker on the remote host. |
| wait-for-init.sh        | A bash script to get copied to the remote host to help it wait for the Jenkins server to finish its initialization process before executing scripts against it. |

## Tools and Versions Used

* Ansible 2.7.8
* Terraform 0.12.2
* Docker 18.09.6
* Jenkins Pipeline (Taken from Jenkinsci/Blueocean image from Docker Hub)

## Unit Testing

Within the Terraform configuration's directory, there is to be an additional directory named `tests/` to house any user defined unit tests to run against the Terraform configuration post-apply. At the moment, this extension of the module is unfinished. This Proof of Concept demonstrates that two sample test scripts (test1.sh and test2.sh) housed within this directory can successfully get passed to the Jenkins server and executed within the pipeline. This feature does not yet dynamically pass and execute any unit test scripts stored in this location. For now the two filenames are hard coded directly into the pipeline definition.

## Thanks to...

* [https://hub.docker.com/r/jenkinsci/blueocean/](https://hub.docker.com/r/jenkinsci/blueocean/)
* [https://wiki.jenkins.io/display/JENKINS/Jenkins+CLI](https://wiki.jenkins.io/display/JENKINS/Jenkins+CLI)
* [https://techbloc.net/archives/3537](https://techbloc.net/archives/3537)
* [https://medium.com/@schogini/running-docker-inside-and-outside-of-a-jenkins-container-along-with-docker-compose-a-tiny-c908c21557aa](https://medium.com/@schogini/running-docker-inside-and-outside-of-a-jenkins-container-along-with-docker-compose-a-tiny-c908c21557aa)

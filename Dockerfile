# jenkinsci/blueocean base image setup to and test run terraform configurations in pipeline
FROM jenkinsci/blueocean

WORKDIR /home/root

# Swtich to root user
USER root

# Copy terraform binary to container and add to root user's path
RUN mkdir Terraform
ADD terraform ./Terraform/
RUN chmod +x ./Terraform/terraform
ENV PATH=$PATH:/home/root/Terraform

# Copy terraform configuration files to container
RUN mkdir terraform-configuration
ADD terraform-configuration/*.tf ./terraform-configuration/
ADD terraform-configuration/*.tfvars ./terraform-configuration/

# Copy tests scripts to contianer
RUN mkdir tests
ADD tests/*.sh ./tests/

# Copy jenkins pipeline execution script to container
ADD execute-pipeline.sh ./


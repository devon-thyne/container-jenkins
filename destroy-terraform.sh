#!/bin/bash

sudo docker exec -it jenkins-master bash -c 'cd /home/root/terraform-configuration; terraform destroy -auto-approve /home/root/terraform-configuration'

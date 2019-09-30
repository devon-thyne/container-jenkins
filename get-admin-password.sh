#!/bin/bash

sudo docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword > /home/ec2-user/jenkins-admin-password.txt

#!/bin/bash

##### Script to perform proper setup then run a jenkins pipeline in container

JENKINS_SERVER=http://localhost:8080
JENKINS_CLI_JAR=/var/jenkins_home/war/WEB-INF/jenkins-cli.jar

# get jenkins server admin password
ADMIN_PASSWD=$(cat /var/jenkins_home/secrets/initialAdminPassword)

# build jenkins job dynamically from terraform configuration passed to container
cat > terraform-config.xml <<- EOM
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.32">
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.plugins.jira.JiraProjectProperty plugin="jira@3.0.7"/>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.70">
    <script>pipeline {
    agent any
    stages {
        stage(&apos;TF Init&apos;) {
            steps {
                ws('/home/root/terraform-configuration') {
                    sh 'pwd'
                    sh 'terraform init --backend-config backend.tfvars'
                }
            }
        }
        stage(&apos;TF Apply&apos;) {
            steps {
                ws('/home/root/terraform-configuration') {
                    sh 'pwd'
                    sh 'terraform apply -auto-approve /home/root/terraform-configuration'
                }
            }
        }
        stage(&apos;Testing&apos;) {
            steps {
                ws('/home/root/tests') {
                    sh 'pwd'
                    sh 'bash test1.sh'
                    sh 'bash test2.sh'
                }
            }
        }
    }
}</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOM

# create job in jenkins server
java -jar $JENKINS_CLI_JAR -s $JENKINS_SERVER -auth admin:$ADMIN_PASSWD create-job terraform-config < terraform-config.xml 

# run jenkins pipeline
java -jar $JENKINS_CLI_JAR -s $JENKINS_SERVER -auth admin:$ADMIN_PASSWD build terraform-config


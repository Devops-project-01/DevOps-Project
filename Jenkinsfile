pipeline {

agent any

environment {
    SVC_ACCOUNT_KEY = credentials('terraform-auth')
    GOOGLE_APPLICATION_CREDENTIALS = '/var/lib/jenkins/workspace/terraform_integration/SA_key.json'
  }

stages {

stage('Checkout') {

steps {
    checkout scm
//checkout([$class: 'GitSCM', branches: [[name: '*/naman']], extensions: [], userRemoteConfigs: [[url:'https://github.com/Devops-project-01/DevOps-Project.git']]])
}
}


stage ("terraform init") {

steps {
sh ('export GOOGLE_APPLICATION_CREDENTIALS=/var/lib/jenkins/workspace/terraform_integration/SA_key.json')
sh ('echo $GOOGLE_APPLICATION_CREDENTIALS')
dir("Terraform") {
    sh ('ls -al')
    sh ('terraform init')
}

}

}
stage ("terraform apply approval")
{
    steps
    {
        input message: 'Do you want to apply ', ok: 'yes do it'
    }
}
stage ("terraform Apply") {

steps {
dir("Terraform"){
echo "Terraform action is –> ${action}"

sh ("terraform ${action} --auto-approve")
}
}

}
stage ("Ansible apply")
{
    steps{
        ansiblePlaybook become: true, credentialsId: 'ssh_key', disableHostKeyChecking: true, forks: 5, installation: 'Ansible', inventory: 'Terraform/hosts.ini', playbook: 'Ansible/first_playook.yml'
    }
}
stage ("terraform destroy approval")
{
    steps
    {
        input message: 'Do you want to destroy ', ok: 'yes do it'
    }
}
stage ("terraform destroy") {

steps {
dir("Terraform"){

sh ("terraform destroy --auto-approve")
}
}

}

}
}

 
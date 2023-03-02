pipeline {
    agent any    
    parameters {
         choice(name: 'ENV', choices: ['dev', 'prod','terraform'], description: 'Chose Environment') 
    }
    stages {    
        stage('VPC') {
            steps {
              dir('VPC') {
                git branch: 'main', url: 'https://github.com/vamsi434/AWS-Glue-job.git'
                sh "terrafile -f env-${ENV}/Terrafile"  
                sh "terraform init"
                sh "terraform plan -var-file=${ENV}.tfvars"
                sh "terraform apply -var-file=${ENV}.tfvars -auto-approve"
              }                    
            }
        }

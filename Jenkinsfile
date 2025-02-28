pipeline {
    agent any
    environment {
        PROJECT_ID = "cts05-murgod"  
        LOCATION = "us-central1"  // Changed to uppercase for consistency
        CLUSTER_NAME = "main-cluster"
        SERVICE_NAME = "nginx-service"
        GOOGLE_APPLICATION_CREDENTIALS = credentials('default-sa-key')
    }
    stages {
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        
        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                // Removed -refresh-only flag to actually apply changes -refresh-only
                sh 'terraform apply -auto-approve'
            }
        }
        
        stage('Wait for Cluster Health') {
            steps {
                script {
                    timeout(time: 15, unit: 'MINUTES') {
                        waitUntil {
                            def status = sh(
                                // Changed to use LOCATION environment variable
                                script: "gcloud container clusters describe ${env.CLUSTER_NAME} --location ${env.LOCATION} --format='value(status)'",
                                returnStdout: true
                            ).trim()
                            
                            echo "Cluster status: ${status}"
                            return status == "RUNNING"
                        }
                    }
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                sh """
                    gcloud container clusters get-credentials ${env.CLUSTER_NAME} \
                        --location ${env.LOCATION} \
                        --project ${env.PROJECT_ID}
                    kubectl apply -f app.yaml
                """
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        waitUntil {
                            def lbIp = sh(
                                script: "kubectl get svc ${env.SERVICE_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
                                returnStdout: true
                            ).trim()
                            return lbIp != ""
                        }
                    }
                }
            }
        }
        
        stage('Load Test with Siege') {
            steps {
                sh """
                    sudo apt update
                    sudo apt install -y siege
                    LB_IP=\$(kubectl get svc ${env.SERVICE_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                    echo "Testing Load Balancer IP: http://\${LB_IP}/"
                    siege -c 250 -t 10M http://\${LB_IP}/
                """
            }
        }
    }
    post {
        always {
            echo "Pipeline completed"
        }
    }
}
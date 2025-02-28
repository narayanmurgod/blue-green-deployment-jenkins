pipeline {
    agent any
    environment {
        PROJECT_ID = "cts05-murgod"  
        location = "us-central1"
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
                sh 'terraform apply -refresh-only -auto-approve'
            }
        }
        
        stage('Wait for Cluster Health') {
            steps {
                script {
                    timeout(time: 15, unit: 'MINUTES') {
                        waitUntil {
                            def status = sh(
                                script: "gcloud container clusters describe ${CLUSTER_NAME} --location ${location} --format='value(status)'",
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
                    gcloud container clusters get-credentials ${CLUSTER_NAME} \
                        --location ${location} \
                        --project ${PROJECT_ID}
                    kubectl apply -f app.yaml
                """
                // Wait for service to get external IP
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        waitUntil {
                            def lbIp = sh(
                                script: "kubectl get svc ${SERVICE_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
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
                    LB_IP=\$(kubectl get svc ${SERVICE_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                    echo "Testing Load Balancer IP: http://\${LB_IP}/"
                    siege -c 250 -t 10M http://\${LB_IP}/
                """
            }
        }
    }
    post {
        always {
            // Cleanup steps (optional)
            echo "Pipeline completed"
        }
    }
}
pipeline {
    agent { label 'linux agent' }   // run only on your EC2 Jenkins agent

    environment {
        IMAGE_NAME = "19901418/my-jenkins-python-app-ci-cd"
        IMAGE_TAG  = "v1"
        K8S_NODE_IP = "18.222.142.100"   // replace with your k8s node public IP
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/1418-jatin/beginner-html-site-styled.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Run kubectl on k8s-node via SSH
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkin-cred', keyFileVariable: 'PEM_KEY')]) {
                    sh '''
                    ssh -i "$PEM_KEY" -o StrictHostKeyChecking=no ubuntu@"$K8S_NODE_IP" "mkdir -p ~/k8s"
                    scp -i "$PEM_KEY" -o StrictHostKeyChecking=no deployment.yml service.yml ubuntu@"$K8S_NODE_IP":~/k8s/
                    ssh -i "$PEM_KEY" -o StrictHostKeyChecking=no ubuntu@"$K8S_NODE_IP" '
                        kubectl delete deployment beginner-html-deployment --ignore-not-found=true &&
                        kubectl delete service beginner-html-service --ignore-not-found=true &&
                        kubectl apply -f ~/k8s/deployment.yml &&
                        kubectl apply -f ~/k8s/service.yml &&
                        kubectl rollout status deployment/beginner-html-deployment
                    '
                    '''
                }
            }
        }
    }

    triggers {
        githubPush()
    }
}

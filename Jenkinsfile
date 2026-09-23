pipeline {
    agent { label 'linux agent' }

    environment {
        IMAGE_NAME = "19901418/my-jenkins-python-app-ci-cd"
        IMAGE_TAG  = "${BUILD_NUMBER}"   // was the fixed string "v1"
    }

    stages {
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
                sh '''
                    sed -i "s|image:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|" deployment.yml

                    kubectl --kubeconfig=/home/ubuntu/.kube/config delete deployment beginner-html-deployment --ignore-not-found=true
                    kubectl --kubeconfig=/home/ubuntu/.kube/config delete service beginner-html-service --ignore-not-found=true
                    kubectl --kubeconfig=/home/ubuntu/.kube/config apply -f deployment.yml
                    kubectl --kubeconfig=/home/ubuntu/.kube/config apply -f service.yml
                    kubectl --kubeconfig=/home/ubuntu/.kube/config rollout status deployment/beginner-html-deployment
                '''
            }
        }
    }

    triggers {
        githubPush()
    }
}

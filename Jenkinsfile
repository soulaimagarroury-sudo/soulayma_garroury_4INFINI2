pipeline {
    agent any

    environment {
        IMAGE_NAME = "soulayma1/student-management"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-private-token',
                    url: 'https://github.com/soulaimagarroury-sudo/soulayma_garroury_4INFINI2.git',
                    branch: 'main'
            }
        }

        stage('Build (Maven)') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                // Login to Docker Hub before building
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                       echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                       docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                       docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                       echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                       docker push ${IMAGE_NAME}:${IMAGE_TAG}
                       docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        } 
        stage('Deploy to Kubernetes') {
           steps {
            sh '''
            # Utiliser le contexte Minikube
            kubectl config use-context minikube

            # Déployer MySQL
            kubectl apply -n devops -f k8s/mysql-pvc.yaml
            kubectl apply -n devops -f k8s/mysql-deployment.yaml
            kubectl apply -n devops -f k8s/mysql-service.yaml

            # Déployer Spring Boot
            kubectl apply -n devops -f k8s/spring-deployment.yaml
            kubectl apply -n devops -f k8s/spring-service.yaml

            # Mettre à jour l'image du déploiement Spring Boot
            kubectl -n devops set image deployment/springboot-app springboot-app=soulayma1/student-management:61

            # Attendre que le déploiement Spring Boot soit prêt
            kubectl -n devops rollout status deployment/springboot-app --timeout=180s
        '''
    }
}

    }

    post {
        success {
            echo "Pipeline finished SUCCESS - image: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline FAILED"
        }
    }
}

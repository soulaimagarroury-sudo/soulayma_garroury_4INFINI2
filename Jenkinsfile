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

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                       # Login Docker Hub
                       echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                       # Build image
                       docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                       docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest

                       # Push images
                       docker push ${IMAGE_NAME}:${IMAGE_TAG}
                       docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        } 

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Configurer l'environnement Docker pour Minikube
                    def dockerEnvOutput = sh(script: 'minikube -p minikube docker-env', returnStdout: true).trim()
                    sh "eval \"${dockerEnvOutput}\""

                    // Appliquer les fichiers YAML si présents
                    def k8sFiles = [
                        'k8s/mysql-pvc.yaml',
                        'k8s/mysql-deployment.yaml',
                        'k8s/mysql-service.yaml',
                        'k8s/spring-deployment.yaml',
                        'k8s/spring-service.yaml'
                    ]

                    for (f in k8sFiles) {
                        sh """
                            if [ -f "$f" ]; then
                                echo "Applying $f"
                                kubectl apply -n devops -f "$f"
                            else
                                echo "File $f not found, skipping..."
                            fi
                        """
                    }

                    // Supprimer les pods Spring Boot existants pour éviter le blocage
                    sh 'kubectl -n devops delete pod -l app=springboot-app --ignore-not-found'

                    // Mettre à jour l'image du déploiement Spring Boot si le déploiement existe
                    sh '''
                        if kubectl get deployment springboot-app -n devops > /dev/null 2>&1; then
                            kubectl -n devops set image deployment/springboot-app springboot-app=${IMAGE_NAME}:${IMAGE_TAG} --record
                            kubectl -n devops rollout status deployment/springboot-app --timeout=300s
                        else
                            echo "Deployment springboot-app not found, skipping image update."
                        fi
                    '''
                }
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

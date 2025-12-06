pipeline {
    agent any

    environment {
        IMAGE_NAME = "soulayma1/student-management"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        K8S_DIR    = "k8s"
        NAMESPACE  = "devops"
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Sélectionne le contexte Minikube
                sh "kubectl config use-context minikube || true"

                // Déploiement des manifests K8s
                sh "kubectl apply -n ${NAMESPACE} -f ${K8S_DIR}/mysql-pvc.yaml || true"
                sh "kubectl apply -n ${NAMESPACE} -f ${K8S_DIR}/mysql-deployment.yaml"
                sh "kubectl apply -n ${NAMESPACE} -f ${K8S_DIR}/spring-deployment.yaml"
                sh "kubectl apply -n ${NAMESPACE} -f ${K8S_DIR}/spring-service.yaml"

                // Met à jour l'image du déploiement Spring Boot
                sh "kubectl -n ${NAMESPACE} set image deployment/springboot-app springboot-app=${IMAGE_NAME}:${IMAGE_TAG} --record || true"
                
                // Vérifie le rollout pour s'assurer que le déploiement est terminé
                sh "kubectl -n ${NAMESPACE} rollout status deployment/springboot-app --timeout=120s"
            }
        }
    }

    post {
        success {
            echo "Pipeline finished SUCCESS - ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline FAILED"
        }
    }
}

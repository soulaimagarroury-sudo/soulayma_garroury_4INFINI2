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
                script {
                    try {
                        // Sélection du contexte Minikube
                        sh "kubectl config use-context minikube"

                        // Appliquer les manifests Kubernetes
                        def k8sFiles = ['mysql-pvc.yaml', 'mysql-deployment.yaml', 'mysql-service.yaml', 'spring-deployment.yaml', 'spring-service.yaml']
                        for (file in k8sFiles) {
                            def filePath = "${K8S_DIR}/${file}"
                            if (fileExists(filePath)) {
                                sh "kubectl apply -n ${NAMESPACE} -f ${filePath}"
                            } else {
                                echo "⚠️  Fichier manquant : ${filePath} (ignoring)"
                            }
                        }

                        // Mettre à jour l'image du déploiement Spring Boot
                        sh "kubectl -n ${NAMESPACE} set image deployment/springboot-app springboot-app=${IMAGE_NAME}:${IMAGE_TAG} --record"

                        // Vérifier le rollout
                        sh "kubectl -n ${NAMESPACE} rollout status deployment/springboot-app --timeout=120s"
                    } catch (Exception e) {
                        error "Déploiement Kubernetes échoué : ${e}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline finished SUCCESS - ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline FAILED"
        }
    }
}

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

        stage('Docker Build (Minikube)') {
            steps {
                sh '''
                   # Configurer Docker pour Minikube
                   $(minikube -p minikube docker-env --shell bash)

                   # Build l'image directement dans Minikube
                   docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                   docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest

                   docker images
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                   kubectl config use-context minikube

                   for f in k8s/mysql-pvc.yaml k8s/mysql-deployment.yaml k8s/mysql-service.yaml k8s/spring-deployment.yaml k8s/spring-service.yaml; do
                       if [ -f "$f" ]; then
                           echo "Applying $f"
                           kubectl apply -n devops -f "$f"
                       else
                           echo "File $f not found, skipping..."
                       fi
                   done

                   kubectl -n devops patch deployment springboot-app \
                     -p '{"spec":{"template":{"spec":{"containers":[{"name":"springboot-app","image":"'"${IMAGE_NAME}:${IMAGE_TAG}"'","imagePullPolicy":"Never"}]}}}}'

                   kubectl -n devops delete pod -l app=springboot-app --ignore-not-found
                   kubectl -n devops rollout status deployment/springboot-app --timeout=600s
                   kubectl -n devops get pods -o wide
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

pipeline {
    agent any
    environment {
        DOCKER_USER = 'soulayma1'
        DOCKER_PASS = credentials('docker-hub-password') // ID de tes credentials dans Jenkins
    }
    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/soulaimagarroury-sudo/soulayma_garroury_4INFINI2.git'
            }
        }
        stage('Build (Maven)') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }
        stage('Docker Build & Push') {
            steps {
                sh '''
                    eval $(minikube docker-env)
                    docker build -t soulayma1/student-management:61 .
                    docker tag soulayma1/student-management:61 soulayma1/student-management:latest
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push soulayma1/student-management:61
                    docker push soulayma1/student-management:latest
                '''
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl config use-context minikube
                    kubectl apply -n devops -f k8s/mysql-pvc.yaml
                    kubectl apply -n devops -f k8s/mysql-deployment.yaml
                    kubectl apply -n devops -f k8s/mysql-service.yaml
                    kubectl apply -n devops -f k8s/spring-deployment.yaml
                    kubectl apply -n devops -f k8s/spring-service.yaml
                    kubectl -n devops rollout status deployment/springboot-app --timeout=180s
                '''
            }
        }
    }
    post {
        success {
            echo "✅ Déploiement terminé avec succès !"
        }
        failure {
            echo "❌ Déploiement échoué !"
        }
    }
}

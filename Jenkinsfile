pipeline {
    agent any

    environment {
        DOCKER_USER = 'soulayma1'
        DOCKER_PASS = credentials('dockerhub-cred') // Ton credential DockerHub dans Jenkins
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/soulaimagarroury-sudo/soulayma_garroury_4INFINI2.git',
                    credentialsId: 'github-private-token'
            }
        }

        stage('Build (Maven)') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker build -t soulayma1/student-management:latest .'
                    sh 'docker push soulayma1/student-management:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Configurer Docker pour Minikube
                    sh 'eval $(minikube -p minikube docker-env)'

                    // Appliquer les fichiers Kubernetes
                    sh 'kubectl apply -f k8s/mysql-pvc.yaml'
                    sh 'kubectl apply -f k8s/mysql-deployment.yaml -n devops'
                    sh 'kubectl apply -f k8s/spring-deployment.yaml -n devops'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès 🚀'
        }
        failure {
            echo 'Pipeline échoué ❌'
        }
    }
}

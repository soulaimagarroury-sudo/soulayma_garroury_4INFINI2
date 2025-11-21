pipeline {
    agent any

    environment {
        // change this to your Docker Hub username and repository
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
                // Use the wrapper if present
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                // Build Docker image using the jar created in target/
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                // Also tag with latest
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Docker Push') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                          usernameVariable: 'DOCKER_USER', 
                                          passwordVariable: 'DOCKER_PASS')]) {
            script {
                docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                    docker.image("soulayma/student-management:${env.BUILD_NUMBER}").push()
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

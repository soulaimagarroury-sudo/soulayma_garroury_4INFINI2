pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "soulayma1/student-management"
        VERSION = "1.0"
        DOCKER_USER = credentials('dockerhub-cred').username
        DOCKER_PASS = credentials('dockerhub-cred').password
    }

    stages {

        stage('Checkout') {
            steps {
                git credentialsId: 'github-private-token',
                    url: 'https://github.com/soulaimagarroury-sudo/soulayma_garroury_4INFINI2.git'
            }
        }

        stage('Build (Maven)') {
            steps {
                sh "chmod +x mvnw"
                sh "./mvnw clean package -DskipTests"
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${VERSION} ."
                sh "docker tag ${DOCKER_IMAGE}:${VERSION} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Docker Push') {
            steps {
                sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                sh "docker push ${DOCKER_IMAGE}:${VERSION}"
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCESS ✔️"
        }
        failure {
            echo "Pipeline FAILED ❌"
        }
    }
}

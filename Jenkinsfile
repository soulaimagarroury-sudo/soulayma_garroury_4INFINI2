pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-private-token', 
                    url: 'https://github.com/soulaimagarroury-sudo/soulayma_garroury_4INFINI2.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
    }

    post {
        success {
            echo 'Build successful! Livrable généré.'
        }
        failure {
            echo 'Build failed!'
        }
    }
}

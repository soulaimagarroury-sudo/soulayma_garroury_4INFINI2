pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Récupération du code depuis le dépôt privé GitHub (branche main)
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/soulaimagarroury-sudo/soulayma_garroury_4INFINI2.git',
                        credentialsId: 'github-private-token'
                    ]]
                ])
            }
        }

        stage('Build') {
            steps {
                // Nettoyage et génération du livrable sans exécuter les tests
                sh 'mvn clean package -DskipTests'
            }
        }
    }

    post {
        success {
            echo '✅ Build successful! Livrable généré avec succès.'
        }
        failure {
            echo '❌ Build failed! Veuillez vérifier la console Jenkins.'
        }
    }
}

pipeline {
    agent any
    options {
        skipDefaultCheckout()
    }
    stages {
        stage('Clone') {
            steps {
                deleteDir()
                echo 'Pobieranie repozytorium...'
                sh 'git clone https://github.com/SaniolJR/ts_fork.git .'
            }
        }
        stage('Build') {
            steps {
                echo 'Budowanie obrazów z pliku Dockerfile.build...'
                sh 'docker build -f Dockerfile.build --target tester -t nest-api:test .'
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Uruchamianie testów...'
                sh 'docker run --rm nest-api:test'
            }
        }
        stage('Deploy Container') {
            steps {
                echo 'Wdrażanie do Minikube...'
                sh 'minikube kubectl -- apply -f nginx-deployment.yaml'
            }
        }
        stage('Smoke Test') {
            steps {
                echo 'Uruchamianie skryptu weryfikacyjnego (Timeout 60s)...'
                sh './verify_deploy.sh'
            }
        }
        stage('Publish') {
            steps {
                echo "Eksportowanie obrazu do pliku i archiwizacja w Jenkinsie..."
                // Zapisywanie obrazu do pliku .tar
                sh "docker save nest-api:${BUILD_NUMBER} -o nest-api-v${BUILD_NUMBER}.tar"
                // Archiwizacja pliku w Jenkinsie - to dodaje go do historii builda
                archiveArtifacts artifacts: "nest-api-v${BUILD_NUMBER}.tar", fingerprint: true
            }
        }
    }
    post {
        success { echo "✅ NARESZCIE SUKCES!" }
        failure { echo "❌ Coś jeszcze nie tak, ale jesteśmy blisko" }
    }
}

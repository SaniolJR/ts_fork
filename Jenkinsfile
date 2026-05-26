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
                sh "docker build -f Dockerfile.build --target tester -t nest-api:test -t nest-api:${BUILD_NUMBER} ."
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
                echo 'Budowanie obrazu wdrożeniowego v2...'
                sh "docker build -f Dockerfile.build --target runtime -t nest-api:v2 -t nest-api:${BUILD_NUMBER} ."

                echo 'Weryfikacja dostępu do działającego kontenera minikube...'
                sh 'docker ps --format "{{.Names}}" | grep -qx minikube'

                echo 'Ładowanie obrazu do runtime Minikube...'
                sh "docker save nest-api:v2 nest-api:${BUILD_NUMBER} -o nest-api-v${BUILD_NUMBER}.tar"
                sh "docker cp nest-api-v${BUILD_NUMBER}.tar minikube:/tmp/nest-api-v${BUILD_NUMBER}.tar"
                sh "docker exec minikube sh -lc 'ctr -n=k8s.io images import /tmp/nest-api-v${BUILD_NUMBER}.tar'"

                echo 'Wdrażanie do Minikube...'
                sh 'docker exec -i minikube kubectl apply -f - < nginx-deployment.yaml'
            }
        }
        stage('Smoke Test') {
            steps {
                echo 'Uruchamianie skryptu weryfikacyjnego (Timeout 60s)...'
                sh './verify_deploy_time.sh'
            }
        }
        stage('Publish') {
            steps {
                echo "Eksportowanie obrazu do pliku i archiwizacja w Jenkinsie..."
                // Zapisywanie obrazu do pliku .tar
                sh "docker save nest-api:v2 nest-api:${BUILD_NUMBER} -o nest-api-v${BUILD_NUMBER}.tar"
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

pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-swiggy-clone"
        IMAGE_TAG = "latest"
        CONTAINER_NAME = "react-app"
        PORT = "3001"
        SONARQUBE_ENV = "sq"
    }

    tools {
        nodejs 'node23'   // 👈 configure in Jenkins (Manage Jenkins → Tools)
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/SatyasaiA99/React_SwiggyClone_FrontEnd.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sq') {
                    script {
                        def scannerHome = tool 'sonar-scanner'
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=e-swiggy \
                        -Dsonar.sources=src \
                        -Dsonar.sourceEncoding=UTF-8
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Run Container') {
            steps {
                sh """
                docker rm -f ${CONTAINER_NAME} || true
                docker run -d -p ${PORT}:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline executed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs!"
        }
    }
}

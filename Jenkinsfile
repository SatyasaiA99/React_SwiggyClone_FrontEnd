pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-swiggy-clone"
        IMAGE_TAG = "latest"
        CONTAINER_NAME = "react-app"
        PORT = "3001"
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
        withSonarQubeEnv("${SONARQUBE_ENV}") {
            sh """
                sonar-scanner \
                -Dsonar.projectKey=e-swiggy \
                -Dsonar.sources=src \
                -Dsonar.sourceEncoding=UTF-8
            """
        }
    }
}

stage('Quality Gate') {
    steps {
        timeout(time: 2, unit: 'MINUTES') {
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
}

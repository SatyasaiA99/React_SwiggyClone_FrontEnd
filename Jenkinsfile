pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-swiggy-clone"
        IMAGE_TAG = "latest"
        CONTAINER_NAME = "react-app"
        PORT = "3001"
        SONARQUBE_ENV = "sq"

        NEXUS_URL = "http://3.108.41.69:8081"
        NEXUS_REPO = "Reactswiggy"
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
        stage('Package App') {
            steps {
                sh 'zip -r app.zip .'
            }
        }
        stage('Upload to Nexus') {
            steps {
                sh """
                curl -u admin:admin123 \
                --upload-file app.zip \
                ${NEXUS_URL}/repository/${NEXUS_REPO}/app-v1.zip
                """
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
    stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    echo "🚀 Deploying to Kubernetes..."

                    kubectl apply -f Deployment.yml
                    kubectl apply -f Service.yml

                    kubectl rollout status deployment/python-app-deployment
                    '''
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

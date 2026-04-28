pipeline {
    agent any

    environment {
        IMAGE_NAME = "satyasaia99/react-swiggy-clone"
        IMAGE_TAG = "${BUILD_NUMBER}"
        SONARQUBE_ENV = "sq"

        NEXUS_URL = "http://3.108.41.69:8081"
        NEXUS_REPO = "Reactswiggy"
    }

    tools {
        nodejs 'node23'
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
                        -Dsonar.sources=src
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
                sh 'zip -r app.zip dist'
            }
        }

        stage('Upload to Nexus') {
            steps {
                sh """
                curl -u admin:admin123 \
                --upload-file app.zip \
                ${NEXUS_URL}/repository/${NEXUS_REPO}/app-${BUILD_NUMBER}.zip
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'Dockerhub',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh """
                    echo $PASS | docker login -u $USER --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                    echo "🚀 Deploying to Kubernetes..."

                    # Apply YAML (safe if already exists)
                    kubectl apply -f Deployment.yml
                    kubectl apply -f Service.yml

                    # 🔥 IMPORTANT: update image
                    kubectl set image deployment/react-app-deployment \
                    react-container=${IMAGE_NAME}:${IMAGE_TAG}

                    # Wait for rollout
                    kubectl rollout status deployment/react-app-deployment
                    """
                }
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

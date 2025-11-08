pipeline {
  agent {
    docker {
      image 'docker.mgkim.net/jenkins/inbound-agent:rhel-ubi9-jdk17'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  triggers {
    githubPush()
  }

  environment {
    NEXUS_CREDS = credentials('nexus-credentials')
    CERT_FILE = 'client-cert.jks'
    DOCKER_IMAGE = 'docker.mgkim.net/app/sample-ci:latest'
  }

  stages {
    stages {
      stage('Test Docker Access') {
        steps {
          sh 'id && docker ps'
        }
      }
    }

    stage('Prepare Cert') {
      steps {
        withCredentials([string(credentialsId: 'CLIENT_CERT_JKS_B64', variable: 'CLIENT_CERT_JKS_B64')]) {
          sh """
            echo "$CLIENT_CERT_JKS_B64" | tr -d '\r\n' | base64 -d > ${CERT_FILE}
          """
        }
      }
    }

    stage('Prepare Maven settings.xml') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'nexus-credentials',
                           usernameVariable: 'NEXUS_USERNAME',
                           passwordVariable: 'NEXUS_PASSWORD')]) {
          sh """
              cat > settings.xml <<EOF
              <settings>
                <servers>
                  <server>
                    <id>maven-releases</id>
                    <username>${NEXUS_USERNAME}</username>
                    <password>${NEXUS_PASSWORD}</password>
                  </server>
                  <server>
                    <id>maven-snapshots</id>
                    <username>${NEXUS_USERNAME}</username>
                    <password>${NEXUS_PASSWORD}</password>
                  </server>
                </servers>
              </settings>
EOF
          """
        }
      }
    }

    stage('Login to nexus') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'nexus-credentials',
                           usernameVariable: 'NEXUS_USERNAME',
                           passwordVariable: 'NEXUS_PASSWORD')]) {
          sh """
            docker login docker.mgkim.net -u $NEXUS_USERNAME -p $NEXUS_PASSWORD
          """
        }
      }
    }

    stage('Build and Deploy docker') {
      steps {
        withCredentials([
          string(credentialsId: 'CLIENT_CERT_PASSWORD',
                 variable: 'CLIENT_CERT_PASSWORD')]) {
          sh """
            docker buildx build \
              --build-arg APP_NAME=sample-ci \
              --build-arg CLIENT_CERT_PASSWORD=${CLIENT_CERT_PASSWORD} \
              -t ${DOCKER_IMAGE} \
              --push .
          """
        }
      }
    }

    stage('Run docker container') {
      steps {
        sh """
          docker pull ${DOCKER_IMAGE}
          docker rm -f sample-ci
          docker run -d \
            --name sample-ci \
            -p 9999:9999 \
            ${DOCKER_IMAGE}
        """
      }
    }
  }
}
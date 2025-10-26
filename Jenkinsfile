pipeline {
  // agent { label 'docker-agent' }
  // agent any // jenkins host 에서 빌드 실행
  agent {
    docker {
      image 'docker.mgkim.net/jenkins/inbound-agent:rhel-ubi9-jdk17'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  
  environment {
    NEXUS_CREDS = credentials('nexus-credentials')
    // sh 'echo "nexus user: $NEXUS_CREDS_USR"'
    // sh 'echo "nexus password: $NEXUS_CREDS_PSW"'
    CERT_FILE = 'client-cert.jks'
  }
  
  stages {
    stage('Prepare Cert') {
      steps {
        withCredentials([string(credentialsId: 'CLIENT_CERT_JKS_B64', variable: 'CLIENT_CERT_JKS_B64')]) {
          sh """
            printf "%s" "$CLIENT_CERT_JKS_B64" | base64 -d > ${CERT_FILE}
          """
        }
      }
    }
    stage('Build and Deploy docker') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'nexus-credentials',
                           usernameVariable: 'NEXUS_USERNAME',
                           passwordVariable: 'NEXUS_PASSWORD'),
          string(credentialsId: 'CLIENT_CERT_PASSWORD',
                 variable: 'CLIENT_CERT_PASSWORD')]) {
          sh """
            docker login docker.mgkim.net -u $NEXUS_USERNAME -p $NEXUS_PASSWORD
            docker build \
              --build-arg APP_NAME=sample-ci \
              --build-arg NEXUS_USERNAME=${NEXUS_USERNAME} \
              --build-arg NEXUS_PASSWORD=${NEXUS_PASSWORD} \
              --build-arg CLIENT_CERT_PASSWORD=${CLIENT_CERT_PASSWORD} \
              -t docker.mgkim.net/app/sample-ci:latest .
          """
        }
      }
    }
    stage('Run docker container') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-credentials',
                                          usernameVariable: 'NEXUS_USERNAME',
                                          passwordVariable: 'NEXUS_PASSWORD')]) {
          sh """
            docker login docker.mgkim.net -u $NEXUS_USERNAME -p $NEXUS_PASSWORD
            docker pull docker.mgkim.net/docker-hosted/app/sample-ci:latest
            docker run -d \
              --name sample-ci \
              -p 9999:9999 \
              docker.mgkim.net/docker-hosted/app/sample-ci:latest
          """
        }
      }
    }
  }
}
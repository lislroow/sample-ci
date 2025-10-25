pipeline {
  // agent { label 'docker-agent' }
  
  environment {
    NEXUS_CREDS = credentials('nexus-credentials')
    // sh 'echo "nexus user: $NEXUS_CREDS_USR"'
    // sh 'echo "nexus password: $NEXUS_CREDS_PSW"'
  }
  
  stages {
    stage('Build and Deploy docker') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
          sh """
            docker login docker.mgkim.net -u $NEXUS_USERNAME -p $NEXUS_PASSWORD
            docker build \
              --build-arg NEXUS_USERNAME=${NEXUS_USERNAME} \
              --build-arg NEXUS_PASSWORD=${NEXUS_PASSWORD} \
              -t docker.mgkim.net/app/sample-ci:latest
          """
        }
      }
    }
    stage('Run') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
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
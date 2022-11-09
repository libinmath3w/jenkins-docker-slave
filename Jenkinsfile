
pipeline {
agent { dockerfile true }
  
        environment {
        DOCKER_TAG = getVersion()
    }
    stages {
        stage('Build') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/libinmath3w/hello-world-java-cicd.git'
            }
        }
        
         stage('Maven Build') {
            steps {
                    sh 'mvn clean package'
            }
        }
        stage('Podman Build') {
            steps{
                    sh "docker build . -t harbor.intrastream.cyou/hello-world-java/hello-java:${DOCKER_TAG}"
            }
        }
    } 
    
}
def getmykeyPath() {
    
}
def getVersion() {
    def commitHash = sh returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash;
}


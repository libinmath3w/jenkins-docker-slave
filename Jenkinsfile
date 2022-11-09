
pipeline {
agent { 
  dockerfile {
      filename 'DockerfileFromGit'
      args ' -v /var/run/docker.sock:/var/run/docker.sock'
  }
}
  
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
                    sh 'sudo chmod 777 /var/run/docker.sock'
                    sh "docker build . -t  harbor.intrastream.cyou/hello-world-java/hello-java:${DOCKER_TAG}"
            }
        }
      stage('Grype Check Sbom') {
            steps {
                    sh 'grype harbor.intrastream.cyou/hello-world-java/hello-java:${DOCKER_TAG} --scope AllLayers'
                    // grype with critical fail exit
                    //sh 'grype harbor.intrastream.cyou/hello-world-java/hello-java:${DOCKER_TAG} --scope AllLayers --fail-on=critical'
            }
        }
        
           stage('Syft Check Sbom') {
            steps{
                   sh "syft packages harbor.intrastream.cyou/hello-world-java/hello-java:${DOCKER_TAG}"
            }
        }
        
         stage('Podman push') {
            steps{
                withCredentials([string(credentialsId: 'harbor-pass', variable: 'harborpwd')]) {
                    sh "docker login harbor.intrastream.cyou -u demo -p ${harborpwd}"
                }
              // sh "podman push --tls-verify=false harbor.intrastream.cyou/hello-world-java/hello-java:${DOCKER_TAG}"
              sh "docker push harbor.intrastream.cyou/hello-world-java/hello-java:${DOCKER_TAG}"
               
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


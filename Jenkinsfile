pipeline {
   agent any
   environment {
       registry = "poizonhack/devops-img"
       GOCACHE = "/tmp"
   }
   stages {
       stage('Build') {
           agent {
               docker {
                   image 'golang'
               }
           }
           steps {
               // Create our project directory.
               sh 'cd ${GOPATH}/src'
               sh 'mkdir -p ${GOPATH}/src/hello-devops'
               // Copy all files in our Jenkins workspace to our project directory.               
               sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-devops'
               // Build the app.
               sh 'go build'              
           }    
       }
       stage('Test') {
           agent {
               docker {
                   image 'golang'
               }
           }
           steps {                
               // Create our project directory.
               sh 'cd ${GOPATH}/src'
               sh 'mkdir -p ${GOPATH}/src/hello-devops'
               // Copy all files in our Jenkins workspace to our project directory.               
               sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-devops'
               // Remove cached test results.
               sh 'go clean -cache'
               // Run Unit Tests.
               sh 'go test ./... -v -short'           
           }
       }
       stage('Publish Image') {
           environment {
               registryCredential = 'docker-hub_id'
           }
           steps{
               script {
                    def appimage = docker.build registry + ":$BUILD_NUMBER"
                  stage('Scan Image'){
                    sh '''
                       docker run -d --name db arminc/clair-db
                       sleep 15 # wait for db to come up
                       docker run -p 6060:6060 --link db:postgres -d --name clair arminc/clair-local-scan
                       sleep 1
                       DOCKER_GATEWAY=$(docker network inspect bridge --format "{{range .IPAM.Config}}{{.Gateway}}{{end}}")
                       wget -qO clair-scanner https://github.com/arminc/clair-scanner/releases/download/v8/clair-scanner_linux_amd64 && chmod +x clair-scanner
                       ./clair-scanner --ip="$DOCKER_GATEWAY" appimage || exit 0
                     '''
                     }
                   docker.withRegistry('https://registry.hub.docker.com', registryCredential ) {
                       appimage.push()
                       appimage.push('latest')
                   }
               }
           }
       }
       stage ('Deploy') {
           steps {
               script{
                   def image_id = registry + ":$BUILD_NUMBER"
                   sh "ansible-playbook  playbook.yaml --extra-vars \"image_id=${image_id}\""
               }
           }
       }
   }
}

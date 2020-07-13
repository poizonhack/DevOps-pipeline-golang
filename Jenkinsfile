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
                 
                  //stage('Scan Image'){
                   // sh '''
                     //   docker run -d --name db arminc/clair-db:latest
                      //  docker run -d --link db:postgres --name clair arminc/clair-local-scan:v2.0.6
                       // docker run --rm  -v /var/run/docker.sock:/var/run/docker.sock --network=container:clair ovotech/clair-scanner clair-scanner poizonhack/devops-img:$BUILD_NUMBER
                     //'''
                     //}
                   docker.withRegistry('https://registry.hub.docker.com', registryCredential ) {
                       appimage.push()
                       appimage.push('latest')
                   }
               }
           }
       }
       stage('Deploy App') {
    steps {
        withCredentials([
            string(credentialsId: 'token', variable: 'api_token')
            ]) 
             {
            // sh 'kubectl --token $api_token --server https://192.168.99.102:8443 --insecure-skip-tls-verify=true --validate=false apply -f playbook.yaml'
             script{
                   def image_id = registry + ":$BUILD_NUMBER"
                   sh "ansible-playbook  playbook.yaml --extra-vars \"image_id=${image_id}\""
               }
               }
            }
           }
   }
}

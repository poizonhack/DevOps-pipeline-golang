#!/usr/bin/env groovy
// The above line is used to trigger correct syntax highlighting.

pipeline {
    // Lets Jenkins use Docker for us later.
    agent any    

    environment {
        registry = "poizonhack/devops_img"
        GOCACHE = "/tmp"
    }

    // If anything fails, the whole Pipeline stops.
    stages {
        stage('Build') {   
            // Use golang.
            agent { docker { image 'golang:1.14' } }

            steps {                                           
                // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/app'

                // Copy all files in our Jenkins workspace to our project directory.                
                sh 'cp -r ${WORKSPACE}/*.go ${GOPATH}/src/app'

                // Build the app.
                sh 'go build'               
            }            
        }

        stage('Test') {
            // Use golang.
            agent { docker { image 'golang' } }

            steps {                 
                // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/app'

                // Copy all files in our Jenkins workspace to our project directory.
                sh 'cp -r ${WORKSPACE}/*.go ${GOPATH}/src/app'

                // Remove cached test results.
                sh 'go clean -cache'

                // Run Unit Tests.
                sh 'go test ./... -v -short'            
            }
        }    

        
        stage('Docker build') {
            environment {
                registryCredential = 'docker-hub_id'
            }
            steps{
                script {

                    def image = docker.build registry + ":v$BUILD_NUMBER" 

                    stage('Docker scan'){
                        sh '''
                        docker run -d --name db arminc/clair-db
                        sleep 15 # wait for db to come up
                        docker run -p 6060:6060 --link db:postgres -d --name clair arminc/clair-local-scan
                        sleep 1
                        DOCKER_GATEWAY=$(docker network inspect bridge --format "{{range .IPAM.Config}}{{.Gateway}}{{end}}")
                        wget -qO clair-scanner https://github.com/arminc/clair-scanner/releases/download/v8/clair-scanner_linux_amd64 && chmod +x clair-scanner
                        ./clair-scanner --ip="$DOCKER_GATEWAY" poizonhack/devops_img:v$BUILD_NUMBER || exit 0
                        docker stop $(docker ps -a -q)
                        docker rm $(docker ps -a -q)
                        '''
                    } 

                    // Use the Credential ID of the Docker Hub Credentials we added to Jenkins.
                    docker.withRegistry('', registryCredential ) {

                        // Push image and tag it with our build number for versioning purposes.
                        image.push()

                        image.push('latest')
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {

                    def image = registry + ":latest"

                    ansiblePlaybook(
                        playbook: '${WORKSPACE}/playbook.yaml',
                        extraVars: [
                            image: image
                        ],
                        disableHostKeyChecking: true,
                    )
                }
            }
        }  

        
    }

    post {
        always {
            // Clean up our workspace.
            deleteDir()
        }
    }
}   

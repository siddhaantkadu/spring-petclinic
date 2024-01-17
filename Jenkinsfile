pipeline {
    agent { label 'MAVEN' }
    options {
        // skipDefaultCheckout()
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    triggers {
        pollSCM('* * * * *')
    }
    stages {

        stage('Clean Workspace') {
            steps{
                cleanWs()
            }
        }

        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/siddhaantkadu/spring-petclinic.git',
                    branch: 'dev'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit testResults: '**/TEST-*.xml'
                }
            }
        }

        stage('Build Package') {
            steps {
                sh 'mvn clean package'
                stash name: 'SpringPetClinic',
                      includes: '**/spring-petclinic-*.jar'
                }
            post {
                success {
                    archiveArtifacts artifacts: '**/spring-petclinic-*.jar'

                }
            }
        }

        stage('Static Code Analysis') {
            steps {
                withSonarQubeEnv(installationName: 'SONAR_QUBE', credentialsId: 'SONAR_TOKEN') {
                    sh  """
                        mvn clean verify sonar:sonar \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.organization=jenkins-spring-petclinic \
                        -Dsonar.projectKey=jenkins-spring-petclinic_spring-petclinic
                        """
                }
            }
        }

        stage('Push Artifact') {
            steps { 
                rtUpload (
                    serverId: 'jfrog_artifactory',
                    spec: '''{
                        "files": [
                            {
                            "pattern": "**/spring-petclinic*.jar",
                            "target": "libs-snapshot-local/"
                            }
                        ]
                    }''',
                    buildName: "${JOB_NAME}-${BUILD_NUMBER}",
                    buildNumber: "${BUILD_NUMBER}",
                )
            }
            post {
                failure { 
                    slackSend channel: "#dcl-jenkins-jobs-notification",
                              message: "Sucessfully Published the artifact: ${JOB_NAME} ${BUILD_NUMBER} (<${BUILD_URL}|Open>)",
                              color: 'good'
                }                
            }
        }
        stage('OWASP DependencyCheck') {
            steps {
                dependencyCheck odcInstallation: 'OWASP_DEPENDENCY_CHECK',
                                additionalArguments: '''
                                                    -o "./" 
                                                    -s "./"
                                                    -f "ALL" 
                                                    --prettyPrint    
                                                    '''
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }
        stage('Docker Image Build') { 
            agent { label 'DOCKER'}
            steps {
                unstash name: 'SpringPetClinic'
                sh "docker image build -t siddhaant/springpetclinic:dev-${BUILD_NUMBER} ."
            }
        }
        stage('Trivy: Scan DockerImage') {
            agent { label 'DOCKER'}
            steps { 
                script {
                    sh "trivy image --format json -o trivy-report.json siddhaant/springpetclinic:dev-${BUILD_NUMBER}"
                }
                publishHTML([reportName: 'Trivy Vulnerability Report', reportDir: '.', reportFiles: 'trivy-report.json', keepAll: true, alwaysLinkToLastBuild: true, allowMissing: false])
            }
        }
        stage('Publish Docker Image') {
            agent { label 'DOCKER'}
            steps {
                    sh """
                        docker image push siddhaant/springpetclinic:dev-${BUILD_NUMBER}
                        docker image rm `docker image ls -q`
                       """
            }
        }
    }

    post {
     always {
        emailext attachLog: true,            
            subject: "${currentBuild.result}",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'devops.cloud.dcl@gmail.com',
        } 
     failure { 
        slackSend channel: "#dcl-jenkins-jobs-notification",
                    message: "${currentBuild.result} - ${JOB_NAME} ${BUILD_NUMBER} (<${BUILD_URL}|Open>)",
                    color: 'danger'
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'devops.cloud.dcl@gmail.com'                 
        }
    }          
}

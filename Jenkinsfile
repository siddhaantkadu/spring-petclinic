pipeline {
    agent { label 'MAVEN' }
    options {
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
                    mail subject: "'${currentBuild.result}'",
                         body: "Project: ${env.JOB_NAME}<br/>" +
                               "Build Number: ${env.BUILD_NUMBER}<br/>" +
                               "URL: ${env.BUILD_URL}<br/>",
                         to: 'siddhant.kadu@featurexcloud.com'  
                }
            }
        }

        stage('Static Code Analysis') {
            steps {
                withSonarQubeEnv(installationName: 'SONAR_CLOUD', credentialsId: 'SONAR_TOKEN') {
                    sh  """
                        mvn clean verify sonar:sonar \
                            -Dsonar.host.url=https://sonarcloud.io \
                            -Dsonar.organization=jenkins-spring-petclinic \
                            -Dsonar.projectKey=jenkins-spring-petclinic_spring-petclinic
                        """
                }
            }
        }

        stage('Quality Gate') {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
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
            steps {
                unstash name: 'SpringPetClinic'
                sh "docker image build -t siddhaant/springpetclinic:dev-${BUILD_NUMBER} ."
            }
        }

    //     stage('Trivy: Scan DockerImage') {
    //         steps { 
    //             script {
    //                 sh "trivy image --format table -o trivy-report.txt siddhaant/springpetclinic:dev-${BUILD_NUMBER}"
    //             }
    //             publishHTML([reportName: 'Trivy Vulnerability Report', reportDir: '.', reportFiles: 'trivy-report.txt', keepAll: true, alwaysLinkToLastBuild: true, allowMissing: false])
    //         }
    //     }

    //     stage('Publish Docker Image') {
    //         steps {
    //             sh """
    //                 docker image push siddhaant/springpetclinic:dev-${BUILD_NUMBER}
    //                 docker image rm -f siddhaant/springpetclinic:dev-${BUILD_NUMBER} 
    //                """
    //         }
    //     }
    }

    post {
        failure { 
            mail subject: "'${currentBuild.result}'",
                 body: "Project: ${env.JOB_NAME}<br/>" +
                       "Build Number: ${env.BUILD_NUMBER}<br/>" +
                       "URL: ${env.BUILD_URL}<br/>",
                 to: 'siddhant.kadu@featurexcloud.com'                 
        }
    }          
}

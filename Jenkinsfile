pipeline {
    agent { label 'JENKINS_AGENT_01' }
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    environment { 
        GIT_REPO = 'https://github.com/siddhaantkadu/spring-petclinic.git'
        GIT_BRANCH = 'dev'
        GIT_CRED = 'github-access-token'
    }
    stages {

        stage('Clean Workspace') {
            steps{
                cleanWs()
            }
        }

        stage('Checkout SCM') {
            steps {
                git credentialsId: "${env.GIT_CRED}",
                    url: "${env.GIT_REPO}",
                    branch: "${env.GIT_BRANCH}"
            }
        }

        // stage('Unit Test') {
        //     steps {
        //         sh 'mvn test'
        //     }
        //     post {
        //         always {
        //             junit testResults: '**/TEST-*.xml'
        //             // junit allowEmptyResults: true, testResults: '**/TEST-*.xml'
        //         }
        //     }
        // }

        stage('Build Package') {
            steps {
                sh 'mvn clean package'
                }
            post {
                success {
                    archiveArtifacts artifacts: '**/spring-petclinic-*.jar'

                }
            }
        }

        // stage('Static Code Analysis') {
        //     steps {
        //         withSonarQubeEnv(installationName: 'SONARQUBE_CLOUD', credentialsId: 'SONAR_TOKEN') {
        //             sh  """
        //                     mvn clean verify sonar:sonar \
        //                     -Dsonar.projectKey=the-beekeeper \
        //                     -Dsonar.projectName='the-beekeeper' \
        //                      -Dsonar.host.url=http://10.128.0.6:9000 \
        //                 """
        //         }
        //     }
        // }
        // stage("Quality Gate") {
        //     steps {
        //         timeout(time: 1, unit: 'HOURS') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }

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

        stage('Build Docker Image') { 
            steps {
                sh "docker image build -t springpetclinic:dev-${BUILD_NUMBER} ."
            }
        }

        stage('Trivy: Scan DockerImage') {
            steps { 
                script {
                    sh "trivy image --format table -o trivy-report.txt springpetclinic:dev-${BUILD_NUMBER}"
                }
                publishHTML([reportName: 'Trivy Vulnerability Report', reportDir: '.', reportFiles: 'trivy-report.txt', keepAll: true, alwaysLinkToLastBuild: true, allowMissing: false])
            }
        }

        // stage('Publish Docker Image') {
        //     steps {
        //         sh """
        //             docker image push siddhaant/springpetclinic:dev-${BUILD_NUMBER}
        //             docker image rm -f siddhaant/springpetclinic:dev-${BUILD_NUMBER} 
        //            """
        //     }
        // }
    }         
}

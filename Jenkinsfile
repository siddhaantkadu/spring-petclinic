pipeline {
    agent { label 'MAVEN' }
    options {
        skipDefaultCheckout()
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    triggers {
        pollSCM('* * * * *')
    }
    stages {

        stage('clean workspace') {
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
                failure {     
                    emailext attachLog: true,
                        subject: "'${currentBuild.result}'",
                        body: "Build Faild Project: ${env.JOB_NAME}<br/>" +
                            "Build Number: ${env.BUILD_NUMBER}<br/>" +
                            "URL: ${env.BUILD_URL}<br/>",
                        to: 'devops.cloud.dcl@gmail.com'
                }
            }
        }

        stage('Build Package') {
            steps {
                sh 'mvn clean package'
                }
            post {
                success {
                    archiveArtifacts artifacts: '**/spring-petclinic-*.jar'

                }
                failure { 
                    emailext attachLog: true,
                        subject: "'${currentBuild.result}'",
                        body: "Build Faild Project: ${env.JOB_NAME}<br/>" +
                            "Build Number: ${env.BUILD_NUMBER}<br/>" +
                            "URL: ${env.BUILD_URL}<br/>",
                        to: 'devops.cloud.dcl@gmail.com'               
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
    }

    post {
     always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'devops.cloud.dcl@gmail.com'
        }
    }          
}


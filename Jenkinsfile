pipeline {
    agent { label 'MAVEN' }
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    triggers {
        pollSCM('* * * * *')
    }
    stages {
        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/siddhaantkadu/spring-petclinic.git',
                    branch: 'development'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
            post {
                success {
                    junit testResults: '**/TEST-*.xml'
                }
                failure { 
                    slackSend channel: "#dcl-jenkins-jobs-notification",
                              message: "Unit Test - ${JOB_NAME} ${BUILD_NUMBER} (<${BUILD_URL}|Open>)",
                              
                    mail subject: 'Unit Test has been faild',
                         from: 'siddhant.kadu@dcl.com',
                         to: 'dcl.developer@dcl.com',
                         body: "Refer to $BUILD_URL for more details"
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
                    slackSend channel: "#dcl-jenkins-jobs-notification",
                              message: "Unit Test - ${JOB_NAME} ${BUILD_NUMBER} (<${BUILD_URL}|Open>)",
                              color: 'danger'
                    mail subject: 'Build has been faild',
                         from: 'siddhant.kadu@dcl.com',
                         to: 'dcl.developer@dcl.com',
                         body: "Refer to $BUILD_URL for more details"               
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
    }
    post {
        success {
            slackSend channel: "#dcl-jenkins-jobs-notification",
                      message: "Unit Test - ${JOB_NAME} ${BUILD_NUMBER} (<${BUILD_URL}|Open>)",
                      color: 'good'
        }     
    }           
}

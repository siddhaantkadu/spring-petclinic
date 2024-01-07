pipeline {
    agent { label 'MAVEN' }
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    triggers {
        pollSCM('0 14 * * 1-5')
    }
    stages {
        stage('Git Checkout') {
            steps {
                git url: 'https://github.com/siddhaantkadu/spring-petclinic.git',
                    branch: 'development'
            }
        }
        stage('Build and Test') {
            steps {
                sh 'mvn clean package'
                }
            post {
                success {
                    archiveArtifacts artifacts: '**/spring-petclinic-*.jar'
                    junit testResults: '**/TEST-*.xml'
                }
            }
        }
        stage('Static Code Analysis') {
            steps {
                withSonarQubeEnv(installationName: 'SONAR_QUBE', credentialsId: 'SONAR_TOKEN') {
                    sh 'mvn clean verify sonar:sonar -Dsonar.host.url=https://sonarcloud.io -Dsonar.organization=jenkins-spring-petclinic -Dsonar.projectKey=jenkins-spring-petclinic_spring-petclinic'
                }
            }
        }
    }
}

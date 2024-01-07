pipeline {
        agent { label 'MAVEN' }
        options {
            timestamps()
            timeout(time: 1, unit: 'HOURS')
        }
        triggers {
            pollSCM('0 14 * * 1-5')
        }
        stages {
            stage('Git Checkout') {
                steps {
                    git url: 'https://github.com/siddhaantkadu/spring-petclinic.git',
                        branch: 'release'
                }
            }
            stage('build') {
                steps {
                    sh 'mvn clean package'
                    withSonarQubeEnv(installationName: 'SONAR_QUBE', credentialsId: 'SONAR_TOKEN') {
                        sh 'mvn clean verify sonar:sonar -Dsonar.host.url=https://sonarcloud.io -Dsonar.organization=jenkins-spring-petclinic -Dsonar.projectKey=jenkins-spring-petclinic_spring-petclinic'
                    }
                }
                post {
                    success {
                        archiveArtifacts artifacts: '**/spring-petclinic-*.jar'
                        junit testResults: '**/TEST-*.xml'
                    }
                }
            }
        }
}
    
pipeline {
    agent any

    options {
        timeout(time: 20, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Checkout SCM (informativo)') {
            steps {
                checkout scm
                sh '''
                  echo "Ref actual: ${GIT_COMMIT}  Branch/Tag: ${BRANCH_NAME}"
                  ls -la
                '''
            }
        }

        stage('Sanity checks') {
            steps {
                sh '''
                  set -eu
                  test -f docker-compose.yml
                  test -f Dockerfile
                '''
            }
        }

        stage('Deploy (solo TAG vX.Y.Z)') {
          when {
              expression { env.BRANCH_NAME ==~ /^v[0-9.]+$/ }
          }
            steps {
                dir("${WORKSPACE}") {
                    sh '''
                      echo "➡️ Docker Compose Down"
                      docker compose down --remove-orphans

                      echo "➡️ Docker Compose Up --build"
                      docker compose up -d --build
                    '''

                }
            }
        }
    }

    post {
        success {
            echo "✅ OK: ${BRANCH_NAME}"
        }
        failure {
            echo "❌ FAIL: ${BRANCH_NAME}"
        }
        always {
            echo "🏁 Fin de pipeline: ${BRANCH_NAME}"
        }
    }
}

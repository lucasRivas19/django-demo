pipeline {
    agent any

    environment {
        DEPLOY_DIR = "${WORKSPACE}"
    }

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
                allOf {
                    buildingTag()
                    expression {
                        def name = env.GIT_TAG_NAME ?: env.BRANCH_NAME
                        return name ==~ /^v\\d+\\.\\d+\\.\\d+$/
                    }
                }
            }
            agent {
                docker {
                    image 'docker:24.0.6-cli'  // Docker CLI oficial
                    args '--network=host -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                dir("${DEPLOY_DIR}") {
                    sh '''
                      set -eu
                      echo "➡️ Deploy con docker-compose en ${DEPLOY_DIR}"
                      docker compose down || true
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
    }
}

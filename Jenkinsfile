pipeline {
  agent any

  options {
    disableConcurrentBuilds()                          
    buildDiscarder(logRotator(daysToKeepStr: '14', numToKeepStr: '20'))
    timeout(time: 20, unit: 'MINUTES')
    timestamps()
    skipDefaultCheckout(true)                          
  }

  environment {
    APP_NAME    = 'django-demo'
    APP_DIR     = "/opt/${APP_NAME}/src"
    SHELL       = '/bin/bash'
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
          test -f "docker-compose.yml"
          test -f "Dockerfile"
        '''
      }
    }

    stage('Deploy (solo TAG vX.Y.Z)') {
      when {
        allOf {
          buildingTag()
          expression { return env.BRANCH_NAME ==~ /^v\d+\.\d+\.\d+$/ }  // <-- regex corregida
        }
      }
      steps {
        dir("${APP_DIR}") {
          sh '''
            set -eu

            echo "🔄 Actualizando código en ${APP_DIR}"
            git fetch --all --tags --prune
            git checkout -B "deploy-${BRANCH_NAME}" "refs/tags/${BRANCH_NAME}"

            echo "🚀 Deploy con docker compose"
            docker compose down || true
            docker compose up -d --build

            echo "✅ Contenedores activos:"
            docker compose ps
          '''
        }
      }
    }
  }

  post {
    success { echo "✅ OK: ${env.BRANCH_NAME}" }
    failure { echo "❌ FAIL: ${env.BRANCH_NAME}" }
    always  { echo "🏁 Fin de pipeline: ${env.BRANCH_NAME}" }
  }
}

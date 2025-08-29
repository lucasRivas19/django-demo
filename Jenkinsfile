pipeline {
  agent any

  options {
    disableConcurrentBuilds()                          // no permite dos deploys pisándose
    buildDiscarder(logRotator(daysToKeepStr: '14', numToKeepStr: '20'))
    timeout(time: 20, unit: 'MINUTES')
    timestamps()
    skipDefaultCheckout(false)                         // dejamos que Jenkins haga el checkout normal
  }

  environment {
    APP_NAME = 'django-demo'
    APP_DIR  = "${WORKSPACE}"   // Jenkins workspace, no /opt
  }

  stages {
    stage('Checkout SCM (informativo)') {
      steps {
        checkout scm
        sh '''#!/bin/bash
          echo "Ref actual: ${GIT_COMMIT}  Branch/Tag: ${BRANCH_NAME}"
          ls -la
        '''
      }
    }

    stage('Sanity checks') {
      steps {
        sh '''#!/bin/bash
          set -euo pipefail
          test -f "${APP_DIR}/docker-compose.yml"
          test -f "${APP_DIR}/Dockerfile"
        '''
      }
    }

    stage('Deploy (solo TAG vX.Y.Z)') {
      when {
        allOf {
          buildingTag()
          expression { return env.BRANCH_NAME ==~ /^v\\d+\\.\\d+\\.\\d+$/ }  // ej: v1.2.3
        }
      }
      options { retry(2) }
      steps {
        dir("${APP_DIR}") {
          sh '''#!/bin/bash
            set -euo pipefail

            # Info de git
            git remote -v
            git fetch --all --tags --prune

            # Checkout al tag
            git checkout -B "deploy-${BRANCH_NAME}" "refs/tags/${BRANCH_NAME}"

            # Deploy con compose
            docker compose down || true
            docker compose up -d --build

            docker compose ps
            docker images | head -n 20
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

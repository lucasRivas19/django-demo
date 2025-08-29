pipeline {
  agent any

  options {
    disableConcurrentBuilds()                          // nada de dos deploys pisándose
    buildDiscarder(logRotator(daysToKeepStr: '14', numToKeepStr: '20'))
    timeout(time: 20, unit: 'MINUTES')
    ansiColor('xterm')
    timestamps()
    skipDefaultCheckout(true)                          // hacemos checkout a mano
  }

  environment {
    APP_NAME    = 'django-demo'
    APP_DIR     = "/opt/${APP_NAME}/src"               // repo local en el MISMO server de Jenkins
    SHELL       = '/bin/bash'
  }

  stages {
    stage('Checkout SCM (informativo)') {
      steps {
        // Trae metadata del repo del multibranch (no pisa /opt)
        checkout scm
        sh 'echo "Ref actual: ${GIT_COMMIT}  Branch/Tag: ${BRANCH_NAME}"'
      }
    }

    stage('Sanity checks') {
      steps {
        sh '''
          set -euo pipefail
          test -d "${APP_DIR}" || { echo "No existe ${APP_DIR}. Clonalo una vez: git clone <ssh> ${APP_DIR}"; exit 1; }
          test -f "${APP_DIR}/docker-compose.yml"
          test -f "${APP_DIR}/Dockerfile"
        '''
      }
    }

    stage('Deploy (solo TAG vX.Y.Z)') {
      when {
        allOf {
          buildingTag()                                 // solo si el build viene de un tag
          expression { return env.BRANCH_NAME ==~ /^v\\d+\\.\\d+\\.\\d+$/ }  // v1.2.3
        }
      }
      options { retry(2) }                               // reintento ante fallos transitorios
      steps {
        // Si tenés el plugin Lockable Resources, mantiene serializado el deploy en este nodo
        lock(resource: "deploy-local-${env.APP_NAME}") {
          dir("${APP_DIR}") {
            sh '''
              set -euo pipefail

              # Asegurar origen y traer tags
              git remote -v
              git fetch --all --tags --prune

              # Checkout inmutable al TAG (rama efímera pegada al tag)
              git checkout -B "deploy-${BRANCH_NAME}" "refs/tags/${BRANCH_NAME}"

              # Deploy con compose (sin romper si no estaba corriendo)
              docker compose down || true
              docker compose up -d --build

              # Info rápida
              docker compose ps
              docker images | head -n 20
            '''
          }
        }
      }
    }
  }

  post {
    success { echo "✅ OK: ${env.BRANCH_NAME}" }
    failure { echo "❌ FAIL: ${env.BRANCH_NAME}" }
    always  { echo "🏁 Fin de pipeline: ${env.BRANCH_NAME}" }
  }
}

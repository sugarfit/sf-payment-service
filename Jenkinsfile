pipeline {
  agent {
    node {
      label 'k8s-kaniko-java-amd64'
    }
  } //agent

  options {
    timeout(time: 1, unit: 'HOURS')
  }

  parameters {
    string(name: 'BuildArg', defaultValue: '', description: 'Custom Build Arguments')
  } //parameters

  environment {
    ORG = 'sugarfit'
    APP_NAME = 'sf-payment-service'
    GITHUB_MVN_TOKEN = credentials('sugarfit-github-mvn-token')
    BUILD_REGISTRY = "${DOCKER_REGISTRY}/${ORG}/build-artifacts"
  } //environment

  stages {
    stage('Prepare Docker Image for Stage Environment') {
      when { branch 'stage' }
      environment {
        TAG = "$BUILD_NUMBER-$BRANCH_NAME".replaceAll('_','-')
        APP_VERSION = "$GIT_COMMIT"
        ENV = "stage"
        APP_REGISTRY = "${DOCKER_REGISTRY}/${ORG}/${ENV}/${APP_NAME}"
      } //environment
      parallel {
        stage('Prepare arm64 Docker Image for Stage Environment') {
          agent {
            label 'k8s-kaniko-java-arm64'
          } // agent
          environment {
            PREVIEW_TAG = "$BUILD_NUMBER-$BRANCH_NAME-arm64".replaceAll('_', '-')
          } // environment
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              buildExecutableImage("${PREVIEW_TAG}")  //builds ${APP_REGISTRY}-build image.
              buildMainImage("${PREVIEW_TAG}")
              updateArtifact("${APP_REGISTRY}", "${TAG}", "${ENV}")
            } // container
          } // steps
        } // stage('Prepare arm64 Docker Image for Stage Environment')
        stage('Prepare amd64 Docker Image for Stage Environment') {
          environment {
            PREVIEW_TAG = "$BUILD_NUMBER-$BRANCH_NAME-amd64".replaceAll('_', '-')
          } // environment
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              buildExecutableImage("${PREVIEW_TAG}")
              buildMainImage("${PREVIEW_TAG}")
              updateArtifact("${APP_REGISTRY}", "${TAG}", "${ENV}")
            } // container
          } // steps
        } // stage('Prepare amd64 Docker Image for Stage Environment')
      } // parallel
    }; //stage('Prepare Docker Image for Stage Environment')

    stage('Prepare Docker Image for Alpha Environment') {
      when{ branch 'alpha'; }
      environment {
        TAG = "$BUILD_NUMBER-$BRANCH_NAME".replaceAll('_', '-')
        APP_VERSION = "$GIT_COMMIT"
        ENV = "alpha"
        APP_REGISTRY = "${DOCKER_REGISTRY}/${ORG}/${ENV}/${APP_NAME}"
      } // environment
      parallel {
        stage('Prepare arm64 Docker Image for Alpha Environment') {
          agent {
            label 'k8s-kaniko-java-arm64'
          } // agent
          environment {
            PREVIEW_TAG = "$BUILD_NUMBER-$BRANCH_NAME-arm64".replaceAll('_', '-')
          } // environment
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              buildExecutableImage("${PREVIEW_TAG}")  //builds ${APP_REGISTRY}-build image.
              buildMainImage("${PREVIEW_TAG}")
              updateArtifact("${APP_REGISTRY}", "${TAG}", "${ENV}")
            } // container
          } // steps
        } // stage('Prepare arm64 Docker Image for Alpha Environment')
        stage('Prepare amd64 Docker Image for Alpha Environment') {
          environment {
            PREVIEW_TAG = "$BUILD_NUMBER-$BRANCH_NAME-amd64".replaceAll('_', '-')
          } // environment
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              buildExecutableImage("${PREVIEW_TAG}")
              buildMainImage("${PREVIEW_TAG}")
              updateArtifact("${APP_REGISTRY}", "${TAG}", "${ENV}")
            } // container
          } // steps
        } // stage('Prepare amd64 Docker Image for Alpha Environment')
      } // parallel
    }; //stage('Prepare Docker Image for Alpha Environment')

    stage('Prepare Docker Image for Production Environment') {
      when{ branch 'master'; }
      environment {
        TAG = "$BUILD_NUMBER-$BRANCH_NAME".replaceAll('_','-')
        APP_VERSION = "$GIT_COMMIT"
        ENV = "prod"
        APP_REGISTRY = "${DOCKER_REGISTRY}/${ORG}/${ENV}/${APP_NAME}"
      } // environment
      parallel {
        stage('Prepare arm64 Docker Image for Production Environment') {
          agent {
            label 'k8s-kaniko-java-arm64'
          } // agent
          environment {
            PREVIEW_TAG = "$BUILD_NUMBER-$BRANCH_NAME-arm64".replaceAll('_', '-')
          } // environment
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              buildExecutableImage("${PREVIEW_TAG}")  //builds ${APP_REGISTRY}-build image.
              buildMainImage("${PREVIEW_TAG}")
              updateArtifact("${APP_REGISTRY}", "${TAG}", "${ENV}")
            } // container
          } // steps
        } // stage('Prepare arm64 Docker Image for Production Environment')
        stage('Prepare amd64 Docker Image for Production Environment') {
          environment {
            PREVIEW_TAG = "$BUILD_NUMBER-$BRANCH_NAME-amd64".replaceAll('_', '-')
          } // environment
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              buildExecutableImage("${PREVIEW_TAG}")
              buildMainImage("${PREVIEW_TAG}")
              updateArtifact("${APP_REGISTRY}", "${TAG}", "${ENV}")
            } // container
          } // steps
        } // stage('Prepare amd64 Docker Image for Production Environment')
      } // parallel
    }; // stage('Prepare Docker Image for Production Environment')

    stage ('Preparing Docker Image for Dev testing Environment') {
      when {
        not {
          anyOf {
            expression { params.branchName == null }
            expression { params.branchName == "stage" }
            expression { params.branchName == "alpha" }
            expression { params.branchName == "master" }
          }
        } //not
      } //when
      environment {
        ENV = "stage"
        APP_REGISTRY = "${DOCKER_REGISTRY}/${ORG}/${ENV}/${APP_NAME}"
        TAG = "$BUILD_NUMBER-$virtualClusterName".replaceAll('_','-')
        APP_VERSION = "$GIT_COMMIT"
        FROM = "${BUILD_REGISTRY}:${APP_NAME}-${TAG}-build"
        VOYAGER_URL = 'http://voyager.production.cure.fit.internal/echidna/deployment'
        VIRTUAL_CLUSTER = "$virtualClusterName"
      } //environment
      steps {
        script {
          container(name: 'kaniko', shell: '/busybox/sh') {
            sh "echo building ${virtualClusterName} ${APP_REGISTRY}"
            buildExecutableImage("${TAG}")
            buildDevspaceImage()
            updateArtifact("${APP_REGISTRY}", "${TAG}", "${ENV}")
            sh "curl -sf -X POST \"${VOYAGER_URL}/${params.deploymentId}/trigger\" -H 'Content-Type: application/json;charset=UTF-8' --data-raw '{\"appName\": \"${APP_NAME}\", \"repoName\": \"${params.repoName}\", \"virtualClusterName\": \"${params.virtualClusterName}\", \"imageUrl\": \"${DOCKER_REGISTRY}/${ORG}/${ENV}/${APP_NAME}\", \"imageTag\": \"${TAG}\"}'"
          } //container
        } //script
      } //steps
    }; // stage(Preparing Docker Image for Dev testing Environment)

    stage('Build Docker Manifest and push') {
      when { anyOf { branch 'master'; branch 'stage'; branch 'alpha'; } }
      agent {
        label 'teleport-db-agent'
      } // agent
      environment {
        VERSION = "$BUILD_NUMBER-$BRANCH_NAME".replaceAll('_', '-')
        VERSION_ARM = "$BUILD_NUMBER-$BRANCH_NAME-arm64".replaceAll('_', '-')
        VERSION_AMD = "$BUILD_NUMBER-$BRANCH_NAME-amd64".replaceAll('_', '-')
      } // environment
      steps {
        script {
          env = "$BRANCH_NAME" == 'master' ? 'prod' : ("$BRANCH_NAME" == 'alpha' ? 'alpha' : 'stage')
          def URL = "${DOCKER_REGISTRY}/${ORG}/${env}/${APP_NAME}:${VERSION}"
          def URL_ARM = "${DOCKER_REGISTRY}/${ORG}/${env}/${APP_NAME}:${VERSION_ARM}"
          def URL_AMD = "${DOCKER_REGISTRY}/${ORG}/${env}/${APP_NAME}:${VERSION_AMD}"
          dockerManifest(URL, URL_ARM, URL_AMD)
        } // script
      } // steps
    };//stage('Build Docker Manifest and push')

  } //stages
} //pipeline

void gitlfs(){
  sh """
  git lfs install
  git lfs pull
  """
}

void buildExecutableImage(tag) {
  sh "pwd"
  sh "ls -lh"
  sh "echo $PATH"
  echo "${BUILD_REGISTRY}"
  sh """
      #!/busybox/sh -xxe
        /kaniko/executor \
        --dockerfile Dockerfile-build \
        --context `pwd`/ \
        --build-arg APP_ENV=${ENV} \
        --build-arg ENVIRONMENT=${ENV} \
        --build-arg TAG=${tag} \
        --build-arg APP_NAME=${APP_NAME} \
        --build-arg APP_VERSION=${APP_VERSION} \
        --build-arg GITHUB_MVN_TOKEN=${GITHUB_MVN_TOKEN} \
        --destination ${BUILD_REGISTRY}:${APP_NAME}-${tag}-build
    """
}

void buildMainImage(tag) {
  sh "echo $PATH"
  sh """
    #!/busybox/sh -xxe
      /kaniko/executor \
      --dockerfile Dockerfile-main \
      --build-arg FROM=${BUILD_REGISTRY}:${APP_NAME}-${tag}-build \
      --context `pwd`/ \
      --build-arg APP_ENV=${ENV} \
      --build-arg ENVIRONMENT=${ENV} \
      --build-arg TAG=${tag} \
      --build-arg APP_NAME=${APP_NAME} \
      --build-arg APP_VERSION=${APP_VERSION} \
      --destination ${APP_REGISTRY}:${tag}
  """
}

void buildDevspaceImage() {
  sh "FROM=${FROM} VIRTUAL_CLUSTER=${virtualClusterName} ENVIRONMENT=${ENV} DOCKER_REGISTRY=${DOCKER_REGISTRY} TAG=${TAG} APP_VERSION=${APP_VERSION} ORG=${ORG} APP_NAME=${APP_NAME} TAG=${TAG} devspace build"
}

void updateArtifact(repo, tag, env) {
  sh """
    touch build.properties
    echo repo=${repo} >> build.properties
    echo tag=${tag} >> build.properties
    echo env=${env} >> build.properties
    """
  archiveArtifacts 'build.properties'
}

void dockerManifest(tag, tag_arm64, tag_amd64) {
  sh "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${DOCKER_REGISTRY}"
  sh "docker manifest create ${tag} ${tag_arm64} ${tag_amd64}"
  sh "docker manifest annotate --arch arm64 ${tag} ${tag_arm64}"
  sh "docker manifest annotate --arch amd64 ${tag} ${tag_amd64}"
  sh "docker manifest push ${tag}"
}

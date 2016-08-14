#!/bin/bash
set -e

usage() {
  echo "Usage: $0 [-p <PROJECT_NAME> -o <BUILD_PHASE> -a <DOCKER_REGISTRY> -r <DOCKER_REPOSITORY> -w]"
}

# Statics and opt
# DOCKER_REGISTRY="https://hub.docker.com"
BUILD_SCRIPT_OPTS="all"
VERSION_STRING=$(date +'%Y%m%d%H%M')
PROJECT_NAME=$(git config --local remote.origin.url | sed -n 's#.*/\([^\/]*\)\.git#\1#p')

while getopts ":a:r:o:wp:" opt; do
  case $opt in
    # Provide commands to run
    o)
      BUILD_SCRIPT_OPTS="${OPTARG}"
    ;;
    # Override default registry
    a)
      DOCKER_REGISTRY="${OPTARG}"
    ;;
    # Set docker repository
    r)
      DOCKER_REPOSITORY="${OPTARG}"
    ;;
    # Override project name.
    p)
      PROJECT_NAME="${OPTARG}"
    ;;
    # Set windows mode, prevent MSYS path conversion breaking docker.
    w)
      export MSYS_NO_PATHCONV=1
    ;;
    \?)
      echo "Invalid option -$OPTARG" >&2
    ;;
    *)
      usage
    ;;
  esac
done

shift "$((OPTIND-1))"

if [ -z "${PROJECT_NAME}" ]; then
  echo "No project name, unable to continue."
  exit 1
fi

FULL_IMAGE_NAME=${DOCKER_REPOSITORY}/${PROJECT_NAME}
# if [ -z "${DOCKER_REPOSITORY}" ]; then
#   FULL_IMAGE_NAME=${DOCKER_REGISTRY}/${PROJECT_NAME}
# else
#   FULL_IMAGE_NAME=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${PROJECT_NAME}
# fi

build_version() {
  if [ -z "${BUILD_NUMBER}" ]; then
    BUILD_NUMBER="0"
  fi

  TAG_NAME="${VERSION_STRING}.${BUILD_NUMBER}"
  echo "TAG_NAME=${TAG_NAME}" > VERSION
}

build_clean() {
  echo "Beginning cleanup step."
  echo "Removing docker images for: ${FULL_IMAGE_NAME}"
  set +e
  # Below if docker >1.10
  # docker rmi -f $(docker images --format "{{.Repository}}:{{.Tag}}" ${FULL_IMAGE_NAME}) 2> /dev/null
  docker rmi $(docker images | grep "^${FULL_IMAGE_NAME}" | awk "{print $3}") 2> /dev/null
  # ensure any test and test result images are removed
  echo "Removing test images"
  docker rm ${PROJECT_NAME}-test
  docker rm ${PROJECT_NAME}-test-reader
  docker rmi $(docker images | grep "^${PROJECT_NAME}-test" | awk "{print $3}") 2> /dev/null
  set -e
}

build_preparation() {
  echo "Beginning preparation step."
  if [[ "$(docker images -q ${FULL_IMAGE_NAME}:${TAG_NAME} 2> /dev/null)" == "" ]]; then
    echo "Creating image: ${FULL_IMAGE_NAME}:${TAG_NAME}"

    # To pass version in as an arg use: --build-arg version_string=${VERSION_STRING}
    docker build --pull -t ${FULL_IMAGE_NAME}:${TAG_NAME} .
  fi
}

build_test() {
  echo "Beginning test step."
  docker run \
  --name ${PROJECT_NAME}-test \
  -v $PWD:/opt/results \
  --workdir="/tmp" \
  --entrypoint="/tmp/test.sh" \
  --env MOCHA_FILE=/opt/results/test-results.xml \
  ${FULL_IMAGE_NAME}:${TAG_NAME}

  # this is because we run jenkins inside docker also...
  docker run \
  --name ${PROJECT_NAME}-test-reader \
  -v $PWD:/opt/results \
  alpine cat /opt/results/test-results.xml > test-results.xml

  docker rm ${PROJECT_NAME}-test
  docker rm ${PROJECT_NAME}-test-reader
}

build_package() {
  echo "Beginning package step."
  echo "Nothing to do."
}

build_publish() {
  echo "Beginning publish step."
  echo "Pushing image to repository: ${FULL_IMAGE_NAME}:${TAG_NAME}"
  docker tag -f ${FULL_IMAGE_NAME}:${TAG_NAME} ${FULL_IMAGE_NAME}:latest
  docker push ${FULL_IMAGE_NAME}:latest
  docker push ${FULL_IMAGE_NAME}:${TAG_NAME}
}

shopt -s nocasematch
case "${BUILD_SCRIPT_OPTS}" in
  all)
    build_version
    build_clean
    build_preparation
    build_test
    build_package
    build_publish
  ;;
  test)
    build_version
    build_preparation
    build_test
  ;;
  package)
    build_version
    build_preparation
    build_package
  ;;
  publish)
    build_version
    build_preparation
    build_publish
  ;;
  clean)
    build_clean
  ;;
esac

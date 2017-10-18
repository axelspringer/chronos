#!/bin/bash

push() {
  CHRONOS_VERSION=${1}

  TAG=${CHRONOS_VERSION}

# base
  echo
  echo Pushing axelspringer/chronos:${TAG}
  docker push axelspringer/chronos:${TAG} || exit $?
}

# login docker before push
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

#    Chronos version
push "3.0.2"
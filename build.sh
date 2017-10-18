#!/bin/bash

build() {
  CHRONOS_VERSION=$1

  TAG=${CHRONOS_VERSION}

# base
  docker build \
    --compress \
    --squash \
    -t axelspringer/chronos \
    --build-arg CHRONOS_VERSION=${TAG} \
    . || exit $?

# tag
  echo
  echo Tagging axelspringer/chronos:${TAG}
  docker tag axelspringer/chronos axelspringer/chronos:${TAG} \
    || exit $?
}

#     Chronos version
build "3.0.2"
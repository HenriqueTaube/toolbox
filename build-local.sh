#!/bin/sh

set -eu

IMAGE_NAME="${IMAGE_NAME:-toolbox-k8s}"
IMAGE_TAG="${IMAGE_TAG:-dev}"

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

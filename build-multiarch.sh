#!/bin/sh

set -eu

IMAGE_REPO="${IMAGE_REPO:?set IMAGE_REPO, por exemplo 192.168.1.54:3000/henrique/toolbox}"
IMAGE_TAG="${IMAGE_TAG:-0.1.0}"
BUILDER_NAME="${BUILDER_NAME:-toolbox-multiarch}"

if ! docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
  docker buildx create --name "$BUILDER_NAME" --use
else
  docker buildx use "$BUILDER_NAME"
fi

docker buildx inspect --bootstrap >/dev/null

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t "${IMAGE_REPO}:${IMAGE_TAG}" \
  -t "${IMAGE_REPO}:latest" \
  --output type=registry,registry.insecure=true \
  .

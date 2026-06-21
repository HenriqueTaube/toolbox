#!/bin/sh

set -eu

# --- config ---
REGISTRY_IP="192.168.1.191:3000"
IMAGE_NAME="henrique/toolbox"
IMAGE_TAG="${IMAGE_TAG:-latest}"
BUILDER_NAME="${BUILDER_NAME:-toolbox}"
# --------------

IMAGE_REPO="${REGISTRY_IP}/${IMAGE_NAME}"

echo ">> Copying ~/.zshrc to build context..."
cp "$HOME/.zshrc" ./zshrc
mv .zshrc zshrc

echo ">> Setting up buildx builder..."
if ! docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
  docker buildx create --name "$BUILDER_NAME" --use
else
  docker buildx use "$BUILDER_NAME"
fi

docker buildx inspect --bootstrap >/dev/null

echo ">> Building multi-arch image (amd64 + arm64)..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t "${IMAGE_REPO}:${IMAGE_TAG}" \
  -t "${IMAGE_REPO}:latest" \
  --output type=registry,registry.insecure=true \
  .

echo ">> Done: ${IMAGE_REPO}:${IMAGE_TAG}"

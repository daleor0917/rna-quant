#!/bin/bash
set -e

# Configuration
IMAGE_NAME="rseqc"
IMAGE_TAG="5.0.3"
REGISTRY="${DOCKER_REGISTRY:-localhost:5000}"  # Change to your registry
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "Building ${FULL_IMAGE}..."

# Build the image
docker build -t "${FULL_IMAGE}" .

# Also tag as latest
docker tag "${FULL_IMAGE}" "${REGISTRY}/${IMAGE_NAME}:latest"

echo "Successfully built ${FULL_IMAGE}"
echo ""
echo "To push to registry, run:"
echo "  docker push ${FULL_IMAGE}"
echo "  docker push ${REGISTRY}/${IMAGE_NAME}:latest"
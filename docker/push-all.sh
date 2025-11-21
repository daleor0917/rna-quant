#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
REGISTRY="${DOCKER_REGISTRY:-localhost:5000}"

# Image definitions (name:version)
declare -A IMAGES=(
    ["samtools"]="1.22.1"
    ["subread"]="2.0.6"
    ["rseqc"]="5.0.3"
    ["multiqc"]="1.32"
)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Pushing All Docker Images${NC}"
echo -e "${BLUE}  Registry: ${REGISTRY}${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if logged in to registry (optional)
echo "Make sure you're logged in to your registry:"
echo "  docker login ${REGISTRY}"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Push each image
for IMAGE_NAME in "${!IMAGES[@]}"; do
    IMAGE_TAG="${IMAGES[$IMAGE_NAME]}"
    FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    LATEST_IMAGE="${REGISTRY}/${IMAGE_NAME}:latest"
    
    echo -e "${GREEN}Pushing ${IMAGE_NAME}:${IMAGE_TAG}...${NC}"
    docker push "${FULL_IMAGE}"
    
    echo -e "${GREEN}Pushing ${IMAGE_NAME}:latest...${NC}"
    docker push "${LATEST_IMAGE}"
    
    echo ""
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  All images pushed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Pushed images:"
for IMAGE_NAME in "${!IMAGES[@]}"; do
    IMAGE_TAG="${IMAGES[$IMAGE_NAME]}"
    echo "  - ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    echo "  - ${REGISTRY}/${IMAGE_NAME}:latest"
done
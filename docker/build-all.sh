#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
REGISTRY="${DOCKER_REGISTRY:-localhost:5000}"
IMAGES=("samtools" "subread" "rseqc" "multiqc")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Building All Docker Images${NC}"
echo -e "${BLUE}  Registry: ${REGISTRY}${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Build each image
for IMAGE in "${IMAGES[@]}"; do
    echo -e "${GREEN}Building ${IMAGE}...${NC}"
    cd "${IMAGE}"
    bash build.sh
    cd ..
    echo ""
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ All images built successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Built images:"
docker images | grep -E "samtools|subread|rseqc|multiqc" | grep "${REGISTRY}" || true
echo ""
echo "To push all images to registry, run:"
echo "  ./push-all.sh"
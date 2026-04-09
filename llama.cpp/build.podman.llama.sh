#!/bin/bash
set -e

cd $(dirname $0)
source ../env.sh "llama.cpp" "rocm" 

IMAGE_TAGS=(
  "$LLAMA_IMAGE:full-${LLAMA_GIT_REF}-rocm-${LLAMA_ROCM_VERSION}-${REPO_GIT_REF}"
  "$LLAMA_IMAGE:full-${LLAMA_GIT_REF}-rocm-${LLAMA_ROCM_VERSION}"
  "$LLAMA_IMAGE:full-rocm-${LLAMA_ROCM_VERSION}"
)

# Removed the image push registry check since you are building purely locally.

DOCKER_EXTRA_ARGS=()
for (( i=0; i<${#IMAGE_TAGS[@]}; i++ )); do
  DOCKER_EXTRA_ARGS+=("-t" "${IMAGE_TAGS[$i]}")
done

mkdir ./logs || true

# Use Podman instead of Docker Buildx and do not push to registry.
# This will build upon the local patched rocm image we generated earlier.
echo "Building llama.cpp image natively using Podman locally (not pushing)..."
podman build ${DOCKER_EXTRA_ARGS[@]} \
  --build-arg BASE_ROCM_DEV_CONTAINER=$PATCHED_ROCM_IMAGE:${LLAMA_ROCM_VERSION}-complete \
  --build-arg ROCM_DOCKER_ARCH=$ROCM_ARCH \
  --build-arg ROCM_VERSION=$LLAMA_ROCM_VERSION \
  --build-arg AMDGPU_VERSION=$LLAMA_ROCM_VERSION \
  --progress=plain --target full -f ./submodules/llama.cpp/.devops/rocm.Dockerfile ./submodules/llama.cpp 2>&1 | tee ./logs/build_$(date +%Y%m%d%H%M%S).log

echo "Build complete! Image tagged locally."

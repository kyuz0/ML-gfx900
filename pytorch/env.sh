#/bin/bash

pushd $(dirname ${BASH_SOURCE[0]})

# rocm version
if [ "$TORCH_ROCM_VERSION" == "" ];  then TORCH_ROCM_VERSION="7.2.1"; fi
# torch git checkpoint
if [ "$TORCH_VERSION" == "" ];       then TORCH_VERSION="v2.7.1"; fi

# destination image
if [ "$TORCH_IMAGE" == "" ]; then
  TORCH_IMAGE="docker.io/kyuz0/pytorch-toolbox-gfx900"
fi

popd

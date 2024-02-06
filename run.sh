#!/bin/bash

# Build the image (assuming the Containerfile is in the current directory)
podman build -t rocm-a1111 -f containerfile &&

# Run the container with necessary options
podman run \
    --name rocm-a1111 \
    --cap-add SYS_PTRACE \
    --device=/dev/kfd:/dev/kfd \
    --device=/dev/dri:/dev/dri \
    --ipc=host \
    --security-opt seccomp=unconfined \
    --userns=keep-id \
    --group-add video \
    --group-add render \
    -p 7860:7860 \
    -v ./app:/root/app \
    -e COMMANDLINE_ARGS="--listen --enable-insecure-extension-access --no-download-sd-model" \
    -e TORCH_INDEX="https://download.pytorch.org/whl/rocm5.7" \
    -e REPO="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" \
    -e UPDATE="" \
    -e HSA_OVERRIDE_GFX_VERSION="10.3.0" \
    -e PYTORCH_HIP_ALLOC_CONF="garbage_collection_threshold:0.9,max_split_size_mb:256" \
    rocm-a1111
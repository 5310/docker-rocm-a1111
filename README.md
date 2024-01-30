# Docker-ROCm-A1111

This Docker container sets up Stable-Diffusion using AUTOMATIC1111/stable-diffusion-webui for AMD ROCm compatible systems.

## Requirements

- Docker
  - Untested with Podman
- The ROCm kernel module
  - Only the minimal kernel module needed on the host for the container to interface with the GPU
  - On Arch: the package [rocm-core](https://archlinux.org/packages/extra/x86_64/rocm-core/) will suffice
  - On Ubuntu: no idea...

## Usage

A deploy the composefile to automatically create the app folder with the web-ui that you can add stuff to and run it.

```bash
git clone --depth 1 https://github.com/5310/docker-rocm-a1111
cd docker-rocm-a1111
docker-compose up
```

## Update

Rebuild the image and container to (try to) update the app, while retaining your models folder, etc.

```bash
docker-compose up --build --force-recreate
```

## Configuration

At the end of the compose-file are all the parameters that are configurable, with comments describing where they go.

- Edit the `PYTORCH_INDEX` environment variable to the [latest version](https://pytorch.org/get-started/locally/) that you need
  - This is needed because PyTorch refuses to publish the ROCm and Intel modules as their own packages or provide a `latest` version to install via PIP
- Edit the `command` parameter to customize what arguments the web-ui runs on
- Tinker around if things break, I have no idea what I'm doing, I don't even have a GPU anymore!
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

Deploy the composefile to automatically create the app folder with the web-ui that you can add stuff to and run it.

```bash
git clone --depth 1 https://github.com/5310/docker-rocm-a1111
cd docker-rocm-a1111
docker-compose up
```

## Update

Rebuild the image and container to (try to) update the app, and underlying dependencies, while retaining your models and extensions folders etcetera (but not any other out-of-git changes).

```bash
WEBUI_UPDATE=true docker-compose up --build --force-recreate 
```

## Configuration

At the end of the compose-file are all the parameters that are configurable, with comments.
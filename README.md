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

```bash
git clone --depth 1 https://github.com/5310/docker-rocm-a1111
cd docker-rocm-a1111
docker-compose up
```

## Configuration

- Edit the `command` parameter to customize what arguments the web-ui runs on
- Edit the `PYTORCH_INDEX` environment variable to the [latest version](https://pytorch.org/get-started/locally/) that you need
  - This is needed because PyTorch refuses to publish the ROCm and Intel modules as their own packages or provide a `latest` version to install via PIP
- Tinker around if things break, I have no idea what I'm doing, I don't even have a GPU anymore!
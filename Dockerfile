FROM rocm/pytorch:latest

SHELL ["/bin/bash", "-c"]

VOLUME /root/app

WORKDIR /root/app

ARG A1111_REPO=https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
ARG PYTORCH_INDEX=https://download.pytorch.org/whl/rocm5.6

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    VIRTUAL_ENV=$(pwd)/venv \
    PATH=$VIRTUAL_ENV/bin:$PATH \
    REQS_FILE='requirements.txt'

RUN echo Updating system... && \
    apt-get update && \
    apt-get install -y libglib2.0-0 wget && \
    apt-get clean -y; \
    \
    echo Setting up Web-UI repository && \
    git config --global --add safe.directory "*" && \
    if [ "$(git config --get remote.origin.url)" == "$A1111_REPO" ]; \
    then \
        echo Existing repository found, updating... && \
        git reset --hard && \
        git pull; \
    else \
        echo Pulling repository... && \
        git clone --depth 1 $A1111_REPO .; \
    fi && \
    echo Patching out the broken PyTorch requirement... && \
    sed -i -e '/^torch\r/d' requirements.txt && \
    sed -i -e '/^torch\r/d' requirements_versions.txt; \
    \
    echo Setting up Python virtual environment... \
    python -m venv venv && \
    python -m pip install --upgrade pip wheel && \
    python -m pip install --force-reinstall torch torchvision torchaudio --index-url $PYTORCH_INDEX;

EXPOSE 7860

ENTRYPOINT ["python", "launch.py"]
CMD ["--precision", "full", "--no-half"]
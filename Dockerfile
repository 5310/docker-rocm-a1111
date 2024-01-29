FROM rocm/pytorch:latest

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y libglib2.0-0 wget && \
    apt-get clean -y

WORKDIR /root

VOLUME app

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    REQS_FILE='requirements.txt'

RUN git clone --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui app && \
    sed -i -e '/^torch\r/d' requirements.txt && \
    sed -i -e '/^torch\r/d' requirements_versions.txt

RUN python -m venv venv && \
    source venv/bin/activate && \
    python -m pip install --upgrade pip wheel && \
    python -m pip install --force-reinstall torch torchvision torchaudio --index-url $PYTORCH_INDEX && \
    deactivate

EXPOSE 7860

ENTRYPOINT git config --global --add safe.directory "*" && \
           source venv/bin/activate && \
           python launch.py

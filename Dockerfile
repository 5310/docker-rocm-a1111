FROM rocm/pytorch:latest

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y libglib2.0-0 wget && \
    apt-get clean -y

VOLUME /root/app

WORKDIR /root/app

ARG A1111_REPO=https://github.com/AUTOMATIC1111/stable-diffusion-webui
ARG PYTORCH_INDEX=https://download.pytorch.org/whl/rocm5.6

RUN if [ "$(ls -A .)" ]; \
    then \
        git reset --hard && \
        git pull; \
    else \
        git clone --depth 1 %A1111_REPO .; \
    fi && \
    sed -i -e '/^torch\r/d' requirements.txt && \
    sed -i -e '/^torch\r/d' requirements_versions.txt

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    REQS_FILE='requirements.txt'

RUN python -m venv venv && \
    source venv/bin/activate && \
    python -m pip install --upgrade pip wheel && \
    python -m pip install --force-reinstall torch torchvision torchaudio --index-url $PYTORCH_INDEX && \
    deactivate

EXPOSE 7860

ENTRYPOINT [ "/bin/sh", "-c", "git config --global --add safe.directory \"*\" && source venv/bin/activate && python launch.py" ]
CMD [ "--precision", "full", "--no-half" ]
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

RUN apt-get update && \
    apt-get install -y libglib2.0-0 wget && \
    apt-get clean -y; \
    \
    git config --global --add safe.directory "*"; \
    if [ "$(git config --get remote.origin.url) == $A1111_REPO" ]; \
    then \
        git reset --hard && \
        git pull; \
    else \
        if [ "$(ls -A .)" ]; \
        then \
            echo `/root/app` volume is not a valid repository \
            exit 1; \
        else \
            git clone --depth 1 $A1111_REPO .; \
        fi; \
    fi && \
    sed -i -e '/^torch\r/d' requirements.txt && \
    sed -i -e '/^torch\r/d' requirements_versions.txt; \
    \
    python -m venv venv && \
    pip install --upgrade pip wheel && \
    pip install --force-reinstall torch torchvision torchaudio --index-url $PYTORCH_INDEX;

EXPOSE 7860

ENTRYPOINT ["python", "launch.py"]
CMD ["--precision", "full", "--no-half"]
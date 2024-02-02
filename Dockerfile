# FROM rocm/pytorch:latest
FROM ubuntu:20.04

SHELL ["/bin/bash", "-cx"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&\
    apt-get install -y git python3 python3-venv python3-pip &&\
    apt-get clean &&\
    ln -s /usr/bin/python3 /usr/bin/python &&\
    :

RUN apt-get update &&\
    apt-get install -y libglib2.0-0 wget &&\
    apt-get clean -y &&\
    :;

VOLUME /root/app
WORKDIR /root/app
EXPOSE 7860

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8
ENV VIRTUAL_ENV=$(pwd)/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH

ENTRYPOINT  echo Setting up Web-UI repository &&\
            git config --global --add safe.directory "*" &&\
            if [ ! -e initialized ] || [ $WEBUI_UPDATE ]; \
            then \
                if [ -d .git ] && [ "$(git config --get remote.origin.url)" == "${WEBUI_REPO:-https://github.com/AUTOMATIC1111/stable-diffusion-webui.git}" ]; \
                then \
                    echo Existing repository found, updating... &&\
                    git reset --hard &&\
                    git pull &&\
                    :; \
                else \
                    echo Pulling repository... &&\
                    git clone --depth 1 ${WEBUI_REPO:-https://github.com/AUTOMATIC1111/stable-diffusion-webui.git} . &&\
                    :; \
                fi &&\
                touch initialized &&\
                \
                echo Patching out the broken PyTorch requirement... &&\
                sed -i -e '/^torc \n\r/d' requirements.txt &&\
                sed -i -e '/^torc \n\r/d' requirements_versions.txt &&\
                \
                echo Setting up Python dependencies... &&\
                python -m venv venv && \
                python -m pip install --upgrade pip wheel &&\
                python -m pip install --upgrade torch torchvision torchaudio --index-url ${PYTORCH_INDEX:-PYTORCH_INDEX=https://download.pytorch.org/whl/rocm5.7} &&\
                :; \
            fi &&\
            echo Launching Web-UI... &&\
            echo python launch.py ${WEBUI_PARAMS:---precision full --no-half} &&\
            :;

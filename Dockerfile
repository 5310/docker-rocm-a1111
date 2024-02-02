FROM rocm/pytorch:latest

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

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
                if [ -d .git ] && [ "$(git config --get remote.origin.url)" == "$WEBUI_REPO" ]; \
                then \
                    echo Existing repository found, updating... &&\
                    git reset --hard &&\
                    git pull &&\
                    :; \
                else \
                    echo Pulling repository... &&\
                    git clone --depth 1 $WEBUI_REPO . &&\
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
                python -m pip install --upgrade torch torchvision torchaudio --index-url $PYTORCH_INDEX &&\
                :; \
            fi &&\
            echo Launching Web-UI... &&\
            echo python launch.py ${WEBUI_PARAMS:---precision full --no-half} &&\
            :;

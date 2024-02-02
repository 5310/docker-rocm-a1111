FROM rocm/pytorch:latest

SHELL ["/bin/bash", "-cx"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&\
    apt-get install -y git libglib2.0-0 wget &&\
    apt-get clean -y &&\
    git config --global --add safe.directory "*" &&\
    :;

VOLUME /root/app
WORKDIR /root/app
EXPOSE 7860

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8
ENV IGNORE_CMD_ARGS_ERRORS=true
ENV REQS_FILE=requirements.txt
ENV PYTORCH_INDEX=${PYTORCH_INDEX:-PYTORCH_INDEX=https://download.pytorch.org/whl/rocm5.7}
ENV WEBUI_REPO=${WEBUI_REPO:-https://github.com/AUTOMATIC1111/stable-diffusion-webui.git}
ENV WEBUI_ARGS=${WEBUI_ARGS:---no-download-sd-model}

ENTRYPOINT  echo Setting up Web-UI repository &&\
            if [ ! -e initialized ] || [ $WEBUI_UPDATE ]; \
            then \
                if [ -d .git ] && [ "$(git config --get remote.origin.url)" == "$WEBUI_REPO" ]; \
                then \
                    echo Existing repository found... &&\
                    :; \
                else \
                    echo "Cloning" new repository... &&\
                    # This whole dance is needed because we want to commit this folder to retain ownership
                    rm -Rf .git &&\
                    git clone --no-checkout $WEBUI_REPO /tmp/repo &&\
                    mv /tmp/repo/.git .git &&\
                    :; \
                fi &&\
                echo Pulling data... &&\
                git reset --hard &&\
                git pull --depth 1 &&\
                \
                echo Setting up Python dependencies... &&\
                python -m venv venv &&\
                source venv/bin/activate &&\
                python -m pip install --upgrade pip wheel &&\
                python -m pip install --upgrade --force-reinstall torch torchvision torchaudio --index-url $PYTORCH_INDEX &&\
                deactivate &&\
                \
                touch initialized &&\
                :; \
            fi &&\
            \
            echo Launching Web-UI... &&\
            source venv/bin/activate &&\
            python launch.py $WEBUI_ARGS &&\
            :;

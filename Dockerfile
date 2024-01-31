FROM rocm/pytorch:latest

VOLUME /root/app

EXPOSE 7860

SHELL ["/bin/bash", "-c"]

WORKDIR /root/app

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PATH=$VIRTUAL_ENV/bin:$PATH \
    REQS_FILE='requirements.txt'

ENTRYPOINT  echo Updating system... &&\
            apt-get update &&\
            apt-get install -y libglib2.0-0 wget &&\
            apt-get clean -y &&\
            \
            echo Setting up Web-UI repository &&\
            git config --global --add safe.directory "*" &&\
            if [ "$(git config --get remote.origin.url)" == "$A1111_REPO" ]; \
            then \
                echo Existing repository found, updating... &&\
                git reset --hard &&\
                git pull; \
            else \
                echo Pulling repository... &&\
                git clone --depth 1 $A1111_REPO .; \
            fi &&\
            \
            echo Patching out the broken PyTorch requirement... &&\
            sed -i -e '/^torc \n\r/d' requirements.txt &&\
            sed -i -e '/^torc \n\r/d' requirements_versions.txt &&\
            \
            echo Setting up Python dependencies... &&\
            python -m pip install --upgrade pip wheel &&\
            python -m pip install --upgrade torch torchvision torchaudio --index-url $PYTORCH_INDEX &&\
            echo Launching Web-UI... &&\
            python launch.py $WEBUI_PARAMS;
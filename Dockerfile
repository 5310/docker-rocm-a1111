FROM rocm/pytorch:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&\
    apt-get install -y git libglib2.0-0 wget libgl1-mesa-glx &&\
    apt-get clean -y &&\
    git config --global --add safe.directory "*" &&\
    :;

VOLUME /root/app
WORKDIR /root/app
EXPOSE 7860

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

ENV REPO=${REPO:-"https://github.com/AUTOMATIC1111/stable-diffusion-webui.git"}
ENV TORCH_COMMAND="pip install --upgrade torch torchvision torchaudio --index-url ${TORCH_INDEX:-"https://download.pytorch.org/whl/rocm5.7"}"
ENV COMMANDLINE_ARGS=${COMMANDLINE_ARGS:-"--listen --enable-insecure-extension-access --no-download-sd-model"}

ENTRYPOINT  echo Setting up Web-UI repository &&\
            if [ ! -e initialized ] || [ $UPDATE ]; \
            then \
                if [ -d .git ] && [ "$(git config --get remote.origin.url)" == "$REPO" ]; \
                then \
                    echo Existing repository found... &&\
                    :; \
                else \
                    echo "Cloning" new repository... &&\
                    # This whole dance is needed because we want to commit this folder to retain ownership
                    rm -Rf .git &&\
                    git clone --no-checkout $REPO /tmp/repo &&\
                    mv /tmp/repo/.git .git &&\
                    :; \
                fi &&\
                echo Pulling data... &&\
                git reset --hard &&\
                git pull --depth 1 &&\
                \
                touch initialized &&\
                :; \
            fi &&\
            \
            echo Launching Web-UI... &&\
            bash ./webui.sh -f &&\
            :;

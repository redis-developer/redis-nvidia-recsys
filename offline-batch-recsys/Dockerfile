FROM nvcr.io/nvidia/merlin/merlin-tensorflow:22.11

WORKDIR /workdir

COPY ./requirements.txt .
RUN python3 -m pip install -r requirements.txt

# Install Curl
RUN apt-get update \
    && echo "Installing curl" \
    && apt-get install -y curl \
    && echo "Installing Redis" \
    && apt-get install -y redis

# Define this parameter to install jupyter lab
ENV JUPYTER_ENABLE_LAB=yes

CMD jupyter lab --no-browser --ip=0.0.0.0 --allow-root --port=8888

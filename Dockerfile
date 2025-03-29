FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        git \
        curl \
        unzip \
        ca-certificates \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1 \
        build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

COPY basalt_env.yml .

RUN conda env create -f basalt_env.yml \
    && conda update -n BASALT -c linbin203 basalt \
    && conda clean --all -f -y \
    && conda run -n BASALT pip cache purge \
    && conda init bash \
    && echo "conda activate BASALT" >> ~/.bashrc

COPY . /app/

# Expose the port of JupyterLab
EXPOSE 8888

# Set entrypoint to run JupyterLab
ENTRYPOINT ["/opt/conda/envs/BASALT/bin/jupyter", "lab", "--ip='0.0.0.0'", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]
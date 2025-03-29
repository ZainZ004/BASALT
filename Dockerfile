# 第一阶段：构建环境
FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime AS builder

WORKDIR /app

# 安装构建依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        git \
        curl \
        unzip \
        ca-certificates \
        build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# 复制环境文件并创建conda环境
COPY basalt_env.yml .
RUN conda env create -f basalt_env.yml \
    && conda update -n BASALT -c linbin203 basalt \
    && conda clean --all -f -y \
    && conda run -n BASALT pip cache purge

# 第二阶段：运行环境
FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime AS runtime

WORKDIR /app

# 安装运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# 从构建阶段复制conda环境
COPY --from=builder /opt/conda/envs/BASALT /opt/conda/envs/BASALT

# 设置conda环境
RUN conda init bash \
    && echo "conda activate BASALT" >> ~/.bashrc

# 复制应用程序文件
COPY . /app/

# 暴露JupyterLab端口
EXPOSE 8888

# 设置入口点
ENTRYPOINT [ "/bin/bash" ]
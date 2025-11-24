# FROM pytorch/pytorch:2.3.1-cuda11.8-cudnn8-devel

# RUN apt-get update && apt-get install -y libgl1-mesa-glx libpci-dev curl nano psmisc zip git && apt-get --fix-broken install -y

# RUN conda install -y scikit-learn pandas flake8 yapf isort yacs future libgcc

# RUN pip install --upgrade pip && python -m pip install --upgrade setuptools && \
#     pip install opencv-python tb-nightly matplotlib logger_tt tabulate tqdm wheel mccabe scipy

# COPY ./fonts/* /opt/conda/lib/python3.10/site-packages/matplotlib/mpl-data/fonts/ttf/


ARG PYTORCH="1.10.0"
ARG CUDA="11.3"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

RUN apt-get update && apt-get install -y \
    ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libxrender-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install MMCV-full (latest stable 1.x)
RUN pip install mmcv-full==1.7.1 \
    -f https://download.openmmlab.com/mmcv/dist/cu113/torch1.10.0/index.html

# Install MMDetection (latest stable 2.x)
RUN pip install mmdet==2.28.2

# Install MMRotate
RUN git clone https://github.com/open-mmlab/mmrotate.git /mmrotate
WORKDIR /mmrotate

# 确保使用 MMRotate 0.x 分支（使用 mmcv1.x）
RUN git checkout v0.3.3

ENV FORCE_CUDA="1"
RUN pip install -r requirements/build.txt
RUN pip install --no-cache-dir -e .


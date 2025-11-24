# FROM pytorch/pytorch:2.3.1-cuda11.8-cudnn8-devel

# RUN apt-get update && apt-get install -y libgl1-mesa-glx libpci-dev curl nano psmisc zip git && apt-get --fix-broken install -y

# RUN conda install -y scikit-learn pandas flake8 yapf isort yacs future libgcc

# RUN pip install --upgrade pip && python -m pip install --upgrade setuptools && \
#     pip install opencv-python tb-nightly matplotlib logger_tt tabulate tqdm wheel mccabe scipy

# COPY ./fonts/* /opt/conda/lib/python3.10/site-packages/matplotlib/mpl-data/fonts/ttf/


ARG PYTORCH="1.6.0"
ARG CUDA="10.1"
ARG CUDNN="7"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install MMCV MMDetection
RUN pip install mmcv-full -f https://download.openmmlab.com/mmcv/dist/cu101/torch1.6.0/index.html
RUN pip install mmdet
# Install MMRotate
RUN conda clean --all
RUN git clone https://github.com/open-mmlab/mmrotate.git /mmrotate
WORKDIR /mmrotate
ENV FORCE_CUDA="1"
RUN pip install -r requirements/build.txt
RUN pip install --no-cache-dir -e .

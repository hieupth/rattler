ARG NV_RELEASE=latest


FROM hieupth/mamba:${NV_RELEASE}

RUN conda install -y \
      rattler-buid \
      jinja2 \
      psutil \
      distro \
      requests \
    && conda clean -ay


FROM nvcr.io/nvidia/tensorrt:${NV_RELEASE}-py3 as nvdia

# Copy tensorrt
COPY --from=nvidia /opt/tensorrt /opt/tensorrt
RUN echo "/opt/tensorrt/lib" > /etc/ld.so.conf.d/tensorrt.conf

# Copy CUDA toolkit tree
COPY --from=nvidia /usr/local/cuda /usr/local/cuda
COPY --from=nvidia /usr/local/cuda-*/ /usr/local/cuda-*/
COPY --from=nvidia /etc/ld.so.conf.d/*cuda* /etc/ld.so.conf.d/
COPY --from=nvidia /etc/ld.so.conf.d/*nvidia* /etc/ld.so.conf.d/

# Importance envs.
ENV CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:/opt/tensorrt/lib:${LD_LIBRARY_PATH}

RUN ldconfig
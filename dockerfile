ARG NV_RELEASE=25.11


FROM nvcr.io/nvidia/tensorrt:${NV_RELEASE}-py3 AS builder


FROM hieupth/mamba:${NV_RELEASE}

RUN conda install -y \
      rattler-build \
      jinja2 \
      psutil \
      distro \
      requests \
    && conda clean -ay

# Copy tensorrt
COPY --from=builder /opt/tensorrt /opt/tensorrt
RUN echo "/opt/tensorrt/lib" > /etc/ld.so.conf.d/tensorrt.conf

# Copy CUDA toolkit tree
COPY --from=builder /usr/local/cuda /usr/local/cuda
COPY --from=builder /usr/local/cuda-*/ /usr/local/cuda-*/
COPY --from=builder /etc/ld.so.conf.d/*cuda* /etc/ld.so.conf.d/
COPY --from=builder /etc/ld.so.conf.d/*nvidia* /etc/ld.so.conf.d/

# Importance envs.
ENV CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:/opt/tensorrt/lib:${LD_LIBRARY_PATH}

RUN ldconfig
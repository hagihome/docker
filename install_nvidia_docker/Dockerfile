FROM nvidia/cuda:9.0-cudnn7-devel

RUN apt update -y && \
    apt install -y --no-install-recommends \
    python3-dev python3-pip python3-setuptools python3-wheel graphviz 

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt && \
    rm requirements.txt

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

CMD ["/bin/bash","-l"]


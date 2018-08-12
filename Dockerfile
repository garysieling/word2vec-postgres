FROM postgres:latest
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y curl
RUN curl -o anaconda.sh https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh
RUN chmod +x ./anaconda.sh
RUN ./anaconda.sh -b
RUN rm ./anaconda.sh
RUN /root/anaconda3/bin/conda install faiss-cpu -c pytorch
RUN mkdir vectors && \
    curl -o vectors/GoogleNews-vectors-negative300.bin.gz "https://s3.amazonaws.com/dl4j-distribution/GoogleNews-vectors-negative300.bin.gz"
RUN gzip --decompress vectors/GoogleNews-vectors-negative300.bin.gz
RUN mkdir index_creation && \
    cd index_creation && \
    /root/anaconda3/bin/python transform_vecs.py
COPY docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
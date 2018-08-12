FROM postgres:latest
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y curl git
RUN curl -o anaconda.sh https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh && \
    chmod +x ./anaconda.sh && \
    ./anaconda.sh -b && \
    rm ./anaconda.sh
RUN /root/anaconda3/bin/conda install gensim faiss-cpu -c pytorch
RUN git clone https://github.com/guenthermi/postgres-word2vec
WORKDIR postgres-word2vec
RUN mkdir vectors && \
    curl -o vectors/GoogleNews-vectors-negative300.bin.gz "https://s3.amazonaws.com/dl4j-distribution/GoogleNews-vectors-negative300.bin.gz"
RUN gzip --decompress vectors/GoogleNews-vectors-negative300.bin.gz
RUN cd index_creation && \
    /root/anaconda3/bin/python3 transform_vecs.py
COPY docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
FROM postgres:latest
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y \
    curl git make build-essential \
    postgresql-server-dev-10 postgresql-common
RUN curl -o anaconda.sh https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh && \
    chmod +x ./anaconda.sh && \
    ./anaconda.sh -b && \
    rm ./anaconda.sh
RUN /root/anaconda3/bin/conda install gensim faiss-cpu psycopg2 -c pytorch
RUN git clone https://github.com/guenthermi/postgres-word2vec
WORKDIR postgres-word2vec
RUN mkdir vectors
ADD google_vecs.txt vectors/google_vecs.txt
RUN cd freddy_extension && \
    make install
WORKDIR index_creation
RUN /root/anaconda3/bin/python3 ./vec2database.py config/vecs_config.json
RUN /root/anaconda3/bin/python3 ./vec2database.py config/vecs_norm_config.json
RUN /root/anaconda3/bin/python3 ./pq_index.py config/pq_config.json
RUN /root/anaconda3/bin/python3 ./ivfadc.py config/ivfadc_config.json
COPY docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

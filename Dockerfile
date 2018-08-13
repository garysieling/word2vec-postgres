FROM postgres:latest
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y \
    curl git make build-essential \
    postgresql-server-dev-10 postgresql-common
RUN mkdir /home/postgres && chown postgres /home/postgres 
RUN git clone https://github.com/guenthermi/postgres-word2vec
WORKDIR postgres-word2vec
RUN chown -R postgres *
RUN mkdir vectors
ADD google_vecs.txt vectors/google_vecs.txt
RUN cd freddy_extension && \
    make install
COPY docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
USER postgres
WORKDIR /home/postgres
RUN curl -o miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ./miniconda.sh && \
    ./miniconda.sh -b && \
    rm ./miniconda.sh
RUN /home/postgres/miniconda3/bin/conda install -y gensim faiss-cpu psycopg2 -c pytorch
apt-get update && apt-get -y upgrade &&
apt-get install -y \
    curl git make build-essential &&
apt-get install -y postgresql postgresql-contrib postgresql-server-dev-9.5

su postgres
cd ~

git clone https://github.com/guenthermi/postgres-word2vec
cd postgres-word2vec
mkdir vectors

# be root...
exit 
cd /var/lib/postgresql/postgres-word2vec
cd postgres-word2vec/freddy_extension && \
    make install

su postgres
psql -c "create database imdb;"
psql -c "create extension freddy;" imdb


cd ..


cd ~
curl -o miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ./miniconda.sh && \
    ./miniconda.sh -b && 
    ~/miniconda3/bin/conda install -y gensim faiss-cpu psycopg2 -c pytorch

# wget -c "https://s3.amazonaws.com/dl4j-distribution/GoogleNews-vectors-negative300.bin.gz" -P vectors
# gzip --decompress vectors/GoogleNews-vectors-negative300.bin.gz

#cd index_creation
# ~/miniconda3/bin/python3 transform_vecs.py

# scp g.tar root@142.93.196.38:/var/lib/postgresql/postgres-word2vec/vectors/g.tar
cd ~/postgres-word2vec/vectors/

create user admin with superuser password 'password';

vi config/db_config.json

# set username, password, db

./slack.sh "started: 'python3 vec2database.py config/vecs_config.json'"
~/miniconda3/bin/python3 vec2database.py config/vecs_config.json
./slack.sh "started: 'python3 vec2database.py config/vecs_norm_config.json'"
~/miniconda3/bin/python3 vec2database.py config/vecs_norm_config.json
./slack.sh "started: 'python3 pq_index.py config/pq_config.json'"
~/miniconda3/bin/python3 pq_index.py config/pq_config.json
./slack.sh "started: 'python3 ivfadc.py config/ivfadc_config.json'"
~/miniconda3/bin/python3 ivfadc.py config/ivfadc_config.json
./slack.sh "load complete"


psql -c "SELECT init('google_vecs', 'google_vecs_norm', 'pq_quantization', 'pq_codebook', 'fine_quantization', 'coarse_quantization', 'residual_codebook');" imdb
psql -c "create extension freddy;" imdb

set -e

#./slack.sh "started: apt install"

# apt-get -y upgrade
apt-get update &&
apt-get install -y curl git make build-essential
apt-get install -y postgresql 
apt-get install -y postgresql-contrib postgresql-server-dev-10

echo "creating db"
su postgres -c 'psql -c "create database imdb;"'

#./slack.sh "started: cloning"

#sudo -u postgres -i
cd ~

echo "cloning code"
git clone https://github.com/guenthermi/postgres-word2vec

echo "cd..ing"
cd postgres-word2vec

echo "making folder"
mkdir vectors

# be root...

# sudo su 
echo "installing "
cd ~/postgres-word2vec/freddy_extension && \
    make install

echo "installing extension"
su postgres -c 'psql -c "create extension freddy;" imdb'

#./slack.sh "started: installing python"

cd ~
curl -o miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ./miniconda.sh && \
    ./miniconda.sh -b && 
    ~/miniconda3/bin/conda install -y gensim faiss-cpu psycopg2 -c pytorch


# wget -c "https://s3.amazonaws.com/dl4j-distribution/GoogleNews-vectors-negative300.bin.gz" -P vectors
# gzip --decompress vectors/GoogleNews-vectors-negative300.bin.gz

#cd index_creation
# ~/miniconda3/bin/python3 transform_vecs.py

#./slack.sh "started: acquiring data"

# scp g.tar root@142.93.196.38:/var/lib/postgresql/postgres-word2vec/vectors/g.tar
cd ~/postgres-word2vec/vectors/

ln -s /vagrant_data/google_vecs.txt ./google_vecs.txt

cd ~/postgres-word2vec/index_creation/

#./slack.sh "started: 'python3 vec2database.py config/vecs_config.json'"
~/miniconda3/bin/python3 vec2database.py config/vecs_config.json
#./slack.sh "started: 'python3 vec2database.py config/vecs_norm_config.json'"
~/miniconda3/bin/python3 vec2database.py config/vecs_norm_config.json
#./slack.sh "started: 'python3 pq_index.py config/pq_config.json'"
~/miniconda3/bin/python3 pq_index.py config/pq_config.json
#./slack.sh "started: 'python3 ivfadc.py config/ivfadc_config.json'"
~/miniconda3/bin/python3 ivfadc.py config/ivfadc_config.json

#./slack.sh "started: inititialing extension"

psql -c "SELECT init('google_vecs', 'google_vecs_norm', 'pq_quantization', 'pq_codebook', 'fine_quantization', 'coarse_quantization', 'residual_codebook');" imdb
psql -c "create extension freddy;" imdb

#./slack.sh "provisioning complete"

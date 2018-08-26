set -e

#./slack.sh "started: apt install"

# apt-get -y upgrade
apt-get update &&
apt-get install -y curl git make build-essential
apt-get install -y postgresql 
apt-get install -y postgresql-contrib postgresql-server-dev-10

echo "creating db"
su postgres -c 'psql -c "create database jobs;"'
su postgres -c 'psql -c "create table jobs (title text, url text, company text, location text, postData text, description text, index bigint, query json);" jobs';
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
cd ~/postgres-word2vec/

curl -L -o ./google_vec.tar https://www.dropbox.com/s/fhglt3y3b7l1hx7/google_vec.tar?dl=0 --progress-bar
find .
tar xvf ./google_vec.tar 

mv ./google_vecs2.txt ./vectors/google_vecs.txt

cd ~/postgres-word2vec/index_creation/

su postgres -c "psql -c \"create user admin with superuser password 'admin'\";"

cat > config/db_config.json << EndOfMessage
{
        "username": "admin",
        "password": "admin",
        "host": "localhost",
        "db_name": "jobs",
        "batch_size": 50000,
        "log": ""
}
EndOfMessage


#./slack.sh "started: 'python3 vec2database.py config/vecs_config.json'"
~/miniconda3/bin/python3 vec2database.py config/vecs_config.json
#./slack.sh "started: 'python3 vec2database.py config/vecs_norm_config.json'"
~/miniconda3/bin/python3 vec2database.py config/vecs_norm_config.json
#./slack.sh "started: 'python3 pq_index.py config/pq_config.json'"
~/miniconda3/bin/python3 pq_index.py config/pq_config.json
#./slack.sh "started: 'python3 ivfadc.py config/ivfadc_config.json'"
~/miniconda3/bin/python3 ivfadc.py config/ivfadc_config.json

#./slack.sh "started: inititialing extension"

su postgres -c "psql -c \"SELECT init('google_vecs', 'google_vecs_norm', 'pq_quantization', 'pq_codebook', 'fine_quantization', 'coarse_quantization', 'residual_codebook');\" jobs"
su postgres -c "psql -c \"create extension freddy;\" jobs"

#./slack.sh "provisioning complete"

echo "listen_addresses = '*'" >> /etc/postgresql/10/main/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/10/main/pg_hba.conf

service postgresql restart

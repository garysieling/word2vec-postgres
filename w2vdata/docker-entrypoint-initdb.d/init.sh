echo "****************************************"

whoami

cd /postgres-word2vec/index_creation

pwd

find .

#set PATH=.
psql -f /docker-entrypoint-initdb.d/createdb

/home/postgres/miniconda3/bin/python3 vec2database.py config/vecs_config.json
/home/postgres/miniconda3/bin/python3 vec2database.py config/vecs_norm_config.json
/home/postgres/miniconda3/bin/python3 pq_index.py config/pq_config.json
/home/postgres/miniconda3/bin/python3 ivfadc.py config/ivfadc_config.json

echo "INITIALIZING INDEX!"

psql -f /docker-entrypoint-initdb.d/setup

echo "SETUP COMPLETE!"
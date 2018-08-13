echo "****************************************"

whoami

cd /postgres-word2vec/index_creation

pwd

find .

set PATH=.
/home/postgres/miniconda3/bin/python3 vec2database.py config/vecs_config.json
/home/postgres/miniconda3/bin/python3 vec2database.py config/vecs_norm_config.json
/home/postgres/miniconda3/bin/python3 pq_index.py config/pq_config.json
/home/postgres/miniconda3/bin/python3 ivfadc.py config/ivfadc_config.json

psql "create extension freddy;"
psql "SELECT init('google_vecs', 'google_vecs_norm', 'pq_quantization', 'pq_codebook', 'fine_quantization', 'coarse_quantization', 'residual_codebook');"
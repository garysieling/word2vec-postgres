git clone https://github.com/garysieling/postgres-word2vec.git
cd postgres-word2vec

wget -c "https://s3.amazonaws.com/dl4j-distribution/GoogleNews-vectors-negative300.bin.gz" -P vectors
gzip --decompress vectors/GoogleNews-vectors-negative300.bin.gz

pip3 install gensim
cd index_creation
python3 transform_vecs.py

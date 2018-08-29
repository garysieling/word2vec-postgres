create index vecs_word on google_vecs (word);
create index vecs_word_vec on google_vecs (word, vector);

-- completed in 6
-- 5112455
select count(*) from doc_averages;
drop table doc_averages;

-- [2018-08-28 02:20:25] 27436 rows affected in 3 h 12 m 31 s 333 ms
create table doc_averages as
select
   agg_vec_plus_bytea(vector) summed,
   url
from (
   select
      term,
      url,
      title,
      google_vecs.vector
   from (
        select
           term,
           url,
           title
        from (
             select
                  lower(json_array_elements_text(words)) term,
                  url,
                  title
             from jobs
             ) words
        ) terms
        join google_vecs on google_vecs.word = terms.term
   ) vectors
group by url
;


-- frequent / infrequent skills
select
    term,
    location,
    count(*)
from (
    select
        lower(json_array_elements_text(words)) term,
        location
    /*query,
         index,
         title,
         url,
         company,
         location,
         description*/
    from jobs
) words
where term in (
    'javascript',
    'css',
    'scala',
    'postgresql'
)
group by term, location;

-- [2018-08-28 08:44:14] 27436 rows affected in 13 m 24 s 215 ms
create table job_descriptions_avg as
select tokenize(words) as job_avg, url
from job_descriptions;

select tokenize('javascript css web developer') as query;

drop table knn_output;

create table knn_output as (
SELECT distinct lower(jobs.title) title, lower(t.word) word, t.similarity
from jobs,
     k_nearest_neighbour_ivfadc(jobs.title, 1000) as t
);

select * from knn_output where title = 'node.js' order by word;
select distinct title from knn_output order by 1;
select distinct title from jobs order by 1;


SELECT *
FROM
  knn_in_pq(
    'css'::text,
    50,
    ARRAY(SELECT title FROM jobs));

CREATE INDEX description_idx ON jobs USING GIN(to_tsvector('english', description));

select ts_rank_cd(
        to_tsvector('english', description),
        to_tsquery('javascript | react | d3 | node | js | css | html | web | front | end')) fts_score, *
from jobs
where to_tsvector('english', description) @@ to_tsquery('javascript | react | d3 | node | js | css | html')
order by 1 desc
limit 100

-- what rare skills do I have?


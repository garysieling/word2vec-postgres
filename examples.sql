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


SELECT jobs.title, t.*
from jobs,
     k_nearest_neighbour_ivfadc(jobs.title, 100) as t
ORDER BY jobs.title ASC;


SELECT *
FROM
  knn_in_pq(
    'javascript'::text,
    50,
    ARRAY(SELECT title FROM jobs));

-- what rare skills do I have?


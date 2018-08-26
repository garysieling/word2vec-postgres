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

-- add up all the vectors for terms
select
   agg_vec_plus_bytea(vector),
   term
from (
    select
        term,
        google_vecs.vector,
        google_vecs.id
    from (
        select
            term
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
        /*where term in (
            'javascript',
            'css',
            'scala',
            'postgresql'
        )*/
     ) terms
     left join google_vecs on google_vecs.word = terms.term
 ) vectors
 group by term
-- what rare skills do I have?


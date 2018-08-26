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
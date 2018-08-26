const indeed = require('indeed-scraper');
const async = require('async');
const _ = require('lodash');
const cheerio = require('cheerio');
const https = require('follow-redirects').https;
const { Client } = require('pg');
const natural = require('natural');

const tokenizer = new natural.WordTokenizer();

const client = new Client({
  user: 'admin',
  host: '172.22.36.108',
  database: 'jobs',
  password: 'admin',
  port: 5432
});

client.connect(
  (err) => {
    console.log(err);
  }
);

const city_set = [
    `New York, NY`,
    `Chicago, IL`,
    `San Francisco, CA`,
    `Austin, TX`,
    `Seattle, WA`,
    `Los Angeles, CA`,
    `Philadelphia, PA`,
    `Atlanta, GA`,
    `Dallas, TX`,
    `Pittsburgh, PA`,
    `Portland, OR`,
    `Phoenix, AZ`,
    `Denver, CO`,
    `Houston, TX`,
    `Miami, FL`,
    `Washington DC`,
    `Boulder, CO`,
    `Baltimore, MD`
];

const levels = [
    'entry_level'
];

const jobTypes = [
    'fulltime',
    'contract',
    'parttime',
    'temporary',
    'internship',
    'commission'
];

async.map(
    city_set,
    (city, city_cb) => {
    console.log(`querying city ${city}`);
        const queryOptions = {
          //query: 'Software',
          city: city,
          //radius: '100',
          //level: 'entry_level',
          //jobType: 'fulltime',
          //maxAge: '7',
          sort: 'relevance',
          //limit: '100'
        };

        console.log('Starting query...');

        indeed
            .query(queryOptions)
            .then(res => {
          //console.log('Result: ' + res);

          index = 0;
          async.mapSeries(
            res,
            (job, cb) => {
              https.get(job.url, (res) => {
                let text = '';
                res.on('data', (d) => {
                  text += d;
                });

                res.on('end', () => {
                  const $ = cheerio.load(text);

                  const description =
                    $('#job_summary').text() + ' ' +
                    $('.jobsearch-JobComponent-description').text();

                  if (description.trim() === '') {
                    console.log('text: ' + text);
                    console.log(job.url);
                  }

                  job.description = description;
                  job.index = index++;

                  job.query = queryOptions;

                  //.log(job); // An array of Job objects

                  const words = JSON.stringify(
                    tokenizer.tokenize(
                      job.title + ' ' +
                      job.company + ' ' +
                      job.location + ' ' +
                      job.description
                    )
                  );

                  //console.log(words);

                  /*
                    create table jobs
                      (title text,
                       url text,
                       company text,
                       location text,
                       postData text,
                       description text,
                       level text,
                       jobType text,
                       index bigint,
                       query json,
                       words json);
                  */
                  client.query(
                    `INSERT INTO jobs 
                        (title, url, company, 
                        location, postData, description,
                        level, jobType,
                        index, query, words)
                     VALUES (
                        $1, $2, $3, 
                        $4, $5, $6, 
                        $7, $8, $9,
                        $10, $11
                      )`,
                     [
                       job.title, job.url, job.company,
                       job.location, job.postData, job.description,
                       job.level, job.jobType,
                       job.index, JSON.stringify(job.query), words
                     ],
                     (err, res) => {
                        if (err) {
                            console.log("result: " + err);
                        }

                      cb(null, job);
                    });
                });

              }).on('error', (e) => {
                console.error(e);
                cb(e, null);
              });
            },
            (results) => {
              console.log(results);

              city_cb();
              //client.end();
            }
          )
        })
    },
    (err, all_cities) => {
        client.end();
    }
);

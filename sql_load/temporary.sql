/*
Write a query to find the average salary both yearly (salary_year_avg) and hourly (salary_hour_avg) for job postings that were posted after June 01, 2023. Group the results by the schedule type.
*/

SELECT
    job_schedule_type,
    ROUND(AVG(salary_year_avg), 2) AS yearly_avg,
    ROUND(AVG(salary_hour_avg), 2) AS hourly_avg
FROM job_postings_fact
WHERE job_posted_date > '2023-06-01'
GROUP BY job_schedule_type;

/*
Write a query to count the number of job postings for each month in 2023, adjusting the job_posted_date to be in 'America/New_York' time zone before extracting the month. Assume the job_posted_date is stored in UTC. Group by and order by the month.
*/

SELECT
    COUNT(job_id),
    EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM job_postings_fact
WHERE job_posted_date > '2022-12-31' AND job_posted_date < '2024-01-01'
GROUP BY date_month
LIMIT 200

SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
    FROM job_postings_fact
    GROUP BY location_category

-- Practice problem 2:30:18
CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM march_jobs;

-- Subquery
SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;

-- CTE
WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)
SELECT *
FROM january_jobs;

-- Subquery example:

SELECT name AS company_name
FROM company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM   
        job_postings_fact
    WHERE
        job_no_degree_mention = true
)

-- CTE example

/*
SELECT
    company_id,
    COUNT(job_id) AS number_of_job_posts
FROM job_postings_fact
GROUP BY company_id
*/

WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM job_postings_fact
    GROUP BY company_id
)
SELECT
    company_dim.name AS company_name,
    total_jobs
FROM company_dim 
LEFT JOIN company_job_count ON company_dim.company_id = company_job_count.company_id
ORDER BY total_jobs DESC
LIMIT 10

-- Practice problems (2:41:57)

SELECT
    sd.skills,
    top_skills.skill_count
FROM(
    SELECT
    skill_id,
    COUNT(*) AS skill_count
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY skill_count DESC
    LIMIT 5
) AS top_skills
JOIN skills_dim AS sd ON top_skills.skill_id = sd.skill_id

/*
Find the count of the # of remote job postings per skill
- Display the top 5 skills by their demand in remote jobs
- include skill ID, name, and count of postings requiring the skill
*/

SELECT
    SKDIM.skill_id,
    SKDIM.skills,
    COUNT(job_location) AS remote_jobs
FROM skills_dim AS SKDIM
INNER JOIN skills_job_dim AS SJDIM ON SKDIM.skill_id = SJDIM.skill_id
INNER JOIN job_postings_fact AS JPFACT ON SJDIM.job_id = JPFACT.job_id
WHERE job_location = 'Anywhere'
GROUP BY SKDIM.skill_id, SKDIM.skills
ORDER BY remote_jobs DESC
LIMIT 20

-- Turning this into a CTE

WITH remote_job_stats AS
(
SELECT
    SKDIM.skill_id,
    SKDIM.skills,
    JPFACT.job_work_from_home
FROM skills_dim AS SKDIM
INNER JOIN skills_job_dim AS SJDIM ON SKDIM.skill_id = SJDIM.skill_id
INNER JOIN job_postings_fact AS JPFACT ON SJDIM.job_id = JPFACT.job_id
WHERE job_work_from_home = True
)
SELECT    
    skill_id,
    skills,
    COUNT(job_work_from_home) AS remote_jobs
FROM remote_job_stats
GROUP BY skill_id, skills
ORDER BY remote_jobs DESC
LIMIT 20

-- Compare with Luke's result (2:50:00)

-- UNIONS

SELECT  
    job_title_short,
    company_id,
    job_location
FROM january_jobs

UNION

SELECT  
    job_title_short,
    company_id,
    job_location
FROM february_jobs

UNION

SELECT  
    job_title_short,
    company_id,
    job_location
FROM march_jobs

-- UNION ALL

SELECT  
    job_title_short,
    company_id,
    job_location
FROM january_jobs

UNION ALL

SELECT  
    job_title_short,
    company_id,
    job_location
FROM february_jobs

UNION ALL

SELECT  
    job_title_short,
    company_id,
    job_location
FROM march_jobs
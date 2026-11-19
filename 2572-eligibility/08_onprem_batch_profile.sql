-- 2572: WHAT IS THE ON-PREM EXTRACT? (key open question)
-- 04 showed all 113,007 on-prem parties have LATEST_STARTDATE between
-- 09-NOV-26 09:40 and 10-NOV-26 19:40 (~34 h window). Is the on-prem extract the full
-- screened population, or only parties touched by the last batch job(s) (a delta)?
-- If it's a delta, bucket 3 (105k) is largely an artefact of comparing full vs delta.
-- Part A: by batch job
SELECT LATEST_BATCH_JOB_ID, COUNT(*) AS parties,
       MIN(LATEST_STARTDATE) AS min_start, MAX(LATEST_STARTDATE) AS max_start
FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID'
GROUP BY 1 ORDER BY parties DESC;

-- Part B: when were parties first inserted on-prem (date part only, string format DD-MON-YY ...)
SELECT SUBSTR(FIRST_INSERTED_DATE, 4, 6) AS mon_yy, COUNT(*) AS parties
FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID'
GROUP BY 1 ORDER BY parties DESC;

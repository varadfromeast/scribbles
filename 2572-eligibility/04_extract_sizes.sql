-- 2572: size of each side. From the bucket query:
--   GCP eligible   = 1_match + 3_gcp_Y_not_onprem = 112,548 + 105,116 = 217,664
--   on-prem screens = 1_match + 2 + 4               = 112,548 + 21 + 438 = 113,007
-- This confirms those numbers and shows whether the on-prem extract looks truncated
-- (row count, date range of LATEST_STARTDATE).
WITH g AS (
  SELECT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0') AS norm_id, IS_SCRN_ELIGIBLE
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
  WHERE PARTY_ID <> 'PARTY_ID'),
op AS (
  SELECT LPAD(REGEXP_REPLACE(EXTERNALRECORDID, r'[^0-9]', ''), 13, '0') AS norm_id,
         CAST(LATEST_STARTDATE AS STRING) AS sd
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
  WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID')
SELECT 'gcp' AS src, COUNT(*) AS row_count, COUNT(DISTINCT norm_id) AS parties,
       COUNT(DISTINCT IF(IS_SCRN_ELIGIBLE = 'Y', norm_id, NULL)) AS eligible_parties,
       CAST(NULL AS STRING) AS min_startdate, CAST(NULL AS STRING) AS max_startdate
FROM g
UNION ALL
SELECT 'onprem', COUNT(*), COUNT(DISTINCT norm_id), NULL, MIN(sd), MAX(sd)
FROM op;

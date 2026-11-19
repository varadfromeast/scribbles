-- 2572: the 21 parties in bucket 2 (on-prem screens, party missing from GCP extract entirely).
-- Also underscreening on GCP. For each: was it in the SDP feed on 10 Nov? what is its own segment?
-- (2021 had e.g. 7723174200100 "not delivered in SDP party feed on 10 Nov").
-- Also check these IDs against an earlier on-prem snapshot (notes item 1).
WITH g AS (
  SELECT DISTINCT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0') AS norm_id
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
  WHERE PARTY_ID <> 'PARTY_ID'),
op AS (
  SELECT LPAD(REGEXP_REPLACE(EXTERNALRECORDID, r'[^0-9]', ''), 13, '0') AS norm_id, *
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
  WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY norm_id ORDER BY LATEST_STARTDATE DESC) = 1)
SELECT op.*
FROM op
WHERE op.norm_id NOT IN (SELECT norm_id FROM g)
ORDER BY op.norm_id;

-- 2572 eligibility: ID format check for bucket 3_gcp_Y_not_onprem
-- Result of 01 was 0, so the dedupe is not inflating bucket 3.
-- Party IDs look like 10 digits + 3-digit suffix (...100, ...000, ...300).
-- If GCP and on-prem use different suffixes for the same party, the join misses them.
-- match_on_first_10 = gap parties that DO exist on-prem when comparing only the first 10 digits.
--   large share of gap_parties -> mostly an ID-format artefact
--   ~0                         -> gap is real; break down by eligibility reason / segment next

WITH g AS (
  SELECT DISTINCT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0') AS id
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
  WHERE PARTY_ID <> 'PARTY_ID' AND IS_SCRN_ELIGIBLE = 'Y'
),
op AS (
  SELECT DISTINCT LPAD(REGEXP_REPLACE(EXTERNALRECORDID, r'[^0-9]', ''), 13, '0') AS id
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
  WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID'
),
gap AS (
  SELECT id FROM g WHERE id NOT IN (SELECT id FROM op)
)
SELECT COUNT(*) AS gap_parties,
       COUNTIF(SUBSTR(id, 1, 10) IN (SELECT SUBSTR(id, 1, 10) FROM op)) AS match_on_first_10
FROM gap;

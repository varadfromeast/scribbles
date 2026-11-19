-- 2572: 50 random parties from bucket 3 (GCP eligible, not on-prem), with ALL GCP columns.
-- Eyeball these for a pattern (segment, reason code, party type, related-party role).
-- Save results -> CSV if useful. Deterministic sample via FARM_FINGERPRINT.
WITH g AS (
  SELECT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0') AS norm_id, *
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
  WHERE PARTY_ID <> 'PARTY_ID'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY norm_id
                             ORDER BY SAFE_CAST(PARTY_VERSION AS INT64) DESC) = 1),
op AS (
  SELECT DISTINCT LPAD(REGEXP_REPLACE(EXTERNALRECORDID, r'[^0-9]', ''), 13, '0') AS norm_id
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
  WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID')
SELECT g.*
FROM g
WHERE g.IS_SCRN_ELIGIBLE = 'Y'
  AND g.norm_id NOT IN (SELECT norm_id FROM op)
ORDER BY FARM_FINGERPRINT(g.norm_id)
LIMIT 50;

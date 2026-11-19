-- 2572 eligibility: GCP de-duplication bias check
-- The mismatch query de-dups GCP rows with ORDER BY IS_SCRN_ELIGIBLE DESC, PARTY_VERSION DESC,
-- so a party whose LATEST version is 'N' but an OLDER version is 'Y' gets counted as 'Y'.
-- This counts how many parties are affected (potential inflation of bucket 3_gcp_Y_not_onprem).

WITH r AS (
  SELECT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0') AS id,
         IS_SCRN_ELIGIBLE,
         SAFE_CAST(PARTY_VERSION AS INT64) AS v
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
  WHERE PARTY_ID <> 'PARTY_ID'
)
SELECT COUNTIF(latest = 'N' AND any_y) AS older_y_latest_n
FROM (
  SELECT id,
         ARRAY_AGG(IS_SCRN_ELIGIBLE ORDER BY v DESC LIMIT 1)[OFFSET(0)] AS latest,
         LOGICAL_OR(IS_SCRN_ELIGIBLE = 'Y') AS any_y
  FROM r
  GROUP BY id
);

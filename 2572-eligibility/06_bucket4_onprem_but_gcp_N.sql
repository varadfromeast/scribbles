-- 2572: all 438 parties in bucket 4 (on-prem screens, GCP says N) = UNDERSCREENING on GCP.
-- Every one needs a cause (cf. 2021 "GcpNotEligibleByCause": no relation, PoA on inactive
-- contracts, inactive contracts, linked party outside segments 20-33, ...).
-- Returns GCP columns (g_*) and on-prem columns side by side. Save results -> CSV.
WITH g AS (
  SELECT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0') AS norm_id, *
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
  WHERE PARTY_ID <> 'PARTY_ID'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY norm_id
                             ORDER BY SAFE_CAST(PARTY_VERSION AS INT64) DESC) = 1),
op AS (
  SELECT LPAD(REGEXP_REPLACE(EXTERNALRECORDID, r'[^0-9]', ''), 13, '0') AS norm_id, *
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
  WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY norm_id ORDER BY LATEST_STARTDATE DESC) = 1)
SELECT g AS gcp, op AS onprem
FROM g JOIN op USING (norm_id)
WHERE IFNULL(g.IS_SCRN_ELIGIBLE, 'N') <> 'Y'
ORDER BY norm_id;

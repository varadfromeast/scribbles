-- 2572: every bucket broken down by GCP REASON_CODE and PARTY_DOMAIN.
-- Equivalent of 2021 sheet "GcpOnlyByReasonCode" (bucket 3) and the starting point for
-- the bucket-4 cause analysis. Uses latest PARTY_VERSION per party.
WITH g AS (
  SELECT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0') AS id,
         IS_SCRN_ELIGBLE, REASON_CODE, PARTY_DOMAIN
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
  WHERE PARTY_ID <> 'PARTY_ID'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY id
          ORDER BY SAFE_CAST(PARTY_VERSION AS INT64) DESC) = 1),
op AS (
  SELECT DISTINCT LPAD(REGEXP_REPLACE(EXTERNALRECORDID, r'[^0-9]', ''), 13, '0') AS id
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
  WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID')
SELECT
  CASE WHEN g.id IS NULL                                  THEN '2_onprem_only'
       WHEN g.IS_SCRN_ELIGBLE = 'Y' AND op.id IS NOT NULL THEN '1_match'
       WHEN g.IS_SCRN_ELIGBLE = 'Y'                        THEN '3_gcp_Y_not_onprem'
       WHEN op.id IS NOT NULL                              THEN '4_onprem_but_gcp_N'
       ELSE '5_both_not_screened' END AS bucket,
  g.REASON_CODE, g.PARTY_DOMAIN,
  COUNT(*) AS parties
FROM g FULL JOIN op USING (id)
GROUP BY 1, 2, 3
ORDER BY 1, parties DESC;

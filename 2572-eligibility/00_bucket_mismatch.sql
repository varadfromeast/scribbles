-- 2572: ORIGINAL bucket comparison GCP vs on-prem (as run by Varad on 19 Nov 2026).
-- Result: 1_match 112,548 | 2_onprem_only 21 | 3_gcp_Y_not_onprem 105,116 |
--         4_onprem_but_gcp_N 438 | 5_both_not_screened 713,106
-- NOTE: dedupe orders by IS_SCRN_ELIGBLE first; check 01 proved this has 0 impact.
WITH g_raw AS (
  SELECT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0') AS id, *
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
  WHERE PARTY_ID <> 'PARTY_ID'),
g AS (
  SELECT * FROM g_raw
  QUALIFY ROW_NUMBER() OVER (PARTITION BY id
          ORDER BY IS_SCRN_ELIGBLE DESC, SAFE_CAST(PARTY_VERSION AS INT64) DESC) = 1),
op AS (
  SELECT LPAD(REGEXP_REPLACE(EXTERNALRECORDID, r'[^0-9]', ''), 13, '0') AS id, *
  FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_onPrem_source_data_extract_10Nov2026`
  WHERE EXTERNALRECORDID <> 'EXTERNALRECORDID'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY LPAD(REGEXP_REPLACE(EXTERNALRECORDID, r'[^0-9]', ''), 13, '0')
          ORDER BY LATEST_STARTDATE DESC) = 1)
SELECT
  CASE WHEN g.id IS NULL                                  THEN '2_onprem_only'
       WHEN g.IS_SCRN_ELIGBLE = 'Y' AND op.id IS NOT NULL THEN '1_match'
       WHEN g.IS_SCRN_ELIGBLE = 'Y'                        THEN '3_gcp_Y_not_onprem'
       WHEN op.id IS NOT NULL                              THEN '4_onprem_but_gcp_N'
       ELSE '5_both_not_screened' END AS bucket,
  COUNT(*) AS parties
FROM g FULL JOIN op USING (id)
GROUP BY 1 ORDER BY 1;

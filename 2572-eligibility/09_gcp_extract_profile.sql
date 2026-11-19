-- 2572: sanity of the GCP extract. Does it hold one dataset and one snapshot only?
-- (931,530 rows / 931,208 distinct parties / 217,664 eligible per check 04)
SELECT DTSET_ID, business_snapshot, meta_snapshot_context, PARTY_DOMAIN, IS_SCRN_ELIGBLE,
       COUNT(*) AS row_count,
       COUNT(DISTINCT LPAD(REGEXP_REPLACE(PARTY_ID, r'[^0-9]', ''), 13, '0')) AS parties
FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.2572_gcp_source_data_extract_10Nov2026`
WHERE PARTY_ID <> 'PARTY_ID'
GROUP BY 1, 2, 3, 4, 5
ORDER BY row_count DESC;

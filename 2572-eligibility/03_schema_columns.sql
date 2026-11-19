-- 2572: list the columns of both extracts so the breakdown queries can use real column names.
-- Paste the result back (screenshot is fine).
SELECT table_name, ordinal_position, column_name, data_type
FROM `db-dev-jiat-mp-dbcs-dev1.test_dataset.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name IN ('2572_gcp_source_data_extract_10Nov2026',
                     '2572_onPrem_source_data_extract_10Nov2026')
ORDER BY table_name, ordinal_position;

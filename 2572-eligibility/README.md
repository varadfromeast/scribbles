# 2572 eligibility: GCP vs on-prem mismatch analysis

**Start with [HANDOFF.md](HANDOFF.md)**: context, the 2021 findings, results so far, hypotheses and next steps.

| File | Purpose | Status |
|---|---|---|
| 00_bucket_mismatch.sql | bucket comparison GCP vs on-prem | done |
| 01_gcp_dedupe_bias_check.sql | dedupe-order bias | done → 0 |
| 02_id_format_check.sql | ID-format artefact in bucket 3 | done → 34 / 105,116 |
| 03_schema_columns.sql | column list | done (see HANDOFF §2) |
| 04_extract_sizes.sql | sizes and on-prem date range | done (see HANDOFF §4) |
| 05_bucket3_sample.sql | 50-row sample of bucket 3 | to run |
| 06_bucket4_onprem_but_gcp_N.sql | all 438 underscreened parties | to run (priority) |
| 07_bucket2_onprem_only.sql | the 21 parties missing from GCP | to run (priority) |
| 08_onprem_batch_profile.sql | is the on-prem extract a delta? | **run next** |
| 09_gcp_extract_profile.sql | one dataset and snapshot in the GCP extract? | to run |
| 10_bucket_by_reason_code.sql | buckets × REASON_CODE × PARTY_DOMAIN | to run |

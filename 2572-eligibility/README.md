# 2572 eligibility: GCP vs on-prem mismatch analysis

Snapshot: 10 Nov 2026 extracts in `db-dev-jiat-mp-dbcs-dev1.test_dataset`.

## Bucket results
| Bucket | Meaning | Parties |
|---|---|---|
| 1_match | both screen | 112,548 |
| 2_onprem_only | on-prem screens, missing from GCP extract (underscreening on GCP) | 21 |
| 3_gcp_Y_not_onprem | GCP screens, on-prem doesn't (overscreening on GCP / underscreening on-prem) | 105,116 |
| 4_onprem_but_gcp_N | on-prem screens, GCP says N (underscreening on GCP) | 438 |
| 5_both_not_screened | agree: not eligible | 713,106 |

## Checks done
- `01` dedupe bias: **0** parties affected -> bucket 3 not inflated by the dedupe.
- `02` ID format: only **34 / 105,116** match on first 10 digits -> bucket 3 gap is real, not a join artefact.

## Next to run
- `03` column list (needed to write breakdowns by reason code / segment)
- `04` extract sizes and on-prem date range (is on-prem extract complete?)
- `05` 50-row sample of bucket 3
- `06` all 438 of bucket 4 (priority: underscreening)
- `07` all 21 of bucket 2 (priority: underscreening)

# Handoff: dataset 2572 eligibility – GCP vs on-prem mismatch analysis

Read this file first. It is written for an agent or analyst who picks up the work cold.
Status as of **19 Nov 2026**. The owner is Varad, who runs the queries in the BigQuery console
and sends back screenshots of the results.

> This repo is **public**. Do not commit client party IDs, people's names, or extracts of
> real data here. Commit only queries, aggregate counts and notes.

---

## 1. Background

- The bank screens parties (clients and related parties), most likely for sanctions or AML
  screening, in **NLS datasets**. The parties come from the **SDP** party feed (mandant 0100).
- Screening is moving from **on-prem** to **GCP**. On GCP, each dataset has eligibility rules
  that set `IS_SCRN_ELIGBLE = Y/N` for each party. These rules are applied through
  generated view queries.
- For the migration, GCP eligibility must reproduce what on-prem screens today, and any
  difference must be explained.
- **Dataset 2021** was analysed first; the findings are in section 3.
  **Dataset 2572 uses the same eligibility logic as 2021, but for client segments 20–33
  instead of 50–59 (GBM).** It is the subject of this analysis.

### Risk framing (agreed priority)
- **Underscreening on GCP**: on-prem screens a party but GCP would not. This is a compliance
  risk, and it is the **top priority**. It covers buckets 2 and 4 below.
- **Overscreening on GCP**: GCP screens a party that on-prem doesn't (bucket 3). If GCP's
  rules are right, this is really *underscreening on-prem today*. If not, it only means extra
  alerts and noise. Either way it has to be explained.

---

## 2. Data

Project `db-dev-jiat-mp-dbcs-dev1`, dataset `test_dataset`. Both tables are snapshots from 10 Nov 2026.
All columns are STRING.

**`2572_gcp_source_data_extract_10Nov2026`**: GCP eligibility output
| col | notes |
|---|---|
| PARTY_ELGB_ID | |
| PARTY_ID | party id. Normalise with `LPAD(REGEXP_REPLACE(x, r'[^0-9]', ''), 13, '0')`. The file contains a header row (`PARTY_ID = 'PARTY_ID'`), which must be excluded. |
| PARTY_DOMAIN | |
| PARTY_VERSION | multiple versions per party are possible; take the latest with `SAFE_CAST(... AS INT64) DESC` |
| NLS_ELGB_VERSION | |
| IS_SCRN_ELIGBLE | Y / N. **Note the spelling: ELIGBLE, not ELIGIBLE.** |
| REASON_CODE | GCP eligibility reason (2021 had values like IBO, GUA, AS, PC, AOP, AR, CSM, UBO, which are related-party roles) |
| CRT_DATE, TRANS_ATTR, SDP_REFERENCE, DTSET_ID, NAR_ID, meta_snapshot_context, business_snapshot | |

**`2572_onPrem_source_data_extract_10Nov2026`**: parties screened on-prem
| col | notes |
|---|---|
| EXTERNALRECORDID | party id. Normalise the same way. The file has a header row. |
| FIRST_INSERTED_DATE | format like `09-NOV-26 09.40.33.000000000` |
| LATEST_CLIENT_RECORD_ID | |
| LATEST_BATCH_JOB_ID | |
| LATEST_STARTDATE | same format as FIRST_INSERTED_DATE |

**Not available yet:** client segment, contracts, relationships and roles from SDP. The 2021
cause analysis depended on these, and the owner can provide the 2021 prod queries that were
used to get them.

---

## 3. What was learned from the 2021 analysis (on-prem vs GCP, segments 50–59)

The categories were the same as the buckets below:

**a) GCP screens, on-prem doesn't (1,073 parties).** All of them are eligible on GCP only as
**related parties** of a client in segments 50–59, not through a client relationship of their
own. By reason code: IBO 976, GUA 55, AS 20, PC 9, AOP 7, AS/CSM/UBO 3, AR 2, CSM/UBO 1.
→ Open question to the business: should these related-party roles be screened? If yes, the gap
is on the on-prem side. If not, the GCP role mapping needs adjusting.

**b) On-prem screens, GCP says not eligible (529).** None of these parties is linked to an
*active* GBM party in segments 50–59, so GCP is correct. Causes:
1. no relation to any party in SDP: 7
2. only Power of Attorney on INACTIVE (terminated) contracts: 87
3. INACTIVE contracts plus relations to non-GBM parties: 385
4. active contract, but the linked party is not in GBM segments 50–59: 49
5. only relations (LR/UBO/Member) to non-GBM parties: 1

472 of the 529 are linked only through terminated contracts, so on-prem is screening stale
relationships. Proposed: ignore this discrepancy for now.

**c) On-prem screens, party absent from GCP output (1,630).** These are active clients in segments
**other than** 50–59, so GCP 2021 excludes them by design (2021 only covers parties with no
active client relationship of their own, or one in 50–59). On-prem includes them through their
link to a GBM party. By own segment: 0–7 and 10–19 (about 1,348), 8/80 (93), 20–33 (about 187),
explicitly excluded segments (1), not in the SDP feed (1). Other datasets fed by the same SDP
source cover them: segments 0–7 and 10–19 by the PCC PB/CB datasets (sources 6012/6013), 8/80
by source 6010, **20–33 by dataset 2572**. Segments 9, 34–36, 40, 42, 79 and 90 are
explicitly ineligible in both the 2021 and 2572 logic.
→ Open questions: should 2021 also screen parties whose own segment is outside 50–59 when they
are linked to a GBM party? Is excluding segments 9, 34–36, 40, 42, 79 and 90 intended?

**Implication for 2572:** expect the same three kinds of cause: related-party roles,
terminated contracts, and own segment outside 20–33. Bucket 3 for 2572 is about 100× larger
than 2021's bucket a), so something more is going on (see the hypotheses in section 5).

---

## 4. 2572 results so far

| # | Query | Result |
|---|---|---|
| 00 | `00_bucket_mismatch.sql` (buckets) | 1_match **112,548** · 2_onprem_only **21** · 3_gcp_Y_not_onprem **105,116** · 4_onprem_but_gcp_N **438** · 5_both_not_screened **713,106** |
| 01 | dedupe bias (latest version N, older version Y) | **0**. The dedupe order does not affect the buckets. |
| 02 | ID format (bucket-3 parties that match on-prem on the first 10 digits) | **34 / 105,116**. The gap is not a join artefact. |
| 03 | columns | see section 2 |
| 04 | extract sizes | GCP: 931,530 rows, 931,208 parties, **217,664 eligible**. On-prem: **113,007 rows = 113,007 parties**, LATEST_STARTDATE from **09-NOV-26 09:40 to 10-NOV-26 19:40** |

Mapping to 2021 categories: bucket 3 ↔ a), bucket 4 ↔ b), bucket 2 ↔ c).
Note that bucket 2 is tiny for 2572 (21, against 1,630 for 2021).

---

## 5. Hypotheses for bucket 3 (105,116)

1. **The on-prem extract is a delta, not the full population.** Every on-prem party has a
   LATEST_STARTDATE inside a window of about 34 hours (9–10 Nov). If the extract only holds parties
   processed by the last batch job(s), GCP's full eligible set will naturally be about twice
   the size. **Check this first with `08`.**
2. **Related-party roles**, as in 2021 a): GCP marks parties eligible through IBO/GUA/etc. roles
   that on-prem doesn't screen. `10` shows this through REASON_CODE.
3. **Terminated or inactive relationships** are still counted as eligible on GCP, or on-prem has
   already dropped them.
4. **The GCP extract mixes snapshots or datasets.** `09` checks DTSET_ID and business_snapshot.

---

## 6. Next steps (in order)

1. Run **`08_onprem_batch_profile.sql`**. Is on-prem a delta? If it is, get a full on-prem
   population extract and re-run `00`.
2. Run **`09_gcp_extract_profile.sql`**. There should be one DTSET_ID and one snapshot.
3. Run **`10_bucket_by_reason_code.sql`**. Break the buckets down by REASON_CODE and PARTY_DOMAIN.
4. **Underscreening deep-dive (priority):**
   - `06`: all 438 in bucket 4. Assign each one a cause using the 2021 cause list in section 3 b.
     This needs the SDP contract and relationship tables, so adapt the **2021 prod queries**
     (segments 50–59 → 20–33).
   - `07`: all 21 in bucket 2. For each: was it in the SDP feed on 10 Nov, what is its own
     segment, and does it appear in an earlier on-prem snapshot?
5. `05`: a 50-row sample of bucket 3, to look for patterns by eye.
6. Write the results up in the same structure as the 2021 email: a/b/c sections, a count per
   cause, and questions for the business.

## 7. Open questions for the owner
- Can you share the 2021 prod queries (SDP segment, contract and relation tables)? These are the main blocker for the cause analysis.
- Where are the GCP view-generation rules kept (repo, config or SQL templates)? They're needed to explain *why* a party is eligible.
- Is the on-prem extract the full screened population for 2572, or the output of the last batch run?

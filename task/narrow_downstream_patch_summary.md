# Narrow Business Downstream Patch Summary

## Files Read
- firm_model_relationships_business_real_split.csv (5676 observations)
- firm_model_relationship_evidence_business_real_split.csv (45408 evidence rows)
- firm_model_relationship_review_cases_business_real_split.csv (7651 review cases)

## Files Produced
1. firm_model_relationships_business_real_split_narrow_downstream.csv
2. firm_model_relationship_evidence_business_real_split_narrow_downstream.csv
3. firm_model_relationship_review_cases_business_real_split_narrow_downstream.csv
4. firm_business_position_classification_narrow_downstream.csv
5. narrow_downstream_patch_summary.md

## business_downstream Before and After

| Metric | Before | After |
|---|---|---|
| Value=1 observations | 3366 | 1584 |
| Value=1 firms | 51 | 24 |

## Firms Retained as business_downstream=1 (24)
Accenture, Adobe, C3.ai, CCC Intelligent Solutions, DXC Technology, Fujitsu, Genpact, Microsoft, NEC, NICE, Palantir, Pegasystems, Salesforce, ServiceNow, Snowflake, SoundHound AI, Temenos, Thomson Reuters, Tietoevry, Twilio, UiPath, Wix, Wolters Kluwer, Workday

## Firms Changed from 1 to 0 (27)
Alibaba, Alphabet, Amazon, AppLovin, Apple, Baidu, Cadence, Cisco, CyberArk, Datadog, Experian, Fortinet, HPE, IBM, Meta, Netflix, Okta, Oracle, Rakuten Group, Shopify, Snap, Synopsys, Tencent, Teradata, The Trade Desk, Uber, Zscaler

## Borderline Firms (defaulted to 0) (8)
CyberArk, Datadog, Experian, Fortinet, Okta, Shopify, Teradata, Zscaler

## Variable Preservation

| Variable | Before | After | Status |
|---|---|---|---|
| owner | 31 | 31 | UNCHANGED |
| investor | 44 | 44 | UNCHANGED |
| cloud | 34 | 34 | UNCHANGED |
| business_upstream | 172 | 172 | UNCHANGED |
| real_upstream | 141 | 141 | UNCHANGED |
| real_downstream | 89 | 89 | UNCHANGED |
| competitor | 495 | 495 | UNCHANGED |
| business_downstream | 3366 | 1584 | CHANGED (expected) |

## Confirmations
- TSMC business_upstream=1 all events: YES
- Nvidia business_upstream=1 all events: YES
- Nvidia competitor=0 all events: YES
- Oracle competitor=0 all events: YES

## QC Results

| # | Check | Result |
|---|---|---|
| 1 | Observations | 5676 |
| 2 | Evidence rows | 45408 |
| 3 | 8 evidence rows per obs | YES |
| 4 | Main/evidence mismatches | 0 |
| 5 | Duplicate observations | 0 |
| 6 | Duplicate evidence rows | 0 |
| 7 | Non-0/1 values | 0 |
| 8 | Unique events | 66 |
| 9 | Firm count | 86 |
| 10-16 | Other variables preserved | SEE TABLE ABOVE |
| 17 | business_downstream changed as expected | YES |
| 18 | TSMC business_upstream=1 | YES |
| 19 | Nvidia business_upstream=1 | YES |
| 20 | Nvidia competitor=0 | YES |
| 21 | Oracle competitor=0 | YES |

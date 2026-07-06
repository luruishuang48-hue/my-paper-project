# Patch Task: Narrow Business Downstream Classification

## Objective

Patch the business/real split dataset by narrowing the definition of `business_downstream`.

Do not rerun broad coding.

Do not change the event sample.

Do not change owner, investor, cloud, business_upstream, real_upstream, real_downstream, or competitor, except for mechanical consistency checks.

The only substantive target of this patch is:

business_downstream

## Input Files

Use:

* firm_model_relationships_business_real_split.csv
* firm_model_relationship_evidence_business_real_split.csv
* firm_model_relationship_review_cases_business_real_split.csv

## Conceptual Correction

The previous version coded `business_downstream = 1` too broadly.

The corrected definition is:

business_downstream = 1 if the firm’s core business directly commercializes generative-AI model capabilities, AI agents, AI copilots, AI workflow automation, AI content/productivity enhancement, or AI-enabled professional/enterprise services.

Do not code business_downstream = 1 merely because:

* the firm uses AI internally;
* the firm may benefit from AI adoption;
* the firm is a large technology company;
* the firm has generic AI features;
* the firm is broadly exposed to digital transformation;
* the firm operates cloud, cybersecurity, networking, chips, infrastructure, or hardware businesses;
* the firm is primarily a model owner / model competitor rather than an application-side downstream firm.

The purpose is to distinguish true downstream business-position exposure from general AI adoption.

## Preserve Other Variables

Do not change:

owner
investor
cloud
business_upstream
real_upstream
real_downstream
competitor

In particular:

* TSMC business_upstream remains 1 for all events.
* Nvidia business_upstream remains 1 for all events.
* Nvidia competitor remains 0 for all events.
* Oracle competitor remains 0 for all events.
* real_downstream remains equal to the current real_downstream values unless there is a mechanical file inconsistency.
* real_upstream remains equal to the current real_upstream values unless there is a mechanical file inconsistency.

## New Business Downstream Coding Rule

Set `business_downstream = 1` for the following high-confidence firms:

ADBE
CRM
NOW
SNOW
MSFT
PLTR
WDAY
PATH
NICE
TWLO
AI
PEGA
WIX
TRI
WKL NA
ACN
G
DXC
6702 JP
6701 JP
TIETO FH
TEMN SW
SOUN
CCC

These firms are treated as business-downstream because their core business plausibly commercializes generative-AI capabilities through creative software, enterprise software, workflow automation, customer engagement, professional information services, IT services, or AI application platforms.

## Borderline Business Downstream Firms

For the following firms, use conservative coding:

DDOG
OKTA
ZS
CYBR
FTNT
SHOP
TDC
EXPN LN

Default rule:

Set business_downstream = 0 for these borderline firms unless the existing classification file or evidence file provides a clear reason that the firm’s core business directly commercializes generative-AI model capabilities rather than merely using AI or providing general software/security/data services.

Whether coded 0 or 1, add each of these firms to the review file.

If coded 1, the review reason should explain why the firm qualifies under the narrowed definition.

If coded 0, the review reason should explain that the firm may use AI or have AI features but does not clearly satisfy the narrowed business-downstream definition.

## Firms to Remove from Business Downstream

Set `business_downstream = 0` for the following firms:

GOOGL
AMZN
META
BABA
BIDU
700 HK
AAPL
IBM
ORCL
CSCO
HPE
SNPS
CDNS
NFLX
UBER
APP
TTD
4755 JP

Reason:

These firms are better treated as model owners, competitors, cloud/infrastructure firms, upstream complements, platforms, adtech/e-commerce firms, or general AI adopters. They should not be mechanically coded as downstream merely because they use or commercialize AI in a broad sense.

Specific notes:

* GOOGL, AMZN, META, BABA, BIDU, 700 HK, AAPL, IBM are primarily model owners / model competitors / AI platforms in this context.
* ORCL, CSCO, HPE are infrastructure/cloud/networking firms rather than narrow downstream AI application firms.
* SNPS and CDNS are EDA / chip design software firms, closer to the AI production ecosystem than downstream model-capability commercialization.
* NFLX, UBER, APP, TTD, 4755 JP are general AI adopters or platform/adtech/e-commerce firms; this is too broad for business_downstream under the narrowed definition.

## Main File Output

Produce:

firm_model_relationships_business_real_split_narrow_downstream.csv

Columns:

firm
firm_ticker
model_company
model
event_date
owner
investor
cloud
business_upstream
real_upstream
business_downstream
real_downstream
competitor
notes

Expected behavior:

* business_downstream should remain a firm-level business-position variable.
* For firms retained as business_downstream = 1, it should usually equal 1 for all 66 events.
* For firms removed, it should equal 0 for all 66 events.
* Do not change event count or firm count.

## Evidence File Output

Produce:

firm_model_relationship_evidence_business_real_split_narrow_downstream.csv

Columns:

firm
firm_ticker
model_company
model
event_date
relationship
value
evidence_text
source_name
source_url
source_date
before_event_date
confidence
notes

Each observation must have exactly eight evidence rows:

owner
investor
cloud
business_upstream
real_upstream
business_downstream
real_downstream
competitor

For `business_downstream`, use evidence_text that reflects the narrowed definition.

For retained high-confidence firms, evidence_text may say:

"Researcher coding convention: firm is classified as business_downstream because its core business directly commercializes generative-AI capabilities through enterprise software, workflow automation, professional services, creative software, AI applications, or related customer-facing AI-enabled products."

For removed firms, evidence_text may say:

"Researcher coding convention: firm is not classified as business_downstream under the narrowed definition because broad AI adoption, platform activity, infrastructure provision, model competition, or general AI exposure is insufficient."

Use source_name = "Researcher Convention" for business_downstream convention-based evidence.

Use source_url = "N/A" if the value is based on researcher convention rather than a specific external source.

Use source_date = "N/A" if the value is based on researcher convention.

Use before_event_date = "N/A" for researcher-convention business-position variables.

Do not force artificial source dates for business_downstream.

## Review File Output

Produce:

firm_model_relationship_review_cases_business_real_split_narrow_downstream.csv

Columns:

firm
firm_ticker
model_company
model
event_date
relationship
provisional_value
reason_for_review
key_sources
recommended_action

The review file should include:

1. all firms removed from business_downstream;
2. all borderline firms;
3. all firms retained as business_downstream = 1 if the classification is not obvious;
4. any case where business_downstream differs from real_downstream;
5. any case where the old classification was changed.

For removed firms, reason_for_review should state:

"Removed from business_downstream under narrowed definition. Broad AI use, model competition, infrastructure provision, platform activity, or generic AI exposure is insufficient for business_downstream = 1."

For borderline firms, reason_for_review should state the specific ambiguity.

## Firm Classification Output

Produce:

firm_business_position_classification_narrow_downstream.csv

Columns:

firm_ticker
firm
business_upstream_universal
business_upstream_reason
business_downstream
business_downstream_reason
classification_confidence
manual_review_required

This file should contain all 86 firms.

For business_downstream, use the narrowed definition.

Do not leave any firm unclassified.

## Summary Output

Produce:

narrow_downstream_patch_summary.md

The summary must report:

1. files read;
2. files produced;
3. old business_downstream count;
4. new business_downstream count;
5. number of firms with business_downstream = 1 before patch;
6. number of firms with business_downstream = 1 after patch;
7. list of firms retained as business_downstream = 1;
8. list of firms changed from business_downstream = 1 to 0;
9. list of borderline firms and final coding decision for each;
10. confirmation that all other variables were preserved;
11. final value=1 counts for all eight variables;
12. QC results.

## QC Requirements

Run and report:

1. number of observations in main file;
2. number of evidence rows;
3. every observation has exactly eight evidence rows;
4. main/evidence consistency;
5. no duplicate main observations;
6. no duplicate evidence rows;
7. all eight variables are numeric 0 or 1;
8. event coverage unchanged;
9. firm count unchanged;
10. owner count unchanged;
11. investor count unchanged;
12. cloud count unchanged;
13. business_upstream count unchanged;
14. real_upstream count unchanged;
15. real_downstream count unchanged;
16. competitor count unchanged;
17. business_downstream count changed only according to this patch;
18. TSMC business_upstream = 1 for all events;
19. Nvidia business_upstream = 1 for all events;
20. Nvidia competitor = 0 for all events;
21. Oracle competitor = 0 for all events.

## Final Standard

The final dataset should use a narrower and economically meaningful business_downstream variable.

business_downstream should not mean “uses AI.”

It should mean “core business is downstream of generative-AI model capabilities in a commercially meaningful way.”

This patch should make business_downstream usable as a meaningful business-position exposure variable rather than a generic AI-adoption indicator.

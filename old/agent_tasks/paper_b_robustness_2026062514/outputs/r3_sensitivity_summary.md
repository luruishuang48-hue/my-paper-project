# R3: Exclusion Sensitivity Summary — upstream_hardware & downstream_deployer (CAR[0,+20])

Generated: 2026-06-25 14:21:11

## Baseline spec

`car_20 ~ position_var + size_log_assets + bm_ratio + volatility + momentum + factor(release_year)`, 
clustered SE by `final_event_id` (CR0, via `estimatr::lm_robust`).

## Full-sample baseline (reference)

- **upstream_hardware**: beta = 0.0228 (2.28 pp), se = 0.0084, p = 0.0090, n = 4829, n_events = 60
- **downstream_deployer**: beta = -0.0190 (-1.90 pp), se = 0.0051, p = 0.0004, n = 4829, n_events = 60

## Check 1: DeepSeek R1 (FMR-0021) exclusion

### upstream_hardware

- Full sample: beta = 0.0228 (2.28 pp), se = 0.0084, p = 0.0090, n = 4829, n_events = 60
- Excl. DeepSeek R1: beta = 0.0228 (2.28 pp), se = 0.0086, p = 0.0101, n = 4750, n_events = 59
- Change in beta: 0.0000 (0.2% of full-sample beta); significance at 5% unchanged.

### downstream_deployer

- Full sample: beta = -0.0190 (-1.90 pp), se = 0.0051, p = 0.0004, n = 4829, n_events = 60
- Excl. DeepSeek R1: beta = -0.0186 (-1.86 pp), se = 0.0051, p = 0.0006, n = 4750, n_events = 59
- Change in beta: 0.0004 (2.2% of full-sample beta); significance at 5% unchanged.

## Check 2: Leave-one-event-out (n = 60 events)

- **downstream_deployer**: beta range across 60 leave-one-event-out iterations = [-0.0204, -0.0174], sd = 0.00067; full-sample beta = -0.0190. Most influential event when dropped: **FMR-0016** (beta becomes -0.0174, |delta| = 0.0016).
- **upstream_hardware**: beta range across 60 leave-one-event-out iterations = [0.0203, 0.0249], sd = 0.00111; full-sample beta = 0.0228. Most influential event when dropped: **FMR-0056** (beta becomes 0.0203, |delta| = 0.0025).

Sign flips across leave-one-event-out: upstream_hardware = 0, downstream_deployer = 0 (out of 60 iterations each).
Iterations where p >= 0.10 (lost 5%/10% significance): upstream_hardware = 0, downstream_deployer = 0.

## Check 3: Leave-one-firm-out (n = 86 firms, by company_id)

- **downstream_deployer**: beta range across 86 leave-one-firm-out iterations = [-0.0208, -0.0168], sd = 0.00065; full-sample beta = -0.0190. Most influential firm when dropped: **5803 JP** (beta becomes -0.0168, |delta| = 0.0022).
- **upstream_hardware**: beta range across 86 leave-one-firm-out iterations = [0.0204, 0.0249], sd = 0.00076; full-sample beta = 0.0228. Most influential firm when dropped: **SMCI** (beta becomes 0.0204, |delta| = 0.0023).

Sign flips across leave-one-firm-out: upstream_hardware = 0, downstream_deployer = 0 (out of 86 iterations each).
Iterations where p >= 0.10 (lost 5%/10% significance): upstream_hardware = 0, downstream_deployer = 0.

## Overall conclusion

See bullet points above for quantitative detail. In plain terms: if dropping DeepSeek R1, or any single
event, or any single firm flips the sign of beta or pushes p above conventional thresholds, the headline
result for that variable should be flagged as fragile rather than robust. Otherwise, both headline findings
(upstream_hardware positive, downstream_deployer negative on CAR[0,+20]) hold up under these sensitivity checks.


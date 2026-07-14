# Audit Journey 2022 — PIZZO-BERKEY (One Provider, One Investigation)

This document is the **shared primary example** used across all task docs (`1.1` → `3.3`). Every step follows the **same provider** and the **same top billing services** through each module — not unrelated global Row 1 outliers.

| Anchor | Value |
|--------|-------|
| **Provider** | **PIZZO-BERKEY**, Allyson J · NPI `1003056821` |
| **Specialty** | Pain Management · **California** · Newport Beach (RUCA **1** Urban/Metro) |
| **Entity** | Individual Clinician · Credential **MD** |
| **Year** | **2022** |
| **Top service (dollars)** | **Q4253** — Zenith amniotic membrane (**38,912** units · **~$28.5M** paid) |
| **Top service (1.2 lens)** | **11042** — skin/tissue debridement (**20,336** units · **~$2.4M** paid · appears in rural-tier chart) |

**2022 provider totals (CMS `ProviderSummary`):**

| Beneficiaries | Services | Submitted | Allowed | Paid | Cost/Patient | Risk Score |
|--------------:|---------:|----------:|--------:|-----:|-------------:|-----------:|
| **4,479** | **111,291** | **$61.4M** | **$56.0M** | **$44.6M** | **$9,953** | **2.89** |

---

## Story at a glance

```
1.1  CA Pain Management row = mostly PIZZO          → $44.6M paid · $5.4M charge padding
1.2  PIZZO's HCPCS 11042 · Urban/Metro tier         → 45.7% overclaim vs suburban +22.7 pp
1.3  PIZZO risk 2.89 vs $9,953/patient              → elevated complexity; not in BH app (< 10 CA peers)
2.1  PIZZO High-Cost Outlier · 24 services/patient  → fixed-threshold classification
2.2  PIZZO +1,013% vs Pain Management peers         → specialty-relative flag
2.2B PIZZO = Individual Clinician                   → not a corporate-network pattern
3.1  Pain Management $3,733 avg · PIZZO $9,953      → 2.7× specialty cost-complexity gap
3.3  PIZZO MD · Q4253/11042 charge padding mix      → service-line escalation target
```

---

## Step 1 — Task 1.1 Cost Analysis

**App:** `app/1.1cost-analysis/` · **Grain:** Year × State × Provider Type  
**Same provider lens:** Task 1.1 Row 1 (Total Paid desc) is the bucket **PIZZO-BERKEY dominates**.

### Table Row 1 — California Pain Management (2022)

| Year | State | Provider Type | Providers | Beneficiaries | Submitted | Allowed | Paid | Rejected |
|------|-------|---------------|----------:|--------------:|----------:|--------:|-----:|---------:|
| **2022** | **CA** | **Pain Management** | **3** | **5,861** | **$63.6M** | **$57.0M** | **$45.4M** | **$6.6M** |

### PIZZO-BERKEY inside this row

| Metric | PIZZO-BERKEY | CA Pain bucket | PIZZO share |
|--------|-------------:|---------------:|------------:|
| Beneficiaries | **4,479** | 5,861 | **76%** |
| Medicare paid | **$44.6M** | $45.4M | **~98%** |
| Submitted | **$61.4M** | $63.6M | **~97%** |
| Charge padding (Submitted − Allowed) | **$5.4M** | $6.6M | **~82%** |

**Read:** Row 1 is not an abstract “specialty problem” — it is **one MD pain provider in Newport Beach** billing **~$44.6M** to **4,479** Medicare patients. STEVENS and O'CONNOR (the other two CA Pain NPIs) contribute the remaining **~2%**.

**Audit decision:** Open workpaper **PIZZO-BERKEY · 2022 · CA · Pain Management**. Pull service lines next (Q4253 amniotic membrane + 11042 debridement).

→ Next: **Task 1.2** (procedure **11042** tier context)

---

## Step 2 — Task 1.2 Rural Analysis

**App:** `app/1.2rural-analysis/` · **Grain:** HCPCS × Geographic tier  
**Same service lens:** **HCPCS 11042** — PIZZO's **#4 service by dollars** (20,336 units · **~$2.37M** paid · **41.5%** charge-padding rate on this code alone).

PIZZO practices in **Urban/Metro** (RUCA 1 · Newport Beach). Task 1.2 compares how **the same procedure code** bills across tiers nationally.

### PIZZO's 11042 service line (2022)

| HCPCS | Description | PIZZO services | PIZZO paid | PIZZO padding rate |
|-------|-------------|---------------:|-----------:|-------------------:|
| **11042** | Removal of skin and tissue, 20 sq cm or less | **20,336** | **~$2.37M** | **~41%** |

### Same HCPCS 11042 — Task 1.2 tier rows (national sample)

| Tier | Tier Deviation | Overclaim Rate | Total Paid (all NPIs) |
|------|---------------:|---------------:|----------------------:|
| **Suburban / Micro** | **+22.74 pp** | **69.9%** | (national aggregate) |
| **Urban / Metro** ← **PIZZO's tier** | **−1.46 pp** | **45.7%** | (national aggregate) |

**Read:** PIZZO is **Urban/Metro**, where **11042** overclaim rates sit near the national procedure baseline (−1.46 pp tier deviation). Yet **PIZZO personally** bills **11042** at **~41% padding** — aggressive **within** a tier that looks average in the aggregate. The investigation is **provider-specific billing on a shared code**, not rural isolation.

**Audit decision:** Keep **11042** on the service-line checklist alongside **Q4253**. Geographic tier does not explain PIZZO; per-NPI HCPCS review does.

→ Next: **Task 1.3** (complexity vs spend for **same provider**)

---

## Step 3 — Task 1.3 Cost-Complexity Frontier

**App:** `app/1.3behavioral-helath-risk/` · **Grain:** Year × State × Specialty × BH Burden Group  
**Same provider lens:** PIZZO-BERKEY does **not appear as a table row** — CA Pain Management has only **3** NPIs (peer groups need **≥ 10**). We apply Task 1.3 **logic** to PIZZO's **source fields**:

### PIZZO-BERKEY — individual cost-complexity profile (2022)

| Field | PIZZO value | Frontier interpretation |
|-------|------------:|-------------------------|
| **Avg Risk Score** | **2.89** | ~2.9× national-average-cost patient — **elevated** complexity |
| **Paid per Beneficiary** | **$9,953** | ~9× a $1.0 baseline patient — **extreme** spend |
| **Depression prevalence** | **32%** | Moderate BH comorbidity on panel |
| **Anxiety prevalence** | **25%** | Moderate BH comorbidity on panel |

**Read:** Risk **2.89** justifies **above-average** spend — but not **$9,953/patient** (national Pain Management average is **$894**; see Task 2.2). BH prevalence is material yet far below the **Zone 2** patterns Task 1.3 surfaces (e.g. low-BH halves billing **$1,780** with risk **1.10**). **PIZZO is high-risk AND high-paid** — the open question is **service mix** (Q4253 membrane units), not undetected BH burden.

**Audit decision:** Task 1.3 cannot split CA Pain peers — proceed with **Tasks 2.1–2.2** on the **same NPI**.

→ Next: **Task 2.1** · NPI `1003056821`

---

## Step 4 — Task 2.1 Provider Classification

**App:** `app/2.1provider-classification/` · **Grain:** Year × NPI  
**Same provider lens:** Filter **Year = 2022 · State = CA · Specialty = Pain Management** — PIZZO is **Row 1**.

| Provider | NPI | Cost/Patient | Services/Patient | Beneficiaries | Risk | Cost Class | Utilization |
|----------|-----|-------------:|-----------------:|--------------:|-----:|------------|-------------|
| **PIZZO-BERKEY** | **1003056821** | **$9,953** | **24** | **4,479** | **2.89** | **High-Cost Outlier** | **High Utilization** |
| STEVENS | 1003001363 | $596 | 15 | 1,079 | 1.60 | Average Spend | High Utilization |
| O'CONNOR | 1003227760 | $441 | 5 | 303 | 1.32 | Average Spend | Moderate Utilization |

**Read:** Fixed Task 2.1 thresholds (≥ **$900**/patient = High-Cost Outlier; ≥ **15** services/patient = High Utilization) flag PIZZO in the **top-right matrix cell**. **111,291** total service units ÷ **4,479** beneficiaries ≈ **24.9** services/patient — driven by high-volume codes **Q4253** (38,912 units) and **99348** home visits (22,261 units).

**Audit decision:** Confirmed **High-Cost / High-Utilization** outlier — same provider traced from Task 1.1 Row 1.

→ Next: **Task 2.2** (peer-relative check on **same NPI**)

---

## Step 5 — Task 2.2 Specialty Peer Profiling

**App:** `app/2.2aspecialty-profiling/` · **Grain:** Year × NPI (joined to specialty baseline)  
**Same provider lens:** Expand **Pain Management** group → PIZZO-BERKEY is the **top CA row**.

| Provider | Specialty | State | Cost/Patient | National Avg | Cost deviation | Services/Patient | Service deviation |
|----------|-----------|-------|-------------:|-------------:|---------------:|-----------------:|------------------:|
| **PIZZO-BERKEY** | **Pain Management** | **CA** | **$9,953** | **$894** | **+1,013%** | **24** | **+158%** |

**Read:** PIZZO bills **11×** the 2022 national Pain Management average and **2.7×** the specialty aggregate in Task 3.1 (**$3,733**). Risk **2.89** explains **some** of the gap — not **1,013%** above peers. The deviation aligns with **Q4253** amniotic membrane volume (**38,912** units · **~$28.5M**).

**Audit decision:** Specialty-relative escalation confirmed on the **same provider** — not a portfolio-wide ambulance or NP outlier.

→ Next: **Task 2.2B** · **Task 3.1**

---

## Step 6 — Task 2.2B Entity Type Comparison

**App:** `app/2.2borganization-profiling/` · **Grain:** Year × NPI  
**Same provider lens:** PIZZO-BERKEY in the **Pain Management · CA** expand group.

| Provider | Entity Type | Cost/Patient | Beneficiaries |
|----------|-------------|-------------:|--------------:|
| **PIZZO-BERKEY** | **Individual Clinician** | **$9,953** | **4,479** |
| STEVENS | Individual Clinician | $596 | 1,079 |
| O'CONNOR | Individual Clinician | $441 | 303 |

**Read:** All three CA Pain NPIs are **Individual Clinicians** (`Rndrng_Prvdr_Ent_Cd = I`). The macro KPI that **Organizations bill +75.4%** more than Individuals nationally does **not** apply — PIZZO is an **individual MD outlier**, not a corporate-network pattern.

**Audit decision:** Keep investigation on **PIZZO-BERKEY** individually; do not reroute to org-vs-ind macro review.

→ Next: **Task 3.1** · **Task 3.3**

---

## Step 7 — Task 3.1 Risk-Cost-Volume Dynamics

**App:** `app/3.1risk-dynamics/` · **Grain:** Year × Specialty  
**Same provider lens:** PIZZO rolls into the **Pain Management** specialty row; compare PIZZO to that aggregate.

### Pain Management specialty row (2022)

| Specialty | Providers | Avg Risk | Cost/Patient | Patients | Total Paid |
|-----------|----------:|---------:|-------------:|---------:|-----------:|
| **Pain Management** | **25** | **1.96** | **$3,733** | **13,273** | **$49.5M** |

### PIZZO-BERKEY vs specialty row

| Lens | Avg Risk | Cost/Patient | Patients | Total Paid |
|------|---------:|-------------:|---------:|-----------:|
| **Pain Management (specialty)** | 1.96 | $3,733 | 13,273 | $49.5M |
| **PIZZO-BERKEY (individual)** | **2.89** | **$9,953** | **4,479** | **$44.6M** |
| **PIZZO ÷ specialty avg** | **1.5×** | **2.7×** | **34%** of patients | **90%** of dollars |

**Read:** PIZZO alone delivers **~90%** of all Pain Management Medicare dollars in the sample (**$44.6M** of **$49.5M**) while serving **34%** of specialty patients. Dual-axis chart: Pain Management shows **moderate-high risk + high cost**; PIZZO is **far above** that specialty bar on the **cost axis**.

**Audit decision:** Task 3.1 explains why Pain Management ranks **#2** nationally on cost — it is largely **one CA MD** on **Q4253** membrane billing.

→ Next: **Task 3.3** (credential + charge padding on **same service lines**)

---

## Step 8 — Task 3.3 Credential Discrepancies

**App:** `app/3.3credential-discrepancies/` · **Grain:** Year × Standardized Credential  
**Same provider lens:** PIZZO maps to **MD - Doctor of Medicine**; evaluate **PIZZO's** padding on **Q4253** and **11042**, not only the class-level Row 1.

### MD credential class Row 1 (2022 — portfolio context)

| Credential | Providers | Charge Padding | Padding Rate | Paid/Allowed |
|------------|----------:|---------------:|-------------:|-------------:|
| **MD - Doctor of Medicine** | **3,912** | **$1.32B** | **67%** | **78%** |

### PIZZO-BERKEY — same provider service-line padding (2022)

| HCPCS | Description | Paid | Charge padding rate |
|-------|-------------|-----:|--------------------:|
| **Q4253** | Zenith amniotic membrane | **~$28.5M** | **~2.3%** |
| **11042** | Skin/tissue debridement | **~$2.4M** | **~41%** |
| **99348** | Home visit (25 min) | **~$1.5M** | **~41%** |
| **All PIZZO lines (17 codes)** | — | **~$44.6M** | **~8.8%** |

**Read:** Portfolio MD Row 1 (**67%** padding) is **not** PIZZO's story — PIZZO's **overall** padding is **~8.8%** ($61.4M − $56.0M). The audit signal is **code-specific**: **Q4253** drives **64%** of PIZZO's dollars at **low fee-schedule rejection** (membrane allowed ≈ submitted), while **11042** and **99348** carry **~41% padding** — a **split billing pattern** on the **same provider**.

**Audit decision:** Escalate **HCPCS-level review** on **PIZZO-BERKEY**:

1. **Q4253** — volume integrity (**38,912** units · medical necessity / documentation)  
2. **11042** + **99348** — charge padding vs Medicare caps  
3. Cross-check against Tasks 2.1–2.2 (**+1,013%** peer deviation)

---

## Final escalation — one provider, one workpaper

| Step | App | Same provider / service takeaway |
|------|-----|----------------------------------|
| **1.1** | Cost Analysis | Row 1 CA Pain = **98% PIZZO** · **$44.6M** paid |
| **1.2** | Rural Analysis | **11042** on PIZZO (Urban/Metro) · national tier vs **41%** PIZZO padding |
| **1.3** | BH Frontier | PIZZO risk **2.89** · paid **$9,953** · not in table (< 10 CA peers) |
| **2.1** | Provider Classification | **High-Cost Outlier** · **24** services/patient |
| **2.2** | Specialty Profiling | **+1,013%** vs Pain Management peers |
| **2.2B** | Entity Comparison | **Individual Clinician** — not org pattern |
| **3.1** | Risk-Cost-Volume | **90%** of Pain Mgmt $ · **2.7×** specialty avg cost |
| **3.3** | Credential Discrepancies | **MD** · **Q4253** dollar volume + **11042/99348** padding |

**Workpaper target:** **PIZZO-BERKEY** · NPI `1003056821` · 2022 · CA · Pain Management  
**Service-line priority:** **Q4253** (Zenith amniotic membrane) → **11042** (debridement) → **99348** (home visits)

---

## Related docs

Each task doc includes a **Primary example — Row 1 (audit journey)** section pointing here.

| Doc | Task |
|-----|------|
| [1.1-cost-analysis.md](./1.1-cost-analysis.md) | Geographic & financial overview |
| [1.2-rural-analysis.md](./1.2-rural-analysis.md) | Rural / urban procedure tiers |
| [1.3-riskscore.md](./1.3-riskscore.md) | BH cost-complexity frontier |
| [2.1-provider-classification.md](./2.1-provider-classification.md) | Provider cost × utilization matrix |
| [2.2-specialty-profiling.md](./2.2-specialty-profiling.md) | Specialty peer deviation |
| [2.2b-entity-type-comparison.md](./2.2b-entity-type-comparison.md) | Individual vs organization |
| [3.1-risk-dynamics.md](./3.1-risk-dynamics.md) | Specialty risk vs cost |
| [3.3-credential-discrepancies.md](./3.3-credential-discrepancies.md) | Credential-class billing gaps |

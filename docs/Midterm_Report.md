# SAP BTP Project: Milestone Report

**Saarland University — Summer Semester 2026**

| | |
|---|---|
| **Project Theme** | Healthcare Analytics — Medicare Provider Audit Assistant |
| **Milestone** | Mid-term (12.06.2026) |
| **Group Members** | _<insert all student names>_ |

---

## 1. Executive Summary

**Core Objective.** The application is an autonomous *Healthcare Audit Assistant* built on SAP BTP that helps auditors detect cost, utilization and risk anomalies across the U.S. Medicare Physician & Other Practitioners dataset (2019–2023). It turns millions of raw provider billing rows into structured, explainable analytical views.

**Early Progress.** A major early effort went into **handling a very large dataset**. The raw CMS extracts contained millions of rows with dozens of mostly-empty or audit-irrelevant columns. We built a cleansing pipeline that **stripped unwanted columns**, normalized inconsistent CSV headers to the CDS schema, removed **clustered duplicate and near-empty records**, and consolidated five annual files into a single year-keyed model. The BTP/BAS environment and CAP service are running, and the cleansed data imports successfully into a local SQLite-backed CAP runtime.

**Key Discovery.** Cost per beneficiary is **extremely right-skewed** — a median of ~$172 but a maximum above $71,000 — so a small cluster of providers drives a disproportionate share of spend. We also found a clear structural split: individual clinicians treat higher-complexity patients (avg risk 1.54) than organizations (1.24), confirming that entity type is a meaningful audit dimension.

_(~195 words)_

---

## 2. Technical Architecture & Data Modeling

### Data Schema (CDS)
The data layer is modelled in **Core Data Services** (`db/schema.cds`) as a compact **star schema** around three base entities:

- **`ProviderSummary`** (fact) — one row per `Year + Rndrng_NPI`, carrying volume, charge, payment and beneficiary-characteristic measures (risk score, comorbidity %, demographics).
- **`ServiceDetails`** (fact) — HCPCS service-level billing detail.
- **`GeoReference`** (dimension) — ZIP-to-locality lookup with the CMS rural indicator, joined on `ZipCode + Year`.

The composite `Year` key lets every view trend across 2019–2023 without duplicating entities.

### Normalization & Theme-Specific Logic
Medicare data carries **geographic and structural disparity** that had to be normalized:

- **Geographic normalization** — provider ZIP codes are joined to the official CMS *Zip Code to Carrier Locality* file to classify each provider as **Urban / Rural / Super Rural / Unknown**, mapping the CMS `RuralInd` codes (blank = Urban, `R` = Rural, `B` = Super Rural) exactly per spec.
- **Ratio normalization** — all per-beneficiary metrics (cost/bene, services/bene) are computed as **ratios of sums** at the view grain, never as averages of per-row ratios, so aggregates stay mathematically correct on roll-up.
- **Entity normalization** — the raw CMS `Rndrng_Prvdr_Ent_Cd` (`I`/`O`) is mapped to readable `Individual` / `Organization` segments.

### CAP Service Layer (OData V4)
`srv/medicare-service.cds` exposes the model as **OData V4** read-only entities. Each analytical view is annotated with `@Aggregation.ApplySupported`, `@Analytics.Dimension/Measure` and custom aggregates so Fiori Elements can perform server-side `groupby`/`aggregate`. The service exposes: `CostByStateProviderType`, `RuralUrbanDistribution`, `RiskScoreDistribution` (Task 1) and `ProviderCostEfficiency`, `SpecialtyRiskProfile`, `OrganizationClassification` (Task 2).

---

## 3. Analytical Findings (Tasks 1–2)

### Task 1 — Data Visualization (Aggregation)
The "Exploration Zone" is a set of Fiori Elements analytical apps with KPIs, visual filters and charts:

- **Cost hotspots** — `CostByStateProviderType` surfaces which states and specialties concentrate Medicare spend, with a Total-Paid KPI and drill-down.
- **Geographic disparity** — `RuralUrbanDistribution` shows that urban providers dominate volume while rural/super-rural segments have distinct cost-per-beneficiary profiles.
- **Patient complexity** — `RiskScoreDistribution` bands providers by risk score, revealing how patient complexity varies across regions and specialties.

### Task 2 — Classification Tool
Three complementary classifications were built, each with **analytically grounded thresholds** validated against the real distribution (n = 50,000):

| Classification | Dimension | Thresholds | Grounding |
|---|---|---|---|
| **Risk / Complexity** | Avg risk score | 1.0 / 1.5 / 2.0 | CMS HCC score of **1.0 = national-average-cost beneficiary**; spread 19/36/20/25% |
| **Utilization** | Services per bene | 5 / 15 | Cuts land on **p75 / p90** (top-quartile / top-decile utilizers) |
| **Cost efficiency** | Cost per bene | 150 / 300 / 600 / 900 | **Percentile-anchored** (≈p45/p75/p90/p95); "Outlier" = genuine top ~5% |

The cost-efficiency tiers were explicitly **recalibrated**: the original round-number bands lumped 87% of providers into one label, so we re-anchored them to the observed distribution (median ≈ $172, p90 ≈ $585), giving a meaningful spread of 43 / 30 / 17 / 5 / 5%. Because cost/bene varies by specialty, this is framed as a **relative cost-intensity** signal rather than a pure efficiency verdict. Two further views — `SpecialtyRiskProfile` (per-specialty complexity tier) and `OrganizationClassification` (Individual vs Organization) — extend classification to specialty and organizational structure.

---

## 4. Self-Reflection & Roadmap

### Technical Challenges
The most difficult hurdle in the BTP environment was a **persistent white screen in the Fiori front end**. The apps deployed and the OData service responded, but the UI rendered blank with no obvious error. After extended debugging we traced it to an **annotation mismatch** — the UI annotations referenced entity/property paths and a binding context that did not align with what the OData service actually exposed (including a V2-vs-V4 template mismatch). Aligning the annotation targets with the exposed OData V4 entities and correcting the card/template version resolved it. A second recurring challenge was **aggregation correctness**: charting ratio measures (cost/bene) with an `AVG` roll-up overstated values, which we fixed by charting only summable measures and keeping exact ratios at row grain.

### GitHub Evidence — Branching Strategy
The team used a **`dev`-centric feature-branch workflow**. `dev` is the **primary integration branch**: once a piece of work is implemented and verified on its feature branch, it is opened as a Pull Request and merged into `dev` (e.g. PR #10 merging `feature/Task1` into `dev`). `main` is kept as the stable/protected baseline. Work was split across many focused branches so members could work in parallel:

| Branch | Purpose | Status |
|---|---|---|
| **`main`** | Stable baseline / project README | Protected baseline |
| **`dev`** | **Primary integration branch** — all verified features merge here via PR | Active (latest: PR #10) |
| `feature/full_stack_biolerplate` | Initial full-stack CAP project scaffold | Merged |
| `feature/btp-foundation` | BTP runtime + SQLite data-handling config | Merged |
| `feature/cap-data-models` | CDS data models + initial Task 1 views | Merged |
| `feature/foundation-fixes` | Stabilization of the CAP foundation | Support |
| `feature/frontend` | Fiori Elements front-end apps | Merged |
| `feature/Task1` | Task 1 — Data Visualization (aggregation) | Merged into `dev` (PR #10) |
| `feature/Task2` | Task 2 — Classification (built on Task 1) | **Active / current** |
| `feature/AI_skeleton` | Autonomous tool-calling orchestration skeleton | In progress |
| `feature/task4-ai-agent-integration` | Task 4 — AI audit agent integration | In progress |

**Workflow:** `feature/*` → Pull Request → **`dev`** (integration & review) → `main` (stable). For Task 2 we merged `feature/Task1` into `feature/Task2` first to build directly on the existing visualization logic, resolving CDS/annotation conflicts before continuing.

### Next Steps (before final deadline)
1. **Task 3 — Association Analysis:** quantify relationships between risk score, service volume and payments (incl. facility vs office place-of-service and submitted-vs-paid discrepancies).
2. **Task 4 — Autonomous Audit Agent:** complete the AI agent (`feature/AI_skeleton` / `feature/task4-ai-agent-integration`) so it can be prompted with a high-level question (e.g. "why does Florida have a high payment-to-charge ratio?") and autonomously query the CDS views.
3. **Integration & BTP deployment:** merge Task 2/3 into `dev`, wire classification + association outputs into the agent's reasoning, and validate the full app deployed on BTP (destination/approuter).

# 5. Self-Reflection, Excellence & Architecture

Part of the final Task 4–5 hand-off for the **Healthcare Audit Assistant** (SAP CAP + Fiori Elements on BTP).  
Related: [4.2 Evaluate AI](./4.2-evaluate-ai-prompt-strategy.md) · [4.1 CAP agent actions](./4.1-autonomous-audit-agent.md) · [BTP deploy guide](./BTP-deploy-guide.md)

---

## Final Technical Hurdles

**Single greatest roadblock (AI integration on BTP):** packaging a **reliable, hallucination-resistant context** for SAP AI Core under real model and payload constraints — not the Approuter wiring itself.

### What broke

1. **GPT-5 deployment parameter mismatch**  
   Early Evaluate AI calls failed or degraded when the chat body still carried patterns valid for older GPT-4-style deployments (`max_tokens`, `stop`, hardcoded `model`). The active GPT-5 deployment (`AI_DEPLOYMENT_URL`) rejects those fields. Restaging with old request shapes after env switches made this recur until the body was locked to only:

   ```json
   { "temperature": 0, "frequency_penalty": 0, "presence_penalty": 0 }
   ```

2. **Hardcoded deployment ID mismatch in the onboarding guide**  
   Course / onboarding materials pointed at a fixed AI Core deployment ID that did not match our tenant’s live GPT-5 (or GPT-4o) deployment. Calls looked “configured” but hit the wrong endpoint or an inactive deployment. Debugging took a long time because env vars appeared set while the ID itself was stale relative to Cockpit → AI Core deployments.

3. **`package-lock.json` drift broke MTA generation**  
   Small variations in `package-lock.json` (npm version differences, incomplete installs, or lockfile out of sync with `package.json`) caused **MTA / `cds build --production` packaging to fail** during BTP deploy. The failure mode was easy to misread as an `mta.yaml` or module path problem until we regenerated a consistent lockfile and rebuilt.

4. **Context-size / sampling bias (the harder product bug)**  
   Each ALP can expose far more rows than an LLM can safely consume. We cap Evaluate AI at **400 rows** (diagrams at **150**). An unsorted or NPI-biased extract made the model “confidently wrong” — e.g. naming a mid-pack Individual as the top cost-per-patient Organization on Task 2.2b, or quoting wrong rural overclaim figures while the directional Finding looked plausible.

5. **Secondary BTP / FE friction (solved earlier, still material)**  
   Blank Fiori screens from annotation ↔ OData V4 mismatches, relative vs absolute UI5 resource paths under `cds watch`, and CF env / restage order for AI credentials. These were painful but eventually mechanical; the AI context bug was the one that survived “it deploys and returns 200.”

### How we solved it

| Layer | Fix |
|-------|-----|
| **AI Core client** | `srv/lib/check-ai.js` — GPT-5-safe request body only; clear env errors for missing `AI_DEPLOYMENT_URL` / token credentials |
| **Deployment ID** | Ignore hardcoded onboarding IDs; copy the live deployment URL/ID from our AI Core resource group into CF env (`AI_DEPLOYMENT_URL`), then restage |
| **MTA / lockfile** | Keep `package-lock.json` committed and in sync; reinstall (`npm ci` / clean install) before `mbt build` so MTA generation sees a deterministic dependency tree |
| **Per-ALP context** | `srv/lib/ai-context.js` — entity-aware schema snapshot, ranking hints, Task 2 tier labels, `sortBy` so the extract is metric-ranked (not random) |
| **Anti-hallucination topology** | System = Lead Auditor persona + silent agency rules; user = compressed JSON `{ schemaSnapshot, dataSnapshot, question }` — no formulas reinvented in the prompt |
| **Sanitization** | Money/rates rounded to 2 decimals before the model sees them; diagram path uses the same sort + sanitize |
| **Entity coverage** | Referer → ALP mapping for all ten analytical apps so Evaluate AI never silently analyzes the wrong cube |

Outcome: Evaluate AI became a **briefing pack from CAP**, not a free-form chat over the whole CMS extract.

---

## UI Architecture Justification

**We did not replace native SAP Fiori Elements with custom wrappers or external UI frameworks.**

The Exploration Zone is **native Fiori Elements** throughout:

- **Overview pages (OVP)** for task dashboards and audit-home navigation  
- **Analytical List Pages (ALP)** for Tasks 1.1–3.3 and risk distribution  
- **CDS UI annotations** (`UI.LineItem`, charts, KPIs, selection/presentation variants) driving layout  
- **OData V4 `$apply`** from FE to CAP analytical views — server-side aggregation, not client mashups  

### Why native FE was viable (and preferred)

| Constraint / goal | How native FE met it |
|-------------------|----------------------|
| Assignment expectation | Course stack is CAP + Fiori Elements; custom SPA would fight the grading model |
| Large CMS grain | Pre-aggregated / cube-annotated CDS views + FE charts keep aggregation in HANA/SQLite |
| Audit UX | KPIs, visual filters, analytical tables, object pages are FE strengths |
| BTP packaging | HTML5 repo + Approuter + destination `srv-api` is the standard enterprise path |
| Maintainability | Layout changes stay in annotations; no parallel React/Vue state layer |

### What custom UI5 *was* used (narrow, Doc 12–style)

Only **controller extensions** on ALPs for Task 4 charting:

| Piece | Role |
|-------|------|
| `ListReportExt.controller.js` | Opens the Generate Diagram dialog |
| `UploadDiagram.fragment.xml` | Hosts `sap.viz` chart from AI-returned `{ label, value }[]` |
| Manifest `sap.viz` + toolbar action | Wires the extension without replacing the List Report |

**Why this is not an “external UI” architecture:** the ALP shell, filters, tables, KPIs, and **Evaluate AI** `DataFieldForAction` remain Fiori Elements. The extension only adds a visualization surface that FE does not provide out of the box for free-form AI chart JSON.

**Why we did *not* build a custom SPA / wrapper:** native FE already owned navigation, draft-less analytical patterns, and OData binding. A wrapper would have duplicated Approuter routing, XSUAA session handling, and annotation semantics for little gain beyond what a `sap.viz` fragment already solves.

---

## Excellence Features (Beyond the Baseline)

Features that go past a minimal “one chart + one AI button” Task 4:

### Analytical depth (Tasks 1–3)

- **Task 1.2 RuralAnalysisChart** — multi-tier HCPCS grain with `OverclaimRate`, procedure-weighted `ProcedureBaselineRate`, and `TierDeviation` (not a single urban/rural flag)  
- **Task 1.3 BH burden peer groups** — Low vs High BH burden with cost-intensity (`PaidPerBeneficiary`) vs complexity (`AvgRiskScore`)  
- **Task 2.1 two-axis classification** — CAP-stamped `EfficiencyCategory` × `UtilizationCategory` (including **High-Cost Outlier**) reused by AI and the agent  
- **Task 2.2a / 2.2b** — specialty peer deviations **and** Individual vs Organization / Corporate Network profiling (including OTP-heavy org spend)  
- **Task 3.x** — risk–cost–volume, Facility vs Office POS intensity, credential charge-padding vs policy shortfall  
- **End-to-end audit journey** — deterministic narrative around NPI `1003056821` (PIZZO-BERKEY) tying OVP → ALP slices ([audit-journey-2022.md](./audit-journey-2022.md))

### AI & agent excellence (Task 4)

- **Evaluate AI on all ten ALP apps** (not a single demo screen), each with its own schema snapshot / ranking hints  
- **Generate Diagram** on the same ALPs via controlled FE extensions  
- **Prompt topology** documented for graders ([4.2](./4.2-evaluate-ai-prompt-strategy.md)) with one test prompt per exercise  
- **CAP multi-slice agent actions** (`investigateAnomalies`, regional/provider/peer tools, `AgentScratchpad`) callable over OData for API demos ([4.1](./4.1-autonomous-audit-agent.md)) — without requiring a separate chat dashboard  

### Engineering polish

- Entity-aware Referer resolution, sorted truncated extracts, decimal sanitization  
- Production CF env for AI Core; Approuter-protected `/medicare`  
- Modular `app/*` HTML5 modules + shared CDS model instead of one monolith UI  

---

## Final Reflection — Production-Grade BTP Workflow

The solution mirrors how enterprise SAP BTP apps are actually built and operated:

```
CMS / CSV seeds
      → CAP domain model + analytical CDS views (db/)
      → OData V4 MedicareService + actions (srv/)
      → Fiori Elements OVPs / ALPs + thin UI5 extensions (app/)
      → Approuter + XSUAA + destinations (BTP)
      → Optional SAP AI Core (Evaluate AI / diagram)
```

| Practice | How this project models it |
|----------|----------------------------|
| **Separation of concerns** | Calculations in CDS; UI in annotations; AI orchestration in `srv/lib/*` |
| **Push-down analytics** | FE `$apply` / cube annotations; ratios at the correct grain (ratio-of-sums, not avg-of-ratios) |
| **Secure edge** | Approuter fronts HTML5 + OData; roles such as `audit_analyst` gate read/actions |
| **Config over code for AI** | Deployment URL and tokens via CF env; restage after credential/model changes |
| **Observable AI** | Structured Finding / Evidence / Confidence / Follow-up; agent scratchpad for multi-step tools |
| **Ship / iterate** | Local `cds watch` → `cds build` / MTA → CF deploy → hard-refresh FE against live metadata |

A modern BTP workflow is not “custom UI everywhere + LLM over raw tables.” It is **declarative data products**, **standard Fiori analytical UX**, and **bounded AI** that reads a curated CAP context. That is what this Healthcare Audit Assistant implements end to end.

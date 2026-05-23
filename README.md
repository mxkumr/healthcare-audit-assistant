# healthcare-audit-assistant

## Data Analysis on the SAP Business Technology Platform

**Saarland University**  
**Summer Semester 2026**  
**M.Sc. Anushka Kothari, B. Sc. Chantale Lauer**

## Healthcare Analytics: Medicare Provider Utilization & GenAI Insights

**Midterm presentation:** 12.06.2026 | Time: 14:00 – 16:00  
**Endterm presentation/Deadline:** 17.07.2026 | Time: 14:00 – 16:00

---

# Introduction

Healthcare systems generate vast amounts of billing and utilization data, making it difficult for auditors to identify unusual provider behavior or regional disparities. In this project, students will develop an AI-augmented analytics application on the SAP Business Technology Platform (BTP) to interpret provider behavior and identify anomalies in Medicare patterns.

Using SAP CAP for the backend and Fiori Elements for the UI, the solution will move beyond static dashboards to simulate a digital audit assistant. The core of the project involves implementing a sophisticated AI layer capable of reasoning through complex healthcare economics to diagnose root causes of billing outliers.

- **AI Tier:** Agent (Very High)
- **Focus:** Autonomous Audit Reasoning & Root-Cause Diagnosis

---

# Mandatory Requirements

## 1. Development & Version Control

- **Environment:** All development must be performed using VSCode or SAP Business Application Studio (BAS).

- **GitHub Repository:** Mandatory for all projects. The repository must feature:
  - A clear commit history and branching strategy (e.g., `main` and `dev`)
  - Complete contents:
    - Source code
    - CDS data models
    - Documentation
    - Configuration files
    - Dependency specifications (`package.json`)

---

## 2. Framework & Technical Architecture

- **Backend:** Must be implemented using SAP Cloud Application Programming Model (CAP) with Node.js/JavaScript.

- **Frontend:** SAP Fiori Elements is mandatory. A separate working dashboard view must be implemented for each task (Task 1–4).

- **OData Services:** All CAP services must expose OData V4 entities to be consumed by both the Fiori UI and the AI components.

- **AI Integration:** Projects must implement the assigned AI Capability Tier (e.g., Low/Medium combination or a single Very High tier).

---

## 3. Deliverables & Milestone Reports

Groups must submit two distinct written reports using the university template at the following checkpoints:

### Checkpoint 1: Mid-term Report (Due 12.06.2026)

**Focus:** Foundation & Design

**Content:**
- Current implementation status of:
  - Task 1 (Visualization)
  - Task 2 (Classification)
- Initial CDS graphical models
- Description of the GitHub branching strategy

---

### Checkpoint 2: End-term Report (Due 17.07.2026)

**Focus:** Final Integration & Analytical Findings

**Content:**
- Architectural decisions for the AI Integration (Task 4)
- Final Association Analysis results (Task 3)
- Summary of “Lessons Learned” regarding:
  - Prompt engineering
  - BTP deployment

---

## 4. Participation & Presentation Rules

- **Attendance:** All group members must attend both the Mid-term and End-term milestones.

- **Presenting:** Each group member must present in at least one of the two milestone presentations.

- **Demonstration:** A live system demonstration is required during the final presentation.

---

## 5. Functional Benchmarks & Grading

To pass, the final solution must include:

1. A working interactive dashboard
2. An AI-generated narrative feature (Market/Audit/Operational narrative)
3. A management-ready downloadable report (PDF)

### Higher Grades Are Awarded For:

- Deeper Segmentation Logic:
  - Sophisticated classification in Task 2

- Enhanced CDS Modeling:
  - Use of complex associations and analytical views

- Refined AI Engineering:
  - High-quality prompt engineering and logic

---

# Tasks

A comprehensive analytics application is to be created on the SAP BTP. This application will enable users (e.g., healthcare policy analysts or auditors) to evaluate provider efficiency, cost structures, and quality of care indicators.

---

## 1. Data Visualization (Aggregation)

Develop an aggregated and exploratory view of healthcare utilization and financial metrics that allows users to compare providers, regions, and patient complexity profiles.

### Requirements

- Visualize relevant cost measures:
  - Submitted charges
  - Allowed amounts
  - Paid amounts

- Compare across:
  - States
  - Provider types

- Visualize geographic distribution of services using `Geo_Reference` data to highlight potential regional disparities:
  - Rural vs. urban

- Explore distributions of beneficiary risk scores to understand differences in patient complexity across providers or regions.

---

## 2. Classification Tool

Design classification approaches that structure providers, services, or specialties into analytically meaningful groups.

### Requirements

- Develop at least one classification related to:
  - Provider cost efficiency
  - Utilization behavior

- Clearly motivate the chosen dimensions and thresholds.

- Classify specialties or organizations based on:
  - Beneficiary characteristics
  - Risk profiles

- Explain the analytical relevance of the grouping.

- You may define outlier classifications using statistical thresholds if justified.

---

## 3. Association Analysis

Identify, visualize, and critically interpret relationships between provider characteristics, patient complexity, and financial outcomes.

### Requirements

- Analyze relationships between:
  - Beneficiary risk scores
  - Service volume
  - Payment amounts

- Assess whether observed patterns align with expected healthcare cost dynamics.

- Examine how place of service (`facility` vs `office`) relates to Medicare payment levels and discuss possible drivers.

- Explore discrepancies between:
  - Submitted charges
  - Actual payments

- Compare across provider credentials and discuss structural or policy-related explanations.

---

## 4. AI Integration (Autonomous Audit Agent)

The system must move beyond simple summaries by implementing an autonomous AI Agent that acts as a lead medical auditor.

### Requirements

#### Autonomous Root-Cause Diagnosis

Implement an agent that can be prompted with a high-level problem such as:

> “Investigate why Florida has a higher-than-average payment-to-charge ratio”

The agent should autonomously query relevant CDS views to determine the answer.

---

#### Reasoning-Based Logic

The agent must:
- Link classification outcomes (Task 2)
- Link associations (Task 3)
- Explain why anomalies exist

Example:
- High costs caused by:
  - Specific patient complexity scores
  - Provider inefficiency

---

#### Audit Reporting

Generate a formal, structured **Provider Audit Report** that synthesizes findings into professional narratives.

---

#### Actionability

The agent should suggest specific follow-up actions such as:

> “Flag Provider X for manual review”

based on diagnostic confidence.

---

# Data Explanation

The project relies on the **Medicare Provider Utilization Dataset**, which links healthcare providers to services performed and costs incurred.

The data is split into three main files.

---

## 1. Provider_Summary

Contains demographic and practice information for healthcare providers.

### Key Attributes

- `Rndrng_NPI` — Unique ID
- `Rndrng_Prvdr_Last_Org_Name`
- `Rndrng_Prvdr_Crdntls`
- `Rndrng_Prvdr_City`
- `Rndrng_Prvdr_State_Abrvtn`

### Risk Metrics

- `Bene_CC_PH_Hypertension_V2_Pct` — Hypertension rate
- `Bene_Avg_Risk_Scre` — Patient complexity score

---

## 2. Service_Details

Contains utilization and cost data for specific procedures (HCPCS codes).

### Key Attributes

- `Rndrng_NPI` — Foreign key
- `HCPCS_Drug_Ind`
- `Place_Of_Srvc` — Office/Facility

### Metrics

- `Tot_Benes` — Patient count
- `Tot_Srvcs` — Service volume
- `Avg_Sbmtd_Chrg` — Provider’s bill
- `Avg_Mdcr_Pymt_Amt` — Actual payment

---

## 3. Geo_Reference

Mapping file used to normalize geographic data and determine pricing localities.

### Key Attributes

- `ZIP CODE`
- `STATE`
- `RURAL IND` — Rural Indicator
- `LOCALITY`

---

# Hints

- **Model for Logic:** Create CDS views that pre-calculate “Peer Deviations” to provide the Agent with a baseline for “normal” behavior.

- **Agentic Orchestration:** Focus on the SAP AI SDK to allow the Agent to call specific CAP functions (Tools) for deeper data drills.

- **Prompt Grounding:** Include classification metadata in JSON prompts so the AI understands which providers are “High Risk.”

- **Context Management:** Use a “Scratchpad” or logging entity in CAP to track reasoning steps for final audit reports.

---

# Dashboard Relevance

## Audit Control Center

Instead of a static view, the dashboard serves as a command center where auditors trigger deep-dive investigations into regional cost hotspots.

---

## Dynamic Discovery

Leverages the Agent to bridge the gap between:
- Geographic maps (`Geo_Reference`)
- Billing anomalies

---

## Automated Evidence

The final PDF output provides a compliance-ready trail of the AI’s diagnostic steps, ensuring audit transparency.

---

# Learning Outcomes

## Agentic Workflow Design

Mastery of:
- Autonomous AI tool-calling
- Multi-step reasoning in healthcare contexts

---

## Advanced Data Normalization

Ability to harmonize:
- Clinical risk scores
- Financial billing metrics

---

## Regulatory AI Ethics

Understanding how to implement:
- Human-in-the-Loop AI
- Sensitive public sector auditing

---

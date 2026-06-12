## 📑 Midterm Presentation Metadata & Strategy

* **Context:** Data Analysis on the SAP Business Technology Platform (Summer Semester 2026).


* **Time Allocation:** 15 Minutes Presentation + 5 Minutes Q&A (Strictly enforced).


* **Target Timing:** 10 minutes for slides (~1.2 minutes per slide) + 5 minutes for a live dashboard demonstration.


* **Core Team Principle:** Continuous distribution of effort. Ensure team members hand off sections cleanly, showcasing unified understanding.



---

## 🛝 Slide-by-Slide Content & Script Architecture

### Slide 1: Title & Project Scope

* **Slide Header:** AI-Augmented Healthcare Audit Assistant on SAP BTP
* **Visual Elements:** University logo, team member names, Date: 12.06.2026.


* **Key Talking Points:**
* Development framework: SAP Cloud Application Programming Model (CAP) and SAP Fiori Elements.


* Data source: Multi-year (2019–2023) CMS Medicare Physician & Other Practitioners dataset.


* Business Goal: Moving from static dashboards to a digital audit assistant capable of identifying utilization outliers and structural healthcare spending disparities.




* **Speaker Script:**
> "Good afternoon. Today we are presenting the Healthcare Audit Assistant, an analytical application built completely on SAP CAP and Fiori Elements. Our goal is to transform millions of messy public CMS billing rows into an actionable, command-center dashboard that optimizes the auditing workflow for healthcare analysts."
> 
> 



### Slide 2: Technical Architecture & Request Flow

* **Slide Header:** Declarative Architecture & Pushed-Down Aggregations
* **Visual Elements:** System block diagram showing the 3-layer architecture (`app/` $\rightarrow$ `srv/` $\rightarrow$ `db/`).


* **Key Talking Points:**
* **Data Layer (`db/`):** Star schema architecture containing central facts (`ProviderSummary`, `ServiceDetails`) and lookups (`GeoReference`).


* **Service Layer (`srv/`):** Purely declarative OData V4 service (`MedicareService`) with **zero custom Node.js handlers**.


* **UI Layer (`app/`):** 7 modular Fiori Elements applications orchestrated via a centralized SAP Approuter.


* **Logic Principle:** Pushing heavy analytical calculations directly to the database layer (SQLite locally / SAP HANA Cloud in production) via OData V4 `$apply` commands.




* **Speaker Script:**
> "As outlined in **Technical_Architecture.md**, we intentionally avoided custom JavaScript handlers in our service layer. By making the backend entirely declarative, when an auditor requests a chart, the Fiori UI generates native OData V4 `$apply` expressions. This pushes the aggregation load directly down to the database engine, ensuring high performance even when processing massive clinical sets."
> 
> 



### Slide 3: Task 1 — Data Visualization & Aggregation Logic

* **Slide Header:** Task 1: Mapping Spend, Disparities, and Patient Complexity
* **Visual Elements:** Structural map pointing out the three analytical views built for Task 1.


* **Key Talking Points:**
* `CostByStateProviderType`: Isolates macro-level spending hotspots across states and medical specialties.


* `RuralUrbanDistribution`: Quantifies regional disparities by handling explicit null-lookup states.


* `RiskScoreDistribution`: Restructures 50,000+ provider profiles into a clean, pre-sorted 5-band histogram of patient complexity.




* **Technical Logic Highlight:** Resolving the `GeoReference` null-handling anomaly.


```sql
case 
  when g.ZipCode is null then 'Unknown'
  when g.RuralInd = 'R'  then 'Rural'
  when g.RuralInd = 'B'  then 'Super Rural'
  else                        'Urban'
end as RuralUrban

```

*   **Speaker Script:** 
    > "For Task 1, we engineered three virtual views to aggregate data meaningfully[cite: 1]. A key technical success here was our precise handling of geographic null values[cite: 1]. Rather than letting missing ZIP lookups skew our metrics, we wrote explicit case logic distinguishing unmapped ZIP codes from true Urban centers where the indicator is blank, ensuring flawless data fidelity[cite: 1]."

### Slide 4: Task 2 — Sophisticated & Percentile-Anchored Classification
*   **Slide Header:** Task 2: Multi-Dimensional Behavioral Segmentation
*   **Visual Elements:** A structured comparative table of the classification thresholds[cite: 1].
*   **Key Talking Points:**
    *   **Deeper Segmentation Logic:** Thresholds are mathematically anchored to real dataset percentiles, satisfying the grading criteria for higher marks[cite: 1, 2].
    *   `ProviderCostEfficiency`: Direct, granular row-level profiling across Risk, Efficiency, and Utilization categories[cite: 1].
    *   `SpecialtyRiskProfile` & `OrganizationClassification`: Macro-level groupings highlighting institutional vs. individual clinician behavior[cite: 1].

| Dimension | Classification Bands | Statistical Anchor / Cut Points | Audit Relevance |
| :--- | :--- | :--- | :--- |
| **Risk Category** | Low / Moderate / High / Very High | CMS HCC Score (1.0 = Nat. Avg.)[cite: 1] | Isolates high-acuity caseloads[cite: 1] |
| **Efficiency Category** | Highly Efficient $\rightarrow$ Outlier | Cost/Bene: \$150 / \$300 / \$600 / \$900[cite: 1] | Outliers represent top ~5% cost intensity[cite: 1] |
| **Utilization Category** | Low / Moderate / High | Services/Bene: Cut points at 5 and 15[cite: 1] | Detects potential over-utilization[cite: 1] |

*   **Speaker Script:** 
    > "To address the Task 2 benchmark for advanced segmentation, we rejected arbitrary round numbers[cite: 1, 2]. We profiled the entire 50,000-provider dataset to establish percentile-anchored thresholds[cite: 1]. For instance, our cost 'Outlier' band is set at equal to or greater than \$900 per beneficiary, which mathematically isolates the exact top 5% of cost-intensive behavior for immediate auditing[cite: 1]."

### Slide 5: The Analytical Core — The Golden Rule of Ratios
*   **Slide Header:** Eliminating Macro Distortion: Ratio-of-Sums
*   **Visual Elements:** Visual comparison of computation methods.
    *   ❌ *Average of Ratios:* Distorts corporate cost to **~\$650**[cite: 1].
    *   ✅ *Ratio of Sums:* Identifies true corporate cost at **~\$354**[cite: 1].
*   **Key Talking Points:**
    *   Aggregating pre-computed per-row ratios introduces fatal unweighted skew[cite: 1].
    *   Implementation of safe dynamic database division to protect analytical precision[cite: 1]:
$$ \text{CostPerBene} = \frac{\text{cast}(\text{sum}(\text{Tot\_Mdcr\_Pymt\_Amt}) \text{ as Decimal})}{\text{nullif}(\text{sum}(\text{Tot\_Benes}), 0)} $$
*   **Speaker Script:** 
    > "A critical analytical challenge we solved involves the calculation of unit costs[cite: 1]. Averaging pre-calculated provider ratios across a state aggregates data incorrectly[cite: 1]. To protect the audit's integrity, our views strictly compute the **Ratio-of-Sums** using SQL `nullif` wrappers to eliminate divide-by-zero risks[cite: 1]. This mathematical precision corrected an error where organizational spend originally appeared nearly double its actual value[cite: 1]."

---

### Slide 6: Live System Demonstration (4–5 Minutes)
*   **Slide Header:** Live System Walkthrough: The Auditor's Command Center
*   **Live Navigation Plan:**
    1.  **Launch & Index:** Show the active `cds watch` local environment exposing the functional OData V4 service layer[cite: 1].
    2.  **Task 1 Execution:** Navigate through the `task1-overview` and open the **Cost Analysis** dashboard[cite: 1]. Apply a filter to isolate a specific high-spend state or provider type[cite: 1].
    3.  **Task 2 Segmentation:** Jump to the **Provider Classification** app[cite: 1]. Filter the dynamic grid to display providers classified simultaneously as `Outlier` for cost and `High Risk` for patient complexity[cite: 1].
    4.  **End-to-End Trace:** Demonstrate the exact execution path of a single Diagnostic Radiology provider in California, showing how raw metrics parse into categorized attributes instantly[cite: 1].

---

### Slide 7: Code Architecture Deep Dive
*   **Slide Header:** Declarative Analytics and Metadata Layering
*   **Visual Elements:** Syntax-highlighted code blocks showing backend metadata configurations[cite: 1].
*   **Key Talking Points:**
    *   **Separation of Concerns:** Keep structural aggregation instructions in `srv/medicare-service.cds` and visual layout details inside `app/*/annotations.cds`[cite: 1].
    *   Exposing custom endpoints using `@Aggregation.ApplySupported` to inform Fiori Elements how to structure queries[cite: 1].
    *   Using `@Analytics.Dimension` and `@Analytics.Measure` with `@Aggregation.default: #SUM` to map database results cleanly to UI chart axes[cite: 1].
*   **Speaker Script:** 
    > "Looking at our code structure, we achieved a strict separation of concerns[cite: 1]. By decoupling our core aggregation rules in the service layer from layout rules in the app layer, we eliminated metadata collisions[cite: 1]. Annotations like `ApplySupported` and `CustomAggregate` inform the Fiori engine exactly how to execute server-side data reductions securely[cite: 1]."

### Slide 8: Development Roadmap & Next Steps
*   **Slide Header:** Road to End-Term: Advanced Associations & Autonomous AI
*   **Visual Elements:** Timeline charting development towards the July 17 deadline[cite: 2].
*   **Key Talking Points:**
    *   **Task 3 (Association Analysis):** Unlocking our deep `ServiceDetails` fact table to trace the impacts of Place of Service (Facility vs. Office) and the submitted-to-payment charge gap[cite: 1, 2].
    *   **Task 4 (Autonomous Audit Agent - Very High Tier):** Utilizing the SAP AI SDK to construct an independent medical audit agent[cite: 2].
    *   **Orchestration Strategy:** Grounding prompts with Task 2 classification schemas and deploying a dedicated CAP "Scratchpad" entity to preserve the agent's step-by-step reasoning logs[cite: 2].
*   **Speaker Script:** 
    > "Our foundational data architecture is built, validated, and ready for our upcoming milestones[cite: 1, 2]. Moving toward the July 17 deadline, we will execute Task 3's granular service analysis using the `ServiceDetails` entity[cite: 1, 2]. For Task 4, we will implement the Very High AI Tier[cite: 2]. Using the SAP AI SDK, our autonomous agent will query our existing analytical views, use a CAP scratchpad to track its reasoning steps, and generate compliance-ready audit narratives[cite: 1, 2]."

### Slide 9: Conclusion & Deliverable Check
*   **Slide Header:** Project Summary & Milestone Status
*   **Visual Elements:** Checklist indicating completed vs. upcoming items.
*   **Key Talking Points:**
    *   ✅ Task 1 (Aggregation) views & Fiori UI layers fully operational[cite: 1, 2].
    *   ✅ Task 2 (Classification) logic mapped, verified, and integrated[cite: 1, 2].
    *   ✅ Checkpoint 1 Mid-term report finalized and uploaded to the repository[cite: 2].
    *   🔒 Repository branching strategy established (main, dev) with clean commit histories[cite: 2].
*   **Speaker Script:** 
    > "In conclusion, our foundation for the Healthcare Audit Assistant is fully implemented[cite: 1]. Our Task 1 and Task 2 components are operational, and our mid-term deliverables have been successfully submitted[cite: 1, 2]. We are well-positioned to integrate the advanced association and AI features in the next phase[cite: 2]. Thank you, and we look forward to your questions."

---

## 🎯 Q&A Preparation Matrix (Defending Your 10/10)

Be prepared for these highly technical questions based on your architectural design choices in **Technical_Architecture.md**[cite: 1]:

> **Q1: Why did you choose to build 6 separate views instead of putting all the logic into a single broad analytical view?**
*   **Answer:** "We prioritized a modular design to keep our data structures clean and performant[cite: 1]. Fiori Elements charts perform best when consuming a view tailored to their required dimensions[cite: 1]. For example, `ProviderCostEfficiency` is kept as a granular, non-aggregated row-level view for individual provider profiling, whereas `CostByStateProviderType` is pre-aggregated to deliver rapid responses for top-level regional charts[cite: 1]."

> **Q2: Why did you choose a pure declarative CDS model instead of using custom Node.js/JavaScript handlers (`srv/*.js`)?**
*   **Answer:** "Using a declarative approach allows the framework to optimize data handling[cite: 1]. Writing custom JavaScript code forces rows to be pulled from the database layer into the Node.js application memory runtime to process loops[cite: 1]. By relying entirely on declarative views and aggregation metadata, we ensure that CAP pushes the execution down to SQL, letting the database engine optimize memory usage and query processing[cite: 1]."

> **Q3: How will your Task 2 classification view benefit the upcoming Autonomous AI Agent in Task 4?**
*   **Answer:** "It prevents prompt saturation and saves context tokens[cite: 2]. Instead of sending thousands of raw billing rows to the Large Language Model and asking it to find patterns, our agent can query `ProviderCostEfficiency` directly using OData[cite: 1, 2]. The data arrives pre-labeled with clear categories like `Outlier` or `Very High Risk`, allowing the agent to focus entirely on root-cause analysis and narrative generation[cite: 1, 2]."

```

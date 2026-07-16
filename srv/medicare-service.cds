using { Core } from '@sap/cds/common';
using medicare from '../db/schema';

service MedicareService @(path:'/medicare') {

  entity ProviderSummary  as projection on medicare.ProviderSummary;
  entity ServiceDetails   as projection on medicare.ServiceDetails;
  entity GeoReference     as projection on medicare.GeoReference;
  entity StateReference   as projection on medicare.StateReference;

  @readonly
  @cds.redirection.target: false
  entity CostByStateProviderType  as projection on medicare.CostByStateProviderType;

  @readonly
  @cds.redirection.target: false
  entity CostAnalysisV2           as projection on medicare.CostAnalysisV2;

  @readonly
  @cds.redirection.target: false
  entity RuralAnalysisV2          as projection on medicare.RuralAnalysisV2;

  @readonly
  @cds.redirection.target: false
  entity RuralAnalysisChart       as projection on medicare.RuralAnalysisChart;

  @readonly
  @cds.redirection.target: false
  entity RuralUrbanDistribution   as projection on medicare.RuralUrbanDistribution;

  @readonly
  @cds.redirection.target: false
  entity RiskScoreDistribution    as projection on medicare.RiskScoreDistribution;

  @readonly
  @cds.redirection.target: false
  entity BehavioralHealthRiskProfile as projection on medicare.BehavioralHealthRiskProfile;

  @readonly
  @cds.redirection.target: false
  entity ProviderCostEfficiency as projection on medicare.ProviderCostEfficiency;

  @readonly
  @cds.redirection.target: false
  entity SpecialtyRiskProfile as projection on medicare.SpecialtyRiskProfile;

  @readonly
  @cds.redirection.target: false
  entity SpecialtyPeerDeviations as projection on medicare.SpecialtyPeerDeviations;

  @readonly
  @cds.redirection.target: false
  entity EntityTypeComparisons as projection on medicare.EntityTypeComparisons;

  @readonly
  @cds.redirection.target: false
  entity EntityTypeProviderProfiles as projection on medicare.EntityTypeProviderProfiles;

  @readonly
  @cds.redirection.target: false
  entity EntityTypeCostInsight as projection on medicare.EntityTypeCostInsight;

  @readonly
  @cds.redirection.target: false
  entity CredentialDiscrepancies as projection on medicare.CredentialDiscrepancies;

  @readonly
  @cds.redirection.target: false
  entity PlaceOfServiceAnalysis as projection on medicare.PlaceOfServiceAnalysis;

  @readonly
  @cds.redirection.target: false
  entity PlaceOfServiceProviderProfiles as projection on medicare.PlaceOfServiceProviderProfiles;

  @readonly
  @cds.redirection.target: false
  entity RiskCostVolumeDynamics as projection on medicare.RiskCostVolumeDynamics;

  @readonly
  entity AgentScratchpad as projection on medicare.AgentScratchpad;

  // ── Doc 11: Fiori Evaluate AI (course incidents pattern → SAP AI Core) ───────
  action checkAI(Query : String);

  /** Doc 12: AI → JSON chart data for custom VizFrame extension (returns JSON string). */
  function diagram(Query : String) returns LargeString;

  // ── Task 4: Joule / Autonomous Audit Agent actions ─────────────────────────

  /** Primary orchestrator — multi-slice investigation across Tasks 1–3. */
  action investigateAnomalies(
    prompt    : String,
    year      : String,
    state     : String,
    specialty : String,
    npi       : String
  ) returns {
    narrative       : String;
    confidenceScore : Integer;
    year            : String;
    flaggedNPIs     : String;
    reasoningSteps  : String;
    sessionId       : String;
  };

  /** Regional billing hotspot tool (Task 1.1). */
  action getRegionalBillingOutliers(
    state : String not null,
    year  : String
  ) returns {
    narrative : String;
    year      : String;
    results   : String;
    sessionId : String;
  };

  /** Provider drill-down tool (Tasks 2.1 + ServiceDetails). */
  action getProviderClaimDetails(
    npi  : String not null,
    year : String
  ) returns {
    narrative : String;
    year      : String;
    provider  : String;
    services  : String;
    sessionId : String;
  };

  /** Specialty peer deviation tool (Task 2.2). */
  action getSpecialtyPeerOutliers(
    specialty : String,
    year      : String,
    state     : String
  ) returns {
    narrative : String;
    year      : String;
    results   : String;
    sessionId : String;
  };

  /** Discovery helper — lists CMS years present in the analytical views. */
  action listAuditYears() returns {
    years       : String;
    defaultYear : String;
  };
}

// Self-association: all year records for the same provider name (object-page history table)
extend MedicareService.ProviderCostEfficiency with columns {
  yearHistory : Association to many MedicareService.ProviderCostEfficiency on yearHistory.ProviderName = $self.ProviderName
}

// ── Aggregation (data-shaping) annotations for the analytical query ────────────
// NOTE: UI annotations (LineItem, Chart, PresentationVariant, KPIs, visual
// filters, facets) live in the app layer at app/1.1cost-analysis/annotations.cds.
// Keep this file limited to service/data concerns to avoid duplicate/conflicting
// annotations.

annotate MedicareService.CostByStateProviderType with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [Year, State, ProviderType],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalSubmitted},
      {Property: TotalAllowed},
      {Property: TotalPaid},
      {Property: TotalBeneficiaries},
      {Property: AvgRiskScore}
    ]
  }
);

// Custom aggregates per measure. Fiori Elements issues a plain
// `aggregate(<measure>)` query for the chart and analytical table; the runtime
// needs BOTH the result type (@Aggregation.CustomAggregate#<measure>) and the
// aggregation function (@Aggregation.default) to resolve such a query.
annotate MedicareService.CostByStateProviderType with @(
  Aggregation.CustomAggregate #ProviderCount      : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalSubmitted     : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowed       : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalBeneficiaries : 'Edm.Int32',
  Aggregation.CustomAggregate #AvgRiskScore       : 'Edm.Decimal'
) {
  // @Analytics.Dimension / .Measure are required by the OVP V4 chart data
  // handler (sap.ovp.cards.v4.charts) to identify dimensions vs measures.
  Year               @Analytics.Dimension: true;
  State              @Analytics.Dimension: true;
  ProviderType       @Analytics.Dimension: true;
  ProviderCount      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmitted     @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalAllowed       @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPaid          @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalBeneficiaries @Analytics.Measure: true  @Aggregation.default: #SUM;
  AvgRiskScore       @Analytics.Measure: true  @Aggregation.default: #AVG;
};

// ── CostAnalysisV2 (state-grain cube — independent ALP target) ─────────────────
annotate MedicareService.CostAnalysisV2 with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [Year, State, StateName, ProviderType],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalSubmitted},
      {Property: TotalAllowed},
      {Property: TotalPaid},
      {Property: RejectedCharges},
      {Property: DrugSubmitted},
      {Property: DrugAllowed},
      {Property: RejectedDrugCharges},
      {Property: DrugPaid},
      {Property: TotalBeneficiaries}
    ]
  }
);

annotate MedicareService.CostAnalysisV2 with @(
  Aggregation.CustomAggregate #ProviderCount      : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalSubmitted     : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowed       : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #RejectedCharges      : 'Edm.Decimal',
  Aggregation.CustomAggregate #DrugSubmitted      : 'Edm.Decimal',
  Aggregation.CustomAggregate #DrugAllowed        : 'Edm.Decimal',
  Aggregation.CustomAggregate #RejectedDrugCharges: 'Edm.Decimal',
  Aggregation.CustomAggregate #DrugPaid           : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalBeneficiaries : 'Edm.Int32'
) {
  Year               @Analytics.Dimension: true;
  State              @Analytics.Dimension: true;
  StateName          @Analytics.Dimension: true;
  ProviderType       @Analytics.Dimension: true;
  ProviderCount      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmitted     @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalAllowed       @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalPaid          @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  RejectedCharges    @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  DrugSubmitted       @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  DrugAllowed         @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  RejectedDrugCharges @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  DrugPaid            @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalBeneficiaries @Analytics.Measure: true  @Aggregation.default: #SUM;
};

// ── RuralAnalysisV2 (HCPCS × RUCA structural tier — overclaiming cube) ─────────
annotate MedicareService.RuralAnalysisV2 with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [HCPCS_Code, HCPCS_Desc, StructuralTier],
    AggregatableProperties : [
      {Property: TotalServices},
      {Property: TotalSubmitted},
      {Property: TotalPaid},
      {Property: RejectedCharges}
    ]
  }
);

annotate MedicareService.RuralAnalysisV2 with @(
  Aggregation.CustomAggregate #TotalServices      : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalSubmitted     : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #RejectedCharges    : 'Edm.Decimal',
  Aggregation.CustomAggregate #OverclaimRate      : 'Edm.Decimal',
  Aggregation.CustomAggregate #UrbanBaselineRate  : 'Edm.Decimal'
) {
  HCPCS_Code       @Analytics.Dimension: true;
  HCPCS_Desc       @Analytics.Dimension: true;
  StructuralTier   @Analytics.Dimension: true;
  TotalServices    @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmitted   @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalPaid        @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  RejectedCharges  @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  OverclaimRate      @Analytics.Measure: true  @Measures.Unit: '%';
  UrbanBaselineRate  @Analytics.Measure: true  @Measures.Unit: '%';
};

// ── RuralAnalysisChart (HCPCS × tier — chart-safe grain, 1 row per code × tier) ─
annotate MedicareService.RuralAnalysisChart with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'topcount', 'orderby', 'skip', 'top'],
    GroupableProperties    : [HCPCS_Code, HCPCS_Desc, StructuralTier, TierCoverageCount],
    AggregatableProperties : [
      {Property: TotalServices},
      {Property: TotalSubmitted},
      {Property: TotalPaid},
      {Property: RejectedCharges},
      {Property: OverclaimRate,           SupportedAggregationMethods: ['max']},
      {Property: ProcedureBaselineRate, SupportedAggregationMethods: ['max']},
      {Property: TierDeviation,         SupportedAggregationMethods: ['max']}
    ]
  }
);

annotate MedicareService.RuralAnalysisChart with @(
  Aggregation.CustomAggregate #TotalServices      : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalSubmitted     : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #RejectedCharges    : 'Edm.Decimal',
  Aggregation.CustomAggregate #OverclaimRate           : 'Edm.Decimal',
  Aggregation.CustomAggregate #ProcedureBaselineRate : 'Edm.Decimal',
  Aggregation.CustomAggregate #TierDeviation         : 'Edm.Decimal'
) {
  HCPCS_Code        @Analytics.Dimension: true;
  HCPCS_Desc        @Analytics.Dimension: true;
  StructuralTier    @Analytics.Dimension: true;
  TierCoverageCount @Analytics.Dimension: true;
  TotalServices    @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmitted   @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalPaid        @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  RejectedCharges  @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  // MAX at HCPCS-only group grain; exact values at HCPCS × StructuralTier leaf rows
  OverclaimRate           @Analytics.Measure: true  @Aggregation.default: #MAX  @Measures.Unit: '%';
  ProcedureBaselineRate @Analytics.Measure: true  @Aggregation.default: #MAX  @Measures.Unit: '%';
  TierDeviation         @Analytics.Measure: true  @Aggregation.default: #MAX  @Measures.Unit: '%';
};

// ── RuralUrbanDistribution (geographic disparities) ───────────────────────────
annotate MedicareService.RuralUrbanDistribution with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [Year, State, RuralUrban],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalSubmitted},
      {Property: TotalAllowed},
      {Property: TotalPaid},
      {Property: TotalBeneficiaries},
      {Property: PaidPerBene},
      {Property: AvgRiskScore}
    ]
  }
);

annotate MedicareService.RuralUrbanDistribution with @(
  Aggregation.CustomAggregate #ProviderCount      : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalSubmitted     : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowed       : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalBeneficiaries : 'Edm.Int32',
  Aggregation.CustomAggregate #PaidPerBene        : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgRiskScore       : 'Edm.Decimal'
) {
  Year               @Analytics.Dimension: true;
  State              @Analytics.Dimension: true;
  RuralUrban         @Analytics.Dimension: true;
  ProviderCount      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmitted     @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalAllowed       @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPaid          @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalBeneficiaries @Analytics.Measure: true  @Aggregation.default: #SUM;
  // AVG rollup is an approximation across states; exact figure is shown at row
  // grain. For an exact per-bucket value, see RuralUrbanSummary (ratio of sums).
  PaidPerBene        @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgRiskScore       @Analytics.Measure: true  @Aggregation.default: #AVG;
};

// ── RiskScoreDistribution (patient complexity bands) ──────────────────────────
annotate MedicareService.RiskScoreDistribution with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [Year, State, ProviderType, RiskBand],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalBeneficiaries},
      {Property: TotalPaid},
      {Property: AvgRiskScore},
      {Property: AvgHypertensionPct},
      {Property: AvgDiabetesPct}
    ]
  }
);

annotate MedicareService.RiskScoreDistribution with @(
  Aggregation.CustomAggregate #ProviderCount      : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalBeneficiaries : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgRiskScore       : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgHypertensionPct : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgDiabetesPct     : 'Edm.Decimal'
) {
  Year               @Analytics.Dimension: true;
  State              @Analytics.Dimension: true;
  ProviderType       @Analytics.Dimension: true;
  RiskBand           @Analytics.Dimension: true;
  ProviderCount      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalBeneficiaries @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPaid          @Analytics.Measure: true  @Aggregation.default: #SUM;
  AvgRiskScore       @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgHypertensionPct @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgDiabetesPct     @Analytics.Measure: true  @Aggregation.default: #AVG;
};

// ── Task 1.3: BehavioralHealthRiskProfile (cost-complexity frontier) ──────────
annotate MedicareService.BehavioralHealthRiskProfile with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'orderby', 'skip', 'top'],
    GroupableProperties    : [Year, State, ProviderType, BHBurdenGroup],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: AvgRiskScore},
      {Property: PaidPerBeneficiary},
      {Property: TotalPaid},
      {Property: TotalBeneficiaries},
      {Property: TotalSubmitted},
      {Property: TotalAllowed},
      {Property: TotalDrugPaid},
      {Property: AvgUniqueProcedures},
      {Property: MedicareAcceptCount}
    ]
  }
);

annotate MedicareService.BehavioralHealthRiskProfile with @(
  Aggregation.CustomAggregate #ProviderCount       : 'Edm.Int32',
  Aggregation.CustomAggregate #AvgRiskScore        : 'Edm.Decimal',
  Aggregation.CustomAggregate #PaidPerBeneficiary  : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPaid           : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalBeneficiaries  : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalSubmitted      : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowed        : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalDrugPaid       : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgUniqueProcedures : 'Edm.Decimal',
  Aggregation.CustomAggregate #MedicareAcceptCount : 'Edm.Int32'
) {
  Year                  @Analytics.Dimension: true;
  State                 @Analytics.Dimension: true;
  ProviderType          @Analytics.Dimension: true;
  BHBurdenGroup         @Analytics.Dimension: true;
  ProviderCount         @Analytics.Measure: true  @Aggregation.default: #SUM;
  AvgRiskScore          @Analytics.Measure: true  @Aggregation.default: #AVG;
  PaidPerBeneficiary    @Analytics.Measure: true  @Aggregation.default: #AVG;
  TotalPaid             @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalBeneficiaries    @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmitted        @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalAllowed          @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalDrugPaid         @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  AvgUniqueProcedures   @Analytics.Measure: true  @Aggregation.default: #AVG;
  MedicareAcceptCount   @Analytics.Measure: true  @Aggregation.default: #SUM;
};

// ── Task 2.1: ProviderCostEfficiency (2-Axis Risk Matrix) ─────────────────────
annotate MedicareService.ProviderCostEfficiency with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'topcount', 'orderby', 'skip', 'top'],
    GroupableProperties    : [
      Year, State, ProviderType, NPI, ProviderName,
      EntityTypeCode, EntityType,
      EfficiencyCategory, UtilizationCategory
    ],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: CostPerBeneficiary},
      {
        Property: ServicesPerBeneficiary,
        SupportedAggregationMethods: ['max']
      },
      {Property: TotalBeneficiaries, SupportedAggregationMethods: ['max']},
      {Property: AvgPatientAge},
      {Property: AvgRiskScore},
      {Property: DiabetesPct},
      {Property: HypertensionPct}
    ]
  }
);

annotate MedicareService.ProviderCostEfficiency with @(
  Aggregation.CustomAggregate #ProviderCount           : 'Edm.Int32',
  Aggregation.CustomAggregate #CostPerBeneficiary      : 'Edm.Decimal',
  Aggregation.CustomAggregate #ServicesPerBeneficiary  : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalBeneficiaries      : 'Edm.Int32',
  Aggregation.CustomAggregate #AvgPatientAge           : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgRiskScore            : 'Edm.Decimal',
  Aggregation.CustomAggregate #DiabetesPct             : 'Edm.Decimal',
  Aggregation.CustomAggregate #HypertensionPct           : 'Edm.Decimal'
) {
  Year                  @Analytics.Dimension: true;
  NPI                   @Analytics.Dimension: true;
  ProviderName          @Analytics.Dimension: true;
  State                 @Analytics.Dimension: true;
  ProviderType          @Analytics.Dimension: true;
  EntityTypeCode        @Analytics.Dimension: true;
  EntityType            @Analytics.Dimension: true;
  EfficiencyCategory    @Analytics.Dimension: true;
  UtilizationCategory   @Analytics.Dimension: true;
  ProviderCount         @Analytics.Measure: true  @Aggregation.default: #SUM;
  CostPerBeneficiary    @Analytics.Measure: true  @Aggregation.default: #AVG;
  ServicesPerBeneficiary @Analytics.Measure: true @Aggregation.default: #MAX;
  TotalBeneficiaries    @Analytics.Measure: true  @Aggregation.default: #MAX;
  AvgPatientAge         @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgRiskScore          @Analytics.Measure: true  @Aggregation.default: #AVG;
  DiabetesPct           @Analytics.Measure: true  @Aggregation.default: #AVG  @Measures.Unit: '%';
  HypertensionPct       @Analytics.Measure: true  @Aggregation.default: #AVG  @Measures.Unit: '%';
};

// ── Task 2: SpecialtyRiskProfile (specialty-level classification) ──────────────
// The view is already aggregated to one row per Year + ProviderType; the
// aggregation metadata lets the ALP chart roll specialties up by their derived
// ComplexityTier (e.g. "how many specialties are High Complexity?").
annotate MedicareService.SpecialtyRiskProfile with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [Year, ProviderType, ComplexityTier],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalBeneficiaries},
      {Property: TotalPaid},
      {Property: AvgRiskScore},
      {Property: AvgCostPerBene},
      {Property: AvgHypertensionPct},
      {Property: AvgDiabetesPct},
      {Property: AvgCKDPct},
      {Property: AvgHeartFailurePct}
    ]
  }
);

annotate MedicareService.SpecialtyRiskProfile with @(
  Aggregation.CustomAggregate #ProviderCount      : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalBeneficiaries : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgRiskScore       : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgCostPerBene     : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgHypertensionPct : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgDiabetesPct     : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgCKDPct          : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgHeartFailurePct : 'Edm.Decimal'
) {
  Year               @Analytics.Dimension: true;
  ProviderType       @Analytics.Dimension: true;
  ComplexityTier     @Analytics.Dimension: true;
  ProviderCount      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalBeneficiaries @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPaid          @Analytics.Measure: true  @Aggregation.default: #SUM;
  // The Avg* measures are specialty-level means; SUM rollups across specialties
  // are not meaningful, so AVG is the safe default for the chart aggregation.
  AvgRiskScore       @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgCostPerBene     @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgHypertensionPct @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgDiabetesPct     @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgCKDPct          @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgHeartFailurePct @Analytics.Measure: true  @Aggregation.default: #AVG;
};

// ── Task 2.2: SpecialtyPeerDeviations (macro specialty peer profiling) ────────
annotate MedicareService.SpecialtyPeerDeviations with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'topcount', 'orderby', 'skip', 'top'],
    GroupableProperties    : [
      Year, Specialty, State, NPI, ProviderName
    ],
    AggregatableProperties : [
      {
        Property: CostPerPatient,
        SupportedAggregationMethods: ['max']
      },
      {Property: NationalAvgCost},
      {
        Property: CostTierDeviation,
        SupportedAggregationMethods: ['max']
      },
      {Property: ServicesPerPatient},
      {Property: NationalAvgServices},
      {Property: ServiceTierDeviation, SupportedAggregationMethods: ['max']},
    ]
  }
);

annotate MedicareService.SpecialtyPeerDeviations with @(
  Aggregation.CustomAggregate #CostPerPatient        : 'Edm.Decimal',
  Aggregation.CustomAggregate #NationalAvgCost        : 'Edm.Decimal',
  Aggregation.CustomAggregate #CostTierDeviation      : 'Edm.Decimal',
  Aggregation.CustomAggregate #ServicesPerPatient       : 'Edm.Int32',
  Aggregation.CustomAggregate #NationalAvgServices    : 'Edm.Decimal',
  Aggregation.CustomAggregate #ServiceTierDeviation   : 'Edm.Decimal'
) {
  Year                  @Analytics.Dimension: true;
  Specialty             @Analytics.Dimension: true;
  State                 @Analytics.Dimension: true;
  NPI                   @Analytics.Dimension: true;
  ProviderName          @Analytics.Dimension: true;
  CostPerPatient        @Analytics.Measure: true  @Aggregation.default: #MAX;
  NationalAvgCost       @Analytics.Measure: true  @Aggregation.default: #MIN;
  CostTierDeviation     @Analytics.Measure: true  @Aggregation.default: #MAX;
  ServicesPerPatient    @Analytics.Measure: true  @Aggregation.default: #AVG;
  NationalAvgServices   @Analytics.Measure: true  @Aggregation.default: #AVG;
  ServiceTierDeviation  @Analytics.Measure: true  @Aggregation.default: #MAX;
};

// ── Task 2.3: EntityTypeComparisons (Individual vs Organization macro) ─────────
annotate MedicareService.EntityTypeComparisons with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'orderby', 'skip', 'top'],
    GroupableProperties    : [Year, EntityType],
    AggregatableProperties : [
      {Property: TotalUniqueProviders},
      {Property: TotalPatientsServed},
      {Property: MacroAvgCostPerPatient},
      {Property: MacroAvgServicesPerPatient},
      {Property: HighCostOutlierCount},
      {Property: HighVolumeOutlierCount}
    ]
  }
);

annotate MedicareService.EntityTypeComparisons with @(
  Aggregation.CustomAggregate #TotalUniqueProviders         : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalPatientsServed          : 'Edm.Int32',
  Aggregation.CustomAggregate #MacroAvgCostPerPatient       : 'Edm.Decimal',
  Aggregation.CustomAggregate #MacroAvgServicesPerPatient     : 'Edm.Decimal',
  Aggregation.CustomAggregate #HighCostOutlierCount         : 'Edm.Int32',
  Aggregation.CustomAggregate #HighVolumeOutlierCount       : 'Edm.Int32'
) {
  Year                         @Analytics.Dimension: true;
  EntityType                   @Analytics.Dimension: true;
  TotalUniqueProviders         @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPatientsServed          @Analytics.Measure: true  @Aggregation.default: #SUM;
  MacroAvgCostPerPatient       @Analytics.Measure: true  @Aggregation.default: #AVG;
  MacroAvgServicesPerPatient   @Analytics.Measure: true  @Aggregation.default: #AVG;
  HighCostOutlierCount         @Analytics.Measure: true  @Aggregation.default: #SUM;
  HighVolumeOutlierCount       @Analytics.Measure: true  @Aggregation.default: #SUM;
};

// ── Task 2.2B: EntityTypeProviderProfiles (specialty drill-down by entity type) ─
annotate MedicareService.EntityTypeProviderProfiles with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'orderby', 'skip', 'top'],
    GroupableProperties    : [
      Year, State, ProviderType, NPI, ProviderName,
      EntityTypeCode, EntityType,
      EfficiencyCategory, UtilizationCategory
    ],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: CostPerBeneficiary},
      {
        Property: ServicesPerBeneficiary,
        SupportedAggregationMethods: ['max']
      },
      {Property: TotalBeneficiaries, SupportedAggregationMethods: ['max']},
      {Property: AvgPatientAge},
      {Property: AvgRiskScore},
      {Property: DiabetesPct},
      {Property: HypertensionPct}
    ]
  }
);

annotate MedicareService.EntityTypeProviderProfiles with @(
  Aggregation.CustomAggregate #ProviderCount           : 'Edm.Int32',
  Aggregation.CustomAggregate #CostPerBeneficiary      : 'Edm.Decimal',
  Aggregation.CustomAggregate #ServicesPerBeneficiary  : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalBeneficiaries      : 'Edm.Int32',
  Aggregation.CustomAggregate #AvgPatientAge           : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgRiskScore            : 'Edm.Decimal',
  Aggregation.CustomAggregate #DiabetesPct             : 'Edm.Decimal',
  Aggregation.CustomAggregate #HypertensionPct         : 'Edm.Decimal'
) {
  Year                   @Analytics.Dimension: true;
  NPI                    @Analytics.Dimension: true;
  ProviderName           @Analytics.Dimension: true;
  State                  @Analytics.Dimension: true;
  ProviderType           @Analytics.Dimension: true;
  EntityTypeCode         @Analytics.Dimension: true;
  EntityType             @Analytics.Dimension: true;
  EfficiencyCategory     @Analytics.Dimension: true;
  UtilizationCategory    @Analytics.Dimension: true;
  ProviderCount          @Analytics.Measure: true  @Aggregation.default: #SUM;
  CostPerBeneficiary     @Analytics.Measure: true  @Aggregation.default: #AVG;
  ServicesPerBeneficiary @Analytics.Measure: true  @Aggregation.default: #MAX;
  TotalBeneficiaries     @Analytics.Measure: true  @Aggregation.default: #MAX;
  AvgPatientAge          @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgRiskScore           @Analytics.Measure: true  @Aggregation.default: #AVG;
  DiabetesPct            @Analytics.Measure: true  @Aggregation.default: #AVG  @Measures.Unit: '%';
  HypertensionPct        @Analytics.Measure: true  @Aggregation.default: #AVG  @Measures.Unit: '%';
};

// ── Task 2.2B: EntityTypeCostInsight (higher-charging entity KPI source) ─────────
annotate MedicareService.EntityTypeCostInsight with {
  Year                 @Analytics.Dimension: true;
  HigherChargingEntity @Analytics.Dimension: true;
  HigherEntityAvgCost  @Analytics.Measure: true;
  LowerEntityAvgCost   @Analytics.Measure: true;
  CostPremiumPct       @Analytics.Measure: true  @Measures.Unit: '%';
};

// ── Task 3.3: CredentialDiscrepancies (credentials & charge write-offs) ────────
annotate MedicareService.CredentialDiscrepancies with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'orderby', 'skip', 'top'],
    GroupableProperties    : [Year, StandardizedCredential],
    AggregatableProperties : [
      {Property: TotalUniqueProviders},
      {Property: TotalPatientsServed},
      {Property: TotalSubmittedCharges},
      {Property: TotalAllowedCharges},
      {Property: TotalActualPayments},
      {Property: ChargePaddingAmt},
      {Property: PolicyShortfallAmt},
      {Property: PaidToAllowedRatePct},
      {Property: ChargePaddingRatePct}
    ]
  }
);

annotate MedicareService.CredentialDiscrepancies with @(
  Aggregation.CustomAggregate #TotalUniqueProviders   : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalPatientsServed    : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalSubmittedCharges  : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowedCharges    : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalActualPayments    : 'Edm.Decimal',
  Aggregation.CustomAggregate #ChargePaddingAmt       : 'Edm.Decimal',
  Aggregation.CustomAggregate #PolicyShortfallAmt     : 'Edm.Decimal',
  Aggregation.CustomAggregate #PaidToAllowedRatePct   : 'Edm.Decimal',
  Aggregation.CustomAggregate #ChargePaddingRatePct     : 'Edm.Decimal'
) {
  Year                     @Analytics.Dimension: true;
  StandardizedCredential   @Analytics.Dimension: true;
  TotalUniqueProviders     @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPatientsServed      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmittedCharges    @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalAllowedCharges      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalActualPayments      @Analytics.Measure: true  @Aggregation.default: #SUM;
  ChargePaddingAmt         @Analytics.Measure: true  @Aggregation.default: #SUM;
  PolicyShortfallAmt       @Analytics.Measure: true  @Aggregation.default: #SUM;
  PaidToAllowedRatePct     @Analytics.Measure: true  @Aggregation.default: #AVG;
  ChargePaddingRatePct     @Analytics.Measure: true  @Aggregation.default: #AVG;
};

// ── Task 3.2: PlaceOfServiceAnalysis (facility vs office payment disparity) ───
annotate MedicareService.PlaceOfServiceAnalysis with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'orderby', 'skip', 'top'],
    GroupableProperties    : [Year, Specialty, PlaceOfService],
    AggregatableProperties : [
      {Property: TotalUniqueProviders},
      {Property: TotalPatientsServed},
      {Property: TotalServicesRendered},
      {Property: TotalSubmittedCharges},
      {Property: TotalAllowedCharges},
      {Property: TotalActualPayments},
      {Property: AvgPaymentPerService},
      {Property: AvgSubmittedPerService}
    ]
  }
);

annotate MedicareService.PlaceOfServiceAnalysis with @(
  Aggregation.CustomAggregate #TotalUniqueProviders   : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalPatientsServed    : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalServicesRendered  : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalSubmittedCharges  : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowedCharges    : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalActualPayments    : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgPaymentPerService   : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgSubmittedPerService : 'Edm.Decimal'
) {
  Year                     @Analytics.Dimension: true;
  Specialty                @Analytics.Dimension: true;
  PlaceOfService           @Analytics.Dimension: true;
  TotalUniqueProviders     @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPatientsServed      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalServicesRendered    @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmittedCharges    @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalAllowedCharges      @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalActualPayments      @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  AvgPaymentPerService     @Analytics.Measure: true  @Aggregation.default: #AVG  @Measures.ISOCurrency: 'USD';
  AvgSubmittedPerService   @Analytics.Measure: true  @Aggregation.default: #AVG  @Measures.ISOCurrency: 'USD';
};

// ── Task 3.2: PlaceOfServiceProviderProfiles (provider drill-down by specialty) ─
annotate MedicareService.PlaceOfServiceProviderProfiles with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'orderby', 'skip', 'top'],
    GroupableProperties    : [
      Year, Specialty, PlaceOfService, NPI, ProviderName, State
    ],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalPatientsServed},
      {Property: TotalServicesRendered},
      {Property: TotalSubmittedCharges},
      {Property: TotalAllowedCharges},
      {Property: TotalActualPayments},
      {
        Property: AvgPaymentPerService,
        SupportedAggregationMethods: ['avg']
      },
      {Property: AvgSubmittedPerService}
    ]
  }
);

annotate MedicareService.PlaceOfServiceProviderProfiles with @(
  Aggregation.CustomAggregate #ProviderCount          : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalPatientsServed    : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalServicesRendered  : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalSubmittedCharges  : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowedCharges    : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalActualPayments    : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgPaymentPerService   : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgSubmittedPerService : 'Edm.Decimal'
) {
  Year                     @Analytics.Dimension: true;
  Specialty                @Analytics.Dimension: true;
  PlaceOfService           @Analytics.Dimension: true;
  NPI                      @Analytics.Dimension: true;
  ProviderName             @Analytics.Dimension: true;
  State                    @Analytics.Dimension: true;
  ProviderCount            @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPatientsServed      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalServicesRendered    @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmittedCharges    @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalAllowedCharges      @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  TotalActualPayments      @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
  AvgPaymentPerService     @Analytics.Measure: true  @Aggregation.default: #AVG  @Measures.ISOCurrency: 'USD';
  AvgSubmittedPerService   @Analytics.Measure: true  @Aggregation.default: #AVG  @Measures.ISOCurrency: 'USD';
};

// ── Task 3.1: RiskCostVolumeDynamics (specialty risk-cost frontier) ───────────
annotate MedicareService.RiskCostVolumeDynamics with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'orderby', 'skip', 'top'],
    GroupableProperties    : [Year, Specialty],
    AggregatableProperties : [
      {Property: TotalUniqueProviders},
      {Property: PatientRiskScore},
      {Property: CostPerPatient},
      {Property: TotalPatientsServed},
      {Property: TotalActualPayments}
    ]
  }
);

annotate MedicareService.RiskCostVolumeDynamics with @(
  Aggregation.CustomAggregate #TotalUniqueProviders : 'Edm.Int32',
  Aggregation.CustomAggregate #PatientRiskScore     : 'Edm.Decimal',
  Aggregation.CustomAggregate #CostPerPatient       : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPatientsServed  : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalActualPayments  : 'Edm.Decimal'
) {
  Year                 @Analytics.Dimension: true;
  Specialty            @Analytics.Dimension: true;
  TotalUniqueProviders @Analytics.Measure: true  @Aggregation.default: #SUM;
  PatientRiskScore     @Analytics.Measure: true  @Aggregation.default: #AVG;
  CostPerPatient       @Analytics.Measure: true  @Aggregation.default: #AVG;
  TotalPatientsServed  @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalActualPayments  @Analytics.Measure: true  @Aggregation.default: #SUM  @Measures.ISOCurrency: 'USD';
};

// ── Task 4: Joule capability metadata ─────────────────────────────────────────
annotate MedicareService with @Core.Description: 'Medicare audit OData service with analytical views (Tasks 1–3) and autonomous agent actions for Joule.';

annotate MedicareService.investigateAnomalies with @(
  Core.Description     : 'Run a multi-slice Medicare anomaly investigation and return a Markdown compliance report.',
  Core.LongDescription : 'Queries RiskCostVolumeDynamics, PlaceOfServiceAnalysis, CredentialDiscrepancies, ProviderCostEfficiency, and CostAnalysisV2 for the requested year. Optional state, specialty, and NPI filters narrow the investigation scope.'
);

annotate MedicareService.getRegionalBillingOutliers with @(
  Core.Description     : 'Return top billing hotspots for a US state and year.',
  Core.LongDescription : 'Joule tool mapping to CostAnalysisV2 — surfaces highest TotalPaid buckets by state and provider type.'
);

annotate MedicareService.getProviderClaimDetails with @(
  Core.Description     : 'Return provider classification metrics and top HCPCS service lines for an NPI.',
  Core.LongDescription : 'Joule tool mapping to ProviderCostEfficiency and ServiceDetails for granular claim drill-down.'
);

annotate MedicareService.getSpecialtyPeerOutliers with @(
  Core.Description     : 'Return providers with the largest cost deviation vs national specialty peers.',
  Core.LongDescription : 'Joule tool mapping to SpecialtyPeerDeviations — surfaces CostTierDeviation outliers.'
);

annotate MedicareService.listAuditYears with @(
  Core.Description     : 'List CMS performance years available in the audit dataset.',
  Core.LongDescription : 'Discovery action for Joule to resolve which year parameter to pass into other agent tools.'
);

annotate MedicareService.AgentScratchpad with @(
  Core.Description : 'Step-by-step reasoning log written by the autonomous audit agent during Joule investigations.'
);

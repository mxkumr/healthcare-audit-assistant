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
  entity OrganizationClassification as projection on medicare.OrganizationClassification;
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

// ── BehavioralHealthRiskProfile (BH burden vs. risk score) ────────────────────
annotate MedicareService.BehavioralHealthRiskProfile with @(
  Common.Label: 'Behavioral Health Risk Profile',
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [
      {Property: State},
      {Property: ProviderType},
      {Property: BHBurdenGroup}
    ],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: AvgRiskScore},
      {Property: TotalPaid},
      {Property: TotalBeneficiaries},
      {Property: PaidPerBeneficiary}
    ]
  },
  Analytics.AggregatedProperties: [
    { Name: 'AvgRiskScoreAvg',   AggregationMethod: 'avg', AggregatableProperty: AvgRiskScore },
    { Name: 'ProviderCountSum',  AggregationMethod: 'sum', AggregatableProperty: ProviderCount }
  ],
  UI.SelectionFields: [State, ProviderType, BHBurdenGroup],
  UI.LineItem: [
    {Value: State},
    {Value: ProviderType},
    {Value: BHBurdenGroup},
    {Value: ProviderCount},
    {Value: AvgRiskScore},
    {Value: PaidPerBeneficiary}
  ],
  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Average Risk Score by State',
    ChartType : #Bar,
    Dimensions: [State],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: State, Role: #Category }
    ],
    Measures: [AvgRiskScore],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: AvgRiskScore, Role: #Axis1 }
    ]
  },
  UI.PresentationVariant: {
    GroupBy       : [State],
    SortOrder     : [{ Property: State, Descending: false }],
    Total         : [AvgRiskScore],
    Visualizations: ['@UI.Chart', '@UI.LineItem']
  }
);
annotate MedicareService.BehavioralHealthRiskProfile with @(
  Aggregation.CustomAggregate #ProviderCount      : 'Edm.Int32',
  Aggregation.CustomAggregate #AvgRiskScore       : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalBeneficiaries : 'Edm.Int32',
  Aggregation.CustomAggregate #PaidPerBeneficiary : 'Edm.Decimal'
) {
  State               @Analytics.Dimension: true;
  ProviderType         @Analytics.Dimension: true;
  BHBurdenGroup        @Analytics.Dimension: true;
  ProviderCount        @Analytics.Measure: true @Aggregation.default: #SUM;
  AvgRiskScore         @Analytics.Measure: true @Aggregation.default: #AVG;
  TotalPaid            @Analytics.Measure: true @Aggregation.default: #SUM;
  TotalBeneficiaries   @Analytics.Measure: true @Aggregation.default: #SUM;
  PaidPerBeneficiary   @Analytics.Measure: true @Aggregation.default: #AVG;
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

// ── Task 2.1: ProviderCostEfficiency (2-Axis Risk Matrix) ─────────────────────
annotate MedicareService.ProviderCostEfficiency with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter', 'topcount', 'orderby', 'skip', 'top'],
    GroupableProperties    : [
      Year, State, ProviderType, NPI, ProviderName,
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

// ── Task 2: OrganizationClassification (Individual vs Organization) ────────────
// Aggregation metadata lets the ALP chart compare segments (e.g. cost per
// beneficiary for Individual vs Organization) and roll up by Year / State.
annotate MedicareService.OrganizationClassification with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [Year, State, EntityType],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalBeneficiaries},
      {Property: TotalServices},
      {Property: TotalSubmitted},
      {Property: TotalAllowed},
      {Property: TotalPaid},
      {Property: AvgRiskScore},
      {Property: CostPerBene},
      {Property: ServicesPerBene}
    ]
  }
);

annotate MedicareService.OrganizationClassification with @(
  Aggregation.CustomAggregate #ProviderCount      : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalBeneficiaries : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalServices      : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalSubmitted     : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowed       : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgRiskScore       : 'Edm.Decimal',
  Aggregation.CustomAggregate #CostPerBene        : 'Edm.Decimal',
  Aggregation.CustomAggregate #ServicesPerBene    : 'Edm.Decimal'
) {
  Year               @Analytics.Dimension: true;
  State              @Analytics.Dimension: true;
  EntityType         @Analytics.Dimension: true;
  ProviderCount      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalBeneficiaries @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalServices      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmitted     @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalAllowed       @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPaid          @Analytics.Measure: true  @Aggregation.default: #SUM;
  // Ratios + risk mean: AVG rollup across states is an approximation; exact
  // per-segment figures are shown at the row grain (Year + State + EntityType).
  AvgRiskScore       @Analytics.Measure: true  @Aggregation.default: #AVG;
  CostPerBene        @Analytics.Measure: true  @Aggregation.default: #AVG;
  ServicesPerBene    @Analytics.Measure: true  @Aggregation.default: #AVG;
};

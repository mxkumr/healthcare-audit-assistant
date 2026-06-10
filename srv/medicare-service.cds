using medicare from '../db/schema';

service MedicareService @(path:'/medicare') {

  entity ProviderSummary  as projection on medicare.ProviderSummary;
  entity ServiceDetails   as projection on medicare.ServiceDetails;
  entity GeoReference     as projection on medicare.GeoReference;

  @readonly
  @cds.redirection.target: false
  entity CostByStateProviderType  as projection on medicare.CostByStateProviderType;

  @readonly
  @cds.redirection.target: false
  entity RuralUrbanDistribution   as projection on medicare.RuralUrbanDistribution;

  @readonly
  @cds.redirection.target: false
  entity RiskScoreDistribution    as projection on medicare.RiskScoreDistribution;

  @readonly
  @cds.redirection.target: false
  entity ProviderCostEfficiency as projection on medicare.ProviderCostEfficiency;
}

// ── Aggregation (data-shaping) annotations for the analytical query ────────────
// NOTE: UI annotations (LineItem, Chart, PresentationVariant, KPIs, visual
// filters, facets) live in the app layer at app/cost-analysis/annotations.cds.
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

// ── Task 2: ProviderCostEfficiency (classification) ───────────────────────────
// Aggregation metadata lets the ALP chart roll providers up by their
// classification dimensions (Efficiency / Risk / Utilization / Specialty).
annotate MedicareService.ProviderCostEfficiency with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [
      Year, State, ProviderType,
      EfficiencyCategory, RiskCategory, UtilizationCategory
    ],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalPaid},
      {Property: TotalSubmitted},
      {Property: TotalAllowed},
      {Property: TotalBeneficiaries},
      {Property: CostPerBeneficiary},
      {Property: AvgRiskScore}
    ]
  }
);

annotate MedicareService.ProviderCostEfficiency with @(
  Aggregation.CustomAggregate #ProviderCount      : 'Edm.Int32',
  Aggregation.CustomAggregate #TotalPaid          : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalSubmitted     : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalAllowed       : 'Edm.Decimal',
  Aggregation.CustomAggregate #TotalBeneficiaries : 'Edm.Int32',
  Aggregation.CustomAggregate #CostPerBeneficiary : 'Edm.Decimal',
  Aggregation.CustomAggregate #AvgRiskScore       : 'Edm.Decimal'
) {
  Year                @Analytics.Dimension: true;
  State               @Analytics.Dimension: true;
  ProviderType        @Analytics.Dimension: true;
  EfficiencyCategory  @Analytics.Dimension: true;
  RiskCategory        @Analytics.Dimension: true;
  UtilizationCategory @Analytics.Dimension: true;
  ProviderCount       @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalPaid           @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalSubmitted      @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalAllowed        @Analytics.Measure: true  @Aggregation.default: #SUM;
  TotalBeneficiaries  @Analytics.Measure: true  @Aggregation.default: #SUM;
  // CostPerBeneficiary is a ratio -> AVG across a group is unweighted; the exact
  // per-provider value is visible in the (non-aggregated) table rows.
  CostPerBeneficiary  @Analytics.Measure: true  @Aggregation.default: #AVG;
  AvgRiskScore        @Analytics.Measure: true  @Aggregation.default: #AVG;
};

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

// ── Aggregation annotations for Analytical List Page ──────────────────────────

annotate MedicareService.CostByStateProviderType with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [
      {Property: Year},
      {Property: State},
      {Property: ProviderType}
    ],
    AggregatableProperties : [
      {Property: ProviderCount},
      {Property: TotalSubmitted},
      {Property: TotalAllowed},
      {Property: TotalPaid},
      {Property: TotalBeneficiaries},
      {Property: AvgRiskScore}
    ]
  },
  Analytics.AggregatedProperties: [
    { Name: 'TotalPaidSum',          AggregationMethod: 'sum', AggregatableProperty: TotalPaid },
    { Name: 'TotalSubmittedSum',     AggregationMethod: 'sum', AggregatableProperty: TotalSubmitted },
    { Name: 'TotalAllowedSum',       AggregationMethod: 'sum', AggregatableProperty: TotalAllowed },
    { Name: 'TotalBeneficiariesSum', AggregationMethod: 'sum', AggregatableProperty: TotalBeneficiaries },
    { Name: 'ProviderCountSum',      AggregationMethod: 'sum', AggregatableProperty: ProviderCount },
    { Name: 'AvgRiskScoreAvg',       AggregationMethod: 'avg', AggregatableProperty: AvgRiskScore }
  ],
  UI.LineItem: [
    {Value: Year},
    {Value: State},
    {Value: ProviderType},
    {Value: ProviderCount},
    {Value: TotalSubmitted},
    {Value: TotalAllowed},
    {Value: TotalPaid},
    {Value: TotalBeneficiaries},
    {Value: AvgRiskScore}
  ],
  UI.Chart: {
    ChartType : #Bar,
    Dimensions: [{Dimension: State}],
    Measures  : [{Measure: TotalPaid}]
  },
  UI.PresentationVariant: {
    GroupBy       : [State, ProviderType],
    Total         : [TotalPaid, TotalSubmitted, ProviderCount],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);

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

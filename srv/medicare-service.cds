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
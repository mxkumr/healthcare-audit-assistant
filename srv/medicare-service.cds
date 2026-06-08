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

// ── Analytical (aggregation) capabilities ─────────────────────────────────────
// Service layer declares ONLY the analytical capabilities (Aggregation /
// Analytics) of the views. All UI presentation annotations (SelectionFields,
// LineItem, Chart, PresentationVariant) live in the app layer at
// app/cost-analysis/annotations.cds so each annotation is defined exactly once.

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
  ]
);

annotate MedicareService.RuralUrbanDistribution with @(
  Aggregation.ApplySupported: {
    Transformations        : ['aggregate', 'groupby', 'filter'],
    GroupableProperties    : [
      {Property: Year},
      {Property: State},
      {Property: RuralInd},
      {Property: Locality}
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
  ]
);
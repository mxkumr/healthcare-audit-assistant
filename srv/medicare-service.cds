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
  ProviderCount      @Aggregation.default: #SUM;
  TotalSubmitted     @Aggregation.default: #SUM;
  TotalAllowed       @Aggregation.default: #SUM;
  TotalPaid          @Aggregation.default: #SUM;
  TotalBeneficiaries @Aggregation.default: #SUM;
  AvgRiskScore       @Aggregation.default: #AVG;
};
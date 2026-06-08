using medicare from '../db/schema';
using { MedicareService } from './medicare-service';

/**
 * Task 1 - Data Visualization (Aggregation)
 *
 * Two flavours are provided:
 *
 *  A) ProviderAnalytics - a FLAT (row-level) analytical entity annotated for
 *     OData aggregation (@Aggregation.ApplySupported). This is the entity to
 *     pick in the Fiori "Analytical List Page" wizard: Fiori itself performs
 *     the grouping/aggregation via $apply, so users can freely slice cost
 *     measures by State, Provider Type, rural/urban Area and risk band.
 *
 *  B) Pre-aggregated convenience views (CostByState, CostByProviderType,
 *     CostByArea, RiskDistribution) - ready-made GROUP BY results that are
 *     handy for simple List-Report charts and for the Task 4 AI agent tools.
 */

// ===========================================================================
//  Helper (enriched, row-level) views
// ===========================================================================

// One row per provider/year, enriched with area type (rural/urban) and a
// beneficiary risk-score band. Used by both the analytical entity and the
// pre-aggregated convenience views below.
define view T1ProviderEnriched as
  select from medicare.ProviderSummary {
    Year,
    Rndrng_NPI                              as NPI,
    Rndrng_Prvdr_Last_Org_Name              as ProviderName,
    Rndrng_Prvdr_Type                       as ProviderType,
    Rndrng_Prvdr_Crdntls                    as Credentials,
    Rndrng_Prvdr_State_Abrvtn               as State,
    Rndrng_Prvdr_City                       as City,
    Rndrng_Prvdr_Zip5                       as ZipCode,
    geo.RuralInd                            as RuralInd,
    case
      when geo.RuralInd = 'R' then 'Rural'
      when geo.RuralInd = 'B' then 'Super Rural'
      else 'Urban'
    end                                     as AreaType : String,
    case
      when Bene_Avg_Risk_Scre is null     then '5. Unknown'
      when Bene_Avg_Risk_Scre <  1.0      then '1. Low (<1.0)'
      when Bene_Avg_Risk_Scre <  1.5      then '2. Moderate (1.0-1.5)'
      when Bene_Avg_Risk_Scre <  2.0      then '3. High (1.5-2.0)'
      else                                     '4. Very High (2.0+)'
    end                                     as RiskBand : String,
    Tot_Sbmtd_Chrg                          as SubmittedCharges,
    Tot_Mdcr_Alowd_Amt                      as AllowedAmount,
    Tot_Mdcr_Pymt_Amt                       as PaidAmount,
    Tot_Benes                               as Beneficiaries,
    Tot_Srvcs                               as Services,
    Bene_Avg_Risk_Scre                      as RiskScore
  };

// ===========================================================================
//  Public entities exposed on the OData service
// ===========================================================================
extend service MedicareService with {

  // (A) FLAT analytical entity -> select THIS one in the ALP wizard.
  @readonly
  entity ProviderAnalytics as projection on T1ProviderEnriched;

  // (B) Pre-aggregated convenience views ------------------------------------

  @readonly
  entity CostByState as
    select from T1ProviderEnriched {
      key Year,
      key State,
      count(*)                              as ProviderCount       : Integer,
      sum(SubmittedCharges)                 as SubmittedCharges    : Decimal,
      sum(AllowedAmount)                    as AllowedAmount       : Decimal,
      sum(PaidAmount)                       as PaidAmount          : Decimal,
      sum(Beneficiaries)                    as Beneficiaries       : Integer,
      sum(Services)                         as Services            : Decimal,
      avg(RiskScore)                        as AvgRiskScore        : Decimal,
      case when sum(SubmittedCharges) > 0
           then sum(PaidAmount) / sum(SubmittedCharges)
           else 0 end                       as PaymentToChargeRatio : Decimal
    }
    where State is not null
    group by Year, State;

  @readonly
  entity CostByProviderType as
    select from T1ProviderEnriched {
      key Year,
      key ProviderType,
      count(*)                              as ProviderCount       : Integer,
      sum(SubmittedCharges)                 as SubmittedCharges    : Decimal,
      sum(AllowedAmount)                    as AllowedAmount       : Decimal,
      sum(PaidAmount)                       as PaidAmount          : Decimal,
      sum(Beneficiaries)                    as Beneficiaries       : Integer,
      avg(RiskScore)                        as AvgRiskScore        : Decimal,
      case when sum(SubmittedCharges) > 0
           then sum(PaidAmount) / sum(SubmittedCharges)
           else 0 end                       as PaymentToChargeRatio : Decimal
    }
    where ProviderType is not null
    group by Year, ProviderType;

  @readonly
  entity CostByArea as
    select from T1ProviderEnriched {
      key Year,
      key AreaType,
      count(*)                              as ProviderCount       : Integer,
      sum(SubmittedCharges)                 as SubmittedCharges    : Decimal,
      sum(AllowedAmount)                    as AllowedAmount       : Decimal,
      sum(PaidAmount)                       as PaidAmount          : Decimal,
      sum(Beneficiaries)                    as Beneficiaries       : Integer,
      avg(RiskScore)                        as AvgRiskScore        : Decimal
    }
    group by Year, AreaType;

  @readonly
  entity RiskDistribution as
    select from T1ProviderEnriched {
      key Year,
      key RiskBand,
      count(*)                              as ProviderCount       : Integer,
      avg(RiskScore)                        as AvgRiskScore        : Decimal,
      sum(PaidAmount)                       as PaidAmount          : Decimal
    }
    group by Year, RiskBand;
}

// ===========================================================================
//  Analytical annotations for ProviderAnalytics (enable Fiori ALP)
// ===========================================================================
annotate MedicareService.ProviderAnalytics with @(
  Aggregation.ApplySupported : {
    Transformations        : [
      'aggregate', 'topcount', 'bottomcount', 'identity',
      'concat', 'groupby', 'filter', 'search'
    ],
    Rollup                 : #None,
    PropertyRestrictions   : true,
    GroupableProperties    : [
      Year, State, ProviderType, Credentials, AreaType, RiskBand, City, ZipCode, NPI, ProviderName
    ],
    AggregatableProperties : [
      { Property: SubmittedCharges },
      { Property: AllowedAmount },
      { Property: PaidAmount },
      { Property: Beneficiaries },
      { Property: Services },
      { Property: RiskScore }
    ]
  },
  Analytics.AggregatedProperty #totalSubmitted : {
    Name                 : 'totalSubmitted',
    AggregationMethod    : 'sum',
    AggregatableProperty : SubmittedCharges,
    ![@Common.Label]     : 'Total Submitted Charges'
  },
  Analytics.AggregatedProperty #totalAllowed : {
    Name                 : 'totalAllowed',
    AggregationMethod    : 'sum',
    AggregatableProperty : AllowedAmount,
    ![@Common.Label]     : 'Total Allowed Amount'
  },
  Analytics.AggregatedProperty #totalPaid : {
    Name                 : 'totalPaid',
    AggregationMethod    : 'sum',
    AggregatableProperty : PaidAmount,
    ![@Common.Label]     : 'Total Paid Amount'
  },
  Analytics.AggregatedProperty #totalBenes : {
    Name                 : 'totalBenes',
    AggregationMethod    : 'sum',
    AggregatableProperty : Beneficiaries,
    ![@Common.Label]     : 'Total Beneficiaries'
  },
  Analytics.AggregatedProperty #avgRisk : {
    Name                 : 'avgRisk',
    AggregationMethod    : 'average',
    AggregatableProperty : RiskScore,
    ![@Common.Label]     : 'Average Risk Score'
  }
);

annotate MedicareService.ProviderAnalytics with {
  SubmittedCharges @Analytics.Measure @Aggregation.default : #SUM;
  AllowedAmount    @Analytics.Measure @Aggregation.default : #SUM;
  PaidAmount       @Analytics.Measure @Aggregation.default : #SUM;
  Beneficiaries    @Analytics.Measure @Aggregation.default : #SUM;
  Services         @Analytics.Measure @Aggregation.default : #SUM;
  RiskScore        @Analytics.Measure @Aggregation.default : #AVG;
  Year             @Analytics.Dimension;
  State            @Analytics.Dimension;
  ProviderType     @Analytics.Dimension;
  Credentials      @Analytics.Dimension;
  AreaType         @Analytics.Dimension;
  RiskBand         @Analytics.Dimension;
};

// ---------------------------------------------------------------------------
//  Default UI (chart + table + filters) so the generated ALP is not empty
// ---------------------------------------------------------------------------
annotate MedicareService.ProviderAnalytics with @(
  UI.SelectionFields : [ Year, State, ProviderType, AreaType, RiskBand ],
  UI.Chart           : {
    $Type           : 'UI.ChartDefinitionType',
    Title           : 'Medicare Cost Analysis',
    ChartType       : #Column,
    Dimensions      : [ State ],
    DynamicMeasures : [ '@Analytics.AggregatedProperty#totalPaid' ],
    MeasureAttributes : [{
      $Type          : 'UI.ChartMeasureAttributeType',
      DynamicMeasure : '@Analytics.AggregatedProperty#totalPaid',
      Role           : #Axis1
    }],
    DimensionAttributes : [{
      $Type     : 'UI.ChartDimensionAttributeType',
      Dimension : State,
      Role      : #Category
    }]
  },
  UI.PresentationVariant : {
    Visualizations : [ '@UI.Chart', '@UI.LineItem' ],
    SortOrder      : [{ Property: PaidAmount, Descending: true }]
  },
  UI.LineItem : [
    { Value: Year },
    { Value: State },
    { Value: ProviderType },
    { Value: AreaType },
    { Value: RiskBand },
    { Value: PaidAmount },
    { Value: SubmittedCharges },
    { Value: AllowedAmount },
    { Value: Beneficiaries }
  ]
);

annotate MedicareService.ProviderAnalytics with {
  Year             @title: 'Year';
  State            @title: 'State';
  ProviderType     @title: 'Provider Type';
  Credentials      @title: 'Credentials';
  AreaType         @title: 'Area (Rural/Urban)';
  RiskBand         @title: 'Risk Band';
  City             @title: 'City';
  ZipCode          @title: 'ZIP Code';
  ProviderName     @title: 'Provider Name';
  SubmittedCharges @title: 'Submitted Charges';
  AllowedAmount    @title: 'Allowed Amount';
  PaidAmount       @title: 'Paid Amount';
  Beneficiaries    @title: 'Beneficiaries';
  Services         @title: 'Services';
  RiskScore        @title: 'Avg Risk Score';
};

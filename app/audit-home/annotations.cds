using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// Audit Home — OVP preview charts + click-to-navigate (UI.Identification URLs)
// Analytical OVP cards: click chart OR header link → opens target ALP app
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.CostAnalysisV2 with @(
  UI.Identification #OVPNavCost: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 1.1 State Cost Analysis →',
    Value: '/commedicare11costanalysis/index.html'
  }]
);

annotate service.RuralUrbanDistribution with @(

  UI.Identification #OVPNavRural: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 1.2 Rural vs Urban →',
    Value: '/commedicare12ruralanalysis/index.html'
  }],

  UI.Chart #RuralUrbanOVP: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Rural vs Urban Spend',
    ChartType : #Donut,
    Dimensions: [RuralUrban],
    Measures  : [TotalPaid],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: RuralUrban,
        Role     : #Category
      }
    ],
    MeasureAttributes: [
      {
        $Type   : 'UI.ChartMeasureAttributeType',
        Measure : TotalPaid,
        Role    : #Axis1
      }
    ]
  },

  UI.PresentationVariant #RuralUrbanOVP: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [RuralUrban],
    SortOrder     : [{ Property: TotalPaid, Descending: true }],
    Visualizations: ['@UI.Chart#RuralUrbanOVP']
  }
);

annotate service.BehavioralHealthRiskProfile with @(
  UI.Identification #OVPNavBehavioral: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 1.3 Behavioral Health Risk →',
    Value: '/commedicare13behavioralhelathrisk/index.html'
  }]
);

annotate service.ProviderCostEfficiency with @(
  UI.Identification #OVPNavEfficiency: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 2.1 Provider Classification →',
    Value: '/commedicare21providerclassification/index.html'
  }]
);

annotate service.SpecialtyPeerDeviations with @(
  UI.Identification #OVPNavSpecialty: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 2.2a Specialty Profiling →',
    Value: '/commedicare22aspecialtyprofiling/index.html'
  }]
);

annotate service.EntityTypeComparisons with @(
  UI.Identification #OVPNavEntityType: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 2.2b Entity Type Comparison →',
    Value: '/commedicare22borganizationprofiling/index.html'
  }]
);

annotate service.RiskCostVolumeDynamics with @(
  UI.Identification #OVPNavRiskDynamics: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 3.1 Risk-Cost Dynamics →',
    Value: '/commedicare31riskdynamics/index.html'
  }]
);

// Card 3.2 — chart must live on PlaceOfServiceAnalysis (OVP entitySet), not ProviderProfiles
annotate service.PlaceOfServiceAnalysis with @(

  UI.Identification #OVPNavPlaceOfService: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 3.2 Place of Service →',
    Value: '/commedicare32placeofservice/index.html'
  }],

  UI.DataPoint #PosAvgPaymentFmt: {
    $Type      : 'UI.DataPointType',
    Value      : AvgPaymentPerService,
    Title      : 'Avg Payment per Service',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.Chart #PlaceOfServiceChart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Facility vs Office: Avg Payment per Service',
    ChartType : #ColumnStacked,
    Dimensions: [
      Specialty,
      PlaceOfService
    ],
    Measures  : [AvgPaymentPerService],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: Specialty,
        Role     : #Category
      },
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: PlaceOfService,
        Role     : #Series
      }
    ],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : AvgPaymentPerService,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#PosAvgPaymentFmt]
      }
    ]
  },

  UI.PresentationVariant #PlaceOfServiceChart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [Specialty, PlaceOfService],
    SortOrder     : [{ Property: AvgPaymentPerService, Descending: true }],
    Visualizations: ['@UI.Chart#PlaceOfServiceChart']
  },

  UI.SelectionVariant #PlaceOfServiceOVPYear: {
    $Type        : 'UI.SelectionVariantType',
    Text         : 'Year 2022',
    SelectOptions: [{
      PropertyName: Year,
      Ranges      : [{ Sign: #I, Option: #EQ, Low: '2022' }]
    }]
  }
);

annotate service.CredentialDiscrepancies with @(
  UI.Identification #OVPNavCredentialGaps: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open 3.3 Credential Discrepancies →',
    Value: '/commedicare33credentialdiscrepancies/index.html'
  }]
);

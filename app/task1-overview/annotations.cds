using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// Task 1 Overview — OVP preview charts + header navigation to child ALP apps
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.CostAnalysisV2 with @(
  UI.Identification #OVPNavCost: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Cost Analysis (1.1)',
    Value: '/com.medicare.11costanalysis/index.html'
  }]
);

annotate service.RuralUrbanDistribution with @(

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
  },

  UI.Identification #OVPNavRural: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Rural Analysis (1.2)',
    Value: '/com.medicare.12ruralanalysis/index.html'
  }]
);

using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// Task 2 Overview — OVP preview charts + header navigation to child ALP apps
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.ProviderCostEfficiency with @(

  UI.Chart #EfficiencyOVP: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Providers per Efficiency Class',
    ChartType : #Donut,
    Dimensions: [EfficiencyCategory],
    Measures  : [ProviderCount],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: EfficiencyCategory,
        Role     : #Category
      }
    ],
    MeasureAttributes: [
      {
        $Type   : 'UI.ChartMeasureAttributeType',
        Measure : ProviderCount,
        Role    : #Axis1
      }
    ]
  },

  UI.PresentationVariant #EfficiencyOVP: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [EfficiencyCategory],
    SortOrder     : [{ Property: ProviderCount, Descending: true }],
    Visualizations: ['@UI.Chart#EfficiencyOVP']
  }
);

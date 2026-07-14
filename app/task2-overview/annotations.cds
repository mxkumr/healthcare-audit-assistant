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
  },

  UI.Identification #OVPNavEfficiency: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Provider Classification (2.1)',
    Value: '/com.medicare.21providerclassification/index.html'
  }]
);

annotate service.SpecialtyPeerDeviations with @(
  UI.Identification #OVPNavSpecialty: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Specialty Profiling (2.2a)',
    Value: '/com.medicare.22aspecialtyprofiling/index.html'
  }]
);

annotate service.EntityTypeComparisons with @(
  UI.Identification #OVPNavEntityType: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Entity Type Comparison (2.2b)',
    Value: '/com.medicare.22borganizationprofiling/index.html'
  }]
);

using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// Audit Home — single OVP dashboard (9 cards → direct ALP navigation)
// Chart annotations live in task-overview / ALP annotation files (merged via services.cds).
// Navigation links (UI.Identification) are defined alongside each entity in those files.
// ═══════════════════════════════════════════════════════════════════════════════

// Rural vs Urban preview chart used by card 1.2 (also referenced from task1-overview)
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
  }
);

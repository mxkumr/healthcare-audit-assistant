using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// EntityTypeProviderProfiles — Task 2.2B Entity Type Profiling ALP
// Chart (top): column — macro avg cost per patient by entity class
// Table (bottom): specialty groups (expand to provider name drill-down)
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.EntityTypeProviderProfiles with @(

  UI.SelectionFields: [Year, EntityType, ProviderType],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Provider Record',
    TypeNamePlural: 'Provider Records',
    Title         : { $Type: 'UI.DataField', Value: ProviderName },
    Description   : { $Type: 'UI.DataField', Value: ProviderType }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LAYER — column chart (macro cost intensity by entity class)
  // EntityType → #Category | CostPerBeneficiary → #Axis1
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #MacroCostFmt: {
    $Type      : 'UI.DataPointType',
    Value      : CostPerBeneficiary,
    Title      : 'Avg Cost per Patient',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.Chart #MacroCostIntensity: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Macro Cost Intensity — Corporate Networks vs. Individual Clinicians',
    ChartType : #Column,
    Dimensions: [EntityType],
    Measures  : [CostPerBeneficiary],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: EntityType,
        Role     : #Category
      }
    ],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : CostPerBeneficiary,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#MacroCostFmt]
      }
    ]
  },

  UI.PresentationVariant #EntityCostChart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [EntityType],
    SortOrder     : [{ Property: CostPerBeneficiary, Descending: true }],
    Visualizations: ['@UI.Chart#MacroCostIntensity']
  },

  UI.SelectionVariant #DefaultYear: {
    $Type        : 'UI.SelectionVariantType',
    Text         : 'Latest data year',
    SelectOptions: [
      {
        PropertyName: Year,
        Ranges      : [{ Sign: #I, Option: #EQ, Low: '2022' }]
      }
    ]
  },

  UI.SelectionPresentationVariant #ALPDashboard: {
    $Type              : 'UI.SelectionPresentationVariantType',
    Text               : 'Entity Type Comparison Dashboard',
    SelectionVariant   : ![@UI.SelectionVariant#DefaultYear],
    PresentationVariant: ![@UI.PresentationVariant#EntityCostChart]
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM LAYER — specialty group rows; expand to see provider names
  // ═══════════════════════════════════════════════════════════════════════════
  UI.LineItem: [
    { $Type: 'UI.DataField', Value: ProviderType,           Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: ProviderName,           Label: 'Provider Name' },
    { $Type: 'UI.DataField', Value: EntityType,             Label: 'Entity Type' },
    { $Type: 'UI.DataField', Value: NPI,                    Label: 'NPI' },
    { $Type: 'UI.DataField', Value: CostPerBeneficiary,     Label: 'Cost per Patient' },
    { $Type: 'UI.DataField', Value: ServicesPerBeneficiary, Label: 'Services per Patient' },
    { $Type: 'UI.DataField', Value: EfficiencyCategory,     Label: 'Cost Classification' },
    { $Type: 'UI.DataField', Value: UtilizationCategory,    Label: 'Utilization Profile' }
  ],

  UI.PresentationVariant #EntityComparisonTable: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [ProviderType],
    SortOrder     : [
      { Property: CostPerBeneficiary, Descending: true },
      { Property: ProviderName,       Descending: false },
      { Property: NPI,                  Descending: false }
    ],
    Visualizations: ['@UI.LineItem']
  }
);

// ── Element annotations: labels, tooltips, descriptions, positions ───────────
annotate service.EntityTypeProviderProfiles with {
  Year @(
    Common.Label     : 'Year',
    Common.QuickInfo : 'Calendar year of the provider record.',
    Core.Description : 'Filter to a single year before comparing specialties or entity types.'
  );

  ProviderType @(
    Common.Label     : 'Specialty',
    Common.QuickInfo : 'CMS provider specialty classification.',
    Core.Description : 'Table groups by specialty. Collapsed rows show the specialty; expand to reveal individual provider names.',
    UI.LineItem      : [{ position: 10 }]
  );

  ProviderName @(
    Common.Label     : 'Provider Name',
    Common.QuickInfo : 'Rendering provider organization or clinician name.',
    Core.Description : 'Visible when a specialty group is expanded. Compare individual vs organization providers within the same specialty.',
    UI.LineItem      : [{ position: 20 }]
  );

  EntityType @(
    Common.Label     : 'Entity Type',
    Common.QuickInfo : 'CMS entity code: I = Individual Clinician, O = Organization / Corporate Network.',
    Core.Description : 'Derived from Rndrng_Prvdr_Ent_Cd. Chart compares macro cost intensity across entity classes.',
    UI.LineItem      : [{ position: 30 }]
  );

  NPI @(
    Common.Label     : 'NPI',
    Common.QuickInfo : 'National Provider Identifier.',
    Core.Description : 'Ten-digit provider key. Combined with Year, uniquely identifies each provider.',
    UI.LineItem      : [{ position: 40 }]
  );

  CostPerBeneficiary @(
    Common.Label        : 'Cost per Patient',
    Common.QuickInfo    : 'Medicare paid amount divided by beneficiary count.',
    Core.Description    : 'Spend intensity per provider. Collapsed specialty rows show aggregated values; expand to compare individuals and organizations side by side.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 50 }]
  );

  ServicesPerBeneficiary @(
    Common.Label     : 'Services per Patient',
    Common.QuickInfo : 'Total service units divided by beneficiary count.',
    Core.Description : 'Utilization intensity per provider within each specialty group.',
    UI.LineItem      : [{ position: 60 }]
  );

  EfficiencyCategory @(
    Common.Label     : 'Cost Classification',
    Common.QuickInfo : 'Highly Efficient, Average Spend, or High-Cost Outlier.',
    Core.Description : 'Fixed threshold cost tier from Task 2.1 classification.',
    UI.LineItem      : [{ position: 70 }]
  );

  UtilizationCategory @(
    Common.Label     : 'Utilization Profile',
    Common.QuickInfo : 'Low, Moderate, or High Utilization.',
    Core.Description : 'Fixed threshold utilization tier from Task 2.1 classification.',
    UI.LineItem      : [{ position: 80 }]
  );
};

// ═══════════════════════════════════════════════════════════════════════════════
// EntityTypeCostInsight — KPI band: which entity likely charges more
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.EntityTypeCostInsight with @(

  UI.DataPoint #HigherChargingEntity: {
    $Type      : 'UI.DataPointType',
    Value      : HigherChargingEntity,
    Title      : 'Likely Higher-Charging Entity',
    Description: 'Entity class with the greater macro average cost per patient when Organizations are compared to Individual clinicians for the filtered year.'
  },

  UI.PresentationVariant #HigherChargingEntity: {
    $Type         : 'UI.PresentationVariantType',
    SortOrder     : [{ Property: CostPremiumPct, Descending: true }],
    MaxItems      : 1,
    Visualizations: ['@UI.DataPoint#HigherChargingEntity']
  },

  UI.SelectionVariant #HigherChargingEntity: {
    $Type: 'UI.SelectionVariantType',
    Text : 'Likely Higher-Charging Entity'
  },

  UI.KPI #HigherChargingEntity: {
    $Type           : 'UI.KPIType',
    ID              : 'HigherChargingEntity',
    DataPoint       : ![@UI.DataPoint#HigherChargingEntity],
    SelectionVariant: ![@UI.SelectionVariant#HigherChargingEntity],
    Detail          : {
      $Type                     : 'UI.KPIDetailType',
      DefaultPresentationVariant: ![@UI.PresentationVariant#HigherChargingEntity]
    }
  },

  UI.DataPoint #EntityCostPremium: {
    $Type      : 'UI.DataPointType',
    Value      : CostPremiumPct,
    Title      : 'Entity Cost Premium (%)',
    Description: 'Percentage by which the higher-charging entity class exceeds the lower entity class on macro average cost per patient.',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 1
    },
    CriticalityCalculation: {
      $Type                  : 'UI.CriticalityCalculationType',
      ImprovementDirection   : #Minimize,
      ToleranceRangeHighValue: 25,
      DeviationRangeHighValue: 75
    }
  },

  UI.PresentationVariant #EntityCostPremium: {
    $Type         : 'UI.PresentationVariantType',
    SortOrder     : [{ Property: CostPremiumPct, Descending: true }],
    MaxItems      : 1,
    Visualizations: ['@UI.DataPoint#EntityCostPremium']
  },

  UI.SelectionVariant #EntityCostPremium: {
    $Type: 'UI.SelectionVariantType',
    Text : 'Entity Cost Premium'
  },

  UI.KPI #EntityCostPremium: {
    $Type           : 'UI.KPIType',
    ID              : 'EntityCostPremium',
    DataPoint       : ![@UI.DataPoint#EntityCostPremium],
    SelectionVariant: ![@UI.SelectionVariant#EntityCostPremium],
    Detail          : {
      $Type                     : 'UI.KPIDetailType',
      DefaultPresentationVariant: ![@UI.PresentationVariant#EntityCostPremium]
    }
  }
);

annotate service.EntityTypeCostInsight with {
  HigherChargingEntity @(
    Common.Label     : 'Likely Higher-Charging Entity',
    Common.QuickInfo : 'Organization / Corporate Network or Individual Clinician with higher macro avg cost per patient.',
    Core.Description : 'Computed by comparing MacroAvgCostPerPatient between CMS entity classes I and O for the same year.'
  );

  CostPremiumPct @(
    Common.Label     : 'Entity Cost Premium (%)',
    Common.QuickInfo : 'How much more the higher-charging entity spends per patient vs the lower class.',
    Core.Description : 'round(|Org avg − Individual avg| ÷ lower avg × 100). For 2022: Organizations ~75% above Individuals.',
    Measures.Unit    : '%'
  );

  HigherEntityAvgCost @(
    Common.Label        : 'Higher Entity Avg Cost',
    Common.QuickInfo    : 'Macro average cost per patient for the higher-charging entity class.',
    Measures.ISOCurrency: 'USD'
  );

  LowerEntityAvgCost @(
    Common.Label        : 'Lower Entity Avg Cost',
    Common.QuickInfo    : 'Macro average cost per patient for the lower-charging entity class.',
    Measures.ISOCurrency: 'USD'
  );
};

// ═══════════════════════════════════════════════════════════════════════════════
// EntityTypeComparisons — macro chart for Task 2 overview OVP card
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.EntityTypeComparisons with @(
  UI.DataPoint #MacroCostComparisonFmt: {
    $Type      : 'UI.DataPointType',
    Value      : MacroAvgCostPerPatient,
    Title      : 'Avg Cost per Patient',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.Chart #MacroCostIntensity: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Macro Cost Intensity — Corporate Networks vs. Individual Clinicians',
    ChartType : #Column,
    Dimensions: [EntityType],
    Measures  : [MacroAvgCostPerPatient],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: EntityType,
        Role     : #Category
      }
    ],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : MacroAvgCostPerPatient,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#MacroCostComparisonFmt]
      }
    ]
  },

  UI.PresentationVariant #EntityCostChart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [EntityType],
    SortOrder     : [{ Property: MacroAvgCostPerPatient, Descending: true }],
    Visualizations: ['@UI.Chart#MacroCostIntensity']
  }
);

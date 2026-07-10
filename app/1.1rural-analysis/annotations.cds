using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// RuralAnalysisChart — HCPCS × structural tier (chart-safe grain)
// Chart (top): horizontal grouped bar — procedure (Y) × tier (series) × inflation % (X)
// Table (bottom): collapsible groups by procedure code → expand into structural tiers
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.RuralAnalysisChart with @(

  UI.SelectionFields: [HCPCS_Code, StructuralTier],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Procedure Tier Record',
    TypeNamePlural: 'Procedure Tier Records',
    Title         : { $Type: 'UI.DataField', Value: HCPCS_Code },
    Description   : { $Type: 'UI.DataField', Value: StructuralTier }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LAYER — horizontal grouped bar (deduplicated RuralAnalysisChart grain)
  // HCPCS_Code → #Category (one Y-axis row per procedure)
  // StructuralTier → #Series (Urban / Suburban / Rural sub-bars per slot)
  // OverclaimRate only — no currency measures on the 0–100% axis
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #InflationRatePct: {
    $Type       : 'UI.DataPointType',
    Value       : OverclaimRate,
    Title       : 'Inflation Rate (%)',
    MinimumValue: 0,
    MaximumValue: 100,
    ValueFormat : {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    },
    CriticalityCalculation: {
      $Type                  : 'UI.CriticalityCalculationType',
      ImprovementDirection   : #Minimize,
      ToleranceRangeHighValue: 15,
      DeviationRangeHighValue: 40
    }
  },

  UI.Chart #V2InflationDelta: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Procedural Inflation Rate (%) by Structural Tier',
    ChartType : #Bar,
    Dimensions: [HCPCS_Code, StructuralTier],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: HCPCS_Code,
        Role     : #Category
      },
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: StructuralTier,
        Role     : #Series
      }
    ],
    Measures  : [OverclaimRate],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : OverclaimRate,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#InflationRatePct]
      }
    ]
  },

  // Chart-only PV: multi-tier procedures only (≥2 tiers); top rows by inflation rate.
  // Single-tier codes (e.g. 31623 Urban-only) are excluded at the view layer.
  UI.PresentationVariant #ChartTopProcedures: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [HCPCS_Code, StructuralTier],
    SortOrder     : [{ Property: OverclaimRate, Descending: true }],
    MaxItems      : 30,
    Visualizations: ['@UI.Chart#V2InflationDelta']
  },

  UI.SelectionPresentationVariant #ALPDashboard: {
    $Type              : 'UI.SelectionPresentationVariantType',
    Text               : 'Rural Analysis V2 Dashboard',
    PresentationVariant: ![@UI.PresentationVariant#ChartTopProcedures]
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM LAYER — comparative grid: procedure cluster × tier × overclaim signal
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #OverclaimRateFmt: {
    $Type      : 'UI.DataPointType',
    Value      : OverclaimRate,
    Title      : 'Inflation Rate (%)',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.LineItem: [
    { $Type: 'UI.DataField', Value: HCPCS_Code,     Label: 'Procedure Code',          ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: HCPCS_Desc,     Label: 'Procedure Description',   ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: StructuralTier, Label: 'Structural Tier',         ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: TotalServices,  Label: 'Frequency (Total Services)', ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: TotalSubmitted, Label: 'Total Billed Charges',    ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: RejectedCharges, Label: 'Rejected Over-Charges',  ![@UI.Importance]: #High },
    {
      $Type      : 'UI.DataField',
      Value      : OverclaimRate,
      Label      : 'Inflation Rate (%)',
      ![@UI.Importance]: #High,
      ![@UI.DataPoint]: ![@UI.DataPoint#OverclaimRateFmt],
      CriticalityCalculation: {
        $Type                  : 'UI.CriticalityCalculationType',
        ImprovementDirection   : #Minimize,
        ToleranceRangeHighValue: 15,
        DeviationRangeHighValue: 40
      },
      ![@UI.CriticalityRepresentation]: #WithIcon
    },
    { $Type: 'UI.DataField', Value: UrbanBaselineRate, Label: 'Urban Baseline (%)', ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: TotalPaid,      Label: 'Total Paid',              ![@UI.Importance]: #High }
  ],

  // GroupBy HCPCS_Code: collapsed rows show procedure code + rolled-up totals;
  // expand reveals Urban / Metro, Suburban / Micro, Rural / Isolated tier rows.
  UI.PresentationVariant #V2Table: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [HCPCS_Code],
    SortOrder     : [
      { Property: HCPCS_Code,    Descending: false },
      { Property: OverclaimRate, Descending: true }
    ],
    Total         : [TotalServices, TotalSubmitted, RejectedCharges, TotalPaid],
    Visualizations: ['@UI.LineItem']
  }
);

// ── Element annotations: labels, tooltips, currency / unit metadata ───────────
annotate service.RuralAnalysisChart with {
  HCPCS_Code @(
    Common.Label     : 'Procedure Code',
    Common.QuickInfo : 'Healthcare Common Procedure Coding System identifier.',
    UI.LineItem      : [{ position: 10 }]
  );

  HCPCS_Desc @(
    Common.Label     : 'Procedure Description',
    Common.QuickInfo : 'Official CMS description of the billed procedure.',
    UI.LineItem      : [{ position: 20 }]
  );

  StructuralTier @(
    Common.Label     : 'Structural Tier',
    Common.QuickInfo : 'Geographic tier derived from RUCA: Urban / Metro (1–3), Suburban / Micro (4–6), Rural / Isolated (7–10.3).',
    UI.LineItem      : [{ position: 30 }]
  );

  TotalServices @(
    Common.Label     : 'Frequency (Total Services)',
    Common.QuickInfo : 'Aggregate count of billed service units for this procedure and tier.',
    UI.LineItem      : [{ position: 40 }]
  );

  TotalSubmitted @(
    Common.Label        : 'Total Billed Charges',
    Common.QuickInfo    : 'Total gross charges submitted to Medicare for this procedure within the structural tier.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 50 }]
  );

  RejectedCharges @(
    Common.Label        : 'Rejected Over-Charges',
    Common.QuickInfo    : 'The raw financial variance between what providers claimed vs. what Medicare allowed. High variance indicates that providers in this area are overcharging for the procedure.',
    Core.Description    : 'The raw financial variance between what providers claimed vs. what Medicare allowed. High variance indicates that providers in this area are overcharging for the procedure.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 60 }]
  );

  OverclaimRate @(
    Common.Label        : 'Inflation Rate (%)',
    Common.QuickInfo    : 'A high variance indicates that providers in this structural tier are systematically overcharging or upcoding for this specific procedure relative to regulatory fee caps.',
    Core.Description    : 'The percentage of billed charges immediately rejected by Medicare. High values in a tier reveal systematic overclaiming and upcoding for that specific procedure.',
    Measures.Unit       : '%',
    UI.DataPoint        : ![@UI.DataPoint#OverclaimRateFmt],
    UI.LineItem         : [{ position: 70 }]
  );

  UrbanBaselineRate @(
    Common.Label     : 'Urban Baseline (%)',
    Common.QuickInfo : 'Urban / Metro inflation rate for the same procedure — used as the comparative target notch on the bullet chart.',
    Measures.Unit    : '%',
    UI.LineItem      : [{ position: 75 }]
  );

  TotalPaid @(
    Common.Label        : 'Total Paid',
    Common.QuickInfo    : 'Total Medicare disbursement for this procedure within the structural tier.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 80 }]
  );
};

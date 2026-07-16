using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// RuralAnalysisChart — HCPCS × structural tier (chart-safe grain)
// Chart (top): grouped column — procedure (X) × tier (series) × tier deviation (Y)
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
  // TOP LAYER — vertical grouped column chart
  // HCPCS_Code → #Category | StructuralTier → #Series | TierDeviation → measure
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #TierDeviationPct: {
    $Type       : 'UI.DataPointType',
    Value       : TierDeviation,
    Title       : 'Tier Deviation (%)',
    ValueFormat : {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    },
    CriticalityCalculation: {
      $Type                  : 'UI.CriticalityCalculationType',
      ImprovementDirection   : #Minimize,
      ToleranceRangeHighValue: 5,
      DeviationRangeHighValue: 15
    }
  },

  UI.Chart #V2InflationDelta: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Tier Deviation (%) by Structural Tier',
    ChartType : #Column,
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
    Measures  : [TierDeviation],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : TierDeviation,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#TierDeviationPct]
      }
    ]
  },

  // Top N procedures by max tier deviation; GroupBy HCPCS_Code loads all tiers per procedure.
  UI.PresentationVariant #ChartTopProcedures: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [HCPCS_Code],
    SortOrder     : [{ Property: TierDeviation, Descending: true }],
    MaxItems      : 10,
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
    Title      : 'Rejection Rate (%)',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },
  UI.DataPoint #TierDeviationFmt: {
    $Type      : 'UI.DataPointType',
    Value      : TierDeviation,
    Title      : 'Tier Deviation (%)',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.LineItem: [
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'MedicareService.EntityContainer/checkAI',
      Label : '{i18n>Evaluate_AI}'
    },
    { $Type: 'UI.DataField', Value: HCPCS_Code,     Label: 'Procedure Code',          ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: HCPCS_Desc,     Label: 'Procedure Description',   ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: StructuralTier, Label: 'Structural Tier',         ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: TotalServices,  Label: 'Frequency (Total Services)', ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: TotalSubmitted, Label: 'Total Billed Charges',    ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: RejectedCharges, Label: 'Rejected Over-Charges',  ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: OverclaimRate,  Label: 'Rejection Rate (%)',      ![@UI.Importance]: #Medium, ![@UI.DataPoint]: ![@UI.DataPoint#OverclaimRateFmt] },
    { $Type: 'UI.DataField', Value: ProcedureBaselineRate, Label: 'Procedure Baseline (%)', ![@UI.Importance]: #Medium },
    {
      $Type      : 'UI.DataField',
      Value      : TierDeviation,
      Label      : 'Tier Deviation (%)',
      ![@UI.Importance]: #High,
      ![@UI.DataPoint]: ![@UI.DataPoint#TierDeviationFmt],
      CriticalityCalculation: {
        $Type                  : 'UI.CriticalityCalculationType',
        ImprovementDirection   : #Minimize,
        ToleranceRangeHighValue: 5,
        DeviationRangeHighValue: 15
      },
      ![@UI.CriticalityRepresentation]: #WithIcon
    },
    { $Type: 'UI.DataField', Value: TotalPaid,      Label: 'Total Medicare Paid',   ![@UI.Importance]: #High }
  ],

  UI.PresentationVariant #V2Table: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [HCPCS_Code],
    SortOrder     : [
      { Property: HCPCS_Code,    Descending: false },
      { Property: TierDeviation, Descending: true }
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
    Common.QuickInfo    : 'The raw financial variance between what providers claimed vs. what Medicare allowed.',
    Core.Description    : 'The raw financial variance between what providers claimed vs. what Medicare allowed.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 60 }]
  );

  OverclaimRate @(
    Common.Label        : 'Rejection Rate (%)',
    Common.QuickInfo    : 'Share of billed charges rejected by Medicare fee caps: (Rejected Over-Charges ÷ Total Billed Charges) × 100.',
    Core.Description    : 'Share of billed charges rejected by Medicare fee caps: (Rejected Over-Charges ÷ Total Billed Charges) × 100.',
    Measures.Unit       : '%',
    UI.DataPoint        : ![@UI.DataPoint#OverclaimRateFmt],
    UI.LineItem         : [{ position: 65 }]
  );

  ProcedureBaselineRate @(
    Common.Label     : 'Procedure Baseline (%)',
    Common.QuickInfo : 'Volume-weighted average rejection rate for this procedure across all structural tiers.',
    Core.Description : 'Volume-weighted average rejection rate for this procedure across all structural tiers.',
    Measures.Unit    : '%',
    UI.LineItem      : [{ position: 68 }]
  );

  TierDeviation @(
    Common.Label        : 'Tier Deviation (%)',
    Common.QuickInfo    : 'How far this tier deviates from the procedure baseline: Rejection Rate (%) − Procedure Baseline (%). Positive = worse than average; negative = more compliant than average.',
    Core.Description    : 'How far this tier deviates from the procedure baseline: Rejection Rate (%) − Procedure Baseline (%). Positive = worse than average; negative = more compliant than average.',
    Measures.Unit       : '%',
    UI.DataPoint        : ![@UI.DataPoint#TierDeviationFmt],
    UI.LineItem         : [{ position: 70 }]
  );

  TotalPaid @(
    Common.Label        : 'Total Medicare Paid',
    Common.QuickInfo    : 'Actual cash disbursed by Medicare (sum of Avg Medicare Payment Amount × services).',
    Core.Description    : 'Actual cash disbursed by Medicare (sum of Avg Medicare Payment Amount × services).',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 80 }]
  );
};

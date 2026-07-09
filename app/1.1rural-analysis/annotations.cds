using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// RuralAnalysisV2 — HCPCS × RUCA structural tier ALP
// Chart (top): grouped column — TotalPaid vs RejectedCharges by StructuralTier
// Table (bottom): collapsible groups by procedure code → expand into structural tiers
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.RuralAnalysisV2 with @(

  UI.SelectionFields: [HCPCS_Code, StructuralTier],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Procedure Tier Record',
    TypeNamePlural: 'Procedure Tier Records',
    Title         : { $Type: 'UI.DataField', Value: HCPCS_Code },
    Description   : { $Type: 'UI.DataField', Value: StructuralTier }
  },

  // ── Chart Y-axis currency shorthand ($M) ───────────────────────────────────
  UI.DataPoint #TotalPaidFmt: {
    $Type      : 'UI.DataPointType',
    Value      : TotalPaid,
    Title      : 'Total Paid',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      ScaleFactor             : 1000000,
      NumberOfFractionalDigits: 1
    }
  },
  UI.DataPoint #RejectedChargesFmt: {
    $Type      : 'UI.DataPointType',
    Value      : RejectedCharges,
    Title      : 'Rejected Over-Charges',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      ScaleFactor             : 1000000,
      NumberOfFractionalDigits: 1
    }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LAYER — Grouped column chart (StructuralTier on X, $ measures on Y)
  // ═══════════════════════════════════════════════════════════════════════════
  UI.Chart #V2TierFootprint: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Financial Footprint by Structural Tier',
    ChartType : #Column,
    AxisScaling: {
      $Type             : 'UI.ChartAxisScalingType',
      ScaleBehavior     : #AutoScale,
      AutoScaleBehavior : {
        $Type             : 'UI.ChartAxisAutoScaleBehaviorType',
        DataScope         : 'DataSet',
        ZeroAlwaysVisible : true
      }
    },
    Dimensions: [StructuralTier],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: StructuralTier, Role: #Category }
    ],
    Measures  : [TotalPaid, RejectedCharges],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : TotalPaid,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#TotalPaidFmt]
      },
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : RejectedCharges,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#RejectedChargesFmt]
      }
    ]
  },

  UI.PresentationVariant #V2Chart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [StructuralTier],
    SortOrder     : [{ Property: TotalPaid, Descending: true }],
    Visualizations: ['@UI.Chart#V2TierFootprint']
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
    { $Type: 'UI.DataField', Value: TotalPaid,      Label: 'Total Paid',              ![@UI.Importance]: #High }
  ],

  // GroupBy HCPCS_Code: collapsed rows show procedure code + rolled-up totals;
  // expand reveals Urban / Metro, Suburban / Micro, Rural / Isolated tier rows.
  // Sort: code ASC, then OverclaimRate DESC within each group.
  // Total: only additive measures — OverclaimRate excluded (ratios must not roll up).
  UI.PresentationVariant #V2Table: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [HCPCS_Code],
    SortOrder     : [
      { Property: HCPCS_Code,    Descending: false },
      { Property: OverclaimRate, Descending: true }
    ],
    Total         : [TotalServices, TotalSubmitted, RejectedCharges, TotalPaid],
    Visualizations: ['@UI.LineItem']
  },

  UI.SelectionPresentationVariant #ALPDashboard: {
    $Type              : 'UI.SelectionPresentationVariantType',
    Text               : 'Rural Analysis V2 Dashboard',
    PresentationVariant: ![@UI.PresentationVariant#V2Chart]
  }
);

// ── Element annotations: labels, tooltips, currency / unit metadata ───────────
annotate service.RuralAnalysisV2 with {
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

  TotalPaid @(
    Common.Label        : 'Total Paid',
    Common.QuickInfo    : 'Total Medicare disbursement for this procedure within the structural tier.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 80 }]
  );
};

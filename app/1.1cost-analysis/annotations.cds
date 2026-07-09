using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// CostAnalysisV2 — ALP annotation layer (state + provider-type grain)
// Chart (top): vertical column chart, Top-10-by-TotalPaid + horizontal scroll
// Table (bottom): State + ProviderType rows with rejected-charges audit column
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.CostAnalysisV2 with @(

  // ── Filter bar: shared selection context for chart + table cross-filtering ──
  UI.SelectionFields: [Year, State, ProviderType],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'State Cost Record',
    TypeNamePlural: 'State Cost Records',
    Title         : { $Type: 'UI.DataField', Value: StateName },
    Description   : { $Type: 'UI.DataField', Value: ProviderType }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER KPI BAND — audit headline metrics above chart + table (ALP title area
  // via manifest keyPerformanceIndicators; Object Page via UI.HeaderFacets below)
  // ═══════════════════════════════════════════════════════════════════════════

  // KPI 1: portfolio-wide rejected over-billing (Submitted − Allowed)
  UI.DataPoint #RejectedChargesKPI: {
    $Type      : 'UI.DataPointType',
    Value      : RejectedCharges,
    Title      : 'Total Rejected Over-Charges',
    Description: 'The absolute variance between what providers claimed vs. what Medicare approved under official fee schedules.',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      ScaleFactor             : 1000000,
      NumberOfFractionalDigits: 1
    }
  },
  UI.Chart #RejectedChargesKPI: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Rejected Over-Charges by State',
    ChartType : #Bar,
    Dimensions: [State],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: State, Role: #Category }
    ],
    Measures  : [RejectedCharges],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : RejectedCharges,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#RejectedChargesKPI]
      }
    ]
  },
  UI.PresentationVariant #RejectedChargesKPI: {
    $Type         : 'UI.PresentationVariantType',
    SortOrder     : [{ Property: RejectedCharges, Descending: true }],
    Visualizations: ['@UI.Chart#RejectedChargesKPI']
  },
  UI.SelectionVariant #RejectedChargesKPI: {
    $Type: 'UI.SelectionVariantType',
    Text : 'Total Rejected Over-Charges'
  },
  UI.KPI #RejectedChargesKPI: {
    $Type           : 'UI.KPIType',
    ID              : 'RejectedChargesKPI',
    DataPoint       : ![@UI.DataPoint#RejectedChargesKPI],
    SelectionVariant: ![@UI.SelectionVariant#RejectedChargesKPI],
    Detail          : {
      $Type                     : 'UI.KPIDetailType',
      DefaultPresentationVariant: ![@UI.PresentationVariant#RejectedChargesKPI]
    }
  },

  // KPI 2: state with highest aggregate TotalPaid (top-1 anchor via PresentationVariant)
  UI.DataPoint #TopSpendingState: {
    $Type      : 'UI.DataPointType',
    Value      : State,
    Title      : 'Highest Expenditure Target',
    Description: 'The state with the greatest aggregate Medicare disbursement in the current filter context.'
  },
  UI.PresentationVariant #TopSpendingState: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [State],
    SortOrder     : [{ Property: TotalPaid, Descending: true }],
    MaxItems      : 1,
    Visualizations: ['@UI.DataPoint#TopSpendingState']
  },
  UI.SelectionVariant #TopSpendingState: {
    $Type: 'UI.SelectionVariantType',
    Text : 'Highest Expenditure Target'
  },
  UI.KPI #TopSpendingState: {
    $Type           : 'UI.KPIType',
    ID              : 'TopSpendingState',
    DataPoint       : ![@UI.DataPoint#TopSpendingState],
    SelectionVariant: ![@UI.SelectionVariant#TopSpendingState],
    Detail          : {
      $Type                     : 'UI.KPIDetailType',
      DefaultPresentationVariant: ![@UI.PresentationVariant#TopSpendingState]
    }
  },

  // Inject KPI data points into the global header band (Object Page + ALP header context)
  UI.HeaderFacets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'RejectedChargesKPIFacet',
      Label : 'Rejected Over-Charges',
      Target: '@UI.KPI#RejectedChargesKPI'
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'TopSpendingStateFacet',
      Label : 'Top Spending State',
      Target: '@UI.KPI#TopSpendingState'
    }
  ],

  // ── DataPoints: Y-axis shorthand ($M / $B) via ScaleFactor + ISOCurrency ───
  UI.DataPoint #TotalSubmittedFmt: {
    $Type      : 'UI.DataPointType',
    Value      : TotalSubmitted,
    Title      : 'Total Charges Claimed',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      ScaleFactor             : 1000000,
      NumberOfFractionalDigits: 1
    }
  },
  UI.DataPoint #TotalAllowedFmt: {
    $Type      : 'UI.DataPointType',
    Value      : TotalAllowed,
    Title      : 'Total Approved Cap',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      ScaleFactor             : 1000000,
      NumberOfFractionalDigits: 1
    }
  },
  UI.DataPoint #TotalPaidFmt: {
    $Type      : 'UI.DataPointType',
    Value      : TotalPaid,
    Title      : 'Total Amount Paid',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      ScaleFactor             : 1000000,
      NumberOfFractionalDigits: 1
    }
  },
  UI.DataPoint #DrugSubmittedFmt: {
    $Type      : 'UI.DataPointType',
    Value      : DrugSubmitted,
    Title      : 'Drug Charges Claimed',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      ScaleFactor             : 1000000,
      NumberOfFractionalDigits: 1
    }
  },
  UI.DataPoint #DrugPaidFmt: {
    $Type      : 'UI.DataPointType',
    Value      : DrugPaid,
    Title      : 'Drug Amount Paid',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      ScaleFactor             : 1000000,
      NumberOfFractionalDigits: 1
    }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LAYER — Vertical column chart (full state names on X, measures on Y)
  // ═══════════════════════════════════════════════════════════════════════════
  UI.Chart #V2Footprint: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'State Financial Footprint Analysis',
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
    Dimensions: [StateName],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: StateName, Role: #Category }
    ],
    Measures  : [TotalSubmitted, TotalAllowed, TotalPaid, DrugSubmitted, DrugPaid],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : TotalSubmitted,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#TotalSubmittedFmt]
      },
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : TotalAllowed,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#TotalAllowedFmt]
      },
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : TotalPaid,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#TotalPaidFmt]
      },
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : DrugSubmitted,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#DrugSubmittedFmt]
      },
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : DrugPaid,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#DrugPaidFmt]
      }
    ]
  },

  // Chart PV: Top 10 states by TotalPaid; manifest vizProperties enable horizontal
  // scroll when bar width exceeds viewport (remaining states visible on scroll).
  UI.PresentationVariant #V2Chart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [StateName],
    SortOrder     : [{ Property: TotalPaid, Descending: true }],
    MaxItems      : 10,
    Visualizations: ['@UI.Chart#V2Footprint']
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM LAYER — analytical table (positions 10–100, labels via @Common.Label)
  // ═══════════════════════════════════════════════════════════════════════════
  // Column order: …60 Submitted → 70 Allowed → 75 Rejected → 80 Paid…
  UI.LineItem: [
    { Value: Year,                 ![@UI.Importance]: #High },
    { Value: StateName,            ![@UI.Importance]: #High },
    { Value: ProviderType,         ![@UI.Importance]: #High },
    { Value: ProviderCount,        ![@UI.Importance]: #Medium },
    { Value: TotalBeneficiaries,   ![@UI.Importance]: #Medium },
    { Value: TotalSubmitted,       ![@UI.Importance]: #High },
    { Value: TotalAllowed,         ![@UI.Importance]: #High },
    {
      $Type      : 'UI.DataField',
      Value      : RejectedCharges,
      Label      : 'Rejected Over-Charges',
      ![@UI.Importance]: #High
    },
    { Value: TotalPaid,            ![@UI.Importance]: #High },
    { Value: DrugSubmitted,        ![@UI.Importance]: #Medium },
    { Value: DrugPaid,             ![@UI.Importance]: #Medium }
  ],

  UI.PresentationVariant #V2Table: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [StateName, ProviderType],
    SortOrder     : [{ Property: TotalPaid, Descending: true }],
    Visualizations: ['@UI.LineItem']
  },

  // ── Object-page drill-down: expandable metric breakdown per state ───────────
  UI.FieldGroup #MetricBreakdown: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: Year },
      { $Type: 'UI.DataField', Value: StateName },
      { $Type: 'UI.DataField', Value: ProviderType },
      { $Type: 'UI.DataField', Value: ProviderCount },
      { $Type: 'UI.DataField', Value: TotalBeneficiaries },
      { $Type: 'UI.DataField', Value: TotalSubmitted },
      { $Type: 'UI.DataField', Value: TotalAllowed },
      { $Type: 'UI.DataField', Value: RejectedCharges },
      { $Type: 'UI.DataField', Value: TotalPaid },
      { $Type: 'UI.DataField', Value: DrugSubmitted },
      { $Type: 'UI.DataField', Value: DrugPaid }
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'MetricBreakdownFacet',
      Label : 'State Financial Metrics',
      Target: '@UI.FieldGroup#MetricBreakdown'
    }
  ],

  // ── ALP master context: chart selection on State filters the table below ────
  UI.SelectionPresentationVariant #ALPDashboard: {
    $Type              : 'UI.SelectionPresentationVariantType',
    Text               : 'Cost Analysis Dashboard',
    PresentationVariant: ![@UI.PresentationVariant#V2Chart]
  }
);

// ── Element annotations: labels, tooltips (QuickInfo), AI (Description), positions ─
annotate service.CostAnalysisV2 with {
  Year @(
    Common.Label       : 'Year',
    Common.QuickInfo   : 'The specific calendar year of the data. Establishes time-series context.',
    Core.Description   : 'The specific calendar year of the data. Establishes time-series context.',
    UI.LineItem        : [{ position: 10 }]
  );

  State @(
    Common.Label       : 'State Code',
    Common.Text        : StateName,
    Common.QuickInfo   : 'Two-letter postal abbreviation used for filtering.',
    Core.Description   : 'Two-letter postal abbreviation used for filtering and chart cross-filter.'
  );

  StateName @(
    Common.Label       : 'State',
    Common.QuickInfo   : 'Full name of the U.S. state or territory where care was rendered.',
    Core.Description   : 'Full name of the U.S. state or territory where care was rendered.',
    UI.LineItem        : [{ position: 20 }]
  );
  State @Common.ValueList #StateCrossFilter: {
    $Type                       : 'Common.ValueListType',
    Label                       : 'State',
    CollectionPath              : 'CostAnalysisV2',
    SearchSupported             : true,
    PresentationVariantQualifier: 'V2Table',
    Parameters                  : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: State,
        ValueListProperty: 'State'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'StateName'
      }
    ]
  };

  ProviderType @(
    Common.Label       : 'Provider Type',
    Common.QuickInfo   : 'The medical specialty of the provider bucket.',
    Core.Description   : 'The medical specialty of the provider bucket.',
    UI.LineItem        : [{ position: 30 }]
  );

  ProviderCount @(
    Common.Label       : 'Provider Count',
    Common.QuickInfo   : 'The total number of unique healthcare providers in this bucket.',
    Core.Description   : 'The total number of unique healthcare providers in this bucket.',
    UI.LineItem        : [{ position: 40 }]
  );

  TotalBeneficiaries @(
    Common.Label       : 'Total Beneficiaries',
    Common.QuickInfo   : 'The total number of unique Medicare patients who received care.',
    Core.Description   : 'The total number of unique Medicare patients who received care.',
    UI.LineItem        : [{ position: 50 }]
  );

  TotalSubmitted @(
    Common.Label        : 'Total Charges Claimed',
    Common.QuickInfo    : 'The total gross dollar amount that providers billed to Medicare.',
    Core.Description    : 'The total gross dollar amount that providers billed to Medicare.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 60 }]
  );

  TotalAllowed @(
    Common.Label        : 'Total Approved Cap',
    Common.QuickInfo    : 'The maximum financial amount allowed by Medicare fee schedules.',
    Core.Description    : 'The maximum financial amount allowed by Medicare fee schedules.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 70 }]
  );

  TotalPaid @(
    Common.Label        : 'Total Amount Paid',
    Common.QuickInfo    : 'The actual bottom-line cash disbursed by Medicare.',
    Core.Description    : 'The actual bottom-line cash disbursed by Medicare.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 80 }]
  );

  // Analytical measure — header-click sort enabled via @Analytics.Measure in service layer
  RejectedCharges @(
    Common.Label        : 'Rejected Over-Charges',
    Common.QuickInfo    : 'The financial variance showing how much money providers claimed that Medicare immediately rejected based on regulatory fee caps. Calculated as (Total Submitted - Total Allowed).',
    Core.Description    : 'The financial variance showing how much money providers claimed that Medicare immediately rejected based on regulatory fee caps. Calculated as (Total Submitted - Total Allowed).',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 75 }]
  );

  DrugSubmitted @(
    Common.Label        : 'Drug Charges Claimed',
    Common.QuickInfo    : 'The total gross dollar amount billed specifically for prescription drugs.',
    Core.Description    : 'The total gross dollar amount billed specifically for prescription drugs.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 90 }]
  );

  DrugPaid @(
    Common.Label        : 'Drug Amount Paid',
    Common.QuickInfo    : 'The actual total money Medicare paid specifically for prescription drugs.',
    Core.Description    : 'The actual total money Medicare paid specifically for prescription drugs.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 100 }]
  );
};

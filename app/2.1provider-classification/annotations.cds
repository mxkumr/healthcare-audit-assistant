using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// ProviderCostEfficiency — Task 2.1 Two-Axis Risk Matrix ALP
// Chart (top): stacked column — EfficiencyCategory (X) × UtilizationCategory (series)
// Table (bottom): per-provider audit log for fraud triage drill-down
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.ProviderCostEfficiency with @(

  UI.SelectionFields: [Year, State, ProviderType, EfficiencyCategory, UtilizationCategory],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Provider Risk Record',
    TypeNamePlural: 'Provider Risk Records',
    Title         : { $Type: 'UI.DataField', Value: ProviderName },
    Description   : { $Type: 'UI.DataField', Value: ProviderType }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LAYER — stacked column chart (2-Axis Risk Matrix)
  // EfficiencyCategory → #Category | UtilizationCategory → #Series
  // ═══════════════════════════════════════════════════════════════════════════
  UI.Chart #RiskMatrix: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Provider Risk Matrix - Cost x Utilization',
    ChartType : #ColumnStacked,
    Dimensions: [
      EfficiencyCategory,
      UtilizationCategory
    ],
    Measures  : [
      ProviderCount
    ],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: EfficiencyCategory,
        Role     : #Category
      },
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: UtilizationCategory,
        Role     : #Series
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

  UI.PresentationVariant #RiskMatrixChart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [EfficiencyCategory],
    SortOrder     : [{ Property: ProviderCount, Descending: true }],
    Visualizations: ['@UI.Chart#RiskMatrix']
  },

  UI.SelectionPresentationVariant #ALPDashboard: {
    $Type              : 'UI.SelectionPresentationVariantType',
    Text               : 'Provider Risk Matrix Dashboard',
    PresentationVariant: ![@UI.PresentationVariant#RiskMatrixChart]
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM LAYER — one row per provider name; expand to see year-wise history
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #ServicesPerPatientFmt: {
    $Type      : 'UI.DataPointType',
    Value      : ServicesPerBeneficiary,
    Title      : 'Services per Patient',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 0
    }
  },

  UI.LineItem: [
    { $Type: 'UI.DataField', Value: ProviderName,          Label: 'Provider Name' },
    { $Type: 'UI.DataField', Value: NPI,                   Label: 'NPI' },
    { $Type: 'UI.DataField', Value: Year,                  Label: 'Year' },
    { $Type: 'UI.DataField', Value: ProviderType,          Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: State,                 Label: 'State' },
    { $Type: 'UI.DataField', Value: TotalBeneficiaries,    Label: 'Patients Served' },
    { $Type: 'UI.DataField', Value: CostPerBeneficiary,    Label: 'Cost per Patient' },
    { $Type: 'UI.DataField', Value: ServicesPerBeneficiary, Label: 'Services per Patient', ![@UI.DataPoint]: ![@UI.DataPoint#ServicesPerPatientFmt] },
    { $Type: 'UI.DataField', Value: EfficiencyCategory,    Label: 'Cost Classification' },
    { $Type: 'UI.DataField', Value: UtilizationCategory,   Label: 'Utilization Profile' }
  ],

  UI.PresentationVariant #AuditTable: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [ProviderName],
    SortOrder     : [
      { Property: ServicesPerBeneficiary, Descending: true },
      { Property: ProviderName,         Descending: false },
      { Property: Year,                 Descending: false },
      { Property: NPI,                  Descending: false }
    ],
    Visualizations: ['@UI.LineItem']
  },

  // ── Object page: selected year record + year-wise history for same provider ──
  UI.FieldGroup #ProviderProfile: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: ProviderName,           Label: 'Provider Name' },
      { $Type: 'UI.DataField', Value: NPI,                    Label: 'NPI' },
      { $Type: 'UI.DataField', Value: Year,                   Label: 'Year' },
      { $Type: 'UI.DataField', Value: ProviderType,           Label: 'Specialty' },
      { $Type: 'UI.DataField', Value: State,                  Label: 'State' },
      { $Type: 'UI.DataField', Value: TotalBeneficiaries,     Label: 'Patients Served' },
      { $Type: 'UI.DataField', Value: AvgPatientAge,          Label: 'Avg Patient Age' },
      { $Type: 'UI.DataField', Value: AvgRiskScore,           Label: 'Avg Risk Score' },
      { $Type: 'UI.DataField', Value: DiabetesPct,            Label: 'Diabetes %' },
      { $Type: 'UI.DataField', Value: HypertensionPct,        Label: 'Hypertension %' },
      { $Type: 'UI.DataField', Value: CostPerBeneficiary,     Label: 'Cost per Patient' },
      { $Type: 'UI.DataField', Value: ServicesPerBeneficiary, Label: 'Services per Patient', ![@UI.DataPoint]: ![@UI.DataPoint#ServicesPerPatientFmt] },
      { $Type: 'UI.DataField', Value: EfficiencyCategory,     Label: 'Cost Classification' },
      { $Type: 'UI.DataField', Value: UtilizationCategory,    Label: 'Utilization Profile' }
    ]
  },

  UI.LineItem #YearHistory: [
    { $Type: 'UI.DataField', Value: Year,                   Label: 'Year' },
    { $Type: 'UI.DataField', Value: NPI,                    Label: 'NPI' },
    { $Type: 'UI.DataField', Value: ProviderType,           Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: State,                  Label: 'State' },
    { $Type: 'UI.DataField', Value: TotalBeneficiaries,     Label: 'Patients Served' },
    { $Type: 'UI.DataField', Value: CostPerBeneficiary,     Label: 'Cost per Patient' },
    { $Type: 'UI.DataField', Value: ServicesPerBeneficiary, Label: 'Services per Patient', ![@UI.DataPoint]: ![@UI.DataPoint#ServicesPerPatientFmt] },
    { $Type: 'UI.DataField', Value: EfficiencyCategory,     Label: 'Cost Classification' },
    { $Type: 'UI.DataField', Value: UtilizationCategory,    Label: 'Utilization Profile' }
  ],

  UI.PresentationVariant #YearHistory: {
    $Type         : 'UI.PresentationVariantType',
    SortOrder     : [{ Property: Year, Descending: false }],
    Visualizations: ['@UI.LineItem#YearHistory']
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'ProviderProfileFacet',
      Label : 'Provider Risk Profile',
      Target: '@UI.FieldGroup#ProviderProfile'
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'YearHistoryFacet',
      Label : 'Year-wise History',
      Target: 'yearHistory/@UI.LineItem#YearHistory'
    }
  ]
);

// ── Element annotations: labels, currency metadata, positions ────────────────
annotate service.ProviderCostEfficiency with {
  ProviderName @(
    Common.Label     : 'Provider Name',
    Common.QuickInfo   : 'Rendering provider organization or clinician name. Expand to see year-wise history.',
    UI.LineItem        : [{ position: 10 }]
  );

  NPI @(
    Common.Label     : 'NPI',
    Common.QuickInfo   : 'National Provider Identifier — unique provider key.',
    UI.LineItem        : [{ position: 20 }]
  );

  Year @(
    Common.Label   : 'Year',
    Common.QuickInfo : 'Calendar year of the Medicare provider summary record.',
    UI.LineItem    : [{ position: 30 }]
  );

  ProviderType @(
    Common.Label   : 'Specialty',
    Common.QuickInfo : 'CMS provider specialty classification.',
    UI.LineItem    : [{ position: 40 }]
  );

  State @(
    Common.Label   : 'State',
    Common.QuickInfo : 'Two-letter state where the provider is located.',
    UI.LineItem    : [{ position: 50 }]
  );

  TotalBeneficiaries @(
    Common.Label   : 'Patients Served',
    Common.QuickInfo : 'Distinct Medicare beneficiaries who received services from this provider in this year. Grouped rows show the peak annual panel size.',
    UI.LineItem    : [{ position: 55 }]
  );

  AvgPatientAge @(
    Common.Label   : 'Avg Patient Age',
    Common.QuickInfo : 'Average age of the provider''s Medicare beneficiary panel — object page only.'
  );

  AvgRiskScore @(
    Common.Label   : 'Avg Risk Score',
    Common.QuickInfo : 'Average HCC risk score — higher values indicate a more clinically complex patient panel. Object page only.'
  );

  DiabetesPct @(
    Common.Label     : 'Diabetes %',
    Common.QuickInfo : 'CMS-reported share of beneficiaries with diabetes. Often capped at 75% for small panels — object page only.',
    Measures.Unit    : '%'
  );

  HypertensionPct @(
    Common.Label     : 'Hypertension %',
    Common.QuickInfo : 'CMS-reported share of beneficiaries with hypertension. Often capped at 75% for small panels — object page only.',
    Measures.Unit    : '%'
  );

  CostPerBeneficiary @(
    Common.Label        : 'Cost per Patient',
    Common.QuickInfo    : 'Medicare paid amount divided by beneficiary count.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 60 }]
  );

  ServicesPerBeneficiary @(
    Common.Label     : 'Services per Patient',
    Common.QuickInfo : 'Total services divided by beneficiary count, rounded to the nearest whole number. At provider level shows the highest annual value across all years.',
    Measures.Unit    : #ONE,
    UI.LineItem      : [{ position: 70 }]
  );

  EfficiencyCategory @(
    Common.Label     : 'Cost Classification',
    Common.QuickInfo : 'Cost-intensity band: Highly Efficient (<$150), Average Spend ($150–$900), High-Cost Outlier (≥$900) per beneficiary.',
    UI.LineItem      : [{ position: 80 }]
  );

  UtilizationCategory @(
    Common.Label     : 'Utilization Profile',
    Common.QuickInfo : 'Service-volume band: Low (<5), Moderate (5–15), High (≥15) services per beneficiary.',
    UI.LineItem      : [{ position: 90 }]
  );

  ProviderCount @(
    Common.Label     : 'Provider Count',
    Common.QuickInfo : 'Constant 1 per provider row; SUM on chart = distinct NPI count per matrix cell.',
    Measures.Unit    : #ONE
  );
};

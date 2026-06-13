using MedicareService as service from '../../srv/medicare-service';

annotate service.CostByStateProviderType with @(

  UI.SelectionFields: [Year, State, ProviderType],

  // ── Object Page header ──────────────────────────────────────────────────────
  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Cost Record',
    TypeNamePlural: 'Cost Records',
    Title         : { $Type: 'UI.DataField', Value: State },
    Description   : { $Type: 'UI.DataField', Value: ProviderType }
  },

  // ── List Report table (Page Content) ────────────────────────────────────────
  UI.LineItem: [
    { Value: Year,                 Label: 'Year' },
    { Value: State,                Label: 'State' },
    { Value: ProviderType,         Label: 'Provider Type' },
    { Value: ProviderCount,        Label: 'Provider Count' },
    { Value: TotalSubmitted,       Label: 'Total Submitted ($)' },
    { Value: TotalAllowed,         Label: 'Total Allowed ($)' },
    { Value: TotalPaid,            Label: 'Total Paid ($)' },
    { Value: TotalBeneficiaries,   Label: 'Total Beneficiaries' },
    { Value: AvgRiskScore,         Label: 'Avg Risk Score' }
  ],

  // ── Object Page form + facets (drill-down) ──────────────────────────────────
  UI.FieldGroup #Details: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: Year,               Label: 'Year' },
      { $Type: 'UI.DataField', Value: State,              Label: 'State' },
      { $Type: 'UI.DataField', Value: ProviderType,       Label: 'Provider Type' },
      { $Type: 'UI.DataField', Value: ProviderCount,      Label: 'Provider Count' },
      { $Type: 'UI.DataField', Value: TotalSubmitted,     Label: 'Total Submitted ($)' },
      { $Type: 'UI.DataField', Value: TotalAllowed,       Label: 'Total Allowed ($)' },
      { $Type: 'UI.DataField', Value: TotalPaid,          Label: 'Total Paid ($)' },
      { $Type: 'UI.DataField', Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
      { $Type: 'UI.DataField', Value: AvgRiskScore,       Label: 'Avg Risk Score' }
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'DetailsFacet',
      Label : 'Cost Details',
      Target: '@UI.FieldGroup#Details'
    }
  ],

  // ── Main hybrid-view chart ──────────────────────────────────────────────────
  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Total Paid by State',
    ChartType : #Bar,
    Dimensions: [State],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: State, Role: #Category }
    ],
    Measures  : [TotalPaid],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalPaid, Role: #Axis1 }
    ]
  },

  UI.PresentationVariant: {
    GroupBy       : [State, ProviderType],
    Total         : [TotalPaid, TotalSubmitted, ProviderCount],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  },

  // ── KPI 1: Total Paid (Page Title) ──────────────────────────────────────────
  UI.DataPoint #TotalPaidKPI: {
    $Type: 'UI.DataPointType',
    Value: TotalPaid,
    Title: 'Total Paid'
  },
  UI.Chart #TotalPaidKPI: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Total Paid by State',
    ChartType : #Bar,
    Dimensions: [State],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: State, Role: #Category }
    ],
    Measures  : [TotalPaid],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalPaid, Role: #Axis1 }
    ]
  },
  UI.PresentationVariant #TotalPaidKPI: {
    $Type         : 'UI.PresentationVariantType',
    Visualizations: ['@UI.Chart#TotalPaidKPI']
  },
  UI.SelectionVariant #TotalPaidKPI: {
    $Type: 'UI.SelectionVariantType',
    Text : 'Total Paid'
  },
  UI.KPI #TotalPaidKPI: {
    $Type           : 'UI.KPIType',
    ID              : 'TotalPaidKPI',
    DataPoint       : ![@UI.DataPoint#TotalPaidKPI],
    SelectionVariant: ![@UI.SelectionVariant#TotalPaidKPI],
    Detail          : {
      $Type                     : 'UI.KPIDetailType',
      DefaultPresentationVariant: ![@UI.PresentationVariant#TotalPaidKPI]
    }
  },

  // ── KPI 2: Total Beneficiaries (Page Title) ─────────────────────────────────
  UI.DataPoint #TotalBeneficiariesKPI: {
    $Type: 'UI.DataPointType',
    Value: TotalBeneficiaries,
    Title: 'Total Beneficiaries'
  },
  UI.Chart #TotalBeneficiariesKPI: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Total Beneficiaries by State',
    ChartType : #Bar,
    Dimensions: [State],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: State, Role: #Category }
    ],
    Measures  : [TotalBeneficiaries],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalBeneficiaries, Role: #Axis1 }
    ]
  },
  UI.PresentationVariant #TotalBeneficiariesKPI: {
    $Type         : 'UI.PresentationVariantType',
    Visualizations: ['@UI.Chart#TotalBeneficiariesKPI']
  },
  UI.SelectionVariant #TotalBeneficiariesKPI: {
    $Type: 'UI.SelectionVariantType',
    Text : 'Total Beneficiaries'
  },
  UI.KPI #TotalBeneficiariesKPI: {
    $Type           : 'UI.KPIType',
    ID              : 'TotalBeneficiariesKPI',
    DataPoint       : ![@UI.DataPoint#TotalBeneficiariesKPI],
    SelectionVariant: ![@UI.SelectionVariant#TotalBeneficiariesKPI],
    Detail          : {
      $Type                     : 'UI.KPIDetailType',
      DefaultPresentationVariant: ![@UI.PresentationVariant#TotalBeneficiariesKPI]
    }
  },

  // ── Visual filter charts (Page Header) ──────────────────────────────────────
  // OData V4 visual filters support only bar and line charts.
  UI.Chart #VFState: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Total Paid by State',
    ChartType : #Bar,
    Dimensions: [State],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: State, Role: #Category }
    ],
    Measures  : [TotalPaid],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalPaid, Role: #Axis1 }
    ]
  },
  UI.PresentationVariant #VFState: {
    $Type         : 'UI.PresentationVariantType',
    Visualizations: ['@UI.Chart#VFState']
  },

  UI.Chart #VFProviderType: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Total Paid by Provider Type',
    ChartType : #Bar,
    Dimensions: [ProviderType],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: ProviderType, Role: #Category }
    ],
    Measures  : [TotalPaid],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalPaid, Role: #Axis1 }
    ]
  },
  UI.PresentationVariant #VFProviderType: {
    $Type         : 'UI.PresentationVariantType',
    Visualizations: ['@UI.Chart#VFProviderType']
  }
);

// ── Visual filter value lists (link filter fields to the charts above) ─────────
annotate service.CostByStateProviderType with {
  State @Common.ValueList #VFState: {
    $Type                       : 'Common.ValueListType',
    Label                       : 'State',
    CollectionPath              : 'CostByStateProviderType',
    SearchSupported             : false,
    PresentationVariantQualifier: 'VFState',
    Parameters                  : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: State,
        ValueListProperty: 'State'
      }
    ]
  };

  ProviderType @Common.ValueList #VFProviderType: {
    $Type                       : 'Common.ValueListType',
    Label                       : 'Provider Type',
    CollectionPath              : 'CostByStateProviderType',
    SearchSupported             : false,
    PresentationVariantQualifier: 'VFProviderType',
    Parameters                  : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: ProviderType,
        ValueListProperty: 'ProviderType'
      }
    ]
  };
}
annotate service.RuralUrbanDistribution with @(

  UI.SelectionFields: [Year, State, RuralUrban],

  UI.LineItem: [
    { Value: Year,               Label: 'Year' },
    { Value: State,              Label: 'State' },
    { Value: RuralUrban,         Label: 'Rural/Urban' },
    { Value: ProviderCount,      Label: 'Provider Count' },
    { Value: TotalSubmitted,     Label: 'Total Submitted ($)' },
    { Value: TotalAllowed,       Label: 'Total Allowed ($)' },
    { Value: TotalPaid,          Label: 'Total Paid ($)' },
    { Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
    { Value: PaidPerBene,        Label: 'Paid / Beneficiary ($)' },
    { Value: AvgRiskScore,       Label: 'Avg Risk Score' }
  ],

  // Share/proportion story -> Donut on TotalPaid (summable -> correct on rollup).
  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Share of Total Paid by Rural/Urban',
    ChartType : #Donut,
    Dimensions: [RuralUrban],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: RuralUrban, Role: #Category }
    ],
    Measures  : [TotalPaid],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalPaid, Role: #Axis1 }
    ]
  },

  UI.PresentationVariant: {
    GroupBy       : [State, RuralUrban],
    Total         : [TotalPaid, TotalBeneficiaries, ProviderCount],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);

annotate service.RiskScoreDistribution with @(

  UI.SelectionFields: [Year, State, ProviderType, RiskBand],

  UI.LineItem: [
    { Value: Year,               Label: 'Year' },
    { Value: State,              Label: 'State' },
    { Value: ProviderType,       Label: 'Provider Type' },
    { Value: RiskBand,           Label: 'Risk Band' },
    { Value: ProviderCount,      Label: 'Provider Count' },
    { Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
    { Value: AvgRiskScore,       Label: 'Avg Risk Score' },
    { Value: AvgHypertensionPct, Label: 'Avg Hypertension %' },
    { Value: AvgDiabetesPct,     Label: 'Avg Diabetes %' },
    { Value: TotalPaid,          Label: 'Total Paid ($)' }
  ],

  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Provider Distribution by Risk Band',
    ChartType : #Column,
    Dimensions: [RiskBand],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: RiskBand, Role: #Category }
    ],
    Measures  : [ProviderCount],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: ProviderCount, Role: #Axis1 }
    ]
  },

  UI.PresentationVariant: {
    GroupBy       : [RiskBand, State],
    Total         : [ProviderCount, TotalBeneficiaries, TotalPaid],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);

annotate service.ProviderCostEfficiency with @(

  UI.SelectionFields: [Year, State, ProviderType, RiskCategory, EfficiencyCategory],

  UI.LineItem: [
    { Value: Year,                 Label: 'Year' },
    { Value: ProviderName,         Label: 'Provider Name' },
    { Value: ProviderType,         Label: 'Specialty' },
    { Value: State,                Label: 'State' },
    { Value: City,                 Label: 'City' },
    { Value: TotalBeneficiaries,   Label: 'Beneficiaries' },
    { Value: CostPerBeneficiary,   Label: 'Cost Per Beneficiary ($)' },
    { Value: TotalPaid,            Label: 'Total Paid ($)' },
    { Value: EfficiencyCategory,   Label: 'Efficiency' },
    { Value: RiskCategory,         Label: 'Risk Profile' },
    { Value: UtilizationCategory,  Label: 'Utilization' },
    { Value: AvgRiskScore,         Label: 'Avg Risk Score' },
    { Value: DiabetesPct,          Label: 'Diabetes %' },
    { Value: HypertensionPct,      Label: 'Hypertension %' }
  ],

  UI.Chart: {
    $Type    : 'UI.ChartDefinitionType',
    Title    : 'Providers per Efficiency Class',
    ChartType: #Column,
    Dimensions: [EfficiencyCategory],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: EfficiencyCategory, Role: #Category }
    ],
    Measures : [ProviderCount],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: ProviderCount, Role: #Axis1 }
    ]
  },

  // No GroupBy here: the TABLE lists individual providers (per-NPI rows) so the
  // auditor can see which providers fall in each class. The CHART aggregates
  // independently via its own Dimensions + the ApplySupported metadata.
  UI.PresentationVariant: {
    SortOrder     : [{ Property: CostPerBeneficiary, Descending: true }],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);

// ── Task 2: SpecialtyRiskProfile (specialty-level classification) ──────────────
annotate service.SpecialtyRiskProfile with @(

  UI.SelectionFields: [Year, ProviderType, ComplexityTier],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Specialty Profile',
    TypeNamePlural: 'Specialty Profiles',
    Title         : { $Type: 'UI.DataField', Value: ProviderType },
    Description   : { $Type: 'UI.DataField', Value: ComplexityTier }
  },

  UI.LineItem: [
    { Value: Year,               Label: 'Year' },
    { Value: ProviderType,       Label: 'Specialty' },
    { Value: ComplexityTier,     Label: 'Complexity Tier' },
    { Value: ProviderCount,      Label: 'Providers' },
    { Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
    { Value: AvgRiskScore,       Label: 'Avg Risk Score' },
    { Value: AvgCostPerBene,     Label: 'Avg Cost / Beneficiary ($)' },
    { Value: AvgHypertensionPct, Label: 'Avg Hypertension %' },
    { Value: AvgDiabetesPct,     Label: 'Avg Diabetes %' },
    { Value: AvgCKDPct,          Label: 'Avg CKD %' },
    { Value: AvgHeartFailurePct, Label: 'Avg Heart Failure %' },
    { Value: TotalPaid,          Label: 'Total Paid ($)' }
  ],

  UI.FieldGroup #SpecialtyDetails: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: Year,               Label: 'Year' },
      { $Type: 'UI.DataField', Value: ProviderType,       Label: 'Specialty' },
      { $Type: 'UI.DataField', Value: ComplexityTier,     Label: 'Complexity Tier' },
      { $Type: 'UI.DataField', Value: ProviderCount,      Label: 'Providers' },
      { $Type: 'UI.DataField', Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
      { $Type: 'UI.DataField', Value: AvgRiskScore,       Label: 'Avg Risk Score' },
      { $Type: 'UI.DataField', Value: AvgCostPerBene,     Label: 'Avg Cost / Beneficiary ($)' },
      { $Type: 'UI.DataField', Value: AvgHypertensionPct, Label: 'Avg Hypertension %' },
      { $Type: 'UI.DataField', Value: AvgDiabetesPct,     Label: 'Avg Diabetes %' },
      { $Type: 'UI.DataField', Value: AvgCKDPct,          Label: 'Avg CKD %' },
      { $Type: 'UI.DataField', Value: AvgHeartFailurePct, Label: 'Avg Heart Failure %' },
      { $Type: 'UI.DataField', Value: TotalPaid,          Label: 'Total Paid ($)' }
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'SpecialtyDetailsFacet',
      Label : 'Specialty Details',
      Target: '@UI.FieldGroup#SpecialtyDetails'
    }
  ],

  // Patient complexity comparison across specialties.
  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Average Risk Score by Specialty',
    ChartType : #Bar,
    Dimensions: [ProviderType],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: ProviderType, Role: #Category }
    ],
    Measures  : [AvgRiskScore],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: AvgRiskScore, Role: #Axis1 }
    ]
  },

  UI.PresentationVariant: {
    SortOrder     : [{ Property: AvgRiskScore, Descending: true }],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);

// ── Task 2: OrganizationClassification (Individual vs Organization) ────────────
annotate service.OrganizationClassification with @(

  UI.SelectionFields: [Year, State, EntityType],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Entity Segment',
    TypeNamePlural: 'Entity Segments',
    Title         : { $Type: 'UI.DataField', Value: EntityType },
    Description   : { $Type: 'UI.DataField', Value: State }
  },

  // Lean table focused on the classification story (size, cost-efficiency,
  // utilization, risk). Raw charge totals live on the object page only.
  UI.LineItem: [
    { Value: EntityType,         Label: 'Entity Type' },
    { Value: State,              Label: 'State' },
    { Value: Year,               Label: 'Year' },
    { Value: ProviderCount,      Label: 'Providers' },
    { Value: TotalBeneficiaries, Label: 'Beneficiaries' },
    { Value: CostPerBene,        Label: 'Cost / Bene ($)' },
    { Value: ServicesPerBene,    Label: 'Svcs / Bene' },
    { Value: AvgRiskScore,       Label: 'Avg Risk' }
  ],

  UI.FieldGroup #OrgDetails: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: Year,               Label: 'Year' },
      { $Type: 'UI.DataField', Value: State,              Label: 'State' },
      { $Type: 'UI.DataField', Value: EntityType,         Label: 'Entity Type' },
      { $Type: 'UI.DataField', Value: ProviderCount,      Label: 'Providers' },
      { $Type: 'UI.DataField', Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
      { $Type: 'UI.DataField', Value: CostPerBene,        Label: 'Cost / Beneficiary ($)' },
      { $Type: 'UI.DataField', Value: ServicesPerBene,    Label: 'Services / Beneficiary' },
      { $Type: 'UI.DataField', Value: AvgRiskScore,       Label: 'Avg Risk Score' },
      { $Type: 'UI.DataField', Value: TotalSubmitted,     Label: 'Total Submitted ($)' },
      { $Type: 'UI.DataField', Value: TotalAllowed,       Label: 'Total Allowed ($)' }
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'OrgDetailsFacet',
      Label : 'Segment Details',
      Target: '@UI.FieldGroup#OrgDetails'
    }
  ],

  // Core classification story: compare patient complexity (avg risk score) of
  // Individual clinicians vs Organizations. Single measure -> single clean axis.
  // Risk scores are bounded and comparable across states, so the AVG rollup is a
  // fair comparison (unlike unbounded cost ratios, which we keep in the table).
  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Average Patient Risk Score by Entity Type',
    ChartType : #Column,
    Dimensions: [EntityType],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: EntityType, Role: #Category }
    ],
    Measures  : [AvgRiskScore],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: AvgRiskScore, Role: #Axis1 }
    ]
  },

  UI.PresentationVariant: {
    GroupBy       : [EntityType, State],
    Total         : [ProviderCount, TotalBeneficiaries],
    SortOrder     : [{ Property: TotalBeneficiaries, Descending: true }],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);

// ══════════════════════════════════════════════════════════════════════════════
// Task 3 — Association Analysis
// ══════════════════════════════════════════════════════════════════════════════

// ── (A) RiskPaymentAssociation: risk ↔ volume ↔ payment ───────────────────────
annotate service.RiskPaymentAssociation with @(

  UI.SelectionFields: [Year, ProviderType, ComplexityTier],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Specialty Association',
    TypeNamePlural: 'Specialty Associations',
    Title         : { $Type: 'UI.DataField', Value: ProviderType },
    Description   : { $Type: 'UI.DataField', Value: ComplexityTier }
  },

  UI.LineItem: [
    { Value: Year,               Label: 'Year' },
    { Value: ProviderType,       Label: 'Specialty' },
    { Value: ComplexityTier,     Label: 'Complexity Tier' },
    { Value: ProviderCount,      Label: 'Providers' },
    { Value: TotalBeneficiaries, Label: 'Beneficiaries' },
    { Value: AvgRiskScore,       Label: 'Avg Risk Score' },
    { Value: ServicesPerBene,    Label: 'Services / Bene' },
    { Value: SubmittedPerBene,   Label: 'Submitted / Bene ($)' },
    { Value: PaidPerBene,        Label: 'Paid / Bene ($)' },
    { Value: TotalPaid,          Label: 'Total Paid ($)' }
  ],

  UI.FieldGroup #AssocDetails: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: Year,               Label: 'Year' },
      { $Type: 'UI.DataField', Value: ProviderType,       Label: 'Specialty' },
      { $Type: 'UI.DataField', Value: ComplexityTier,     Label: 'Complexity Tier' },
      { $Type: 'UI.DataField', Value: ProviderCount,      Label: 'Providers' },
      { $Type: 'UI.DataField', Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
      { $Type: 'UI.DataField', Value: AvgRiskScore,       Label: 'Avg Risk Score' },
      { $Type: 'UI.DataField', Value: ServicesPerBene,    Label: 'Services / Beneficiary' },
      { $Type: 'UI.DataField', Value: SubmittedPerBene,   Label: 'Submitted / Beneficiary ($)' },
      { $Type: 'UI.DataField', Value: PaidPerBene,        Label: 'Paid / Beneficiary ($)' },
      { $Type: 'UI.DataField', Value: TotalPaid,          Label: 'Total Paid ($)' }
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'AssocDetailsFacet',
      Label : 'Association Details',
      Target: '@UI.FieldGroup#AssocDetails'
    }
  ],

  // Core association as a bubble scatter: each bubble is a specialty.
  // X = patient complexity (risk), Y = paid per beneficiary, size = beneficiaries.
  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Patient Risk vs Paid per Beneficiary (by Specialty)',
    ChartType : #Bubble,
    Dimensions: [ProviderType],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: ProviderType, Role: #Category }
    ],
    Measures  : [AvgRiskScore, PaidPerBene, TotalBeneficiaries],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: AvgRiskScore,       Role: #Axis1 },
      { $Type: 'UI.ChartMeasureAttributeType', Measure: PaidPerBene,        Role: #Axis2 },
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalBeneficiaries, Role: #Axis3 }
    ]
  },

  // Overview-friendly aggregate chart: avg paid/bene per complexity tier.
  UI.Chart #AssocOVP: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Paid per Beneficiary by Complexity Tier',
    ChartType : #Column,
    Dimensions: [ComplexityTier],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: ComplexityTier, Role: #Category }
    ],
    Measures  : [PaidPerBene],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: PaidPerBene, Role: #Axis1 }
    ]
  },

  UI.PresentationVariant: {
    SortOrder     : [{ Property: PaidPerBene, Descending: true }],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  },

  UI.PresentationVariant #AssocOVP: {
    GroupBy       : [ComplexityTier],
    Visualizations: ['@UI.Chart#AssocOVP']
  }
);

// ── (B) ServicePlaceAnalysis: Facility vs Office ──────────────────────────────
annotate service.ServicePlaceAnalysis with @(

  UI.SelectionFields: [Year, State, PlaceOfService],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Place-of-Service Record',
    TypeNamePlural: 'Place-of-Service Records',
    Title         : { $Type: 'UI.DataField', Value: PlaceOfService },
    Description   : { $Type: 'UI.DataField', Value: State }
  },

  UI.LineItem: [
    { Value: Year,               Label: 'Year' },
    { Value: State,              Label: 'State' },
    { Value: PlaceOfService,     Label: 'Place of Service' },
    { Value: ServiceLineCount,   Label: 'Service Lines' },
    { Value: TotalServices,      Label: 'Total Services' },
    { Value: TotalBeneficiaries, Label: 'Beneficiaries' },
    { Value: AvgSubmittedChrg,   Label: 'Avg Submitted ($)' },
    { Value: AvgAllowedAmt,      Label: 'Avg Allowed ($)' },
    { Value: AvgPaidAmt,         Label: 'Avg Paid ($)' },
    { Value: PaymentToChargePct, Label: 'Paid / Submitted (%)' }
  ],

  UI.FieldGroup #PlaceDetails: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: Year,               Label: 'Year' },
      { $Type: 'UI.DataField', Value: State,              Label: 'State' },
      { $Type: 'UI.DataField', Value: PlaceOfService,     Label: 'Place of Service' },
      { $Type: 'UI.DataField', Value: ServiceLineCount,   Label: 'Service Lines' },
      { $Type: 'UI.DataField', Value: TotalServices,      Label: 'Total Services' },
      { $Type: 'UI.DataField', Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
      { $Type: 'UI.DataField', Value: AvgSubmittedChrg,   Label: 'Avg Submitted Charge ($)' },
      { $Type: 'UI.DataField', Value: AvgAllowedAmt,      Label: 'Avg Allowed Amount ($)' },
      { $Type: 'UI.DataField', Value: AvgPaidAmt,         Label: 'Avg Paid Amount ($)' },
      { $Type: 'UI.DataField', Value: PaymentToChargePct, Label: 'Paid / Submitted (%)' }
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'PlaceDetailsFacet',
      Label : 'Place-of-Service Details',
      Target: '@UI.FieldGroup#PlaceDetails'
    }
  ],

  // Charge-to-payment gap by place of service: submitted vs allowed vs paid.
  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Submitted vs Allowed vs Paid by Place of Service',
    ChartType : #Column,
    Dimensions: [PlaceOfService],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: PlaceOfService, Role: #Category }
    ],
    Measures  : [AvgSubmittedChrg, AvgAllowedAmt, AvgPaidAmt],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: AvgSubmittedChrg, Role: #Axis1 },
      { $Type: 'UI.ChartMeasureAttributeType', Measure: AvgAllowedAmt,    Role: #Axis1 },
      { $Type: 'UI.ChartMeasureAttributeType', Measure: AvgPaidAmt,       Role: #Axis1 }
    ]
  },

  UI.PresentationVariant: {
    GroupBy       : [PlaceOfService],
    SortOrder     : [{ Property: AvgPaidAmt, Descending: true }],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);

// ── (C) CredentialChargeGap: submitted vs paid by credential ──────────────────
annotate service.CredentialChargeGap with @(

  UI.SelectionFields: [Year, Credential],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Credential Group',
    TypeNamePlural: 'Credential Groups',
    Title         : { $Type: 'UI.DataField', Value: Credential },
    Description   : { $Type: 'UI.DataField', Value: Year }
  },

  UI.LineItem: [
    { Value: Year,               Label: 'Year' },
    { Value: Credential,         Label: 'Credential' },
    { Value: ProviderCount,      Label: 'Providers' },
    { Value: TotalBeneficiaries, Label: 'Beneficiaries' },
    { Value: AvgRiskScore,       Label: 'Avg Risk Score' },
    { Value: AllowedToChargePct, Label: 'Allowed / Submitted (%)' },
    { Value: PaymentToChargePct, Label: 'Paid / Submitted (%)' },
    { Value: PaidPerBene,        Label: 'Paid / Bene ($)' },
    { Value: TotalSubmitted,     Label: 'Total Submitted ($)' },
    { Value: TotalPaid,          Label: 'Total Paid ($)' }
  ],

  UI.FieldGroup #CredDetails: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: Year,               Label: 'Year' },
      { $Type: 'UI.DataField', Value: Credential,         Label: 'Credential' },
      { $Type: 'UI.DataField', Value: ProviderCount,      Label: 'Providers' },
      { $Type: 'UI.DataField', Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
      { $Type: 'UI.DataField', Value: AvgRiskScore,       Label: 'Avg Risk Score' },
      { $Type: 'UI.DataField', Value: AllowedToChargePct, Label: 'Allowed / Submitted (%)' },
      { $Type: 'UI.DataField', Value: PaymentToChargePct, Label: 'Paid / Submitted (%)' },
      { $Type: 'UI.DataField', Value: PaidPerBene,        Label: 'Paid / Beneficiary ($)' },
      { $Type: 'UI.DataField', Value: TotalSubmitted,     Label: 'Total Submitted ($)' },
      { $Type: 'UI.DataField', Value: TotalAllowed,       Label: 'Total Allowed ($)' },
      { $Type: 'UI.DataField', Value: TotalPaid,          Label: 'Total Paid ($)' }
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'CredDetailsFacet',
      Label : 'Credential Details',
      Target: '@UI.FieldGroup#CredDetails'
    }
  ],

  // Share of billed charges actually paid, compared across credential groups.
  UI.Chart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Paid-to-Submitted Ratio by Credential',
    ChartType : #Bar,
    Dimensions: [Credential],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: Credential, Role: #Category }
    ],
    Measures  : [PaymentToChargePct],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: PaymentToChargePct, Role: #Axis1 }
    ]
  },

  UI.PresentationVariant: {
    GroupBy       : [Credential],
    SortOrder     : [{ Property: ProviderCount, Descending: true }],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);
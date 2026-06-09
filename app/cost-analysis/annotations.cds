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

  UI.SelectionFields: [Year, State, RuralInd],

  UI.LineItem: [
    { Value: Year,               Label: 'Year' },
    { Value: State,              Label: 'State' },
    { Value: RuralInd,           Label: 'Rural/Urban' },
    { Value: Locality,           Label: 'Locality' },
    { Value: ProviderCount,      Label: 'Provider Count' },
    { Value: TotalPaid,          Label: 'Total Paid ($)' },
    { Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
    { Value: AvgRiskScore,       Label: 'Avg Risk Score' }
  ],

  UI.Chart: {
    Title    : 'Total Paid by Rural/Urban',
    ChartType: #Bar,
    Dimensions: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: RuralInd }
    ],
    Measures: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalPaid }
    ]
  }
);

annotate service.RiskScoreDistribution with @(

  UI.SelectionFields: [Year, State, ProviderType],

  UI.LineItem: [
    { Value: Year,               Label: 'Year' },
    { Value: NPI,                Label: 'NPI' },
    { Value: ProviderName,       Label: 'Provider Name' },
    { Value: ProviderType,       Label: 'Provider Type' },
    { Value: State,              Label: 'State' },
    { Value: City,               Label: 'City' },
    { Value: AvgRiskScore,       Label: 'Avg Risk Score' },
    { Value: TotalBeneficiaries, Label: 'Total Beneficiaries' },
    { Value: HypertensionPct,    Label: 'Hypertension %' },
    { Value: DiabetesPct,        Label: 'Diabetes %' },
    { Value: CKDPct,             Label: 'CKD %' },
    { Value: HeartFailurePct,    Label: 'Heart Failure %' },
    { Value: TotalPaid,          Label: 'Total Paid ($)' },
    { Value: RuralInd,           Label: 'Rural/Urban' }
  ]
);
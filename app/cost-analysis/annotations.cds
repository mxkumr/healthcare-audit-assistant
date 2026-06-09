using MedicareService as service from '../../srv/medicare-service';

annotate service.CostByStateProviderType with @(

  UI.SelectionFields: [Year, State, ProviderType],

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

  UI.Chart: {
    Title    : 'Total Paid by State',
    ChartType: #Bar,
    Dimensions: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: State }
    ],
    Measures: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: TotalPaid }
    ]
  },

  UI.PresentationVariant: {
    GroupBy       : [State, ProviderType],
    Total         : [TotalPaid, TotalSubmitted, ProviderCount],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);
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
    Title    : 'Cost Efficiency by Provider Type',
    ChartType: #Bar,
    Dimensions: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: EfficiencyCategory }
    ],
    Measures: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: CostPerBeneficiary }
    ]
  },

  UI.PresentationVariant: {
    SortOrder: [{
      Property: CostPerBeneficiary,
      Descending: true
    }],
    Visualizations: ['@UI.LineItem', '@UI.Chart']
  }
);
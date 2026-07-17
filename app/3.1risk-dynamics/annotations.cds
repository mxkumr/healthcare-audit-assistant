using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// RiskCostVolumeDynamics — Task 3.1 Risk-Cost-Volume Dynamics ALP
// Chart (top): dual-axis column — avg patient risk (left) vs avg cost/patient (right)
// Table (bottom): specialty-level audit log sorted by cost intensity
// Object page: specialty KPIs + providers (sorted by Total Amount Paid desc)
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.RiskCostVolumeDynamics with @(

  UI.SelectionFields: [Year, Specialty, providers.ProviderName],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Specialty Risk-Cost Profile',
    TypeNamePlural: 'Specialty Risk-Cost Profiles',
    Title         : { $Type: 'UI.DataField', Value: Specialty },
    Description   : { $Type: 'UI.DataField', Value: Year }
  },

  UI.DataPoint #PatientRiskScoreFmt: {
    $Type      : 'UI.DataPointType',
    Value      : PatientRiskScore,
    Title      : 'Avg Patient Risk Score (Complexity)',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.DataPoint #CostPerPatientFmt: {
    $Type      : 'UI.DataPointType',
    Value      : CostPerPatient,
    Title      : 'Avg Cost per Patient',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.Chart #RiskCostDualAxis: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Cost-Complexity Frontier: Specialty Risk vs. Billing Intensity',
    ChartType : #ColumnDual,
    Dimensions: [Specialty],
    Measures  : [
      PatientRiskScore,
      CostPerPatient
    ],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: Specialty,
        Role     : #Category
      }
    ],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : PatientRiskScore,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#PatientRiskScoreFmt]
      },
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : CostPerPatient,
        Role     : #Axis2,
        DataPoint: ![@UI.DataPoint#CostPerPatientFmt]
      }
    ]
  },

  UI.PresentationVariant #RiskCostChart: {
    $Type         : 'UI.PresentationVariantType',
    SortOrder     : [{ Property: CostPerPatient, Descending: true }],
    Visualizations: ['@UI.Chart#RiskCostDualAxis']
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
    Text               : 'Risk-Cost-Volume Dynamics Dashboard',
    SelectionVariant   : ![@UI.SelectionVariant#DefaultYear],
    PresentationVariant: ![@UI.PresentationVariant#RiskCostChart]
  },

  UI.LineItem: [
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'MedicareService.EntityContainer/checkAI',
      Label : '{i18n>Evaluate_AI}'
    },
    { $Type: 'UI.DataField', Value: Specialty,              Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: TotalUniqueProviders,   Label: 'Total Unique Providers' },
    {
      $Type      : 'UI.DataField',
      Value      : PatientRiskScore,
      Label      : 'Avg Patient Risk Score (Complexity)',
      ![@UI.DataPoint]: ![@UI.DataPoint#PatientRiskScoreFmt]
    },
    {
      $Type      : 'UI.DataField',
      Value      : CostPerPatient,
      Label      : 'Avg Cost per Patient ($)',
      ![@UI.DataPoint]: ![@UI.DataPoint#CostPerPatientFmt]
    },
    { $Type: 'UI.DataField', Value: TotalPatientsServed,    Label: 'Total Patients Served' },
    { $Type: 'UI.DataField', Value: TotalActualPayments,      Label: 'Total Actual Payments' }
  ],

  UI.PresentationVariant #RiskCostTable: {
    $Type         : 'UI.PresentationVariantType',
    SortOrder     : [{ Property: CostPerPatient, Descending: true }],
    Visualizations: ['@UI.LineItem']
  },

  UI.FieldGroup #SpecialtyProfile: {
    $Type: 'UI.FieldGroupType',
    Data : [
      { $Type: 'UI.DataField', Value: Year,                 Label: 'Year' },
      { $Type: 'UI.DataField', Value: Specialty,            Label: 'Specialty' },
      { $Type: 'UI.DataField', Value: TotalUniqueProviders, Label: 'Total Unique Providers' },
      {
        $Type : 'UI.DataField',
        Value : PatientRiskScore,
        Label : 'Avg Patient Risk Score (Complexity)',
        ![@UI.DataPoint]: ![@UI.DataPoint#PatientRiskScoreFmt]
      },
      {
        $Type : 'UI.DataField',
        Value : CostPerPatient,
        Label : 'Avg Cost per Patient ($)',
        ![@UI.DataPoint]: ![@UI.DataPoint#CostPerPatientFmt]
      },
      { $Type: 'UI.DataField', Value: TotalPatientsServed, Label: 'Total Patients Served' },
      { $Type: 'UI.DataField', Value: TotalActualPayments, Label: 'Total Actual Payments' }
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'SpecialtyProfileFacet',
      Label : 'Specialty Risk-Cost Profile',
      Target: '@UI.FieldGroup#SpecialtyProfile'
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'ProvidersFacet',
      Label : 'Providers in Specialty',
      Target: 'providers/@UI.PresentationVariant#Providers'
    }
  ]
);

annotate service.RiskCostVolumeDynamics with {
  Year @(
    Common.Label     : 'Year',
    Common.QuickInfo : 'Calendar year of the Medicare provider summary record.',
    Core.Description : 'Filter to a single year before comparing specialties — defaults to 2022.'
  );

  Specialty @(
    Common.Label     : 'Specialty',
    Common.QuickInfo : 'CMS provider type / specialty classification.',
    Core.Description : 'Chart category — one dual-axis column pair per specialty at Year grain.',
    UI.LineItem      : [{ position: 10 }],
    Common.ValueList #SpecialtyVH: {
      $Type                   : 'Common.ValueListType',
      CollectionPath          : 'RiskCostVolumeDynamics',
      DistinctValuesSupported : true,
      SearchSupported         : true,
      Parameters              : [
        {
          $Type            : 'Common.ValueListParameterInOut',
          LocalDataProperty: Specialty,
          ValueListProperty: 'Specialty'
        },
        {
          $Type            : 'Common.ValueListParameterIn',
          LocalDataProperty: Year,
          ValueListProperty: 'Year'
        }
      ]
    }
  );

  TotalUniqueProviders @(
    Common.Label     : 'Total Unique Providers',
    Common.QuickInfo : 'count(distinct NPI) within the specialty-year cohort.',
    Core.Description : 'Panel breadth — how many distinct billing entities contribute to the specialty averages.',
    UI.LineItem      : [{ position: 20 }]
  );

  PatientRiskScore @(
    Common.Label     : 'Avg Patient Risk Score (Complexity)',
    Common.QuickInfo : 'Beneficiary-weighted mean HCC risk score across the specialty.',
    Core.Description : 'Left chart axis — sum(AvgRiskScore × TotalBeneficiaries) ÷ sum(TotalBeneficiaries).',
    UI.LineItem      : [{ position: 30 }]
  );

  CostPerPatient @(
    Common.Label        : 'Avg Cost per Patient ($)',
    Common.QuickInfo    : 'Beneficiary-weighted Medicare spend per patient for the specialty.',
    Core.Description    : 'Right chart axis and table sort key — sum(payments) ÷ sum(beneficiaries).',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 40 }]
  );

  TotalPatientsServed @(
    Common.Label     : 'Total Patients Served',
    Common.QuickInfo : 'Sum of Medicare beneficiaries treated across all providers in the specialty.',
    Core.Description : 'Volume context for interpreting per-patient averages.',
    UI.LineItem      : [{ position: 50 }]
  );

  TotalActualPayments @(
    Common.Label        : 'Total Actual Payments',
    Common.QuickInfo    : 'Total Medicare cash disbursed to the specialty cohort.',
    Core.Description    : 'Dollar volume behind the per-patient cost intensity metric.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 60 }]
  );

  providers @(
    Common.Label     : 'Providers',
    Common.QuickInfo : 'Individual providers (NPI) in this Year × Specialty from ProviderCostEfficiency.'
  );
};

annotate service.RiskCostVolumeDynamics:providers with {
  ProviderName @(
    Common.Label     : 'Provider',
    Common.QuickInfo : 'Provider name within the selected specialty (cascades from Specialty / Year filters).',
    Common.ValueList #ProviderVH: {
      $Type                   : 'Common.ValueListType',
      CollectionPath          : 'ProviderCostEfficiency',
      DistinctValuesSupported : true,
      SearchSupported         : true,
      Parameters              : [
        {
          $Type            : 'Common.ValueListParameterInOut',
          LocalDataProperty: providers.ProviderName,
          ValueListProperty: 'ProviderName'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'NPI'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'State'
        },
        {
          $Type            : 'Common.ValueListParameterIn',
          LocalDataProperty: Specialty,
          ValueListProperty: 'ProviderType'
        },
        {
          $Type            : 'Common.ValueListParameterIn',
          LocalDataProperty: Year,
          ValueListProperty: 'Year'
        }
      ]
    }
  );
};

annotate service.ProviderCostEfficiency with @(
  UI.LineItem #Providers: [
    { $Type: 'UI.DataField', Value: ProviderName,        Label: 'Provider Name' },
    { $Type: 'UI.DataField', Value: NPI,                 Label: 'NPI' },
    { $Type: 'UI.DataField', Value: State,               Label: 'State' },
    { $Type: 'UI.DataField', Value: CostPerBeneficiary,  Label: 'Cost per Patient' },
    { $Type: 'UI.DataField', Value: TotalActualPayments, Label: 'Total Amount Paid' },
    { $Type: 'UI.DataField', Value: EfficiencyCategory,  Label: 'Cost Classification' },
    { $Type: 'UI.DataField', Value: UtilizationCategory, Label: 'Utilization Profile' },
    { $Type: 'UI.DataField', Value: TotalBeneficiaries,  Label: 'Patients Served' }
  ],

  UI.PresentationVariant #Providers: {
    $Type         : 'UI.PresentationVariantType',
    SortOrder     : [{ Property: TotalActualPayments, Descending: true }],
    Visualizations: ['@UI.LineItem#Providers']
  }
);

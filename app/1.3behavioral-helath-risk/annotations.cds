using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// BehavioralHealthRiskProfile — Task 1.3 Cost-Complexity Frontier ALP
// Chart (top): bubble — risk score (X) vs paid/beneficiary (Y), BH group series
// Table (bottom): peer-group audit log grouped by specialty, sorted by cost intensity
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.BehavioralHealthRiskProfile with @(

  UI.SelectionFields: [Year, State, ProviderType, BHBurdenGroup],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Cost-Complexity Peer Group',
    TypeNamePlural: 'Cost-Complexity Peer Groups',
    Title         : { $Type: 'UI.DataField', Value: ProviderType },
    Description   : { $Type: 'UI.DataField', Value: BHBurdenGroup }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LAYER — cost-complexity frontier (Zone 1 baseline vs Zone 2 audit)
  // AvgRiskScore → #Axis1 (X) | PaidPerBeneficiary → #Axis2 (Y) | BH group → #Series
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #AvgRiskScoreFmt: {
    $Type      : 'UI.DataPointType',
    Value      : AvgRiskScore,
    Title      : 'Avg Risk Score',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 3
    }
  },

  UI.DataPoint #PaidPerBeneficiaryFmt: {
    $Type      : 'UI.DataPointType',
    Value      : PaidPerBeneficiary,
    Title      : 'Paid per Beneficiary',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.Chart #CostComplexityFrontier: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Cost-Complexity Frontier: Risk Score vs. Medicare Paid',
    ChartType : #Bubble,
    Dimensions: [
      ProviderType,
      BHBurdenGroup
    ],
    Measures  : [
      AvgRiskScore,
      PaidPerBeneficiary,
      ProviderCount
    ],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: ProviderType,
        Role     : #Category
      },
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: BHBurdenGroup,
        Role     : #Series
      }
    ],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : AvgRiskScore,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#AvgRiskScoreFmt]
      },
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : PaidPerBeneficiary,
        Role     : #Axis2,
        DataPoint: ![@UI.DataPoint#PaidPerBeneficiaryFmt]
      },
      {
        $Type   : 'UI.ChartMeasureAttributeType',
        Measure : ProviderCount,
        Role    : #Axis3
      }
    ]
  },

  UI.PresentationVariant #FrontierChart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [ProviderType],
    SortOrder     : [{ Property: PaidPerBeneficiary, Descending: true }],
    Visualizations: ['@UI.Chart#CostComplexityFrontier']
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
    Text               : 'Cost-Complexity Frontier Dashboard',
    SelectionVariant   : ![@UI.SelectionVariant#DefaultYear],
    PresentationVariant: ![@UI.PresentationVariant#FrontierChart]
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM LAYER — peer groups collapsed by specialty; expand to state × BH group
  // Sort by PaidPerBeneficiary desc to surface Zone 2 audit candidates first
  // ═══════════════════════════════════════════════════════════════════════════
  UI.LineItem: [
    { $Type: 'UI.DataField', Value: ProviderType,         Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: State,                Label: 'State' },
    { $Type: 'UI.DataField', Value: BHBurdenGroup,        Label: 'BH Burden Group' },
    { $Type: 'UI.DataField', Value: ProviderCount,        Label: 'Provider Count' },
    {
      $Type      : 'UI.DataField',
      Value      : AvgRiskScore,
      Label      : 'Avg Risk Score',
      ![@UI.DataPoint]: ![@UI.DataPoint#AvgRiskScoreFmt]
    },
    {
      $Type      : 'UI.DataField',
      Value      : PaidPerBeneficiary,
      Label      : 'Paid per Beneficiary',
      ![@UI.DataPoint]: ![@UI.DataPoint#PaidPerBeneficiaryFmt]
    },
    { $Type: 'UI.DataField', Value: TotalBeneficiaries,   Label: 'Total Beneficiaries' },
    { $Type: 'UI.DataField', Value: TotalPaid,            Label: 'Total Medicare Paid' }
  ],

  UI.PresentationVariant #FrontierTable: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [ProviderType],
    SortOrder     : [
      { Property: PaidPerBeneficiary, Descending: true },
      { Property: State,              Descending: false },
      { Property: BHBurdenGroup,      Descending: false }
    ],
    Visualizations: ['@UI.LineItem']
  }
);

annotate service.BehavioralHealthRiskProfile with {
  Year @(
    Common.Label     : 'Year',
    Common.QuickInfo : 'Calendar year of the Medicare provider summary record.',
    Core.Description : 'Filter to a single year before comparing peer groups — defaults to 2022.'
  );

  State @(
    Common.Label     : 'State',
    Common.QuickInfo : 'Provider state abbreviation — part of the peer-group key.',
    Core.Description : 'Peer groups are Year × State × Specialty. Expand a specialty row to compare states.',
    UI.LineItem      : [{ position: 20 }]
  );

  ProviderType @(
    Common.Label     : 'Specialty',
    Common.QuickInfo : 'CMS provider specialty (peer-group dimension).',
    Core.Description : 'Table groups by specialty. Each leaf row is one State × Specialty × BH burden bucket.',
    UI.LineItem      : [{ position: 10 }]
  );

  BHBurdenGroup @(
    Common.Label     : 'BH Burden Group',
    Common.QuickInfo : 'A = below peer median BH burden; B = at/above peer median.',
    Core.Description : 'Derived from 11 CMS behavioral-health prevalence fields vs the median within the same Year × State × Specialty peer group (min 10 providers). Chart series dimension.',
    UI.LineItem      : [{ position: 30 }],
    Common.ValueListWithFixedValues: [
      { Value: 'A - Low BH Burden',  Label: 'A - Low BH Burden' },
      { Value: 'B - High BH Burden', Label: 'B - High BH Burden' }
    ]
  );

  ProviderCount @(
    Common.Label     : 'Provider Count',
    Common.QuickInfo : 'Distinct NPIs in this peer-group × BH bucket.',
    Core.Description : 'Bubble size on the frontier chart. Small counts (<10) are excluded at the median pass.',
    UI.LineItem      : [{ position: 40 }]
  );

  AvgRiskScore @(
    Common.Label     : 'Avg Risk Score',
    Common.QuickInfo : 'Mean beneficiary HCC risk score — X-axis on the frontier chart.',
    Core.Description : 'Zone 2 audit signal: low risk score paired with high paid/beneficiary (upper-left on chart).',
    UI.LineItem      : [{ position: 50 }]
  );

  PaidPerBeneficiary @(
    Common.Label        : 'Paid per Beneficiary',
    Common.QuickInfo    : 'Total Medicare paid ÷ total beneficiaries — Y-axis on the frontier chart.',
    Core.Description    : 'sum(Tot_Mdcr_Pymt_Amt) ÷ sum(Tot_Benes). Table sort key. Expected: Group B ≥ Group A on both axes.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 60 }]
  );

  TotalBeneficiaries @(
    Common.Label     : 'Total Beneficiaries',
    Common.QuickInfo : 'Patient volume in this peer-group bucket.',
    UI.LineItem      : [{ position: 70 }]
  );

  TotalPaid @(
    Common.Label        : 'Total Medicare Paid',
    Common.QuickInfo    : 'Cash disbursed in this peer-group bucket.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 80 }]
  );

  TotalSubmitted @(
    Common.Label        : 'Total Submitted Charges',
    Measures.ISOCurrency: 'USD'
  );

  TotalAllowed @(
    Common.Label        : 'Total Allowed Charges',
    Measures.ISOCurrency: 'USD'
  );

  TotalDrugPaid @(
    Common.Label        : 'Total Drug Paid',
    Measures.ISOCurrency: 'USD'
  );
};

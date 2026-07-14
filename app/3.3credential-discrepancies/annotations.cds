using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// CredentialDiscrepancies - Task 3.3 Credentials & Charge Discrepancies ALP
// Chart (top): charge-padding rate by credential (Submitted - Allowed)
// Table (bottom): split gap - charge padding vs policy shortfall vs paid/allowed
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.CredentialDiscrepancies with @(

  UI.SelectionFields: [Year, StandardizedCredential],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Credential Discrepancy Record',
    TypeNamePlural: 'Credential Discrepancy Records',
    Title         : { $Type: 'UI.DataField', Value: StandardizedCredential },
    Description   : { $Type: 'UI.DataField', Value: Year }
  },

  UI.DataPoint #ChargePaddingRatePctFmt: {
    $Type      : 'UI.DataPointType',
    Value      : ChargePaddingRatePct,
    Title      : 'Charge Padding Rate (%)',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 1
    },
    CriticalityCalculation: {
      $Type                  : 'UI.CriticalityCalculationType',
      ImprovementDirection   : #Minimize,
      ToleranceRangeHighValue: 50,
      DeviationRangeHighValue: 80
    }
  },

  UI.DataPoint #ChargePaddingAmtFmt: {
    $Type      : 'UI.DataPointType',
    Value      : ChargePaddingAmt,
    Title      : 'Charge Padding Amount',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 0
    },
    CriticalityCalculation: {
      $Type                  : 'UI.CriticalityCalculationType',
      ImprovementDirection   : #Minimize,
      ToleranceRangeHighValue: 1000000,
      DeviationRangeHighValue: 5000000
    }
  },

  UI.DataPoint #PolicyShortfallAmtFmt: {
    $Type      : 'UI.DataPointType',
    Value      : PolicyShortfallAmt,
    Title      : 'Policy Shortfall Amount',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 0
    }
  },

  UI.DataPoint #PaidToAllowedRatePctFmt: {
    $Type      : 'UI.DataPointType',
    Value      : PaidToAllowedRatePct,
    Title      : 'Paid-to-Allowed Rate (%)',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 1
    }
  },

  UI.Chart #CredentialDiscrepancyChart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Charge Padding Rate (%) by Provider Credentials',
    ChartType : #Bar,
    Dimensions: [StandardizedCredential],
    Measures  : [ChargePaddingRatePct],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: StandardizedCredential,
        Role     : #Category
      }
    ],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : ChargePaddingRatePct,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#ChargePaddingRatePctFmt]
      }
    ]
  },

  UI.PresentationVariant #CredentialDiscrepancyChart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [StandardizedCredential],
    SortOrder     : [{ Property: ChargePaddingRatePct, Descending: true }],
    Visualizations: ['@UI.Chart#CredentialDiscrepancyChart']
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
    Text               : 'Credential Discrepancies Dashboard',
    SelectionVariant   : ![@UI.SelectionVariant#DefaultYear],
    PresentationVariant: ![@UI.PresentationVariant#CredentialDiscrepancyChart]
  },

  // BOTTOM LAYER - audit story table (fraud vs policy vs statutory rate)
  UI.LineItem: [
    { $Type: 'UI.DataField', Value: StandardizedCredential, Label: 'Standardized Credential' },
    { $Type: 'UI.DataField', Value: TotalUniqueProviders,   Label: 'Total Unique Providers' },
    {
      $Type      : 'UI.DataField',
      Value      : ChargePaddingAmt,
      Label      : 'Charge Padding Amount (Fraud Signal)',
      ![@UI.DataPoint]: ![@UI.DataPoint#ChargePaddingAmtFmt],
      CriticalityCalculation: {
        $Type                  : 'UI.CriticalityCalculationType',
        ImprovementDirection   : #Minimize,
        ToleranceRangeHighValue: 1000000,
        DeviationRangeHighValue: 5000000
      },
      ![@UI.CriticalityRepresentation]: #WithIcon
    },
    {
      $Type      : 'UI.DataField',
      Value      : ChargePaddingRatePct,
      Label      : 'Charge Padding Rate (%)',
      ![@UI.DataPoint]: ![@UI.DataPoint#ChargePaddingRatePctFmt],
      CriticalityCalculation: {
        $Type                  : 'UI.CriticalityCalculationType',
        ImprovementDirection   : #Minimize,
        ToleranceRangeHighValue: 50,
        DeviationRangeHighValue: 80
      },
      ![@UI.CriticalityRepresentation]: #WithIcon
    },
    {
      $Type      : 'UI.DataField',
      Value      : PolicyShortfallAmt,
      Label      : 'Policy Shortfall Amount (Statutory Gap)',
      ![@UI.DataPoint]: ![@UI.DataPoint#PolicyShortfallAmtFmt]
    },
    {
      $Type      : 'UI.DataField',
      Value      : PaidToAllowedRatePct,
      Label      : 'Paid-to-Allowed Rate (%) - NP/PA ~85%',
      ![@UI.DataPoint]: ![@UI.DataPoint#PaidToAllowedRatePctFmt]
    }
  ],

  UI.PresentationVariant #CredentialDiscrepancyTable: {
    $Type         : 'UI.PresentationVariantType',
    SortOrder     : [{ Property: ChargePaddingAmt, Descending: true }],
    Visualizations: ['@UI.LineItem']
  }
);

annotate service.CredentialDiscrepancies with {
  Year @(
    Common.Label     : 'Year',
    Common.QuickInfo : 'Calendar year of the Medicare provider summary record.',
    Core.Description : 'Metrics are computed within each year - filter to a single year before comparing credential buckets.'
  );

  StandardizedCredential @(
    Common.Label     : 'Standardized Credential',
    Common.QuickInfo : 'Clinical degree or license bucket after normalizing raw CMS credential text.',
    Core.Description : 'Groups providers by practitioner class (MD, DO, NP, PA, CRNA, etc.). Raw values like "M.D." and "MD" map to the same bucket. Use this column to compare billing behavior across credential types - not individual providers.',
    UI.LineItem      : [{ position: 10 }],
    Common.ValueListWithFixedValues: [
      { Value: 'MD - Doctor of Medicine',       Label: 'MD - Doctor of Medicine' },
      { Value: 'DO - Osteopathic Medicine',     Label: 'DO - Osteopathic Medicine' },
      { Value: 'NP - Nurse Practitioner',       Label: 'NP - Nurse Practitioner' },
      { Value: 'PA - Physician Assistant',      Label: 'PA - Physician Assistant' },
      { Value: 'CRNA - Nurse Anesthetist',      Label: 'CRNA - Nurse Anesthetist' },
      { Value: 'Unspecified Credentials',       Label: 'Unspecified Credentials' },
      { Value: 'Other Specialists',             Label: 'Other Specialists' }
    ]
  );

  TotalUniqueProviders @(
    Common.Label     : 'Total Unique Providers',
    Common.QuickInfo : 'How many distinct NPIs fall in this credential bucket for the selected year.',
    Core.Description : 'count(distinct Rndrng_NPI). Scale indicator only - a high charge-padding rate on 200 providers is more actionable than the same rate on 5 providers.',
    UI.LineItem      : [{ position: 20 }]
  );

  TotalPatientsServed @(
    Common.Label     : 'Total Patients Served',
    Common.QuickInfo : 'Sum of beneficiaries across providers in this credential bucket.'
  );

  TotalSubmittedCharges @(
    Common.Label        : 'Total Submitted Charges',
    Common.QuickInfo    : 'Gross amount providers billed Medicare before adjudication.',
    Measures.ISOCurrency: 'USD'
  );

  TotalAllowedCharges @(
    Common.Label        : 'Total Allowed Charges',
    Common.QuickInfo    : 'Maximum amount Medicare fee schedules permit.',
    Core.Description    : 'sum(Tot_Mdcr_Alowd_Amt) - the Medicare-approved cap before payment rules and cost-sharing.',
    Measures.ISOCurrency: 'USD'
  );

  TotalActualPayments @(
    Common.Label        : 'Total Actual Payments',
    Common.QuickInfo    : 'Cash Medicare actually disbursed.',
    Measures.ISOCurrency: 'USD'
  );

  ChargePaddingAmt @(
    Common.Label        : 'Charge Padding Amount (Fraud Signal)',
    Common.QuickInfo    : 'Dollar volume billed above Medicare fee-schedule caps - primary charge-inflation indicator.',
    Core.Description    : 'sum(Tot_Sbmtd_Chrg) - sum(Tot_Mdcr_Alowd_Amt). Answers: "How much did this credential class ask for beyond what Medicare allows?" High values flag potential charge padding (e.g. billing $1,000 for a $100 cap). Table sorts by this column descending so worst buckets surface first.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 30 }]
  );

  ChargePaddingRatePct @(
    Common.Label     : 'Charge Padding Rate (%)',
    Common.QuickInfo : 'Percentage of submitted charges rejected by Medicare fee schedules - normalized fraud indicator.',
    Core.Description : 'round(ChargePaddingAmt ÷ TotalSubmittedCharges × 100). Pairs with Charge Padding Amount: the dollar column shows volume, this column shows intensity. Matches the top chart measure.',
    Measures.Unit    : '%',
    UI.LineItem      : [{ position: 40 }]
  );

  PolicyShortfallAmt @(
    Common.Label        : 'Policy Shortfall Amount (Statutory Gap)',
    Common.QuickInfo    : 'Dollar gap between Medicare allowed amounts and actual payments - policy and cost-sharing, not charge inflation.',
    Core.Description    : 'sum(Tot_Mdcr_Alowd_Amt) - sum(Tot_Mdcr_Pymt_Amt). Answers: "How much of the allowed amount was not paid out?" Reflects statutory rules (e.g. NP/PA paid at 85% of physician rate) and patient deductibles/coinsurance. A large value here with normal Paid-to-Allowed is often expected policy, not fraud.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 50 }]
  );

  PaidToAllowedRatePct @(
    Common.Label     : 'Paid-to-Allowed Rate (%) - NP/PA ~85%',
    Common.QuickInfo : 'Share of fee-schedule-allowed charges that Medicare actually paid out.',
    Core.Description : 'round(TotalActualPayments ÷ TotalAllowedCharges × 100). Answers: "What fraction of the allowed amount became payment?" NP and PA buckets typically cluster near ~85% due to statutory mid-level reimbursement. MD/DO buckets usually higher. If NP/PA is near 85% but charge padding is low, the gap is policy - not abuse.',
    Measures.Unit    : '%',
    UI.LineItem      : [{ position: 60 }]
  );
};

using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// PlaceOfServiceProviderProfiles — Task 3.2 Place of Service Analysis ALP
// Chart (top): stacked column — avg payment per service by specialty × POS setting
// Table (bottom): specialty groups (collapsed) → expand to individual providers
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.PlaceOfServiceProviderProfiles with @(

  UI.SelectionFields: [Year, Specialty, PlaceOfService, State],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Provider Place of Service Record',
    TypeNamePlural: 'Provider Place of Service Records',
    Title         : { $Type: 'UI.DataField', Value: ProviderName },
    Description   : { $Type: 'UI.DataField', Value: PlaceOfService }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LAYER — stacked column chart (facility vs office payment disparity)
  // Specialty → #Category | PlaceOfService → #Series
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #AvgPaymentPerServiceFmt: {
    $Type      : 'UI.DataPointType',
    Value      : AvgPaymentPerService,
    Title      : 'Avg Payment per Service',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.DataPoint #AvgSubmittedPerServiceFmt: {
    $Type      : 'UI.DataPointType',
    Value      : AvgSubmittedPerService,
    Title      : 'Avg Submitted Charge per Service',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 2
    }
  },

  UI.Chart #PlaceOfServiceChart: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Average Payment per Service: Facility vs. Office',
    ChartType : #ColumnStacked,
    Dimensions: [
      Specialty,
      PlaceOfService
    ],
    Measures  : [AvgPaymentPerService],
    DimensionAttributes: [
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: Specialty,
        Role     : #Category
      },
      {
        $Type    : 'UI.ChartDimensionAttributeType',
        Dimension: PlaceOfService,
        Role     : #Series
      }
    ],
    MeasureAttributes: [
      {
        $Type    : 'UI.ChartMeasureAttributeType',
        Measure  : AvgPaymentPerService,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#AvgPaymentPerServiceFmt]
      }
    ]
  },

  UI.PresentationVariant #PlaceOfServiceChart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [Specialty],
    SortOrder     : [{ Property: AvgPaymentPerService, Descending: true }],
    Visualizations: ['@UI.Chart#PlaceOfServiceChart']
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
    Text               : 'Place of Service Analysis Dashboard',
    SelectionVariant   : ![@UI.SelectionVariant#DefaultYear],
    PresentationVariant: ![@UI.PresentationVariant#PlaceOfServiceChart]
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM LAYER — collapsed by specialty; expand to see each provider × POS
  // ═══════════════════════════════════════════════════════════════════════════
  UI.LineItem: [
    { $Type: 'UI.DataField', Value: Specialty,              Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: ProviderName,         Label: 'Provider Name' },
    { $Type: 'UI.DataField', Value: PlaceOfService,       Label: 'Place of Service' },
    { $Type: 'UI.DataField', Value: NPI,                    Label: 'NPI' },
    { $Type: 'UI.DataField', Value: State,                  Label: 'State' },
    { $Type: 'UI.DataField', Value: TotalPatientsServed,    Label: 'Total Patients Served' },
    { $Type: 'UI.DataField', Value: TotalServicesRendered,  Label: 'Total Services Rendered' },
    {
      $Type      : 'UI.DataField',
      Value      : AvgSubmittedPerService,
      Label      : 'Avg Submitted Charge per Service',
      ![@UI.DataPoint]: ![@UI.DataPoint#AvgSubmittedPerServiceFmt]
    },
    {
      $Type      : 'UI.DataField',
      Value      : AvgPaymentPerService,
      Label      : 'Avg Payment per Service',
      ![@UI.DataPoint]: ![@UI.DataPoint#AvgPaymentPerServiceFmt]
    },
    { $Type: 'UI.DataField', Value: TotalActualPayments,    Label: 'Total Actual Payments' }
  ],

  UI.PresentationVariant #PlaceOfServiceTable: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [Specialty],
    SortOrder     : [
      { Property: AvgPaymentPerService, Descending: true },
      { Property: ProviderName,         Descending: false },
      { Property: NPI,                  Descending: false }
    ],
    Visualizations: ['@UI.LineItem']
  }
);

// ── Element annotations: labels, tooltips, currency formatting ───────────────
annotate service.PlaceOfServiceProviderProfiles with {
  Year @(
    Common.Label     : 'Year',
    Common.QuickInfo : 'Calendar year of the Medicare service-detail records.',
    Core.Description : 'Metrics are computed within each year — filter to a single year before comparing specialties or place-of-service settings.'
  );

  Specialty @(
    Common.Label     : 'Specialty',
    Common.QuickInfo : 'CMS rendering provider type (specialty classification).',
    Core.Description : 'Table groups by specialty. Collapsed rows show the specialty aggregate; expand to reveal individual providers and their place-of-service billing.',
    UI.LineItem      : [{ position: 10 }]
  );

  ProviderName @(
    Common.Label     : 'Provider Name',
    Common.QuickInfo : 'Rendering provider organization or clinician name.',
    Core.Description : 'Visible when a specialty group is expanded. Each provider may appear twice if they bill both facility and office settings.',
    UI.LineItem      : [{ position: 20 }]
  );

  PlaceOfService @(
    Common.Label     : 'Place of Service',
    Common.QuickInfo : 'Facility (Hospital/ASC) vs Office (Non-Facility) derived from CMS Place_Of_Srvc flag.',
    Core.Description : 'F = Facility, O = Office. Chart series dimension — compare average Medicare payment per service across settings within each specialty.',
    UI.LineItem      : [{ position: 30 }],
    Common.ValueListWithFixedValues: [
      { Value: 'Facility (Hospital/ASC)', Label: 'Facility (Hospital/ASC)' },
      { Value: 'Office (Non-Facility)',   Label: 'Office (Non-Facility)' }
    ]
  );

  NPI @(
    Common.Label     : 'NPI',
    Common.QuickInfo : 'National Provider Identifier.',
    Core.Description : 'Ten-digit provider key. Combined with Year and Place of Service, identifies each provider billing profile.',
    UI.LineItem      : [{ position: 40 }]
  );

  State @(
    Common.Label     : 'State',
    Common.QuickInfo : 'Provider practice state abbreviation.',
    Core.Description : 'Rendering provider state from CMS service-detail records.',
    UI.LineItem      : [{ position: 50 }]
  );

  TotalPatientsServed @(
    Common.Label     : 'Total Patients Served',
    Common.QuickInfo : 'Sum of beneficiaries for this provider in this specialty × POS bucket.',
    Core.Description : 'sum(Tot_Benes) at the service-line grain — use as volume context when comparing payment intensity.',
    UI.LineItem      : [{ position: 60 }]
  );

  TotalServicesRendered @(
    Common.Label     : 'Total Services Rendered',
    Common.QuickInfo : 'Total Medicare service units for this provider × POS bucket.',
    Core.Description : 'sum(Tot_Srvcs). Denominator for average payment and submitted metrics.',
    UI.LineItem      : [{ position: 70 }]
  );

  AvgSubmittedPerService @(
    Common.Label        : 'Avg Submitted Charge per Service',
    Common.QuickInfo    : 'Average amount this provider billed Medicare per service unit.',
    Core.Description    : 'TotalSubmittedCharges ÷ TotalServicesRendered. Compare against Avg Payment per Service to see how much of the ask converts to payment by setting.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 80 }]
  );

  AvgPaymentPerService @(
    Common.Label        : 'Avg Payment per Service',
    Common.QuickInfo    : 'Average Medicare payment per service unit — primary disparity indicator.',
    Core.Description    : 'TotalActualPayments ÷ TotalServicesRendered. Chart measure and table sort key. Expand a specialty group to compare individual providers.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 90 }]
  );

  TotalActualPayments @(
    Common.Label        : 'Total Actual Payments',
    Common.QuickInfo    : 'Total cash Medicare disbursed for this provider × POS bucket.',
    Core.Description    : 'sum(Avg_Mdcr_Pymt_Amt × Tot_Srvcs). Dollar volume context for the per-service averages.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 100 }]
  );

  TotalSubmittedCharges @(
    Common.Label        : 'Total Submitted Charges',
    Common.QuickInfo    : 'Gross billed amount before adjudication.',
    Measures.ISOCurrency: 'USD'
  );

  TotalAllowedCharges @(
    Common.Label        : 'Total Allowed Charges',
    Common.QuickInfo    : 'Medicare fee-schedule allowed amounts.',
    Measures.ISOCurrency: 'USD'
  );

  ProviderCount @(
    Common.Label     : 'Provider Count',
    Common.QuickInfo : 'Rollup helper — sums to provider count within a specialty group.',
    Core.Description : 'Constant 1 per provider row; SUM at collapsed specialty grain equals number of provider × POS rows in the group.'
  );
};

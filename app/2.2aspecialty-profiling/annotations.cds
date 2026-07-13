using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// SpecialtyPeerDeviations — Task 2.2 Macro Specialty Profiling ALP
// Chart (top): horizontal bar — Specialty (category) × avg cost peer deviation (%)
// Table (bottom): providers grouped by specialty vs national peer baselines
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.SpecialtyPeerDeviations with @(

  UI.SelectionFields: [Year, Specialty, State],

  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Specialty Peer Record',
    TypeNamePlural: 'Specialty Peer Records',
    Title         : { $Type: 'UI.DataField', Value: ProviderName },
    Description   : { $Type: 'UI.DataField', Value: Specialty }
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LAYER — horizontal bar chart (macro specialty cost deviation)
  // Specialty → #Category | CostTierDeviation → #Axis1
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #CostTierDeviationPct: {
    $Type      : 'UI.DataPointType',
    Value      : CostTierDeviation,
    Title      : 'Cost Peer Deviation (%)',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 1
    },
    CriticalityCalculation: {
      $Type                  : 'UI.CriticalityCalculationType',
      ImprovementDirection   : #Minimize,
      ToleranceRangeHighValue: 25,
      DeviationRangeHighValue: 100
    }
  },

  UI.Chart #MacroSpecialtyRisk: {
    $Type     : 'UI.ChartDefinitionType',
    Title     : 'Macro Specialty Risk Peer Deviation Costs',
    ChartType : #Bar,
    Dimensions: [Specialty],
    Measures  : [CostTierDeviation],
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
        Measure  : CostTierDeviation,
        Role     : #Axis1,
        DataPoint: ![@UI.DataPoint#CostTierDeviationPct]
      }
    ]
  },

  UI.PresentationVariant #MacroSpecialtyChart: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [Specialty],
    SortOrder     : [{ Property: CostTierDeviation, Descending: true }],
    Visualizations: ['@UI.Chart#MacroSpecialtyRisk']
  },

  UI.SelectionVariant #DefaultYear: {
    $Type       : 'UI.SelectionVariantType',
    Text        : 'Latest data year',
    SelectOptions: [
      {
        PropertyName: Year,
        Ranges      : [{ Sign: #I, Option: #EQ, Low: '2022' }]
      }
    ]
  },

  UI.SelectionPresentationVariant #ALPDashboard: {
    $Type              : 'UI.SelectionPresentationVariantType',
    Text               : 'Macro Specialty Profiling Dashboard',
    SelectionVariant   : ![@UI.SelectionVariant#DefaultYear],
    PresentationVariant: ![@UI.PresentationVariant#MacroSpecialtyChart]
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM LAYER — provider drill-down grouped by specialty
  // ═══════════════════════════════════════════════════════════════════════════
  UI.DataPoint #ServiceTierDeviationPct: {
    $Type      : 'UI.DataPointType',
    Value      : ServiceTierDeviation,
    Title      : 'Service Peer Deviation (%)',
    ValueFormat: {
      $Type                   : 'UI.NumberFormat',
      NumberOfFractionalDigits: 1
    },
    CriticalityCalculation: {
      $Type                  : 'UI.CriticalityCalculationType',
      ImprovementDirection   : #Minimize,
      ToleranceRangeHighValue: 25,
      DeviationRangeHighValue: 100
    }
  },

  UI.LineItem: [
    { $Type: 'UI.DataField', Value: Specialty,            Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: ProviderName,         Label: 'Provider Name' },
    { $Type: 'UI.DataField', Value: NPI,                  Label: 'NPI' },
    { $Type: 'UI.DataField', Value: CostPerPatient,       Label: 'Cost per Patient' },
    { $Type: 'UI.DataField', Value: NationalAvgCost,      Label: 'National Avg Cost' },
    {
      $Type      : 'UI.DataField',
      Value      : CostTierDeviation,
      Label      : 'Cost Peer Deviation (%)',
      ![@UI.DataPoint]: ![@UI.DataPoint#CostTierDeviationPct],
      CriticalityCalculation: {
        $Type                  : 'UI.CriticalityCalculationType',
        ImprovementDirection   : #Minimize,
        ToleranceRangeHighValue: 25,
        DeviationRangeHighValue: 100
      },
      ![@UI.CriticalityRepresentation]: #WithIcon
    },
    {
      $Type      : 'UI.DataField',
      Value      : ServiceTierDeviation,
      Label      : 'Service Peer Deviation (%)',
      ![@UI.DataPoint]: ![@UI.DataPoint#ServiceTierDeviationPct],
      CriticalityCalculation: {
        $Type                  : 'UI.CriticalityCalculationType',
        ImprovementDirection   : #Minimize,
        ToleranceRangeHighValue: 25,
        DeviationRangeHighValue: 100
      },
      ![@UI.CriticalityRepresentation]: #WithIcon
    }
  ],

  UI.PresentationVariant #SpecialtyPeerTable: {
    $Type         : 'UI.PresentationVariantType',
    GroupBy       : [Specialty],
    SortOrder     : [
      { Property: CostTierDeviation, Descending: true },
      { Property: ProviderName,      Descending: false },
      { Property: NPI,               Descending: false }
    ],
    Visualizations: ['@UI.LineItem']
  }
);

// ── Element annotations: labels, tooltips (QuickInfo), descriptions, positions ─
annotate service.SpecialtyPeerDeviations with {
  Year @(
    Common.Label     : 'Year',
    Common.QuickInfo : 'Calendar year of the Medicare provider summary record.',
    Core.Description : 'Peer baselines and deviations are computed within each year — always filter to a single year before comparing specialties or providers.'
  );

  Specialty @(
    Common.Label     : 'Specialty',
    Common.QuickInfo : 'CMS provider specialty classification.',
    Core.Description : 'Groups providers into peer cohorts for baseline comparison. The table groups by this field; the chart shows one bar per specialty (max cost deviation).',
    UI.LineItem      : [{ position: 10 }]
  );

  ProviderName @(
    Common.Label     : 'Provider Name',
    Common.QuickInfo : 'Rendering provider organization or clinician name.',
    Core.Description : 'Legal or organizational name from CMS. Expand a specialty group to see individual providers ranked by cost peer deviation.',
    UI.LineItem      : [{ position: 20 }]
  );

  NPI @(
    Common.Label     : 'NPI',
    Common.QuickInfo : 'National Provider Identifier — unique provider key.',
    Core.Description : 'Ten-digit National Provider Identifier. Combined with Year, uniquely identifies each provider record in this view.',
    UI.LineItem      : [{ position: 30 }]
  );

  State @(
    Common.Label     : 'State',
    Common.QuickInfo : 'Two-letter state where the provider is located.',
    Core.Description : 'U.S. state or territory abbreviation from the provider''s CMS practice address. Use as a filter to compare peer deviations within a geography.'
  );

  CostPerPatient @(
    Common.Label        : 'Cost per Patient',
    Common.QuickInfo    : 'Medicare paid amount ÷ beneficiaries. Grouped specialty rows show the peak provider cost (MAX); expand to see each provider''s individual value.',
    Core.Description    : 'This provider''s actual spend intensity: Tot_Mdcr_Pymt_Amt ÷ Tot_Benes. On collapsed specialty groups, shows the highest cost per patient in that specialty — compare against National Avg Cost (the peer baseline).',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 40 }]
  );

  NationalAvgCost @(
    Common.Label        : 'National Avg Cost',
    Common.QuickInfo    : 'Specialty-year peer baseline — same for every provider in this specialty.',
    Core.Description    : 'Calculated once per specialty and year in SpecialtyPeerBaselines: avg(Cost per Patient) across all peers. Constant within a specialty — expand a group to compare individual providers against this benchmark.',
    Measures.ISOCurrency: 'USD',
    UI.LineItem         : [{ position: 45 }]
  );

  CostTierDeviation @(
    Common.Label     : 'Cost Peer Deviation (%)',
    Common.QuickInfo : 'Percentage above or below the specialty-year average cost per patient.',
    Core.Description : 'Authentic variance vs peer baseline: round(((Cost per Patient − National Avg Cost) ÷ National Avg Cost) × 100). Positive = spends more than specialty peers; negative = spends less. Chart uses MAX per specialty to surface the worst outlier.',
    Measures.Unit    : '%',
    UI.LineItem      : [{ position: 50 }]
  );

  ServicesPerPatient @(
    Common.Label     : 'Services per Patient',
    Common.QuickInfo : 'Total service units divided by beneficiary count (rounded whole number).',
    Core.Description : 'This provider''s billing volume intensity: round(Tot_Srvcs ÷ Tot_Benes). For ambulance and similar specialties, service units may represent mileage or equipment charges, not discrete visits.',
    Measures.Unit    : #ONE
  );

  NationalAvgServices @(
    Common.Label     : 'National Avg Services',
    Common.QuickInfo : 'Mean services per patient across all providers in this specialty and year.',
    Core.Description : 'The specialty-year peer baseline for utilization: average of every provider''s Services per Patient in the same CMS specialty. Service Peer Deviation (%) measures relative volume vs this benchmark.'
  );

  ServiceTierDeviation @(
    Common.Label     : 'Service Peer Deviation (%)',
    Common.QuickInfo : 'Percentage above or below the specialty-year average services per patient.',
    Core.Description : 'Authentic variance vs peer baseline: round(((Services per Patient − National Avg Services) ÷ National Avg Services) × 100). Positive = higher utilization than specialty peers; negative = lower utilization.',
    Measures.Unit    : '%',
    UI.LineItem      : [{ position: 60 }]
  );
};

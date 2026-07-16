'use strict';

/**
 * Per-ALP Evaluate AI context.
 * Do NOT put calculation formulas here — CDS views already compute the columns.
 * Instruct the model to trust CSV values on that ALP and pick the right ranking column.
 */
const ENTITY_CONTEXTS = {
  CostAnalysisV2: {
    csvColumns: [
      'Year',
      'State',
      'StateName',
      'ProviderType',
      'ProviderCount',
      'TotalBeneficiaries',
      'TotalSubmitted',
      'TotalAllowed',
      'RejectedCharges',
      'TotalPaid',
    ],
    diagramColumns: [
      'Year',
      'StateName',
      'ProviderType',
      'TotalPaid',
      'RejectedCharges',
      'TotalSubmitted',
    ],
    diagramHint:
      'Prefer StateName or ProviderType as the chart category (label) and TotalPaid or RejectedCharges as the numeric value.',
    alpName: '1.1 State Cost Analysis',
    task: '1.1',
    grain: 'Year × State × ProviderType',
    primaryMetrics: ['TotalPaid', 'RejectedCharges'],
    rankingHints: {
      highestSpend: 'TotalPaid',
      mostOverBilling: 'RejectedCharges',
    },
    schemaRules: [
      'ALP purpose: state × specialty Medicare spend and rejected over-charges.',
      'For highest spend: rank by TotalPaid. For most over-billing: rank by RejectedCharges.',
      'Use only rows on this ALP; trust precomputed CAP column values.',
    ],
    emptyMessage: 'No state cost analysis data available.',
  },
  RuralAnalysisChart: {
    csvColumns: [
      'HCPCS_Code',
      'HCPCS_Desc',
      'StructuralTier',
      'TotalServices',
      'TotalSubmitted',
      'RejectedCharges',
      'OverclaimRate',
      'TierDeviation',
      'ProcedureBaselineRate',
    ],
    diagramColumns: [
      'HCPCS_Code',
      'HCPCS_Desc',
      'StructuralTier',
      'OverclaimRate',
      'TierDeviation',
      'RejectedCharges',
      'TotalSubmitted',
    ],
    diagramHint:
      'Prefer HCPCS_Code or StructuralTier as label and OverclaimRate, TierDeviation, or RejectedCharges as value.',
    alpName: '1.2 Rural vs Urban Analysis',
    task: '1.2',
    grain: 'HCPCS_Code × StructuralTier',
    primaryMetrics: ['OverclaimRate', 'TierDeviation', 'TotalServices'],
    rankingHints: {
      mostOverclaim: 'OverclaimRate',
      worstVsBaseline: 'TierDeviation',
    },
    schemaRules: [
      'ALP purpose: same HCPCS across Urban / Suburban / Rural tiers.',
      'Most overclaim → rank StructuralTier by OverclaimRate (use TotalSubmitted/TotalServices for volume context).',
      'Worse than baseline → rank by TierDeviation. Trust CAP columns; do not invent rates.',
    ],
    emptyMessage: 'No rural vs urban procedure data available.',
  },
  BehavioralHealthRiskProfile: {
    csvColumns: [
      'Year',
      'State',
      'ProviderType',
      'BHBurdenGroup',
      'ProviderCount',
      'AvgRiskScore',
      'PaidPerBeneficiary',
      'TotalBeneficiaries',
      'TotalPaid',
    ],
    diagramColumns: [
      'Year',
      'State',
      'ProviderType',
      'BHBurdenGroup',
      'PaidPerBeneficiary',
      'AvgRiskScore',
      'TotalPaid',
    ],
    diagramHint:
      'Prefer ProviderType, State, or BHBurdenGroup as label and PaidPerBeneficiary, AvgRiskScore, or TotalPaid as value.',
    alpName: '1.3 Behavioral Health Risk Frontier',
    task: '1.3',
    grain: 'Year × State × ProviderType × BHBurdenGroup',
    primaryMetrics: ['PaidPerBeneficiary', 'AvgRiskScore'],
    rankingHints: {
      highestCostIntensity: 'PaidPerBeneficiary',
      highestComplexity: 'AvgRiskScore',
    },
    schemaRules: [
      'ALP purpose: BH burden peer groups vs cost and risk.',
      'Highest cost intensity → PaidPerBeneficiary. Audit focus: high PaidPerBeneficiary with relatively low AvgRiskScore.',
      'Trust BHBurdenGroup labels on each CAP row.',
    ],
    emptyMessage: 'No behavioral health risk profile data available.',
  },
  ProviderCostEfficiency: {
    csvColumns: [
      'Year',
      'NPI',
      'ProviderName',
      'ProviderType',
      'State',
      'CostPerBeneficiary',
      'ServicesPerBeneficiary',
      'EfficiencyCategory',
      'UtilizationCategory',
      'TotalBeneficiaries',
    ],
    diagramColumns: [
      'ProviderName',
      'State',
      'Year',
      'NPI',
      'CostPerBeneficiary',
      'ServicesPerBeneficiary',
      'EfficiencyCategory',
      'UtilizationCategory',
    ],
    diagramHint:
      'Prefer High-Cost Outlier providers; use ProviderName as label and CostPerBeneficiary as value.',
    alpName: '2.1 Provider Classification (Risk Matrix)',
    task: '2.1',
    grain: 'Year × NPI',
    primaryMetrics: ['CostPerBeneficiary', 'ServicesPerBeneficiary', 'EfficiencyCategory', 'UtilizationCategory'],
    task2ClassificationTiers: {
      EfficiencyCategory: ['Highly Efficient', 'Average Spend', 'High-Cost Outlier'],
      UtilizationCategory: ['Low Utilization', 'Moderate Utilization', 'High Utilization'],
      authority:
        'Task 2 CAP classifications already stamped on each row — reason WITH these labels; never invent alternate bands.',
    },
    rankingHints: {
      highCostOutliers: 'filter EfficiencyCategory=High-Cost Outlier then rank CostPerBeneficiary',
      highUtilization: 'filter UtilizationCategory=High Utilization then rank ServicesPerBeneficiary',
    },
    schemaRules: [
      'ALP purpose: Task 2.1 two-axis provider classification matrix.',
      'Reason through EfficiencyCategory × UtilizationCategory tiers from CAP before ranking numeric measures.',
      'High-cost outliers → EfficiencyCategory High-Cost Outlier, then CostPerBeneficiary.',
    ],
    emptyMessage: 'No provider classification data available.',
  },
  SpecialtyPeerDeviations: {
    csvColumns: [
      'Year',
      'Specialty',
      'ProviderName',
      'NPI',
      'State',
      'CostPerPatient',
      'NationalAvgCost',
      'CostTierDeviation',
      'ServicesPerPatient',
      'ServiceTierDeviation',
    ],
    diagramColumns: [
      'ProviderName',
      'Specialty',
      'CostPerPatient',
      'CostTierDeviation',
      'ServiceTierDeviation',
      'NationalAvgCost',
    ],
    diagramHint:
      'Prefer provider or specialty names as label and CostPerPatient or CostTierDeviation as value.',
    alpName: '2.2a Specialty Peer Profiling',
    task: '2.2a',
    grain: 'Year × NPI (specialty peer baselines)',
    primaryMetrics: ['CostTierDeviation', 'ServiceTierDeviation', 'CostPerPatient'],
    rankingHints: {
      costPeerOutlier: 'CostTierDeviation',
      servicePeerOutlier: 'ServiceTierDeviation',
    },
    schemaRules: [
      'ALP purpose: Task 2.2a peer deviation vs specialty national averages already on each row.',
      'Biggest cost peer outlier → CostTierDeviation. Biggest utilization peer outlier → ServiceTierDeviation.',
    ],
    emptyMessage: 'No specialty peer deviation data available.',
  },
  EntityTypeProviderProfiles: {
    csvColumns: [
      'Year',
      'ProviderName',
      'NPI',
      'ProviderType',
      'EntityType',
      'State',
      'CostPerBeneficiary',
      'ServicesPerBeneficiary',
      'EfficiencyCategory',
      'UtilizationCategory',
    ],
    diagramColumns: [
      'ProviderName',
      'EntityType',
      'ProviderType',
      'CostPerBeneficiary',
      'ServicesPerBeneficiary',
      'EfficiencyCategory',
    ],
    diagramHint:
      'Prefer ProviderName or EntityType as label and CostPerBeneficiary or ServicesPerBeneficiary as value.',
    alpName: '2.2b Organization / Entity Profiling',
    task: '2.2b',
    grain: 'Year × NPI × EntityType',
    primaryMetrics: ['CostPerBeneficiary', 'EntityType', 'EfficiencyCategory'],
    task2ClassificationTiers: {
      EfficiencyCategory: ['Highly Efficient', 'Average Spend', 'High-Cost Outlier'],
      UtilizationCategory: ['Low Utilization', 'Moderate Utilization', 'High Utilization'],
      authority: 'Reuse Task 2.1 classification columns stamped by CAP on each row.',
    },
    rankingHints: {
      entityCostCompare: 'CostPerBeneficiary by EntityType',
      outliers: 'EfficiencyCategory then CostPerBeneficiary',
    },
    schemaRules: [
      'ALP purpose: Task 2.2b Individual vs Organization using Task 2 classification tiers.',
      'Compare EntityType using CostPerBeneficiary; reason with EfficiencyCategory / UtilizationCategory on the row.',
    ],
    emptyMessage: 'No organization profiling data available.',
  },
  RiskCostVolumeDynamics: {
    csvColumns: [
      'Year',
      'Specialty',
      'TotalUniqueProviders',
      'PatientRiskScore',
      'CostPerPatient',
      'TotalPatientsServed',
      'TotalActualPayments',
    ],
    diagramColumns: [
      'Specialty',
      'PatientRiskScore',
      'CostPerPatient',
      'TotalPatientsServed',
      'TotalActualPayments',
    ],
    diagramHint:
      'Prefer Specialty as label and CostPerPatient, PatientRiskScore, or TotalActualPayments as value.',
    alpName: '3.1 Risk–Cost–Volume Dynamics',
    task: '3.1',
    grain: 'Year × Specialty',
    primaryMetrics: ['CostPerPatient', 'PatientRiskScore', 'TotalActualPayments'],
    rankingHints: {
      mostExpensiveSpecialty: 'CostPerPatient',
      highestComplexity: 'PatientRiskScore',
    },
    schemaRules: [
      'ALP purpose: Task 3.1 specialty risk vs cost associations.',
      'Most expensive → CostPerPatient. Highest complexity → PatientRiskScore.',
      'High cost + high risk = complexity-aligned; high cost + low risk = inefficiency signal.',
    ],
    emptyMessage: 'No risk-cost dynamics data available.',
  },
  PlaceOfServiceProviderProfiles: {
    csvColumns: [
      'Year',
      'Specialty',
      'ProviderName',
      'PlaceOfService',
      'NPI',
      'State',
      'TotalPatientsServed',
      'AvgSubmittedPerService',
      'AvgPaymentPerService',
      'TotalActualPayments',
    ],
    diagramColumns: [
      'ProviderName',
      'Specialty',
      'PlaceOfService',
      'AvgPaymentPerService',
      'AvgSubmittedPerService',
      'TotalActualPayments',
    ],
    diagramHint:
      'Prefer ProviderName, Specialty, or PlaceOfService as label and AvgPaymentPerService or TotalActualPayments as value.',
    alpName: '3.2 Place of Service',
    task: '3.2',
    grain: 'Year × NPI × Specialty × PlaceOfService',
    primaryMetrics: ['AvgPaymentPerService', 'AvgSubmittedPerService', 'TotalActualPayments'],
    rankingHints: {
      paymentIntensity: 'AvgPaymentPerService',
    },
    schemaRules: [
      'ALP purpose: Task 3.2 Facility vs Office payment intensity.',
      'Higher payment intensity → AvgPaymentPerService; compare POS within the same specialty when both exist.',
    ],
    emptyMessage: 'No place-of-service data available.',
  },
  CredentialDiscrepancies: {
    csvColumns: [
      'Year',
      'StandardizedCredential',
      'TotalUniqueProviders',
      'ChargePaddingAmt',
      'ChargePaddingRatePct',
      'PolicyShortfallAmt',
      'PaidToAllowedRatePct',
      'TotalActualPayments',
    ],
    diagramColumns: [
      'StandardizedCredential',
      'ChargePaddingAmt',
      'ChargePaddingRatePct',
      'PaidToAllowedRatePct',
      'TotalActualPayments',
    ],
    diagramHint:
      'Prefer StandardizedCredential as label and ChargePaddingAmt, ChargePaddingRatePct, or TotalActualPayments as value.',
    alpName: '3.3 Credential Discrepancies',
    task: '3.3',
    grain: 'Year × StandardizedCredential',
    primaryMetrics: ['ChargePaddingAmt', 'ChargePaddingRatePct', 'PaidToAllowedRatePct'],
    rankingHints: {
      mostPaddingDollars: 'ChargePaddingAmt',
      mostPaddingRate: 'ChargePaddingRatePct',
    },
    schemaRules: [
      'ALP purpose: Task 3.3 credential-level padding vs policy shortfall.',
      'Most charge padding → ChargePaddingAmt or ChargePaddingRatePct as asked.',
      'PaidToAllowedRatePct near mid-level norms is often policy, not fraud by itself.',
    ],
    emptyMessage: 'No credential discrepancy data available.',
  },
  RiskScoreDistribution: {
    csvColumns: [
      'Year',
      'State',
      'ProviderType',
      'RiskBand',
      'ProviderCount',
      'TotalBeneficiaries',
      'TotalPaid',
      'AvgRiskScore',
      'AvgHypertensionPct',
      'AvgDiabetesPct',
    ],
    diagramColumns: [
      'RiskBand',
      'ProviderType',
      'State',
      'TotalPaid',
      'AvgRiskScore',
      'ProviderCount',
    ],
    diagramHint:
      'Prefer RiskBand or ProviderType as label and TotalPaid, AvgRiskScore, or ProviderCount as value.',
    alpName: 'Risk Score Distribution',
    task: '1.x',
    grain: 'Year × State × ProviderType × RiskBand',
    primaryMetrics: ['TotalPaid', 'AvgRiskScore', 'RiskBand'],
    rankingHints: {
      highestSpendBand: 'TotalPaid',
      highestAvgRisk: 'AvgRiskScore',
    },
    schemaRules: [
      'ALP purpose: patient complexity RiskBand distribution.',
      'Trust RiskBand labels on CAP rows. Highest spend → TotalPaid; highest risk → AvgRiskScore.',
    ],
    emptyMessage: 'No risk score distribution data available.',
  },
};

const APP_PATTERNS = [
  { pattern: /commedicare11costanalysis|com\.medicare\.11costanalysis/i, entity: 'CostAnalysisV2' },
  { pattern: /commedicare12ruralanalysis|com\.medicare\.12ruralanalysis/i, entity: 'RuralAnalysisChart' },
  {
    pattern: /commedicare13behavioralhelathrisk|com\.medicare\.13behavioralhelathrisk/i,
    entity: 'BehavioralHealthRiskProfile',
  },
  {
    pattern: /commedicare21providerclassification|com\.medicare\.21providerclassification/i,
    entity: 'ProviderCostEfficiency',
  },
  {
    pattern: /commedicare22aspecialtyprofiling|com\.medicare\.22aspecialtyprofiling/i,
    entity: 'SpecialtyPeerDeviations',
  },
  {
    pattern: /commedicare22borganizationprofiling|com\.medicare\.22borganizationprofiling/i,
    entity: 'EntityTypeProviderProfiles',
  },
  { pattern: /commedicare31riskdynamics|com\.medicare\.31riskdynamics/i, entity: 'RiskCostVolumeDynamics' },
  { pattern: /commedicare32placeofservice|com\.medicare\.32placeofservice/i, entity: 'PlaceOfServiceProviderProfiles' },
  {
    pattern: /commedicare33credentialdiscrepancies|com\.medicare\.33credentialdiscrepancies/i,
    entity: 'CredentialDiscrepancies',
  },
  { pattern: /commedicareriskanalysis|com\.medicare\.riskanalysis/i, entity: 'RiskScoreDistribution' },
];

function resolveAiContext(req) {
  const referer = String(req.headers?.referer || req.headers?.referrer || '');
  for (const { pattern, entity } of APP_PATTERNS) {
    if (pattern.test(referer)) {
      return { entityName: entity, ...ENTITY_CONTEXTS[entity] };
    }
  }

  return { entityName: 'ProviderCostEfficiency', ...ENTITY_CONTEXTS.ProviderCostEfficiency };
}

/** Compressed JSON schema layout passed in the AI context window (CAP → AI Core). */
function buildSchemaSnapshot(context) {
  return {
    persona: 'Lead Medicare Auditor',
    agency: 'Task4-EvaluateAI',
    alp: {
      name: context.alpName,
      task: context.task || null,
      entity: context.entityName,
      grain: context.grain || null,
    },
    columns: context.csvColumns || [],
    primaryMetrics: context.primaryMetrics || [],
    rankingHints: context.rankingHints || {},
    task2ClassificationTiers: context.task2ClassificationTiers || null,
    alpGuidance: context.schemaRules || [],
    antiHallucination: [
      'Use ONLY rows in dataSnapshot.rows',
      'Trust precomputed CAP column values',
      'Never invent identifiers, categories, or amounts',
      'If Task 2 tiers exist, reason with EfficiencyCategory/UtilizationCategory on each row first',
    ],
  };
}

/** Compressed data snapshot from CAP query results. */
function buildDataSnapshot(rows, context, { maxRows } = {}) {
  const limit = maxRows || rows.length;
  const sliced = rows.slice(0, limit);
  return {
    source: 'CAP MedicareService',
    entity: context.entityName,
    format: 'json-rows',
    rowCount: sliced.length,
    truncated: rows.length > sliced.length,
    columns: context.csvColumns || [],
    rows: sliced,
  };
}

module.exports = {
  resolveAiContext,
  ENTITY_CONTEXTS,
  APP_PATTERNS,
  buildSchemaSnapshot,
  buildDataSnapshot,
};

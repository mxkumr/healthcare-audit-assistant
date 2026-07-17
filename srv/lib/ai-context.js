'use strict';

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

module.exports = { resolveAiContext, ENTITY_CONTEXTS, APP_PATTERNS };

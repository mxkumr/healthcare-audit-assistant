using MedicareService as service from '../../srv/medicare-service';

// ═══════════════════════════════════════════════════════════════════════════════
// Task 3 Overview — OVP preview charts + navigation to 3.1 / 3.2 / 3.3 ALP apps
// ═══════════════════════════════════════════════════════════════════════════════

annotate service.RiskCostVolumeDynamics with @(
  UI.Identification #OVPNavRiskDynamics: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Risk-Cost-Volume Dynamics (3.1)',
    Value: '/commedicare31riskdynamics/index.html'
  }]
);

annotate service.PlaceOfServiceAnalysis with @(
  UI.Identification #OVPNavPlaceOfService: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Place of Service Analysis (3.2)',
    Value: '/commedicare32placeofservice/index.html'
  }]
);

annotate service.CredentialDiscrepancies with @(
  UI.Identification #OVPNavCredentialGaps: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Credential Discrepancies (3.3)',
    Value: '/commedicare33credentialdiscrepancies/index.html'
  }]
);

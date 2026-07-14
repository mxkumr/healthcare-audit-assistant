using MedicareService as service from '../../srv/medicare-service';

// Task 1 Overview — navigation only (preview chart for 1.2 lives in audit-home/annotations.cds)

annotate service.CostAnalysisV2 with @(
  UI.Identification #OVPNavCost: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Cost Analysis (1.1)',
    Value: '/commedicare11costanalysis/index.html'
  }]
);

annotate service.RuralUrbanDistribution with @(
  UI.Identification #OVPNavRural: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Rural Analysis (1.2)',
    Value: '/commedicare12ruralanalysis/index.html'
  }]
);

annotate service.BehavioralHealthRiskProfile with @(
  UI.Identification #OVPNavBehavioral: [{
    $Type: 'UI.DataFieldWithUrl',
    Label: 'Open Behavioral Health Risk (1.3)',
    Value: '/commedicare13behavioralhelathrisk/index.html'
  }]
);

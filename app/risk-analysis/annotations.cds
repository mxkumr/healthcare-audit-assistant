using MedicareService as service from '../../srv/medicare-service';

annotate service.RiskScoreDistribution with @(
  UI.LineItem: [
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'MedicareService.EntityContainer/checkAI',
      Label : '{i18n>Evaluate_AI}'
    },
    { $Type: 'UI.DataField', Value: Year,           Label: 'Year' },
    { $Type: 'UI.DataField', Value: State,          Label: 'State' },
    { $Type: 'UI.DataField', Value: ProviderType,   Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: RiskBand,       Label: 'Risk Band' },
    { $Type: 'UI.DataField', Value: ProviderCount,  Label: 'Provider Count' },
    { $Type: 'UI.DataField', Value: TotalPaid,      Label: 'Total Medicare Paid' },
    { $Type: 'UI.DataField', Value: AvgRiskScore,   Label: 'Avg Risk Score' }
  ]
);

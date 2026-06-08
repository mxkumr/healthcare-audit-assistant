using medicare from '../db/schema';
using { MedicareService } from './medicare-service';

/**
 * Task 1 - Data Visualization (Aggregation)
 *
 * Aggregated, exploratory analytical views over the Medicare data so that
 * auditors can compare cost measures across states and provider types,
 * inspect rural-vs-urban disparities (via GeoReference) and study the
 * distribution of beneficiary risk scores (patient complexity).
 *
 * All measures are pre-aggregated here so the Fiori Elements dashboard and
 * the AI agent can consume ready-to-chart numbers without re-computing.
 */

// ---------------------------------------------------------------------------
// Helper (enriched, row-level) views - not exposed directly
// ---------------------------------------------------------------------------

// Each provider tagged with its geographic area type (rural / urban) by
// joining the provider ZIP + Year to the GeoReference locality table.
define view T1ProviderGeo as
  select from medicare.ProviderSummary {
    Year,
    Rndrng_NPI                              as NPI,
    Rndrng_Prvdr_State_Abrvtn               as State,
    Rndrng_Prvdr_Zip5                       as ZipCode,
    geo.RuralInd                            as RuralInd,
    case
      when geo.RuralInd = 'R' then 'Rural'
      when geo.RuralInd = 'B' then 'Super Rural'
      else 'Urban'
    end                                     as AreaType : String,
    Tot_Sbmtd_Chrg                          as SubmittedCharges,
    Tot_Mdcr_Alowd_Amt                      as AllowedAmount,
    Tot_Mdcr_Pymt_Amt                       as PaidAmount,
    Tot_Benes                               as Beneficiaries,
    Tot_Srvcs                               as Services,
    Bene_Avg_Risk_Scre                      as RiskScore
  };

// Each provider tagged with a beneficiary risk-score band (patient complexity).
define view T1ProviderRisk as
  select from medicare.ProviderSummary {
    Year,
    Rndrng_NPI                              as NPI,
    Rndrng_Prvdr_State_Abrvtn               as State,
    Bene_Avg_Risk_Scre                      as RiskScore,
    case
      when Bene_Avg_Risk_Scre is null     then '5. Unknown'
      when Bene_Avg_Risk_Scre <  1.0      then '1. Low (<1.0)'
      when Bene_Avg_Risk_Scre <  1.5      then '2. Moderate (1.0-1.5)'
      when Bene_Avg_Risk_Scre <  2.0      then '3. High (1.5-2.0)'
      else                                     '4. Very High (2.0+)'
    end                                     as RiskBand : String,
    Tot_Mdcr_Pymt_Amt                       as PaidAmount
  };

// ---------------------------------------------------------------------------
// Public analytical entities, exposed on the OData service
// ---------------------------------------------------------------------------
extend service MedicareService with {

  // 1) Cost & utilization measures aggregated by State + Year.
  //    Drives state comparison charts and the geographic (choropleth) map.
  @readonly
  entity CostByState as
    select from medicare.ProviderSummary {
      key Year,
      key Rndrng_Prvdr_State_Abrvtn         as State,
      count(*)                              as ProviderCount       : Integer,
      sum(Tot_Sbmtd_Chrg)                   as SubmittedCharges    : Decimal,
      sum(Tot_Mdcr_Alowd_Amt)               as AllowedAmount       : Decimal,
      sum(Tot_Mdcr_Pymt_Amt)                as PaidAmount          : Decimal,
      sum(Tot_Benes)                        as Beneficiaries       : Integer,
      sum(Tot_Srvcs)                        as Services            : Decimal,
      avg(Bene_Avg_Risk_Scre)               as AvgRiskScore        : Decimal,
      case when sum(Tot_Sbmtd_Chrg) > 0
           then sum(Tot_Mdcr_Pymt_Amt) / sum(Tot_Sbmtd_Chrg)
           else 0 end                       as PaymentToChargeRatio : Decimal
    }
    where Rndrng_Prvdr_State_Abrvtn is not null
    group by Year, Rndrng_Prvdr_State_Abrvtn;

  // 2) Cost & utilization measures aggregated by Provider Type + Year.
  @readonly
  entity CostByProviderType as
    select from medicare.ProviderSummary {
      key Year,
      key Rndrng_Prvdr_Type                 as ProviderType        : String,
      count(*)                              as ProviderCount       : Integer,
      sum(Tot_Sbmtd_Chrg)                   as SubmittedCharges    : Decimal,
      sum(Tot_Mdcr_Alowd_Amt)               as AllowedAmount       : Decimal,
      sum(Tot_Mdcr_Pymt_Amt)                as PaidAmount          : Decimal,
      sum(Tot_Benes)                        as Beneficiaries       : Integer,
      avg(Bene_Avg_Risk_Scre)               as AvgRiskScore        : Decimal,
      case when sum(Tot_Sbmtd_Chrg) > 0
           then sum(Tot_Mdcr_Pymt_Amt) / sum(Tot_Sbmtd_Chrg)
           else 0 end                       as PaymentToChargeRatio : Decimal
    }
    where Rndrng_Prvdr_Type is not null
    group by Year, Rndrng_Prvdr_Type;

  // 3) Rural vs. urban distribution of cost & complexity (regional disparity).
  @readonly
  entity CostByArea as
    select from T1ProviderGeo {
      key Year,
      key AreaType,
      count(*)                              as ProviderCount       : Integer,
      sum(SubmittedCharges)                 as SubmittedCharges    : Decimal,
      sum(AllowedAmount)                    as AllowedAmount       : Decimal,
      sum(PaidAmount)                       as PaidAmount          : Decimal,
      sum(Beneficiaries)                    as Beneficiaries       : Integer,
      avg(RiskScore)                        as AvgRiskScore        : Decimal
    }
    group by Year, AreaType;

  // 4) Distribution of providers across beneficiary risk-score bands.
  @readonly
  entity RiskDistribution as
    select from T1ProviderRisk {
      key Year,
      key RiskBand,
      count(*)                              as ProviderCount       : Integer,
      avg(RiskScore)                        as AvgRiskScore        : Decimal,
      sum(PaidAmount)                       as PaidAmount          : Decimal
    }
    group by Year, RiskBand;

  // 5) Row-level geo detail (provider + area type) for ZIP/point map drill-down.
  @readonly
  entity ProviderGeoDetail as projection on T1ProviderGeo;
}

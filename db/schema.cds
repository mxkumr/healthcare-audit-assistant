namespace medicare;

entity ProviderSummary {
  key Year                              : String;
  key Rndrng_NPI                        : String;
  Rndrng_Prvdr_Last_Org_Name            : String;
  Rndrng_Prvdr_First_Name               : String;
  Rndrng_Prvdr_MI                       : String;
  Rndrng_Prvdr_Crdntls                  : String;
  Rndrng_Prvdr_Ent_Cd                   : String;
  Rndrng_Prvdr_St1                      : String;
  Rndrng_Prvdr_St2                      : String;
  Rndrng_Prvdr_City                     : String;
  Rndrng_Prvdr_State_Abrvtn             : String;
  Rndrng_Prvdr_State_FIPS               : String;
  Rndrng_Prvdr_Zip5                     : String;
  Rndrng_Prvdr_RUCA                     : String;
  Rndrng_Prvdr_RUCA_Desc                : String;
  Rndrng_Prvdr_Cntry                    : String;
  Rndrng_Prvdr_Type                     : String;
  Rndrng_Prvdr_Mdcr_Prtcptg_Ind         : String;
  Tot_HCPCS_Cds                         : Integer;
  Tot_Benes                             : Integer;
  Tot_Srvcs                             : Decimal;
  Tot_Sbmtd_Chrg                        : Decimal;
  Tot_Mdcr_Alowd_Amt                    : Decimal;
  Tot_Mdcr_Pymt_Amt                     : Decimal;
  Tot_Mdcr_Stdzd_Amt                    : Decimal;
  Drug_Sprsn_Ind                        : String;
  Drug_Tot_HCPCS_Cds                    : Integer;
  Drug_Tot_Benes                        : Integer;
  Drug_Tot_Srvcs                        : Decimal;
  Drug_Sbmtd_Chrg                       : Decimal;
  Drug_Mdcr_Alowd_Amt                   : Decimal;
  Drug_Mdcr_Pymt_Amt                    : Decimal;
  Drug_Mdcr_Stdzd_Amt                   : Decimal;
  Med_Sprsn_Ind                         : String;
  Med_Tot_HCPCS_Cds                     : Integer;
  Med_Tot_Benes                         : Integer;
  Med_Tot_Srvcs                         : Decimal;
  Med_Sbmtd_Chrg                        : Decimal;
  Med_Mdcr_Alowd_Amt                    : Decimal;
  Med_Mdcr_Pymt_Amt                     : Decimal;
  Med_Mdcr_Stdzd_Amt                    : Decimal;
  Bene_Avg_Age                          : Decimal;
  Bene_Age_LT_65_Cnt                    : Integer;
  Bene_Age_65_74_Cnt                    : Integer;
  Bene_Age_75_84_Cnt                    : Integer;
  Bene_Age_GT_84_Cnt                    : Integer;
  Bene_Feml_Cnt                         : Integer;
  Bene_Male_Cnt                         : Integer;
  Bene_Race_Wht_Cnt                     : Integer;
  Bene_Race_Black_Cnt                   : Integer;
  Bene_Race_API_Cnt                     : Integer;
  Bene_Race_Hspnc_Cnt                   : Integer;
  Bene_Race_NatInd_Cnt                  : Integer;
  Bene_Race_Othr_Cnt                    : Integer;
  Bene_Dual_Cnt                         : Integer;
  Bene_Ndual_Cnt                        : Integer;
  Bene_CC_BH_ADHD_OthCD_V1_Pct         : Decimal;
  Bene_CC_BH_Alcohol_Drug_V1_Pct        : Decimal;
  Bene_CC_BH_Tobacco_V1_Pct            : Decimal;
  Bene_CC_BH_Alz_NonAlzdem_V2_Pct      : Decimal;
  Bene_CC_BH_Anxiety_V1_Pct            : Decimal;
  Bene_CC_BH_Bipolar_V1_Pct            : Decimal;
  Bene_CC_BH_Mood_V2_Pct               : Decimal;
  Bene_CC_BH_Depress_V1_Pct            : Decimal;
  Bene_CC_BH_PD_V1_Pct                 : Decimal;
  Bene_CC_BH_PTSD_V1_Pct               : Decimal;
  Bene_CC_BH_Schizo_OthPsy_V1_Pct      : Decimal;
  Bene_CC_PH_Asthma_V2_Pct             : Decimal;
  Bene_CC_PH_Afib_V2_Pct               : Decimal;
  Bene_CC_PH_Cancer6_V2_Pct            : Decimal;
  Bene_CC_PH_CKD_V2_Pct                : Decimal;
  Bene_CC_PH_COPD_V2_Pct               : Decimal;
  Bene_CC_PH_Diabetes_V2_Pct           : Decimal;
  Bene_CC_PH_HF_NonIHD_V2_Pct          : Decimal;
  Bene_CC_PH_Hyperlipidemia_V2_Pct     : Decimal;
  Bene_CC_PH_Hypertension_V2_Pct       : Decimal;
  Bene_CC_PH_IschemicHeart_V2_Pct      : Decimal;
  Bene_CC_PH_Osteoporosis_V2_Pct       : Decimal;
  Bene_CC_PH_Parkinson_V2_Pct          : Decimal;
  Bene_CC_PH_Arthritis_V2_Pct          : Decimal;
  Bene_CC_PH_Stroke_TIA_V2_Pct         : Decimal;
  Bene_Avg_Risk_Scre                    : Decimal;

  // Associations
  services : Association to many ServiceDetails
               on services.Rndrng_NPI = Rndrng_NPI
              and services.Year       = Year;
  geo      : Association to GeoReference
               on  geo.ZipCode = Rndrng_Prvdr_Zip5
              and  geo.Year    = Year;
}

entity ServiceDetails {
  key ID                                : UUID;
  Year                                  : String;
  Rndrng_NPI                            : String;
  Rndrng_Prvdr_Last_Org_Name            : String;
  Rndrng_Prvdr_First_Name               : String;
  Rndrng_Prvdr_MI                       : String;
  Rndrng_Prvdr_Crdntls                  : String;
  Rndrng_Prvdr_Ent_Cd                   : String;
  Rndrng_Prvdr_St1                      : String;
  Rndrng_Prvdr_St2                      : String;
  Rndrng_Prvdr_City                     : String;
  Rndrng_Prvdr_State_Abrvtn             : String;
  Rndrng_Prvdr_State_FIPS               : String;
  Rndrng_Prvdr_Zip5                     : String;
  Rndrng_Prvdr_RUCA                     : String;
  Rndrng_Prvdr_RUCA_Desc                : String;
  Rndrng_Prvdr_Cntry                    : String;
  Rndrng_Prvdr_Type                     : String;
  Rndrng_Prvdr_Mdcr_Prtcptg_Ind         : String;
  HCPCS_Cd                              : String;
  HCPCS_Desc                            : String;
  HCPCS_Drug_Ind                        : String;
  Place_Of_Srvc                         : String;
  Tot_Benes                             : Integer;
  Tot_Srvcs                             : Decimal;
  Tot_Bene_Day_Srvcs                    : Decimal;
  Avg_Sbmtd_Chrg                        : Decimal;
  Avg_Mdcr_Alowd_Amt                    : Decimal;
  Avg_Mdcr_Pymt_Amt                     : Decimal;
  Avg_Mdcr_Stdzd_Amt                    : Decimal;

  // Association back to the rendering provider (composite key: Year + NPI)
  provider : Association to ProviderSummary
               on  provider.Rndrng_NPI = Rndrng_NPI
              and  provider.Year       = Year;
}

entity GeoReference {
  key Year                              : String;
  key ZipCode                           : String;
  State                                 : String;
  Carrier                               : String;
  Locality                              : String;
  RuralInd                              : String;
}
// ─── Task 1 Views ────────────────────────────────────────────────────────────

//view CostByStateProviderType as
  //select
    //p.Year,
    //p.Rndrng_Prvdr_State_Abrvtn  as State             : String,
    //p.Rndrng_Prvdr_Type          as ProviderType       : String,
    //count(p.Rndrng_NPI)          as ProviderCount      : Integer,
    //sum(p.Tot_Sbmtd_Chrg)        as TotalSubmitted     : Decimal,
    //sum(p.Tot_Mdcr_Alowd_Amt)    as TotalAllowed       : Decimal,
    //sum(p.Tot_Mdcr_Pymt_Amt)     as TotalPaid          : Decimal,
    //sum(p.Tot_Benes)             as TotalBeneficiaries : Integer,
    //avg(p.Bene_Avg_Risk_Scre)    as AvgRiskScore       : Decimal
  //from ProviderSummary as p
  //group by p.Year, p.Rndrng_Prvdr_State_Abrvtn, p.Rndrng_Prvdr_Type;

view CostByStateProviderType as
  select from ProviderSummary as p {
    key p.Year,
    key p.Rndrng_Prvdr_State_Abrvtn as State        : String,
    key p.Rndrng_Prvdr_Type         as ProviderType  : String,

    count(p.Rndrng_NPI)          as ProviderCount      : Integer,
    sum(p.Tot_Sbmtd_Chrg)        as TotalSubmitted     : Decimal,
    sum(p.Tot_Mdcr_Alowd_Amt)    as TotalAllowed       : Decimal,
    sum(p.Tot_Mdcr_Pymt_Amt)     as TotalPaid          : Decimal,
    sum(p.Tot_Benes)             as TotalBeneficiaries : Integer,
    avg(p.Bene_Avg_Risk_Scre)    as AvgRiskScore       : Decimal
  }
  group by
    p.Year,
    p.Rndrng_Prvdr_State_Abrvtn,
    p.Rndrng_Prvdr_Type;

// Maps the CMS Rural Indicator (RuralInd) to readable locality buckets per the
// official CMS Zip Code to Carrier Locality File spec (field position 15):
//   blank = urban, R = rural, B = super rural (lowest-population-density rural).
// A provider whose ZIP has no GeoReference match at all (g.ZipCode is null after
// the LEFT JOIN) is the ONLY true "Unknown"; a matched row with a blank RuralInd
// is genuinely Urban and must not be conflated with an unmatched join.
view RuralUrbanDistribution as
  select from ProviderSummary as p
  left join GeoReference as g
    on  g.ZipCode = p.Rndrng_Prvdr_Zip5
    and g.Year    = p.Year {

    key p.Year,
    key p.Rndrng_Prvdr_State_Abrvtn as State : String,
    key case
          when g.ZipCode is null  then 'Unknown'
          when g.RuralInd  = 'R'  then 'Rural'
          when g.RuralInd  = 'B'  then 'Super Rural'
          else                         'Urban'
        end                         as RuralUrban : String,

    count(p.Rndrng_NPI)          as ProviderCount      : Integer,
    sum(p.Tot_Sbmtd_Chrg)        as TotalSubmitted     : Decimal,
    sum(p.Tot_Mdcr_Alowd_Amt)    as TotalAllowed       : Decimal,
    sum(p.Tot_Mdcr_Pymt_Amt)     as TotalPaid          : Decimal,
    sum(p.Tot_Benes)             as TotalBeneficiaries : Integer,
    // Normalized cost measure: ratio of the sums (NOT an average of ratios),
    // so it stays correct at this view grain (Year + State + Rural/Urban).
    cast(sum(p.Tot_Mdcr_Pymt_Amt) as Decimal) / nullif(sum(p.Tot_Benes), 0)
                                 as PaidPerBene        : Decimal,
    avg(p.Bene_Avg_Risk_Scre)    as AvgRiskScore       : Decimal
  }
  group by
    p.Year,
    p.Rndrng_Prvdr_State_Abrvtn,
    case
      when g.ZipCode is null  then 'Unknown'
      when g.RuralInd  = 'R'  then 'Rural'
      when g.RuralInd  = 'B'  then 'Super Rural'
      else                         'Urban'
    end;

// Simplified: instead of 50k provider-level rows, providers are bucketed into
// risk-score bands per Year/State/ProviderType. This turns the entity into a
// true "distribution" (how many providers / beneficiaries fall in each band)
// that is light-weight and directly chartable as a histogram.
view RiskScoreDistribution as
  select from ProviderSummary as p {

    key p.Year,
    key p.Rndrng_Prvdr_State_Abrvtn as State        : String,
    key p.Rndrng_Prvdr_Type         as ProviderType : String,
    key case
          when p.Bene_Avg_Risk_Scre <  0.5 then '1 - Very Low (<0.5)'
          when p.Bene_Avg_Risk_Scre <  1.0 then '2 - Low (0.5-1.0)'
          when p.Bene_Avg_Risk_Scre <  1.5 then '3 - Moderate (1.0-1.5)'
          when p.Bene_Avg_Risk_Scre <  2.0 then '4 - High (1.5-2.0)'
          else                                   '5 - Very High (>=2.0)'
        end                         as RiskBand     : String,

    count(p.Rndrng_NPI)                    as ProviderCount      : Integer,
    sum(p.Tot_Benes)                       as TotalBeneficiaries : Integer,
    sum(p.Tot_Mdcr_Pymt_Amt)               as TotalPaid          : Decimal,
    avg(p.Bene_Avg_Risk_Scre)              as AvgRiskScore       : Decimal,
    avg(p.Bene_CC_PH_Hypertension_V2_Pct)  as AvgHypertensionPct : Decimal,
    avg(p.Bene_CC_PH_Diabetes_V2_Pct)      as AvgDiabetesPct     : Decimal
  }
  group by
    p.Year,
    p.Rndrng_Prvdr_State_Abrvtn,
    p.Rndrng_Prvdr_Type,
    case
      when p.Bene_Avg_Risk_Scre <  0.5 then '1 - Very Low (<0.5)'
      when p.Bene_Avg_Risk_Scre <  1.0 then '2 - Low (0.5-1.0)'
      when p.Bene_Avg_Risk_Scre <  1.5 then '3 - Moderate (1.0-1.5)'
      when p.Bene_Avg_Risk_Scre <  2.0 then '4 - High (1.5-2.0)'
      else                                   '5 - Very High (>=2.0)'
    end;

// ─── Task 2 Views ────────────────────────────────────────────────────────────

view ProviderCostEfficiency as
  select from ProviderSummary as p {
    key p.Year,
    key p.Rndrng_NPI                          as NPI                : String,
    p.Rndrng_Prvdr_Last_Org_Name              as ProviderName       : String,
    p.Rndrng_Prvdr_First_Name                 as FirstName          : String,
    p.Rndrng_Prvdr_Type                       as ProviderType       : String,
    p.Rndrng_Prvdr_State_Abrvtn               as State              : String,
    p.Rndrng_Prvdr_City                       as City               : String,
    p.Tot_Benes                               as TotalBeneficiaries : Integer,
    p.Tot_Mdcr_Pymt_Amt                       as TotalPaid          : Decimal,
    p.Tot_Sbmtd_Chrg                          as TotalSubmitted     : Decimal,
    p.Tot_Mdcr_Alowd_Amt                      as TotalAllowed       : Decimal,
    p.Bene_Avg_Risk_Scre                      as AvgRiskScore       : Decimal,

    // Constant 1 per provider; SUM(ProviderCount) over a group = #providers,
    // which powers the "providers per classification" distribution chart in the ALP.
    cast(1 as Integer)                        as ProviderCount      : Integer,

    // Cost per beneficiary (nullif guards against divide-by-zero / null beneficiaries)
    (p.Tot_Mdcr_Pymt_Amt / nullif(p.Tot_Benes, 0)) as CostPerBeneficiary : Decimal,

    // Risk classification based on Bene_Avg_Risk_Scre
    case
      when p.Bene_Avg_Risk_Scre < 1.0 then 'Low Risk'
      when p.Bene_Avg_Risk_Scre < 1.5 then 'Moderate Risk'
      when p.Bene_Avg_Risk_Scre < 2.0 then 'High Risk'
      else 'Very High Risk'
    end                                       as RiskCategory       : String,

    // Efficiency classification based on cost per beneficiary
    case
      when (p.Tot_Mdcr_Pymt_Amt / p.Tot_Benes) < 500  then 'Highly Efficient'
      when (p.Tot_Mdcr_Pymt_Amt / p.Tot_Benes) < 1000 then 'Efficient'
      when (p.Tot_Mdcr_Pymt_Amt / p.Tot_Benes) < 2000 then 'Average'
      when (p.Tot_Mdcr_Pymt_Amt / p.Tot_Benes) < 5000 then 'Inefficient'
      else 'Outlier'
    end                                       as EfficiencyCategory : String,

    // Utilization behavior
    case
      when p.Tot_Srvcs / p.Tot_Benes < 5  then 'Low Utilization'
      when p.Tot_Srvcs / p.Tot_Benes < 15 then 'Moderate Utilization'
      else 'High Utilization'
    end                                       as UtilizationCategory : String,

    p.Bene_CC_PH_Diabetes_V2_Pct             as DiabetesPct        : Decimal,
    p.Bene_CC_PH_Hypertension_V2_Pct         as HypertensionPct    : Decimal,
    p.Bene_CC_PH_CKD_V2_Pct                  as CKDPct             : Decimal,
    p.Bene_CC_PH_HF_NonIHD_V2_Pct            as HeartFailurePct    : Decimal
  };

// Specialty-level classification (Task 2): collapses ~50k individual providers
// into one row per Year + ProviderType, profiling each SPECIALTY by patient
// complexity (avg risk score), comorbidity burden and normalized cost. The
// derived ComplexityTier answers "is Internal Medicine a high-complexity
// specialty?" rather than judging a single provider.
//
// ComplexityTier thresholds reuse the same risk-score cut points as the
// provider-level RiskCategory (1.0 / 1.5 / 2.0) so the specialty tier and the
// provider tier are directly comparable across the Task 2 dashboards.
//
// AvgCostPerBene is a ratio of sums (total paid / total beneficiaries) so it
// stays exact at the specialty grain instead of averaging per-provider ratios.
view SpecialtyRiskProfile as
  select from ProviderSummary as p {
    key p.Year,
    key p.Rndrng_Prvdr_Type                  as ProviderType        : String,

    count(p.Rndrng_NPI)                      as ProviderCount       : Integer,
    sum(p.Tot_Benes)                         as TotalBeneficiaries  : Integer,
    sum(p.Tot_Mdcr_Pymt_Amt)                 as TotalPaid           : Decimal,

    avg(p.Bene_Avg_Risk_Scre)                as AvgRiskScore        : Decimal,
    cast(sum(p.Tot_Mdcr_Pymt_Amt) as Decimal) / nullif(sum(p.Tot_Benes), 0)
                                             as AvgCostPerBene      : Decimal,

    avg(p.Bene_CC_PH_Hypertension_V2_Pct)    as AvgHypertensionPct  : Decimal,
    avg(p.Bene_CC_PH_Diabetes_V2_Pct)        as AvgDiabetesPct      : Decimal,
    avg(p.Bene_CC_PH_CKD_V2_Pct)             as AvgCKDPct           : Decimal,
    avg(p.Bene_CC_PH_HF_NonIHD_V2_Pct)       as AvgHeartFailurePct  : Decimal,

    // Specialty patient-complexity tier, derived from the specialty's mean risk
    // score (aligned with provider-level RiskCategory thresholds).
    case
      when avg(p.Bene_Avg_Risk_Scre) < 1.0 then 'Low Complexity'
      when avg(p.Bene_Avg_Risk_Scre) < 1.5 then 'Moderate Complexity'
      when avg(p.Bene_Avg_Risk_Scre) < 2.0 then 'High Complexity'
      else                                      'Very High Complexity'
    end                                      as ComplexityTier      : String
  }
  group by
    p.Year,
    p.Rndrng_Prvdr_Type;

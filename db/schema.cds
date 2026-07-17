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
  key Year                                  : String;
  key Rndrng_NPI                            : String;
  key HCPCS_Cd                              : String;
  key Place_Of_Srvc                         : String;
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
  HCPCS_Desc                            : String;
  HCPCS_Drug_Ind                        : String;
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

// US state / territory code → full name (for readable table and chart labels)
entity StateReference {
  key Code : String;
      Name : String;
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

// ─── Cost Analysis V2 — state + provider-type grain (table); chart rolls up to State ─
view CostAnalysisV2 as
  select from ProviderSummary as p
  left join StateReference as sr
    on sr.Code = p.Rndrng_Prvdr_State_Abrvtn {
    key p.Year,
    key p.Rndrng_Prvdr_State_Abrvtn as State       : String,
    key p.Rndrng_Prvdr_Type         as ProviderType : String,

    max(coalesce(sr.Name, p.Rndrng_Prvdr_State_Abrvtn)) as StateName : String,
    count(p.Rndrng_NPI)           as ProviderCount      : Integer,
    sum(p.Tot_Sbmtd_Chrg)         as TotalSubmitted     : Decimal,
    sum(p.Tot_Mdcr_Alowd_Amt)     as TotalAllowed       : Decimal,
    sum(p.Tot_Mdcr_Pymt_Amt)      as TotalPaid          : Decimal,
    // Over-billing delta: claimed charges minus Medicare-approved fee-schedule cap
    sum(p.Tot_Sbmtd_Chrg) - sum(p.Tot_Mdcr_Alowd_Amt) as RejectedCharges : Decimal,
    sum(p.Drug_Sbmtd_Chrg)        as DrugSubmitted      : Decimal,
    sum(p.Drug_Mdcr_Alowd_Amt)    as DrugAllowed        : Decimal,
    sum(p.Drug_Sbmtd_Chrg) - sum(p.Drug_Mdcr_Alowd_Amt) as RejectedDrugCharges : Decimal,
    sum(p.Drug_Mdcr_Pymt_Amt)     as DrugPaid           : Decimal,
    sum(p.Tot_Benes)              as TotalBeneficiaries : Integer
  }
  group by
    p.Year,
    p.Rndrng_Prvdr_State_Abrvtn,
    p.Rndrng_Prvdr_Type;

// Analytical cube semantics for OData V4 aggregation + GenAI currency context
annotate medicare.CostAnalysisV2 with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

annotate medicare.CostAnalysisV2 with {
  TotalSubmitted  @Measures.ISOCurrency: 'USD';
  TotalAllowed    @Measures.ISOCurrency: 'USD';
  TotalPaid       @Measures.ISOCurrency: 'USD';
  RejectedCharges @Measures.ISOCurrency: 'USD';
  DrugSubmitted       @Measures.ISOCurrency: 'USD';
  DrugAllowed         @Measures.ISOCurrency: 'USD';
  RejectedDrugCharges @Measures.ISOCurrency: 'USD';
  DrugPaid            @Measures.ISOCurrency: 'USD';
};

// ─── Rural Analysis V2 — HCPCS × RUCA structural tier (overclaiming & frequency) ─
// Base tier grain: one row per procedure × structural tier.
view RuralAnalysisV2Tier as
  select from ServiceDetails as s {
    key s.HCPCS_Cd   as HCPCS_Code : String,
    key s.HCPCS_Desc as HCPCS_Desc : String,
    key case
          when s.Rndrng_Prvdr_RUCA is null
            or s.Rndrng_Prvdr_RUCA = ''                    then 'Unclassified'
          when cast(s.Rndrng_Prvdr_RUCA as Decimal) >= 1.0
           and cast(s.Rndrng_Prvdr_RUCA as Decimal) <= 3.0  then 'Urban / Metro'
          when cast(s.Rndrng_Prvdr_RUCA as Decimal) >= 4.0
           and cast(s.Rndrng_Prvdr_RUCA as Decimal) <= 6.0  then 'Suburban / Micro'
          when cast(s.Rndrng_Prvdr_RUCA as Decimal) >= 7.0
           and cast(s.Rndrng_Prvdr_RUCA as Decimal) <= 10.3 then 'Rural / Isolated'
          else                                                   'Unclassified'
        end              as StructuralTier : String,

    // CMS CSV may include thousands separators in Tot_Srvcs (e.g. "1,200") and in currency strings
    sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as TotalServices : Decimal,
    sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as TotalSubmitted : Decimal,
    sum(cast(replace(replace(s.Avg_Mdcr_Pymt_Amt, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as TotalPaid : Decimal,
    sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
      - sum(cast(replace(replace(s.Avg_Mdcr_Alowd_Amt, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as RejectedCharges : Decimal,
    // Clamp to 0–100%: negative rejected = no overclaim; >100% capped for chart axis stability
    cast(round(
      case
        when sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) <= 0 then null
        when sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
           - sum(cast(replace(replace(s.Avg_Mdcr_Alowd_Amt, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) <= 0 then 0
        when cast((cast(sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as Decimal)
           - cast(sum(cast(replace(replace(s.Avg_Mdcr_Alowd_Amt, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as Decimal)) as Double)
           / cast(sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as Double) * 100 > 100 then 100
        else cast((cast(sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as Decimal)
           - cast(sum(cast(replace(replace(s.Avg_Mdcr_Alowd_Amt, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as Decimal)) as Double)
           / cast(sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal) * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) as Double) * 100
      end
    , 2) as Decimal) as OverclaimRate : Decimal
  }
  group by
    s.HCPCS_Cd,
    s.HCPCS_Desc,
    case
      when s.Rndrng_Prvdr_RUCA is null
        or s.Rndrng_Prvdr_RUCA = ''                    then 'Unclassified'
      when cast(s.Rndrng_Prvdr_RUCA as Decimal) >= 1.0
       and cast(s.Rndrng_Prvdr_RUCA as Decimal) <= 3.0  then 'Urban / Metro'
      when cast(s.Rndrng_Prvdr_RUCA as Decimal) >= 4.0
       and cast(s.Rndrng_Prvdr_RUCA as Decimal) <= 6.0  then 'Suburban / Micro'
      when cast(s.Rndrng_Prvdr_RUCA as Decimal) >= 7.0
       and cast(s.Rndrng_Prvdr_RUCA as Decimal) <= 10.3 then 'Rural / Isolated'
      else                                                   'Unclassified'
    end;

// Enriched projection: attaches Urban / Metro inflation rate as the comparative baseline
// for each procedure code (used as the bullet-chart target notch).
view RuralAnalysisV2 as
  select from RuralAnalysisV2Tier as tier
  left join (
    select from RuralAnalysisV2Tier as urban {
      key urban.HCPCS_Code,
      key urban.HCPCS_Desc,
      urban.OverclaimRate as UrbanBaselineRate : Decimal
    }
    where urban.StructuralTier = 'Urban / Metro'
  ) as baseline on  baseline.HCPCS_Code = tier.HCPCS_Code
                and baseline.HCPCS_Desc = tier.HCPCS_Desc {
    key tier.HCPCS_Code,
    key tier.HCPCS_Desc,
    key tier.StructuralTier,
    tier.TotalServices,
    tier.TotalSubmitted,
    tier.TotalPaid,
    tier.RejectedCharges,
    tier.OverclaimRate,
    baseline.UrbanBaselineRate
  };

annotate medicare.RuralAnalysisV2 with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

annotate medicare.RuralAnalysisV2 with {
  TotalSubmitted     @Measures.ISOCurrency: 'USD';
  TotalPaid          @Measures.ISOCurrency: 'USD';
  RejectedCharges    @Measures.ISOCurrency: 'USD';
  OverclaimRate      @Measures.Unit: '%';
  UrbanBaselineRate  @Measures.Unit: '%';
};

// Chart / ALP grain — one row per HCPCS_Code × StructuralTier (descriptions merged).
// OverclaimRate is recomputed from summed charges (never sum of row-level percentages).
view RuralAnalysisChartBase as
  select from RuralAnalysisV2Tier as tier {
    key tier.HCPCS_Code,
    key tier.StructuralTier,
    min(tier.HCPCS_Desc) as HCPCS_Desc : String,
    sum(tier.TotalServices)  as TotalServices  : Decimal,
    sum(tier.TotalSubmitted) as TotalSubmitted : Decimal,
    sum(tier.TotalPaid)      as TotalPaid      : Decimal,
    sum(tier.RejectedCharges) as RejectedCharges : Decimal,
    cast(round(
      case
        when sum(tier.TotalSubmitted) <= 0 then null
        when sum(tier.RejectedCharges) <= 0 then 0
        when cast(sum(tier.RejectedCharges) as Double) / cast(sum(tier.TotalSubmitted) as Double) * 100 > 100 then 100
        else cast(sum(tier.RejectedCharges) as Double) / cast(sum(tier.TotalSubmitted) as Double) * 100
      end
    , 2) as Decimal) as OverclaimRate : Decimal
  }
  group by
    tier.HCPCS_Code,
    tier.StructuralTier;

// Procedure codes present in 2+ structural tiers (comparative chart grain).
view RuralAnalysisChartMultiTier as
  select from RuralAnalysisChartBase {
    key HCPCS_Code,
    count(distinct StructuralTier) as TierCoverageCount : Integer
  }
  where StructuralTier in (
    'Urban / Metro', 'Suburban / Micro', 'Rural / Isolated'
  )
  group by HCPCS_Code
  having count(distinct StructuralTier) >= 2;

// Volume-weighted rejection rate per procedure across all structural tiers (comparative baseline).
view RuralAnalysisChartProcedureBaseline as
  select from RuralAnalysisChartBase {
    key HCPCS_Code,
    cast(round(
      case
        when sum(TotalSubmitted) <= 0 then null
        when sum(RejectedCharges) <= 0 then 0
        else cast(sum(RejectedCharges) as Double) / cast(sum(TotalSubmitted) as Double) * 100
      end
    , 2) as Decimal) as ProcedureBaselineRate : Decimal
  }
  where StructuralTier in (
    'Urban / Metro', 'Suburban / Micro', 'Rural / Isolated'
  )
  group by HCPCS_Code;

view RuralAnalysisChart as
  select from RuralAnalysisChartBase as tier
  inner join RuralAnalysisChartMultiTier as coverage
    on coverage.HCPCS_Code = tier.HCPCS_Code
  left join RuralAnalysisChartProcedureBaseline as baseline
    on baseline.HCPCS_Code = tier.HCPCS_Code {
    key tier.HCPCS_Code,
    key tier.StructuralTier,
    tier.HCPCS_Desc,
    tier.TotalServices,
    tier.TotalSubmitted,
    tier.TotalPaid,
    tier.RejectedCharges,
    tier.OverclaimRate,
    baseline.ProcedureBaselineRate,
    // Tier deviation = tier rejection rate minus procedure-weighted average baseline
    cast(round(
      case
        when baseline.ProcedureBaselineRate is null then tier.OverclaimRate
        else tier.OverclaimRate - baseline.ProcedureBaselineRate
      end
    , 2) as Decimal) as TierDeviation : Decimal,
    coverage.TierCoverageCount
  }
  where tier.StructuralTier in (
    'Urban / Metro', 'Suburban / Micro', 'Rural / Isolated'
  );

annotate medicare.RuralAnalysisChart with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

annotate medicare.RuralAnalysisChart with {
  TotalSubmitted     @Measures.ISOCurrency: 'USD';
  TotalPaid          @Measures.ISOCurrency: 'USD';
  RejectedCharges    @Measures.ISOCurrency: 'USD';
  OverclaimRate           @Measures.Unit: '%';
  ProcedureBaselineRate   @Measures.Unit: '%';
  TierDeviation           @Measures.Unit: '%';
  TierCoverageCount       @Measures.Unit: #ONE;
};

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

// ─── Task 1.3 — Cost-Complexity Frontier (BH burden peer groups) ─────────────

// Pass 1: median BH burden per (Year, State, ProviderType) group
view BHBurdenMedianByGroup as
  select from ProviderSummary as p {
    key p.Year,
    key p.Rndrng_Prvdr_State_Abrvtn as State        : String,
    key p.Rndrng_Prvdr_Type         as ProviderType : String,

    count(p.Rndrng_NPI) as ProviderCount : Integer,

    median(
      ( coalesce(p.Bene_CC_BH_ADHD_OthCD_V1_Pct, 0)
      + coalesce(p.Bene_CC_BH_Alcohol_Drug_V1_Pct, 0)
      + coalesce(p.Bene_CC_BH_Tobacco_V1_Pct, 0)
      + coalesce(p.Bene_CC_BH_Alz_NonAlzdem_V2_Pct, 0)
      + coalesce(p.Bene_CC_BH_Anxiety_V1_Pct, 0)
      + coalesce(p.Bene_CC_BH_Bipolar_V1_Pct, 0)
      + coalesce(p.Bene_CC_BH_Mood_V2_Pct, 0)
      + coalesce(p.Bene_CC_BH_Depress_V1_Pct, 0)
      + coalesce(p.Bene_CC_BH_PD_V1_Pct, 0)
      + coalesce(p.Bene_CC_BH_PTSD_V1_Pct, 0)
      + coalesce(p.Bene_CC_BH_Schizo_OthPsy_V1_Pct, 0) ) / 11
    ) as MedianBHBurden : Decimal
  }
  group by
    p.Year, p.Rndrng_Prvdr_State_Abrvtn, p.Rndrng_Prvdr_Type
  having count(p.Rndrng_NPI) >= 10;

// Pass 2: classify each provider vs their peer group's median, then aggregate
view BehavioralHealthRiskProfile as
  select from ProviderSummary as p
  inner join BHBurdenMedianByGroup as m
    on  m.Year         = p.Year
    and m.State        = p.Rndrng_Prvdr_State_Abrvtn
    and m.ProviderType = p.Rndrng_Prvdr_Type {

    key p.Year,
    key p.Rndrng_Prvdr_State_Abrvtn as State        : String,
    key p.Rndrng_Prvdr_Type         as ProviderType : String,
    key case
          when ( ( coalesce(p.Bene_CC_BH_ADHD_OthCD_V1_Pct, 0)
                 + coalesce(p.Bene_CC_BH_Alcohol_Drug_V1_Pct, 0)
                 + coalesce(p.Bene_CC_BH_Tobacco_V1_Pct, 0)
                 + coalesce(p.Bene_CC_BH_Alz_NonAlzdem_V2_Pct, 0)
                 + coalesce(p.Bene_CC_BH_Anxiety_V1_Pct, 0)
                 + coalesce(p.Bene_CC_BH_Bipolar_V1_Pct, 0)
                 + coalesce(p.Bene_CC_BH_Mood_V2_Pct, 0)
                 + coalesce(p.Bene_CC_BH_Depress_V1_Pct, 0)
                 + coalesce(p.Bene_CC_BH_PD_V1_Pct, 0)
                 + coalesce(p.Bene_CC_BH_PTSD_V1_Pct, 0)
                 + coalesce(p.Bene_CC_BH_Schizo_OthPsy_V1_Pct, 0) ) / 11 ) >= m.MedianBHBurden
            then 'B - High BH Burden'
            else 'A - Low BH Burden'
        end                          as BHBurdenGroup : String,

    count(p.Rndrng_NPI)                        as ProviderCount       : Integer,
    cast(round(avg(p.Bene_Avg_Risk_Scre), 3) as Decimal(10,3)) as AvgRiskScore : Decimal(10,3),
    sum(p.Tot_Sbmtd_Chrg)                      as TotalSubmitted      : Decimal,
    sum(p.Tot_Mdcr_Alowd_Amt)                  as TotalAllowed        : Decimal,
    sum(p.Tot_Mdcr_Pymt_Amt)                   as TotalPaid           : Decimal,
    sum(p.Tot_Benes)                           as TotalBeneficiaries  : Integer,
    cast(round(cast(sum(p.Tot_Mdcr_Pymt_Amt) as Decimal) / nullif(sum(p.Tot_Benes), 0), 3) as Decimal(10,3))
                                            as PaidPerBeneficiary  : Decimal(10,3),
    sum(p.Drug_Mdcr_Pymt_Amt)                  as TotalDrugPaid       : Decimal,
    avg(p.Tot_HCPCS_Cds)                       as AvgUniqueProcedures : Decimal,
    sum(case when p.Rndrng_Prvdr_Mdcr_Prtcptg_Ind = 'Y' then 1 else 0 end)
                                                as MedicareAcceptCount : Integer
  }
  group by
    p.Year, p.Rndrng_Prvdr_State_Abrvtn, p.Rndrng_Prvdr_Type,
    case
      when ( ( coalesce(p.Bene_CC_BH_ADHD_OthCD_V1_Pct, 0)
             + coalesce(p.Bene_CC_BH_Alcohol_Drug_V1_Pct, 0)
             + coalesce(p.Bene_CC_BH_Tobacco_V1_Pct, 0)
             + coalesce(p.Bene_CC_BH_Alz_NonAlzdem_V2_Pct, 0)
             + coalesce(p.Bene_CC_BH_Anxiety_V1_Pct, 0)
             + coalesce(p.Bene_CC_BH_Bipolar_V1_Pct, 0)
             + coalesce(p.Bene_CC_BH_Mood_V2_Pct, 0)
             + coalesce(p.Bene_CC_BH_Depress_V1_Pct, 0)
             + coalesce(p.Bene_CC_BH_PD_V1_Pct, 0)
             + coalesce(p.Bene_CC_BH_PTSD_V1_Pct, 0)
             + coalesce(p.Bene_CC_BH_Schizo_OthPsy_V1_Pct, 0) ) / 11 ) >= m.MedianBHBurden
      then 'B - High BH Burden'
      else 'A - Low BH Burden'
    end;

annotate medicare.BehavioralHealthRiskProfile with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

// ─── Task 2 Views ────────────────────────────────────────────────────────────

// Task 2.1 — 2-Axis Risk Matrix: Cost Classification × Utilization Profile
// One row per provider (Year + NPI). Chart aggregates ProviderCount by the
// EfficiencyCategory (X) × UtilizationCategory (series) matrix cells.
view ProviderCostEfficiency as
  select from ProviderSummary as p {
    key p.Year,
    key p.Rndrng_NPI                    as NPI                    : String,
    upper(p.Rndrng_Prvdr_Last_Org_Name) as ProviderName           : String,
    p.Rndrng_Prvdr_Type                 as ProviderType           : String,
    p.Rndrng_Prvdr_State_Abrvtn         as State                  : String,
    p.Rndrng_Prvdr_Ent_Cd                 as EntityTypeCode         : String,
    case
      when p.Rndrng_Prvdr_Ent_Cd = 'O' then 'Organization / Corporate Network'
      when p.Rndrng_Prvdr_Ent_Cd = 'I' then 'Individual Clinician'
      else                                   'Unknown Entity Type'
    end                                              as EntityType             : String(40),

    (p.Tot_Mdcr_Pymt_Amt / nullif(p.Tot_Benes, 0)) as CostPerBeneficiary     : Decimal,
    cast(round(p.Tot_Srvcs / nullif(p.Tot_Benes, 0)) as Integer) as ServicesPerBeneficiary : Integer,

    case
      when (p.Tot_Mdcr_Pymt_Amt / nullif(p.Tot_Benes, 0)) < 150 then 'Highly Efficient'
      when (p.Tot_Mdcr_Pymt_Amt / nullif(p.Tot_Benes, 0)) < 900 then 'Average Spend'
      else 'High-Cost Outlier'
    end                                              as EfficiencyCategory     : String,

    case
      when (p.Tot_Srvcs / nullif(p.Tot_Benes, 0)) < 5  then 'Low Utilization'
      when (p.Tot_Srvcs / nullif(p.Tot_Benes, 0)) < 15 then 'Moderate Utilization'
      else 'High Utilization'
    end                                              as UtilizationCategory    : String,

    p.Tot_Benes                                      as TotalBeneficiaries     : Integer,
    p.Tot_Mdcr_Pymt_Amt                              as TotalActualPayments    : Decimal,
    p.Bene_Avg_Age                                   as AvgPatientAge          : Decimal,
    p.Bene_Avg_Risk_Scre                             as AvgRiskScore           : Decimal,
    p.Bene_CC_PH_Diabetes_V2_Pct                     as DiabetesPct            : Decimal,
    p.Bene_CC_PH_Hypertension_V2_Pct                 as HypertensionPct        : Decimal,

    cast(1 as Integer)                               as ProviderCount          : Integer
  };

annotate medicare.ProviderCostEfficiency with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

annotate medicare.ProviderCostEfficiency with {
  ProviderCount       @Aggregation.default: #SUM;
  TotalActualPayments @Measures.ISOCurrency: 'USD';
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

// ─── Task 2.2 — Specialty Peer Profiling ─────────────────────────────────────

// National peer baseline averages per year and specialty.
view SpecialtyPeerBaselines as
  select from ProviderCostEfficiency {
    key Year,
    key ProviderType                         as Specialty            : String,
    avg(CostPerBeneficiary)                  as NationalAvgCost      : Decimal(15, 2),
    avg(ServicesPerBeneficiary)              as NationalAvgServices  : Decimal(15, 2)
  }
  group by
    Year,
    ProviderType;

// Baseline join: authentic variance percentages vs specialty-year peer averages.
view SpecialtyPeerDeviations as
  select from ProviderCostEfficiency as Provider
  inner join SpecialtyPeerBaselines as Baseline on (
    Provider.Year = Baseline.Year
    and Provider.ProviderType = Baseline.Specialty
  ) {
    key Provider.Year,
    key Provider.NPI,
    Provider.ProviderName,
    Provider.ProviderType                      as Specialty            : String,
    Provider.State,
    Provider.CostPerBeneficiary                as CostPerPatient       : Decimal,
    Baseline.NationalAvgCost,
    case
      when nullif(Baseline.NationalAvgCost, 0) is not null
        then round(((Provider.CostPerBeneficiary - Baseline.NationalAvgCost) / Baseline.NationalAvgCost) * 100)
      else 0
    end                                        as CostTierDeviation    : Decimal(15, 2),
    Provider.ServicesPerBeneficiary            as ServicesPerPatient   : Integer,
    Baseline.NationalAvgServices,
    case
      when nullif(Baseline.NationalAvgServices, 0) is not null
        then round(((Provider.ServicesPerBeneficiary - Baseline.NationalAvgServices) / Baseline.NationalAvgServices) * 100)
      else 0
    end                                        as ServiceTierDeviation : Decimal(15, 2)
  };

annotate medicare.SpecialtyPeerDeviations with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

// ─── Task 2.3 — Entity Type Macro Comparison (Individual vs Organization) ─────

// Compares Individual clinicians vs Corporate organizations using CMS entity code.
view EntityTypeComparisons as
  select from ProviderCostEfficiency {
    key Year,
    key case
      when EntityTypeCode = 'O' then 'Organization / Corporate Network'
      when EntityTypeCode = 'I' then 'Individual Clinician'
      else                           'Unknown Entity Type'
    end                                      as EntityType                 : String(40),
    count(distinct NPI)                      as TotalUniqueProviders       : Integer,
    sum(TotalBeneficiaries)                  as TotalPatientsServed        : Integer,
    avg(CostPerBeneficiary)                  as MacroAvgCostPerPatient     : Decimal(15, 2),
    avg(ServicesPerBeneficiary)              as MacroAvgServicesPerPatient : Decimal(15, 2),
    sum(case
          when EfficiencyCategory = 'High-Cost Outlier' then 1
          else 0
        end)                                 as HighCostOutlierCount       : Integer,
    sum(case
          when UtilizationCategory = 'High Utilization' then 1
          else 0
        end)                                 as HighVolumeOutlierCount     : Integer
  }
  group by
    Year,
    EntityTypeCode;

annotate medicare.EntityTypeComparisons with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

// ─── Task 2.2B — Provider-level entity type profiling (specialty drill-down) ───

view EntityTypeProviderProfiles as
  select from ProviderCostEfficiency {
    key Year,
    key NPI,
    ProviderName,
    ProviderType,
    State,
    EntityTypeCode,
    EntityType,
    CostPerBeneficiary,
    ServicesPerBeneficiary,
    EfficiencyCategory,
    UtilizationCategory,
    TotalBeneficiaries,
    AvgPatientAge,
    AvgRiskScore,
    DiabetesPct,
    HypertensionPct,
    ProviderCount
  };

annotate medicare.EntityTypeProviderProfiles with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

// ─── Task 2.2B — Yearly insight: which entity class charges more ───────────────

view EntityTypeCostInsight as
  select from EntityTypeComparisons as org
  inner join EntityTypeComparisons as ind
    on  org.Year = ind.Year
    and org.EntityType = 'Organization / Corporate Network'
    and ind.EntityType = 'Individual Clinician' {
    key org.Year,
    case
      when org.MacroAvgCostPerPatient >= ind.MacroAvgCostPerPatient
        then org.EntityType
      else ind.EntityType
    end                                      as HigherChargingEntity   : String(40),
    case
      when org.MacroAvgCostPerPatient >= ind.MacroAvgCostPerPatient
        then org.MacroAvgCostPerPatient
      else ind.MacroAvgCostPerPatient
    end                                      as HigherEntityAvgCost    : Decimal(15, 2),
    case
      when org.MacroAvgCostPerPatient >= ind.MacroAvgCostPerPatient
        then ind.MacroAvgCostPerPatient
      else org.MacroAvgCostPerPatient
    end                                      as LowerEntityAvgCost     : Decimal(15, 2),
    round(
      abs(org.MacroAvgCostPerPatient - ind.MacroAvgCostPerPatient)
      / nullif(
          case
            when org.MacroAvgCostPerPatient < ind.MacroAvgCostPerPatient
              then org.MacroAvgCostPerPatient
            else ind.MacroAvgCostPerPatient
          end,
          0
        ) * 100,
      1
    )                                        as CostPremiumPct         : Decimal(15, 1)
  };

// ─── Task 3.3 - Credentials & Charge Discrepancies ───────────────────────────

// Standardizes credentials and splits the financial gap into:
//   ChargePaddingAmt   = Submitted - Allowed  (inflated billing vs fee schedule)
//   PolicyShortfallAmt = Allowed - Paid       (85% mid-level rule, cost-sharing)
//   PaidToAllowedRatePct = Paid ÷ Allowed     (statutory reimbursement tracking)
view CredentialDiscrepancies as
  select from ProviderSummary as p {
    key p.Year,
    key case
          when upper(p.Rndrng_Prvdr_Crdntls) like '%M.D.%' or upper(p.Rndrng_Prvdr_Crdntls) = 'MD'
            then 'MD - Doctor of Medicine'
          when upper(p.Rndrng_Prvdr_Crdntls) like '%D.O.%' or upper(p.Rndrng_Prvdr_Crdntls) = 'DO'
            then 'DO - Osteopathic Medicine'
          when upper(p.Rndrng_Prvdr_Crdntls) like '%N.P.%' or upper(p.Rndrng_Prvdr_Crdntls) = 'NP'
            or upper(p.Rndrng_Prvdr_Crdntls) like '%NURSE PRACTITIONER%'
            then 'NP - Nurse Practitioner'
          when upper(p.Rndrng_Prvdr_Crdntls) like '%P.A.%' or upper(p.Rndrng_Prvdr_Crdntls) = 'PA'
            or upper(p.Rndrng_Prvdr_Crdntls) like '%PHYSICIAN ASSISTANT%'
            then 'PA - Physician Assistant'
          when upper(p.Rndrng_Prvdr_Crdntls) like '%CRNA%'
            then 'CRNA - Nurse Anesthetist'
          when p.Rndrng_Prvdr_Crdntls is null or p.Rndrng_Prvdr_Crdntls = ''
            then 'Unspecified Credentials'
          else 'Other Specialists'
        end                                  as StandardizedCredential : String(50),

    count(distinct p.Rndrng_NPI)             as TotalUniqueProviders   : Integer,
    sum(p.Tot_Benes)                         as TotalPatientsServed    : Integer,
    sum(p.Tot_Sbmtd_Chrg)                    as TotalSubmittedCharges  : Decimal(15, 2),
    sum(p.Tot_Mdcr_Alowd_Amt)                as TotalAllowedCharges    : Decimal(15, 2),
    sum(p.Tot_Mdcr_Pymt_Amt)                 as TotalActualPayments    : Decimal(15, 2),

    // 1. Charge padding - billed amount above Medicare fee-schedule allowance
    (sum(p.Tot_Sbmtd_Chrg) - sum(p.Tot_Mdcr_Alowd_Amt))
                                             as ChargePaddingAmt       : Decimal(15, 2),

    // 2. Policy shortfall - allowed amount not realized as payment (85% rule, cost-sharing)
    (sum(p.Tot_Mdcr_Alowd_Amt) - sum(p.Tot_Mdcr_Pymt_Amt))
                                             as PolicyShortfallAmt     : Decimal(15, 2),

    // 3. Paid-to-allowed rate - statutory reimbursement tracking (NP/PA expected lower)
    case
      when sum(p.Tot_Mdcr_Alowd_Amt) > 0
        then round((sum(p.Tot_Mdcr_Pymt_Amt) / sum(p.Tot_Mdcr_Alowd_Amt)) * 100)
      else 0
    end                                      as PaidToAllowedRatePct   : Decimal(5, 2),

    // Charge-padding rate - share of submitted charges rejected by fee schedule
    case
      when sum(p.Tot_Sbmtd_Chrg) > 0
        then round(
          ((sum(p.Tot_Sbmtd_Chrg) - sum(p.Tot_Mdcr_Alowd_Amt)) / sum(p.Tot_Sbmtd_Chrg)) * 100
        )
      else 0
    end                                      as ChargePaddingRatePct   : Decimal(5, 2)
  }
  group by
    p.Year,
    case
      when upper(p.Rndrng_Prvdr_Crdntls) like '%M.D.%' or upper(p.Rndrng_Prvdr_Crdntls) = 'MD'
        then 'MD - Doctor of Medicine'
      when upper(p.Rndrng_Prvdr_Crdntls) like '%D.O.%' or upper(p.Rndrng_Prvdr_Crdntls) = 'DO'
        then 'DO - Osteopathic Medicine'
      when upper(p.Rndrng_Prvdr_Crdntls) like '%N.P.%' or upper(p.Rndrng_Prvdr_Crdntls) = 'NP'
        or upper(p.Rndrng_Prvdr_Crdntls) like '%NURSE PRACTITIONER%'
        then 'NP - Nurse Practitioner'
      when upper(p.Rndrng_Prvdr_Crdntls) like '%P.A.%' or upper(p.Rndrng_Prvdr_Crdntls) = 'PA'
        or upper(p.Rndrng_Prvdr_Crdntls) like '%PHYSICIAN ASSISTANT%'
        then 'PA - Physician Assistant'
      when upper(p.Rndrng_Prvdr_Crdntls) like '%CRNA%'
        then 'CRNA - Nurse Anesthetist'
      when p.Rndrng_Prvdr_Crdntls is null or p.Rndrng_Prvdr_Crdntls = ''
        then 'Unspecified Credentials'
      else 'Other Specialists'
    end;

annotate medicare.CredentialDiscrepancies with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

// ─── Task 3.2 — Place of Service Analysis ─────────────────────────────────────

// Aggregates payments and volume by specialty and place-of-service setting.
// Source: ServiceDetails (procedure grain) — Place_Of_Srvc is F = Facility, O = Office.
// Charge totals = Avg_* × Tot_Srvcs (same CMS line-item pattern as RuralAnalysisV2Tier).
view PlaceOfServiceAnalysis as
  select from ServiceDetails as s {
    key s.Year,
    key s.Rndrng_Prvdr_Type              as Specialty              : String,
    key case
          when s.Place_Of_Srvc = 'F' then 'Facility (Hospital/ASC)'
          when s.Place_Of_Srvc = 'O' then 'Office (Non-Facility)'
          else                             'Unknown Place of Service'
        end                              as PlaceOfService         : String(30),

    count(distinct s.Rndrng_NPI)         as TotalUniqueProviders   : Integer,
    sum(s.Tot_Benes)                     as TotalPatientsServed    : Integer,
    sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
                                         as TotalServicesRendered  : Decimal(15, 2),
    sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal)
      * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
                                         as TotalSubmittedCharges  : Decimal(15, 2),
    sum(cast(replace(replace(s.Avg_Mdcr_Alowd_Amt, '$', ''), ',', '') as Decimal)
      * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
                                         as TotalAllowedCharges    : Decimal(15, 2),
    sum(cast(replace(replace(s.Avg_Mdcr_Pymt_Amt, '$', ''), ',', '') as Decimal)
      * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
                                         as TotalActualPayments    : Decimal(15, 2),

    case
      when sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) > 0
        then round(
          sum(cast(replace(replace(s.Avg_Mdcr_Pymt_Amt, '$', ''), ',', '') as Decimal)
            * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
          / sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
        )
      else 0
    end                                  as AvgPaymentPerService   : Decimal(15, 2),

    case
      when sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) > 0
        then round(
          sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal)
            * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
          / sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
        )
      else 0
    end                                  as AvgSubmittedPerService : Decimal(15, 2)
  }
  group by
    s.Year,
    s.Rndrng_Prvdr_Type,
    case
      when s.Place_Of_Srvc = 'F' then 'Facility (Hospital/ASC)'
      when s.Place_Of_Srvc = 'O' then 'Office (Non-Facility)'
      else                             'Unknown Place of Service'
    end;

annotate medicare.PlaceOfServiceAnalysis with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

// Provider grain: one row per Year × NPI × Specialty × Place of Service.
// Powers the ALP table — collapsed by specialty, expand to individual providers.
view PlaceOfServiceProviderProfiles as
  select from ServiceDetails as s {
    key s.Year,
    key s.Rndrng_NPI                     as NPI                    : String,
    key s.Rndrng_Prvdr_Type              as Specialty              : String,
    key case
          when s.Place_Of_Srvc = 'F' then 'Facility (Hospital/ASC)'
          when s.Place_Of_Srvc = 'O' then 'Office (Non-Facility)'
          else                             'Unknown Place of Service'
        end                              as PlaceOfService         : String(30),

    max(upper(s.Rndrng_Prvdr_Last_Org_Name)) as ProviderName         : String,
    max(s.Rndrng_Prvdr_State_Abrvtn)         as State                : String,

    sum(s.Tot_Benes)                     as TotalPatientsServed    : Integer,
    sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
                                         as TotalServicesRendered  : Decimal(15, 2),
    sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal)
      * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
                                         as TotalSubmittedCharges  : Decimal(15, 2),
    sum(cast(replace(replace(s.Avg_Mdcr_Alowd_Amt, '$', ''), ',', '') as Decimal)
      * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
                                         as TotalAllowedCharges    : Decimal(15, 2),
    sum(cast(replace(replace(s.Avg_Mdcr_Pymt_Amt, '$', ''), ',', '') as Decimal)
      * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
                                         as TotalActualPayments    : Decimal(15, 2),

    case
      when sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) > 0
        then round(
          sum(cast(replace(replace(s.Avg_Mdcr_Pymt_Amt, '$', ''), ',', '') as Decimal)
            * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
          / sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
        )
      else 0
    end                                  as AvgPaymentPerService   : Decimal(15, 2),

    case
      when sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal)) > 0
        then round(
          sum(cast(replace(replace(s.Avg_Sbmtd_Chrg, '$', ''), ',', '') as Decimal)
            * cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
          / sum(cast(replace(cast(s.Tot_Srvcs as String), ',', '') as Decimal))
        )
      else 0
    end                                  as AvgSubmittedPerService : Decimal(15, 2),

    cast(1 as Integer)                   as ProviderCount          : Integer
  }
  group by
    s.Year,
    s.Rndrng_NPI,
    s.Rndrng_Prvdr_Type,
    case
      when s.Place_Of_Srvc = 'F' then 'Facility (Hospital/ASC)'
      when s.Place_Of_Srvc = 'O' then 'Office (Non-Facility)'
      else                             'Unknown Place of Service'
    end;

annotate medicare.PlaceOfServiceProviderProfiles with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

// ─── Task 3.1 — Risk-Cost-Volume Dynamics ─────────────────────────────────────

// Specialty × Year grain — beneficiary-weighted risk and cost intensity.
// Avoids NPI-level overplotting on the ALP chart; one column pair per specialty.
view RiskCostVolumeDynamics as
  select from ProviderCostEfficiency {
    key Year,
    key ProviderType                         as Specialty              : String,

    count(distinct NPI)                      as TotalUniqueProviders   : Integer,

    case
      when sum(TotalBeneficiaries) > 0
      then round(sum(AvgRiskScore * TotalBeneficiaries) / sum(TotalBeneficiaries), 2)
      else 0
    end                                      as PatientRiskScore       : Decimal(5, 2),

    case
      when sum(TotalBeneficiaries) > 0
      then round(sum(CostPerBeneficiary * TotalBeneficiaries) / sum(TotalBeneficiaries), 2)
      else 0
    end                                      as CostPerPatient         : Decimal(11, 2),

    sum(TotalBeneficiaries)                  as TotalPatientsServed    : Integer,
    sum(CostPerBeneficiary * TotalBeneficiaries)
                                             as TotalActualPayments    : Decimal(15, 2)
  }
  group by
    Year,
    ProviderType;

annotate medicare.RiskCostVolumeDynamics with @(
  Analytics.dataCategory   : #CUBE,
  Aggregation.ApplyDefault : true
);

// ─── Task 4 — Autonomous Audit Agent (Joule scratchpad) ───────────────────────

entity AgentScratchpad {
  key ID            : UUID;
      sessionId     : String(100);
      step          : Integer;
      toolName      : String(100);
      inputPayload  : LargeString;
      outputPayload : LargeString;
      createdAt     : Timestamp;
}

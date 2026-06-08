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

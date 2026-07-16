#!/usr/bin/env node
'use strict';

/**
 * CMS Medicare CSVs load into SQLite with empty strings and $/comma formatting.
 * SAP HANA HDI tabledata rejects those values for numeric columns.
 * Run before `cds build --production` on BTP.
 */

const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'db', 'data');

const FILE_SPECS = {
  'medicare-ProviderSummary.csv': {
    integers: [
      'Tot_HCPCS_Cds', 'Tot_Benes', 'Drug_Tot_HCPCS_Cds', 'Drug_Tot_Benes',
      'Med_Tot_HCPCS_Cds', 'Med_Tot_Benes', 'Bene_Age_LT_65_Cnt', 'Bene_Age_65_74_Cnt',
      'Bene_Age_75_84_Cnt', 'Bene_Age_GT_84_Cnt', 'Bene_Feml_Cnt', 'Bene_Male_Cnt',
      'Bene_Race_Wht_Cnt', 'Bene_Race_Black_Cnt', 'Bene_Race_API_Cnt', 'Bene_Race_Hspnc_Cnt',
      'Bene_Race_NatInd_Cnt', 'Bene_Race_Othr_Cnt', 'Bene_Dual_Cnt', 'Bene_Ndual_Cnt',
    ],
    decimals: [
      'Tot_Srvcs', 'Tot_Sbmtd_Chrg', 'Tot_Mdcr_Alowd_Amt', 'Tot_Mdcr_Pymt_Amt', 'Tot_Mdcr_Stdzd_Amt',
      'Drug_Tot_Srvcs', 'Drug_Sbmtd_Chrg', 'Drug_Mdcr_Alowd_Amt', 'Drug_Mdcr_Pymt_Amt', 'Drug_Mdcr_Stdzd_Amt',
      'Med_Tot_Srvcs', 'Med_Sbmtd_Chrg', 'Med_Mdcr_Alowd_Amt', 'Med_Mdcr_Pymt_Amt', 'Med_Mdcr_Stdzd_Amt',
      'Bene_Avg_Age', 'Bene_CC_BH_ADHD_OthCD_V1_Pct', 'Bene_CC_BH_Alcohol_Drug_V1_Pct',
      'Bene_CC_BH_Tobacco_V1_Pct', 'Bene_CC_BH_Alz_NonAlzdem_V2_Pct', 'Bene_CC_BH_Anxiety_V1_Pct',
      'Bene_CC_BH_Bipolar_V1_Pct', 'Bene_CC_BH_Mood_V2_Pct', 'Bene_CC_BH_Depress_V1_Pct',
      'Bene_CC_BH_PD_V1_Pct', 'Bene_CC_BH_PTSD_V1_Pct', 'Bene_CC_BH_Schizo_OthPsy_V1_Pct',
      'Bene_CC_PH_Asthma_V2_Pct', 'Bene_CC_PH_Afib_V2_Pct', 'Bene_CC_PH_Cancer6_V2_Pct',
      'Bene_CC_PH_CKD_V2_Pct', 'Bene_CC_PH_COPD_V2_Pct', 'Bene_CC_PH_Diabetes_V2_Pct',
      'Bene_CC_PH_HF_NonIHD_V2_Pct', 'Bene_CC_PH_Hyperlipidemia_V2_Pct', 'Bene_CC_PH_Hypertension_V2_Pct',
      'Bene_CC_PH_IschemicHeart_V2_Pct', 'Bene_CC_PH_Osteoporosis_V2_Pct', 'Bene_CC_PH_Parkinson_V2_Pct',
      'Bene_CC_PH_Arthritis_V2_Pct', 'Bene_CC_PH_Stroke_TIA_V2_Pct', 'Bene_Avg_Risk_Scre',
    ],
  },
  'medicare-ServiceDetails.csv': {
    integers: ['Tot_Benes'],
    decimals: [
      'Tot_Srvcs', 'Tot_Bene_Day_Srvcs', 'Avg_Sbmtd_Chrg', 'Avg_Mdcr_Alowd_Amt',
      'Avg_Mdcr_Pymt_Amt', 'Avg_Mdcr_Stdzd_Amt',
    ],
  },
};

function parseCsvLine(line) {
  const fields = [];
  let current = '';
  let inQuotes = false;

  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') {
      if (inQuotes && line[i + 1] === '"') {
        current += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (ch === ',' && !inQuotes) {
      fields.push(current);
      current = '';
    } else {
      current += ch;
    }
  }
  fields.push(current);
  return fields;
}

function escapeCsvField(value) {
  if (/[",\n\r]/.test(value)) {
    return `"${value.replace(/"/g, '""')}"`;
  }
  return value;
}

function cleanNumeric(value, asInteger) {
  let v = (value ?? '').trim();
  if (v === '' || v === '*' || v === '#') {
    return '0';
  }
  v = v.replace(/\$/g, '').replace(/,/g, '');
  if (v === '' || v === '.' || Number.isNaN(Number(v))) {
    return '0';
  }
  if (asInteger) {
    return String(Math.trunc(Number(v)));
  }
  return v;
}

function sanitizeFile(fileName, spec) {
  const filePath = path.join(DATA_DIR, fileName);
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split(/\r?\n/).filter((line) => line.length > 0);
  if (lines.length === 0) {
    return;
  }

  const headers = parseCsvLine(lines[0]);
  const intIdx = new Set(spec.integers.map((name) => headers.indexOf(name)).filter((i) => i >= 0));
  const decIdx = new Set(spec.decimals.map((name) => headers.indexOf(name)).filter((i) => i >= 0));

  const out = [lines[0]];
  for (let i = 1; i < lines.length; i++) {
    const fields = parseCsvLine(lines[i]);
    for (const idx of intIdx) {
      fields[idx] = cleanNumeric(fields[idx], true);
    }
    for (const idx of decIdx) {
      fields[idx] = cleanNumeric(fields[idx], false);
    }
    out.push(fields.map(escapeCsvField).join(','));
  }

  fs.writeFileSync(filePath, `${out.join('\n')}\n`, 'utf8');
  console.log(`[sanitize-csv] ${fileName}: ${lines.length - 1} rows normalized for HANA`);
}

for (const [fileName, spec] of Object.entries(FILE_SPECS)) {
  sanitizeFile(fileName, spec);
}

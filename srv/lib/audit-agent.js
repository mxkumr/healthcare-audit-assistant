const cds = require('@sap/cds');
const { randomUUID } = require('crypto');

const DEFAULT_YEAR = '2022';

function fmtCurrency(value) {
  const n = Number(value);
  if (Number.isNaN(n)) return '$0';
  return `$${n.toLocaleString(undefined, { maximumFractionDigits: 2 })}`;
}

function fmtPct(value) {
  const n = Number(value);
  if (Number.isNaN(n)) return '0%';
  return `${n}%`;
}

function json(value) {
  return JSON.stringify(value ?? null);
}

class AuditAgentEngine {
  constructor(entities) {
    this.entities = entities;
  }

  async listAvailableYears() {
    const { RiskCostVolumeDynamics } = this.entities;
    const rows = await SELECT.from(RiskCostVolumeDynamics)
      .columns('Year')
      .groupBy('Year')
      .orderBy('Year desc');
    return rows.map((r) => String(r.Year));
  }

  async resolveYear(yearParam) {
    const years = await this.listAvailableYears();
    if (yearParam && years.includes(String(yearParam))) return String(yearParam);
    if (years.includes(DEFAULT_YEAR)) return DEFAULT_YEAR;
    return years[0] || DEFAULT_YEAR;
  }

  async logStep(tx, sessionId, step, toolName, inputPayload, outputPayload) {
    const { AgentScratchpad } = this.entities;
    await tx.run(
      INSERT.into(AgentScratchpad).entries({
        ID: randomUUID(),
        sessionId,
        step,
        toolName,
        inputPayload: json(inputPayload),
        outputPayload: typeof outputPayload === 'string' ? outputPayload : json(outputPayload),
        createdAt: new Date().toISOString(),
      })
    );
  }

  async queryMacroOutliers(year, specialty) {
    const { RiskCostVolumeDynamics } = this.entities;
    let q = SELECT.from(RiskCostVolumeDynamics).where({ Year: year });
    if (specialty) q = q.and({ Specialty: specialty });
    return q.orderBy('CostPerPatient desc').limit(3);
  }

  async queryFacilitySpreads(year, specialty) {
    const { PlaceOfServiceAnalysis } = this.entities;
    let q = SELECT.from(PlaceOfServiceAnalysis).where({
      Year: year,
      PlaceOfService: 'Facility (Hospital/ASC)',
    });
    if (specialty) q = q.and({ Specialty: specialty });
    return q.orderBy('AvgPaymentPerService desc').limit(2);
  }

  async queryOfficeRate(year, specialty) {
    const { PlaceOfServiceAnalysis } = this.entities;
    return SELECT.one.from(PlaceOfServiceAnalysis).where({
      Year: year,
      Specialty: specialty,
      PlaceOfService: 'Office (Non-Facility)',
    });
  }

  async queryCredentialPadding(year) {
    const { CredentialDiscrepancies } = this.entities;
    return SELECT.from(CredentialDiscrepancies)
      .where({ Year: year })
      .orderBy('ChargePaddingRatePct desc')
      .limit(2);
  }

  async queryRegionalOutliers(state, year) {
    const { CostAnalysisV2 } = this.entities;
    return SELECT.from(CostAnalysisV2)
      .where({ Year: year, State: state.toUpperCase() })
      .orderBy('TotalPaid desc')
      .limit(5);
  }

  async queryProviderProfile(npi, year) {
    const { ProviderCostEfficiency } = this.entities;
    return SELECT.one.from(ProviderCostEfficiency).where({ Year: year, NPI: npi });
  }

  async queryProviderServices(npi, year) {
    const { ServiceDetails } = this.entities;
    return SELECT.from(ServiceDetails)
      .where({ Year: year, Rndrng_NPI: npi })
      .orderBy('Tot_Srvcs desc')
      .limit(10);
  }

  async querySpecialtyPeerOutliers(year, specialty, state) {
    const { SpecialtyPeerDeviations } = this.entities;
    let q = SELECT.from(SpecialtyPeerDeviations).where({ Year: year });
    if (specialty) q = q.and({ Specialty: specialty });
    if (state) q = q.and({ State: state.toUpperCase() });
    return q.orderBy('CostTierDeviation desc').limit(5);
  }

  async queryFlaggedProviders(year, { state, specialty, npi } = {}) {
    const { ProviderCostEfficiency } = this.entities;
    let q = SELECT.from(ProviderCostEfficiency).where({
      Year: year,
      EfficiencyCategory: 'High-Cost Outlier',
    });
    if (state) q = q.and({ State: state.toUpperCase() });
    if (specialty) q = q.and({ ProviderType: specialty });
    if (npi) q = q.and({ NPI: npi });
    return q.orderBy('CostPerBeneficiary desc').limit(10);
  }

  computeConfidence(steps) {
    const populated = steps.filter((s) => s.recordCount > 0).length;
    return Math.min(95, 70 + populated * 8);
  }

  buildInvestigationNarrative({
    prompt,
    year,
    state,
    specialty,
    npi,
    macroOutliers,
    facilitySpreads,
    officePaymentPerService,
    credentialPadding,
    regionalOutliers,
    providerProfile,
    flaggedProviders,
  }) {
    let narrative = `## EXECUTIVE PROVIDER AUDIT REPORT\n\n`;
    narrative += `**Investigation Objective:** ${prompt || 'Autonomous anomaly screening'}\n`;
    narrative += `**Performance Year:** ${year}\n`;
    const filters = [
      state && `State = ${state.toUpperCase()}`,
      specialty && `Specialty = ${specialty}`,
      npi && `NPI = ${npi}`,
    ].filter(Boolean);
    if (filters.length) narrative += `**Scope Filters:** ${filters.join(' · ')}\n`;
    narrative += `\n`;

    if (regionalOutliers?.length) {
      narrative += `### 🗺️ 0. Regional Context (Task 1.1 · ${state?.toUpperCase()})\n`;
      regionalOutliers.slice(0, 3).forEach((row, i) => {
        const paddingRate =
          row.TotalSubmitted > 0
            ? (((row.TotalSubmitted - row.TotalAllowed) / row.TotalSubmitted) * 100).toFixed(1)
            : '0';
        narrative += `${i + 1}. **${row.ProviderType}** — paid ${fmtCurrency(row.TotalPaid)} · charge padding **${paddingRate}%**\n`;
      });
      narrative += `\n`;
    }

    if (providerProfile) {
      narrative += `### 👤 Provider Focus (Task 2.1)\n`;
      narrative += `* **${providerProfile.ProviderName}** (NPI \`${providerProfile.NPI}\`) · ${providerProfile.ProviderType} · ${providerProfile.State}\n`;
      narrative += `* Cost/patient **${fmtCurrency(providerProfile.CostPerBeneficiary)}** · ${providerProfile.ServicesPerBeneficiary} services/patient · risk **${providerProfile.AvgRiskScore}**\n`;
      narrative += `* Classification: **${providerProfile.EfficiencyCategory}** / **${providerProfile.UtilizationCategory}**\n\n`;
    }

    narrative += `### 🔍 1. Specialty Outlier Frontier (Task 3.1)\n`;
    if (macroOutliers?.length) {
      narrative += `* **Cost-Complexity Frontier Outlier:** **${macroOutliers[0].Specialty}** averages **${fmtCurrency(macroOutliers[0].CostPerPatient)}/patient** at complexity index **${macroOutliers[0].PatientRiskScore}** (national baseline ≈ 1.0).\n`;
    } else {
      narrative += `* No Task 3.1 outlier metrics found for the selected scope.\n`;
    }

    narrative += `\n### 🏢 2. Site-of-Service Arbitrage (Task 3.2)\n`;
    if (facilitySpreads?.length) {
      const facilityRate = Number(facilitySpreads[0].AvgPaymentPerService);
      const officeRate = officePaymentPerService != null ? Number(officePaymentPerService) : null;
      narrative += `* **${facilitySpreads[0].Specialty}** facility rate **${fmtCurrency(facilityRate)}/service**`;
      if (officeRate != null) narrative += ` vs office **${fmtCurrency(officeRate)}/service**`;
      narrative += `.\n`;
    } else {
      narrative += `* No facility vs office spreads found for the selected scope.\n`;
    }

    narrative += `\n### 🪪 3. Credential-Based Charge Padding (Task 3.3)\n`;
    if (credentialPadding?.length) {
      narrative += `* **${credentialPadding[0].StandardizedCredential}** — padding rate **${fmtPct(credentialPadding[0].ChargePaddingRatePct)}** · paid/allowed **${fmtPct(credentialPadding[0].PaidToAllowedRatePct)}**.\n\n`;
    } else {
      narrative += `* No credential padding signals found for ${year}.\n\n`;
    }

    narrative += `### 📋 4. Actionable Compliance Recommendations\n`;
    if (flaggedProviders?.length) {
      narrative += `The agent flagged **${flaggedProviders.length}** high-cost outlier provider(s):\n`;
      flaggedProviders.slice(0, 5).forEach((p, i) => {
        narrative += `${i + 1}. **${p.ProviderName}** (NPI \`${p.NPI}\`) — ${fmtCurrency(p.CostPerBeneficiary)}/patient · ${p.State} · ${p.ProviderType}\n`;
      });
    } else if (macroOutliers?.length) {
      narrative += `1. **Trigger Manual Audit:** Review top-volume practitioners in **${macroOutliers[0].Specialty}** for ${year}.\n`;
    }
    if (facilitySpreads?.length) {
      narrative += `2. **Place of Service Flag:** Scrub facility-fee claims for **${facilitySpreads[0].Specialty}**.\n`;
    }

    return narrative;
  }

  buildRegionalNarrative(state, year, rows) {
    if (!rows?.length) {
      return `No regional billing data found for **${state.toUpperCase()}** in **${year}**.`;
    }
    let text = `## Regional Billing Outliers — ${state.toUpperCase()} (${year})\n\n`;
    rows.forEach((row, i) => {
      const padding =
        row.TotalSubmitted > 0
          ? (((row.TotalSubmitted - row.TotalAllowed) / row.TotalSubmitted) * 100).toFixed(1)
          : '0';
      text += `${i + 1}. **${row.ProviderType}** — ${row.ProviderCount} providers · paid ${fmtCurrency(row.TotalPaid)} · padding **${padding}%**\n`;
    });
    return text;
  }

  buildProviderNarrative(year, profile, services) {
    if (!profile) return `No provider profile found for the requested NPI in **${year}**.`;
    let text = `## Provider Claim Profile (${year})\n\n`;
    text += `**${profile.ProviderName}** · NPI \`${profile.NPI}\` · ${profile.ProviderType} · ${profile.State}\n\n`;
    text += `| Metric | Value |\n|--------|------:|\n`;
    text += `| Cost/Patient | ${fmtCurrency(profile.CostPerBeneficiary)} |\n`;
    text += `| Services/Patient | ${profile.ServicesPerBeneficiary} |\n`;
    text += `| Risk Score | ${profile.AvgRiskScore} |\n`;
    text += `| Efficiency | ${profile.EfficiencyCategory} |\n`;
    text += `| Utilization | ${profile.UtilizationCategory} |\n\n`;
    if (services?.length) {
      text += `### Top HCPCS Lines\n`;
      services.forEach((s, i) => {
        text += `${i + 1}. **${s.HCPCS_Cd}** — ${s.HCPCS_Desc} · ${s.Tot_Srvcs} units · POS ${s.Place_Of_Srvc}\n`;
      });
    }
    return text;
  }

  buildSpecialtyNarrative(year, specialty, state, rows) {
    if (!rows?.length) {
      return `No specialty peer deviations found for **${specialty || 'all specialties'}** in **${year}**.`;
    }
    let text = `## Specialty Peer Outliers (${year})\n\n`;
    if (specialty) text += `**Specialty filter:** ${specialty}\n`;
    if (state) text += `**State filter:** ${state.toUpperCase()}\n\n`;
    rows.forEach((row, i) => {
      text += `${i + 1}. **${row.ProviderName}** (NPI \`${row.NPI}\`) — ${fmtCurrency(row.CostPerPatient)}/patient vs national ${fmtCurrency(row.NationalAvgCost)} (**+${Number(row.CostTierDeviation).toFixed(0)}%**)\n`;
    });
    return text;
  }

  async investigateAnomalies(req, params) {
    const sessionId = randomUUID();
    const year = await this.resolveYear(params.year);
    const state = params.state?.trim()?.toUpperCase() || null;
    const specialty = params.specialty?.trim() || null;
    const npi = params.npi?.trim() || null;
    const prompt = params.prompt?.trim() || 'Autonomous anomaly screening';

    const steps = [];
    const tx = cds.transaction(req);

    const macroOutliers = await this.queryMacroOutliers(year, specialty);
    steps.push({ tool: 'RiskCostVolumeDynamics', recordCount: macroOutliers.length });
    await this.logStep(tx, sessionId, 1, 'RiskCostVolumeDynamics', { year, specialty }, macroOutliers);

    const facilitySpreads = await this.queryFacilitySpreads(year, specialty);
    steps.push({ tool: 'PlaceOfServiceAnalysis', recordCount: facilitySpreads.length });
    await this.logStep(tx, sessionId, 2, 'PlaceOfServiceAnalysis', { year, specialty }, facilitySpreads);

    let officePaymentPerService;
    if (facilitySpreads.length) {
      const officeRow = await this.queryOfficeRate(year, facilitySpreads[0].Specialty);
      officePaymentPerService = officeRow?.AvgPaymentPerService;
    }

    const credentialPadding = await this.queryCredentialPadding(year);
    steps.push({ tool: 'CredentialDiscrepancies', recordCount: credentialPadding.length });
    await this.logStep(tx, sessionId, 3, 'CredentialDiscrepancies', { year }, credentialPadding);

    let regionalOutliers = [];
    if (state) {
      regionalOutliers = await this.queryRegionalOutliers(state, year);
      steps.push({ tool: 'CostAnalysisV2', recordCount: regionalOutliers.length });
      await this.logStep(tx, sessionId, 4, 'CostAnalysisV2', { year, state }, regionalOutliers);
    }

    let providerProfile;
    if (npi) {
      providerProfile = await this.queryProviderProfile(npi, year);
      steps.push({ tool: 'ProviderCostEfficiency', recordCount: providerProfile ? 1 : 0 });
      await this.logStep(tx, sessionId, 5, 'ProviderCostEfficiency', { year, npi }, providerProfile);
    }

    const flaggedProviders = await this.queryFlaggedProviders(year, { state, specialty, npi });
    steps.push({ tool: 'FlaggedProviders', recordCount: flaggedProviders.length });
    await this.logStep(tx, sessionId, 6, 'FlaggedProviders', { year, state, specialty, npi }, flaggedProviders);

    const narrative = this.buildInvestigationNarrative({
      prompt,
      year,
      state,
      specialty,
      npi,
      macroOutliers,
      facilitySpreads,
      officePaymentPerService,
      credentialPadding,
      regionalOutliers,
      providerProfile,
      flaggedProviders,
    });

    return {
      narrative,
      confidenceScore: this.computeConfidence(steps),
      year,
      flaggedNPIs: json(flaggedProviders.map((p) => p.NPI)),
      reasoningSteps: json(steps),
      sessionId,
    };
  }

  async getRegionalBillingOutliers(req, state, yearParam) {
    const sessionId = randomUUID();
    const year = await this.resolveYear(yearParam);
    const rows = await this.queryRegionalOutliers(state, year);
    await this.logStep(cds.transaction(req), sessionId, 1, 'getRegionalBillingOutliers', { state, year }, rows);
    return {
      narrative: this.buildRegionalNarrative(state, year, rows),
      year,
      results: json(rows),
      sessionId,
    };
  }

  async getProviderClaimDetails(req, npi, yearParam) {
    const sessionId = randomUUID();
    const year = await this.resolveYear(yearParam);
    const profile = await this.queryProviderProfile(npi, year);
    const services = profile ? await this.queryProviderServices(npi, year) : [];
    await this.logStep(cds.transaction(req), sessionId, 1, 'getProviderClaimDetails', { npi, year }, { profile, services });
    return {
      narrative: this.buildProviderNarrative(year, profile, services),
      year,
      provider: json(profile),
      services: json(services),
      sessionId,
    };
  }

  async getSpecialtyPeerOutliers(req, specialty, yearParam, state) {
    const sessionId = randomUUID();
    const year = await this.resolveYear(yearParam);
    const rows = await this.querySpecialtyPeerOutliers(year, specialty, state);
    await this.logStep(cds.transaction(req), sessionId, 1, 'getSpecialtyPeerOutliers', { specialty, year, state }, rows);
    return {
      narrative: this.buildSpecialtyNarrative(year, specialty, state, rows),
      year,
      results: json(rows),
      sessionId,
    };
  }

  async listAuditYears() {
    const years = await this.listAvailableYears();
    const defaultYear = await this.resolveYear();
    return { years: json(years), defaultYear };
  }
}

module.exports = { AuditAgentEngine, DEFAULT_YEAR };

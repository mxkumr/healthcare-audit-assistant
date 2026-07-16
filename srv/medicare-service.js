const cds = require('@sap/cds');
const { AuditAgentEngine } = require('./lib/audit-agent');
const { runCheckAI, runDiagram, resolveAiContext } = require('./lib/check-ai');

function resolveAiEntity(req, entities) {
  const context = resolveAiContext(req);
  const entity = entities[context.entityName];
  if (!entity) {
    throw new Error(`AI entity not found: ${context.entityName}`);
  }
  return { entity, context };
}

module.exports = cds.service.impl(async function () {
  const agent = new AuditAgentEngine(this.entities);

  this.on('checkAI', async (req) => {
    try {
      const { entity, context } = resolveAiEntity(req, this.entities);
      await runCheckAI(req, entity, context);
    } catch (error) {
      return req.reject(500, `Evaluate AI failed: ${error.message}`);
    }
  });

  this.on('diagram', async (req) => {
    try {
      const { entity, context } = resolveAiEntity(req, this.entities);
      return await runDiagram(req, entity, context);
    } catch (error) {
      return req.reject(500, `Generate diagram failed: ${error.message}`);
    }
  });

  this.on('listAuditYears', async () => {
    try {
      return await agent.listAuditYears();
    } catch (error) {
      return { years: '[]', defaultYear: '2022' };
    }
  });

  this.on('getRegionalBillingOutliers', async (req) => {
    const { state, year } = req.data;
    if (!state) return req.reject(400, 'Parameter "state" is required (two-letter US abbreviation, e.g. CA).');
    try {
      return await agent.getRegionalBillingOutliers(req, state, year);
    } catch (error) {
      return req.reject(500, `Regional outlier query failed: ${error.message}`);
    }
  });

  this.on('getProviderClaimDetails', async (req) => {
    const { npi, year } = req.data;
    if (!npi) return req.reject(400, 'Parameter "npi" is required (10-digit National Provider Identifier).');
    try {
      return await agent.getProviderClaimDetails(req, npi, year);
    } catch (error) {
      return req.reject(500, `Provider claim query failed: ${error.message}`);
    }
  });

  this.on('getSpecialtyPeerOutliers', async (req) => {
    const { specialty, year, state } = req.data;
    try {
      return await agent.getSpecialtyPeerOutliers(req, specialty, year, state);
    } catch (error) {
      return req.reject(500, `Specialty peer query failed: ${error.message}`);
    }
  });

  this.on('investigateAnomalies', async (req) => {
    const { prompt, year, state, specialty, npi } = req.data;
    try {
      return await agent.investigateAnomalies(req, { prompt, year, state, specialty, npi });
    } catch (error) {
      return req.reject(500, `Autonomous Agent Reasoning Loop failed: ${error.message}`);
    }
  });
});

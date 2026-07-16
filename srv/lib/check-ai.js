'use strict';

const cds = require('@sap/cds');
const { SELECT } = cds.ql;
const {
  resolveAiContext,
  buildSchemaSnapshot,
  buildDataSnapshot,
} = require('./ai-context');

try {
  require('dotenv').config();
} catch (_) {
  /* dotenv optional at runtime */
}

const MAX_CSV_ROWS = 400;
const MAX_DIAGRAM_ROWS = 150;

/**
 * Prompt topology (Task 4 — hallucination control):
 *  1) system  → persona + agency reasoning protocol (no raw data)
 *  2) user    → compressed JSON { schemaSnapshot, dataSnapshot, question }
 *
 * Schema snapshot = ALP/Task metadata + Task 2 tiers (when present).
 * Data snapshot   = CAP JSON rows (not free-form prose).
 */

const LEAD_AUDITOR_SYSTEM_PROMPT = [
  'PERSONA: You are the Lead Medicare Auditor for a CAP/Fiori Healthcare Audit Assistant on SAP BTP.',
  'You operate as an explanation agent grounded in Analytical List Pages (ALPs) backed by CDS views.',
  '',
  'AGENCY FRAMEWORK (always follow in order):',
  '1) ALP frame — Read schemaSnapshot.alp and alpGuidance. Identify which CAP columns answer the question.',
  '2) Task 2 classification reasoning — If schemaSnapshot.task2ClassificationTiers is present, first reason with',
  '   EfficiencyCategory and/or UtilizationCategory values already stamped on each CAP row (Task 2 bands).',
  '   Only then rank numeric measures (CostPerBeneficiary, ServicesPerBeneficiary, etc.).',
  '3) CSV/JSON evidence — Scan ALL rows in dataSnapshot.rows. Filter/sort using rankingHints / primaryMetrics.',
  '   Build a complete picture (aggregates, top/bottom rows, counter-examples). Quote identifiers and numbers exactly.',
  '4) Actionability — Propose one concrete follow-up on this ALP (filter, sort, flag NPI/specialty/state).',
  '',
  'ANTI-HALLUCINATION:',
  '- Use ONLY dataSnapshot.rows. Never invent NPIs, providers, states, codes, categories, or amounts.',
  '- Trust precomputed CAP column values. Do not invent alternate formulas or classification cutoffs.',
  '- Stay on this ALP entity only. If the snapshot is truncated, say so under Confidence.',
  '',
  'OUTPUT (exact Markdown):',
  '## Finding',
  '## Evidence',
  '## Confidence',
  '## Follow-up',
].join('\n');

function escapeCsv(value) {
  if (value === null || value === undefined) return '';
  const text = String(value);
  if (/[",\n\r]/.test(text)) return `"${text.replace(/"/g, '""')}"`;
  return text;
}

function rowsToCsv(rows, columns) {
  const header = columns.join(',');
  const lines = rows.map((row) => columns.map((col) => escapeCsv(row[col])).join(','));
  return [header, ...lines].join('\n');
}

async function getToken() {
  const url = process.env.AI_TOKEN_URL;
  const username = process.env.USERNAME;
  const password = process.env.PASSWORD;

  if (!url || !username || !password) {
    throw new Error(
      'Missing AI credentials. Set AI_TOKEN_URL, USERNAME, and PASSWORD in .env (local) or CF env vars (BTP).'
    );
  }

  const auth = Buffer.from(`${username}:${password}`).toString('base64');
  const response = await fetch(url, {
    method: 'POST',
    headers: { Authorization: `Basic ${auth}` },
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`AI token request failed (${response.status}): ${body}`);
  }

  const data = await response.json();
  if (!data.access_token) throw new Error('AI token response did not include access_token');
  return data.access_token;
}

async function callAiCore(token, body) {
  const url = process.env.AI_DEPLOYMENT_URL;
  const resourceGroup = process.env.AI_RESOURCE_GROUP || 'default';

  if (!url) {
    throw new Error('Missing AI_DEPLOYMENT_URL in .env or CF environment.');
  }

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'AI-Resource-Group': resourceGroup,
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const bodyText = await response.text();
    throw new Error(`AI query failed (${response.status}): ${bodyText}`);
  }

  return response.json();
}

function buildContextWindowPayload(context, rows, question) {
  return {
    schemaSnapshot: buildSchemaSnapshot(context),
    dataSnapshot: buildDataSnapshot(rows, context, { maxRows: MAX_CSV_ROWS }),
    question,
  };
}

async function doQuery(token, question, rows, context) {
  const payload = buildContextWindowPayload(context, rows, question);
  return callAiCore(token, {
    messages: [
      { role: 'system', content: LEAD_AUDITOR_SYSTEM_PROMPT },
      {
        role: 'user',
        content:
          'CONTEXT WINDOW (compressed CAP JSON snapshots). ' +
          'Execute Agency steps 1→4 using schemaSnapshot then dataSnapshot.\n\n' +
          JSON.stringify(payload),
      },
    ],
    temperature: 0,
    frequency_penalty: 0,
    presence_penalty: 0,
  });
}

async function doDiagramQuery(token, query, inputJson, diagramHint) {
  return callAiCore(token, {
    messages: [
      {
        role: 'system',
        content:
          'PERSONA: Lead Medicare Auditor charting assistant. ' +
          'Use only the provided CAP JSON rows. Output chart JSON only.',
      },
      {
        role: 'user',
        content:
          'schemaHint: ' +
          diagramHint +
          '\n\ndataSnapshot:\n' +
          inputJson +
          '\n\nquestion:\n' +
          query +
          '\n\nReturn a JSON object whose first key is "response". ' +
          '"response" must be an array of at most 10 objects. ' +
          'Each object must have "label" (string) and "value" (number, not string).',
      },
    ],
    temperature: 0,
    frequency_penalty: 0,
    presence_penalty: 0,
  });
}

async function runCheckAI(req, entity, context) {
  const userInput = req.data.Query;
  if (!userInput?.trim()) {
    return req.reject(400, 'Please enter a question for the AI analysis.');
  }

  const columns = context.csvColumns;
  const rows = await SELECT.from(entity).columns(columns).limit(MAX_CSV_ROWS);

  if (!rows.length) {
    return req.reject(400, context.emptyMessage);
  }

  const bearerToken = await getToken();
  const response = await doQuery(bearerToken, userInput.trim(), rows, context);

  const answer = response?.choices?.[0]?.message?.content;
  if (!answer) {
    return req.reject(502, 'AI service returned an empty response.');
  }

  req.info(answer);
  console.log(`Evaluate AI (${context.entityName}) question:\n`, userInput);
  console.log(`Evaluate AI (${context.entityName}) answer:\n`, answer);
}

async function runDiagram(req, entity, context) {
  const userInput = req.data.Query;
  if (!userInput?.trim()) {
    return req.reject(400, 'Please enter a chart question.');
  }

  const columns = context.diagramColumns;
  const rows = await SELECT.from(entity).columns(columns).limit(MAX_DIAGRAM_ROWS);

  if (!rows.length) {
    return req.reject(400, context.emptyMessage);
  }

  const formattedRows = JSON.stringify({
    schemaSnapshot: {
      alp: context.alpName,
      entity: context.entityName,
      columns,
      diagramHint: context.diagramHint,
    },
    dataSnapshot: { rows },
  });
  const bearerToken = await getToken();
  const response = await doDiagramQuery(
    bearerToken,
    userInput.trim(),
    formattedRows,
    context.diagramHint
  );

  const content = response?.choices?.[0]?.message?.content;
  if (!content) {
    return req.reject(502, 'AI service returned an empty diagram response.');
  }

  return content;
}

module.exports = {
  runCheckAI,
  runDiagram,
  rowsToCsv,
  resolveAiContext,
  buildContextWindowPayload,
  LEAD_AUDITOR_SYSTEM_PROMPT,
};

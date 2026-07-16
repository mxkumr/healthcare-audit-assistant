'use strict';

const cds = require('@sap/cds');
const { SELECT } = cds.ql;
const {
  resolveAiContext,
  buildSchemaSnapshot,
  buildDataSnapshot,
  sanitizeRow,
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
  'PERSONA: You are the Lead Medicare Auditor briefing a colleague.',
  'Write in clear, natural professional English — like an audit memo, not a system log.',
  '',
  'INTERNAL REASONING (do this silently; do NOT narrate these steps or JSON field names):',
  '1) Read the ALP metadata in the context JSON to know which columns answer the question.',
  '2) If Task 2 classification tiers are present, use EfficiencyCategory / UtilizationCategory on each row first.',
  '3) Scan every data row; filter/sort; compare; quote only values that appear in those rows.',
  '4) End with one practical next step an auditor can take in the Fiori table.',
  '',
  'ANTI-HALLUCINATION:',
  '- Use only the provided data rows. Never invent NPIs, providers, codes, or amounts.',
  '- Prefer a smaller set of correctly copied figures over a long list of guessed ones.',
  '- Money and rates are already rounded to 2 decimals in the briefing pack — quote them as-is (e.g. 7314.08, not long fractions).',
  '- If EntityType is present, use the full labels on each row ("Individual Clinician" / "Organization / Corporate Network"); do not invent alternate entity names.',
  '- For organization vs individual questions, filter by EntityType before picking a winner — do not treat a random Individual as proof Organizations are cheap.',
  '- EfficiencyCategory uses "High-Cost Outlier" (not bare "Outlier").',
  '- If you cannot compute a clean aggregate from the rows, say so briefly in Confidence.',
  '',
  'STYLE:',
  '- Do NOT mention schemaSnapshot, dataSnapshot, truncated, CAP JSON, agency framework, or "ALP frame".',
  '- Do NOT dump raw JSON keys. Use normal labels (e.g. Urban / Metro, rejected charges, procedure 99214).',
  '- Finding: 2–4 plain sentences.',
  '- Evidence: short bullets with real figures; group by tier/specialty when helpful.',
  '- Confidence: one short human sentence (High/Medium/Low + why), no machine metadata.',
  '- Follow-up: one concrete UI action in everyday words (filter, sort, open a provider).',
  '',
  'OUTPUT — use exactly these Markdown headings, then natural prose underneath:',
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
          'Answer the question as a Lead Medicare Auditor memo. ' +
          'Use the JSON below only as your private briefing pack (ALP metadata + data rows). ' +
          'Do not echo JSON field names in your answer.\n\n' +
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
  let query = SELECT.from(entity).columns(columns);
  if (context.sortBy) {
    query = query.orderBy(`${context.sortBy} desc`);
  }
  const rows = await query.limit(MAX_CSV_ROWS);

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
  let query = SELECT.from(entity).columns(columns);
  if (context.sortBy) {
    query = query.orderBy(`${context.sortBy} desc`);
  }
  const rows = await query.limit(MAX_DIAGRAM_ROWS);

  if (!rows.length) {
    return req.reject(400, context.emptyMessage);
  }

  const sanitized = rows.map((row) => sanitizeRow(row, columns));
  const formattedRows = JSON.stringify({
    schemaSnapshot: {
      alp: context.alpName,
      entity: context.entityName,
      columns,
      sortedBy: context.sortBy || null,
      diagramHint: context.diagramHint,
    },
    dataSnapshot: { rows: sanitized, sortedBy: context.sortBy || null },
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

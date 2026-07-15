'use strict';

const cds = require('@sap/cds');
const { SELECT } = cds.ql;

try {
  require('dotenv').config();
} catch (_) {
  /* dotenv optional at runtime */
}

const MAX_CSV_ROWS = 200;
const MAX_DIAGRAM_ROWS = 150;

const CSV_COLUMNS = [
  'Year',
  'NPI',
  'ProviderName',
  'ProviderType',
  'State',
  'CostPerBeneficiary',
  'ServicesPerBeneficiary',
  'EfficiencyCategory',
  'UtilizationCategory',
  'TotalBeneficiaries',
];

const DIAGRAM_JSON_COLUMNS = [
  'ProviderName',
  'State',
  'Year',
  'NPI',
  'CostPerBeneficiary',
  'ServicesPerBeneficiary',
  'EfficiencyCategory',
  'UtilizationCategory',
];

function escapeCsv(value) {
  if (value === null || value === undefined) return '';
  const text = String(value);
  if (/[",\n\r]/.test(text)) return `"${text.replace(/"/g, '""')}"`;
  return text;
}

function rowsToCsv(rows) {
  const header = CSV_COLUMNS.join(',');
  const lines = rows.map((row) =>
    CSV_COLUMNS.map((col) => escapeCsv(row[col])).join(',')
  );
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

async function doQuery(token, query, inputCsv) {
  return callAiCore(token, {
    messages: [
      {
        role: 'user',
        content:
          'You are a Medicare audit analyst. Answer using only the CSV data below.\n\n' +
          inputCsv +
          '\n\nQuestion:\n' +
          query,
      },
    ],
    max_tokens: 1000,
    temperature: 0,
    frequency_penalty: 0,
    presence_penalty: 0,
    stop: null,
  });
}

async function doDiagramQuery(token, query, inputJson) {
  return callAiCore(token, {
    model: 'gpt-3.5-turbo-1106',
    response_format: { type: 'json_object' },
    messages: [
      {
        role: 'system',
        content: 'You are a helpful assistant designed to output JSON for Medicare audit charts.',
      },
      {
        role: 'user',
        content:
          'Given the following provider risk data in JSON format:\n\n' +
          inputJson +
          '\n\n' +
          query +
          '\n\n' +
          'Return a JSON object whose first key is "response". ' +
          '"response" must be an array of at most 10 objects. ' +
          'Each object must have "provider" (string, provider name) and ' +
          '"cost_per_beneficiary" (number, not string). ' +
          'Prefer High-Cost Outlier providers with the highest cost_per_beneficiary.',
      },
    ],
    max_tokens: 1000,
    temperature: 0,
    frequency_penalty: 0,
    presence_penalty: 0,
    stop: null,
  });
}

async function runCheckAI(req, entity) {
  const userInput = req.data.Query;
  if (!userInput?.trim()) {
    return req.reject(400, 'Please enter a question for the AI analysis.');
  }

  const rows = await SELECT.from(entity)
    .columns(CSV_COLUMNS)
    .limit(MAX_CSV_ROWS);

  if (!rows.length) {
    return req.reject(400, 'No provider risk data available to analyze.');
  }

  const csv = rowsToCsv(rows);
  const bearerToken = await getToken();
  const response = await doQuery(bearerToken, userInput.trim(), csv);

  const answer = response?.choices?.[0]?.message?.content;
  if (!answer) {
    return req.reject(502, 'AI service returned an empty response.');
  }

  req.info(answer);
  console.log('Evaluate AI question:\n', userInput);
  console.log('Evaluate AI answer:\n', answer);
}

async function runDiagram(req, entity) {
  const userInput = req.data.Query;
  if (!userInput?.trim()) {
    return req.reject(400, 'Please enter a chart question.');
  }

  const rows = await SELECT.from(entity)
    .columns(DIAGRAM_JSON_COLUMNS)
    .limit(MAX_DIAGRAM_ROWS);

  if (!rows.length) {
    return req.reject(400, 'No provider risk data available for charting.');
  }

  const formattedProviders = JSON.stringify(rows);
  const bearerToken = await getToken();
  const response = await doDiagramQuery(bearerToken, userInput.trim(), formattedProviders);

  const content = response?.choices?.[0]?.message?.content;
  if (!content) {
    return req.reject(502, 'AI service returned an empty diagram response.');
  }

  return content;
}

module.exports = { runCheckAI, runDiagram, rowsToCsv, CSV_COLUMNS };

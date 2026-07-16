'use strict';

const cds = require('@sap/cds');
const { SELECT } = cds.ql;
const { resolveAiContext } = require('./ai-context');

try {
  require('dotenv').config();
} catch (_) {
  /* dotenv optional at runtime */
}

const MAX_CSV_ROWS = 200;
const MAX_DIAGRAM_ROWS = 150;

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
        content: 'You are a helpful assistant designed to output JSON for Medicare audit charts.',
      },
      {
        role: 'user',
        content:
          'Given the following Medicare audit data in JSON format:\n\n' +
          inputJson +
          '\n\n' +
          query +
          '\n\n' +
          'Return a JSON object whose first key is "response". ' +
          '"response" must be an array of at most 10 objects. ' +
          'Each object must have "label" (string, category name) and "value" (number, not string). ' +
          diagramHint,
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

  const csv = rowsToCsv(rows, columns);
  const bearerToken = await getToken();
  const response = await doQuery(bearerToken, userInput.trim(), csv);

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

  const formattedRows = JSON.stringify(rows);
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

module.exports = { runCheckAI, runDiagram, rowsToCsv, resolveAiContext };

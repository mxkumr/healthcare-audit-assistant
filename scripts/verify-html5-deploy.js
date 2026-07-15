#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const apps = JSON.parse(fs.readFileSync(path.join(__dirname, 'html5-apps.json'), 'utf8'));
const mta = fs.readFileSync(path.join(root, 'mta.yaml'), 'utf8');

console.log('Expected HTML5 zips in MTA (all must deploy for updated ALPs on BTP):\n');
for (const { archive, path: appPath, title } of apps) {
  const zip = `${archive}.zip`;
  const inMta = mta.includes(zip);
  const manifest = JSON.parse(
    fs.readFileSync(path.join(root, appPath, 'webapp/manifest.json'), 'utf8')
  );
  const localId = manifest['sap.app'].id;
  console.log(`  ${inMta ? '✓' : '✗'} ${zip.padEnd(42)} ${title}`);
  console.log(`      BTP:   /${archive}/index.html`);
  console.log(`      local: /${localId}/index.html`);
}
console.log('\nAnnotations + navigation → CAP srv metadata. Redeploy FULL MTA after changes.');
console.log('If BTP shows old 1.2 UI, commedicare12ruralanalysis.zip likely not redeployed.\n');

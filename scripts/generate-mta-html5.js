#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const apps = JSON.parse(fs.readFileSync(path.join(__dirname, 'html5-apps.json'), 'utf8'));
const mtaPath = path.join(__dirname, '..', 'mta.yaml');
let mta = fs.readFileSync(mtaPath, 'utf8');

const firstArchive = apps[0].archive;

const moduleBlocks = apps.map(({ path: appPath, archive }) => {
  return `- name: ${archive}
  type: html5
  path: ${appPath}
  build-parameters:
    build-result: dist
    builder: custom
    commands:
    - npm install
    - npm run build:cf
    supported-platforms: []`;
}).join('\n');

const artifactBlocks = apps.map(({ archive }) => `    - artifacts:
      - ${archive}.zip
      name: ${archive}
      target-path: resources/`).join('\n');

const modulesStart = mta.indexOf(`- name: ${firstArchive}`);
const resourcesStart = mta.indexOf('\nresources:', modulesStart);
if (modulesStart === -1 || resourcesStart === -1) {
  console.error(`[generate-mta-html5] Could not locate html5 module block (expected - name: ${firstArchive})`);
  process.exit(1);
}
mta = mta.slice(0, modulesStart) + moduleBlocks + mta.slice(resourcesStart);

const requiresMarker = '  build-parameters:\n    build-result: resources\n    requires:\n';
const requiresStart = mta.indexOf(requiresMarker);
const html5ModulesStart = mta.indexOf(`- name: ${firstArchive}`, requiresStart);
if (requiresStart === -1 || html5ModulesStart === -1) {
  console.error('[generate-mta-html5] Could not locate app-content artifacts block');
  process.exit(1);
}
mta =
  mta.slice(0, requiresStart + requiresMarker.length) +
  artifactBlocks +
  '\n' +
  mta.slice(html5ModulesStart);

fs.writeFileSync(mtaPath, mta, 'utf8');
console.log(`[generate-mta-html5] updated ${apps.length} html5 modules in mta.yaml`);

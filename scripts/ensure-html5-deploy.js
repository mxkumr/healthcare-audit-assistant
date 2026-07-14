#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const apps = JSON.parse(fs.readFileSync(path.join(__dirname, 'html5-apps.json'), 'utf8'));

const UI5_DEPLOY_TEMPLATE = (archiveName, metadataName) => `# yaml-language-server: $schema=https://sap.github.io/ui5-tooling/schema/ui5.yaml.json

specVersion: "4.0"
metadata:
  name: ${metadataName}
type: application
resources:
  configuration:
    propertiesFileSourceEncoding: UTF-8
builder:
  resources:
    excludes:
      - /test/**
      - /localService/**
  customTasks:
    - name: ui5-task-zipper
      afterTask: generateCachebusterInfo
      configuration:
        archiveName: ${archiveName}
        relativePaths: false
        additionalFiles:
          - xs-app.json
`;

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJson(filePath, data) {
  fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

for (const { path: appPath, archive } of apps) {
  const abs = path.join(root, appPath);
  const manifestPath = path.join(abs, 'webapp/manifest.json');
  const pkgPath = path.join(abs, 'package.json');
  const deployPath = path.join(abs, 'ui5-deploy.yaml');

  if (!fs.existsSync(manifestPath)) {
    console.warn(`[ensure-html5-deploy] skip missing manifest: ${appPath}`);
    continue;
  }

  const manifest = readJson(manifestPath);
  const metadataName = manifest['sap.app']?.id || archive;

  fs.writeFileSync(deployPath, UI5_DEPLOY_TEMPLATE(archive, metadataName), 'utf8');

  const pkg = fs.existsSync(pkgPath) ? readJson(pkgPath) : { name: path.basename(appPath), version: '0.0.1' };
  pkg.devDependencies = pkg.devDependencies || {};
  pkg.devDependencies['@ui5/cli'] = pkg.devDependencies['@ui5/cli'] || '^4.0.33';
  pkg.devDependencies['@sap/ux-ui5-tooling'] = pkg.devDependencies['@sap/ux-ui5-tooling'] || '1';
  pkg.devDependencies['ui5-task-zipper'] = pkg.devDependencies['ui5-task-zipper'] || '^3.4.x';
  pkg.scripts = pkg.scripts || {};
  pkg.scripts['build:cf'] =
    'ui5 build preload --clean-dest --config ui5-deploy.yaml --include-task=generateCachebusterInfo';
  pkg.scripts.build = 'npm run build:cf';
  writeJson(pkgPath, pkg);

  console.log(`[ensure-html5-deploy] ${appPath} → ${archive}.zip`);
}

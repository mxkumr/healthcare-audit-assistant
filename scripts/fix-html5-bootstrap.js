#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const apps = JSON.parse(fs.readFileSync(path.join(__dirname, 'html5-apps.json'), 'utf8'));

const XS_APP = {
  welcomeFile: '/index.html',
  authenticationMethod: 'route',
  routes: [
    {
      source: '^/resources/(.*)$',
      target: '/resources/$1',
      authenticationType: 'none',
      destination: 'ui5'
    },
    {
      source: '^/test-resources/(.*)$',
      target: '/test-resources/$1',
      authenticationType: 'none',
      destination: 'ui5'
    },
    {
      source: '^(.*)$',
      target: '$1',
      service: 'html5-apps-repo-rt',
      authenticationType: 'xsuaa'
    }
  ]
};

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function titleFromPath(appPath) {
  return path.basename(appPath).replace(/-/g, ' ');
}

for (const { path: appPath } of apps) {
  const abs = path.join(root, appPath);
  const manifestPath = path.join(abs, 'webapp/manifest.json');
  const indexPath = path.join(abs, 'webapp/index.html');
  const xsAppPath = path.join(abs, 'xs-app.json');

  if (!fs.existsSync(manifestPath)) {
    console.warn(`[fix-html5-bootstrap] skip missing manifest: ${appPath}`);
    continue;
  }

  const componentId = readJson(manifestPath)['sap.app'].id;
  const title = titleFromPath(appPath);

  const indexHtml = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>${title}</title>
    <style>
        html, body, body > div, #container, #container-uiarea {
            height: 100%;
        }
    </style>
    <script
        id="sap-ui-bootstrap"
        src="/resources/sap-ui-core.js"
        data-sap-ui-version="1.148.1"
        data-sap-ui-theme="sap_horizon"
        data-sap-ui-resource-roots='{"${componentId}": "./"}'
        data-sap-ui-on-init="module:sap/ui/core/ComponentSupport"
        data-sap-ui-compat-version="edge"
        data-sap-ui-async="true"
        data-sap-ui-frame-options="trusted"
    ></script>
</head>
<body class="sapUiBody sapUiSizeCompact" id="content">
    <div
        data-sap-ui-component
        data-name="${componentId}"
        data-id="container"
        data-settings='{"id": "${componentId}"}'
        data-handle-validation="true"
    ></div>
</body>
</html>
`;

  fs.writeFileSync(indexPath, indexHtml, 'utf8');
  fs.writeFileSync(xsAppPath, `${JSON.stringify(XS_APP, null, 2)}\n`, 'utf8');
  console.log(`[fix-html5-bootstrap] ${appPath} → ${componentId}`);
}

#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');

const ALP_APPS = [
  {
    path: 'app/1.1cost-analysis',
    diagramQuery: 'Show the top states by total Medicare paid for a bar chart.',
  },
  {
    path: 'app/1.2rural-analysis',
    diagramQuery: 'Show the top procedure codes by rejection rate for a bar chart.',
  },
  {
    path: 'app/1.3behavioral-helath-risk',
    diagramQuery: 'Show specialties with the highest paid per beneficiary for a bar chart.',
  },
  {
    path: 'app/2.1provider-classification',
    diagramQuery:
      'Show the top high-cost outlier providers by cost per beneficiary for a bar chart.',
  },
  {
    path: 'app/2.2aspecialty-profiling',
    diagramQuery: 'Show providers with the highest cost peer deviation for a bar chart.',
  },
  {
    path: 'app/2.2borganization-profiling',
    diagramQuery: 'Show the highest cost per beneficiary providers by entity type for a bar chart.',
  },
  {
    path: 'app/3.1risk-dynamics',
    diagramQuery: 'Show specialties with the highest average cost per patient for a bar chart.',
  },
  {
    path: 'app/3.2place-of-service',
    diagramQuery: 'Show providers with the highest average payment per service for a bar chart.',
  },
  {
    path: 'app/3.3credential-discrepancies',
    diagramQuery: 'Show credential groups with the highest charge padding amount for a bar chart.',
  },
  {
    path: 'app/risk-analysis',
    diagramQuery: 'Show risk bands with the highest total Medicare paid for a bar chart.',
  },
];

const CHECK_AI_BLOCK = `    {
      $Type : 'UI.DataFieldForAction',
      Action: 'MedicareService.EntityContainer/checkAI',
      Label : '{i18n>Evaluate_AI}'
    },`;

const I18N_LINES = `
#XFLD: Evaluate AI action button (Doc 11 course pattern)
Evaluate_AI=Evaluate AI

#XFLD: Generate diagram action (Doc 12 course pattern)
Generate_Diagram=Generate Diagram
Evaluate_Diagram=Evaluate Diagram
CANCEL=Cancel
`;

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJson(filePath, data) {
  fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`);
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function controllerSource(componentId, diagramQuery) {
  const escapedQuery = diagramQuery.replace(/'/g, "\\'");
  return `sap.ui.define([
  'sap/m/MessageBox',
  'sap/ui/core/mvc/ControllerExtension',
  'sap/ui/model/json/JSONModel',
  'sap/ui/core/Fragment'
], (MessageBox, ControllerExtension, JSONModel, Fragment) =>
  ControllerExtension.extend('${componentId}.controller.ListReportExt', {
    metadata: {
      methods: {
        openDiagram: { public: true }
      }
    },

    override: {
      onBeforeRendering() {
        const dataModel = new JSONModel({
          Query: '${escapedQuery}'
        });
        this.getView().setModel(dataModel, 'data');
      }
    },

    openDiagram() {
      const oView = this.getView();
      if (!this._oDiagramDialog) {
        this._oDiagramDialog = Fragment.load({
          id: oView.getId(),
          name: '${componentId}.ext.fragment.UploadDiagram',
          controller: this
        }).then((oDialog) => {
          oView.addDependent(oDialog);
          this._oDiagramDialog = oDialog;
          return oDialog;
        });
      }
      Promise.resolve(this._oDiagramDialog).then((oDialog) => oDialog.open());
    },

    async onPress(oEvent) {
      const sQuery = this.getView().getModel('data').getProperty('/Query');
      const oVBox = oEvent.getSource().getParent();
      const oBinding = oVBox.getObjectBinding();

      try {
        oBinding.setParameter('Query', sQuery);
        if (oBinding.invoke) {
          await oBinding.invoke();
        } else {
          await oBinding.execute();
        }

        const oCtx = oBinding.getBoundContext();
        const raw = oCtx.getObject();
        const jsonText = typeof raw === 'string' ? raw : (raw?.value ?? JSON.stringify(raw));
        const parsed = JSON.parse(jsonText);
        const jsonModel = new JSONModel(parsed);

        const oViz = Fragment.byId(this.getView().getId(), 'idVizFrame');
        if (oViz) {
          oViz.setModel(jsonModel);
        }
      } catch (error) {
        MessageBox.error(error.message || String(error));
      }
    },

    onUploadDialogClose() {
      Promise.resolve(this._oDiagramDialog).then((oDialog) => oDialog.close());
    }
  })
);
`;
}

const FRAGMENT_XML = `<core:FragmentDefinition
    xmlns="sap.m"
    xmlns:core="sap.ui.core"
    xmlns:viz="sap.viz.ui5.controls"
    xmlns:viz.feeds="sap.viz.ui5.controls.common.feeds"
    xmlns:viz.data="sap.viz.ui5.data"
>
    <Dialog
        id="uploadDiagramDialog"
        title="{i18n>Generate_Diagram}"
    >
        <content>
            <VBox
                alignItems="Center"
                id="getUserQuery"
                binding="{/diagram(...)}"
            >
                <TextArea
                    width="420px"
                    id="diagramQueryInput"
                    value="{data>/Query}"
                    rows="4"
                />
                <Button
                    id="evaluateDiagramButton"
                    text="{i18n>Evaluate_Diagram}"
                    press=".onPress"
                    class="sapUiSmallMarginTop"
                />
            </VBox>
            <viz:VizFrame
                id="idVizFrame"
                uiConfig="{applicationSet:'fiori'}"
                height="400px"
                width="640px"
                vizType="bar"
                class="sapUiSmallMarginTop"
            >
                <viz:dataset>
                    <viz.data:FlattenedDataset data="{/response}">
                        <viz.data:dimensions>
                            <viz.data:DimensionDefinition
                                name="label"
                                value="{label}"
                            />
                        </viz.data:dimensions>
                        <viz.data:measures>
                            <viz.data:MeasureDefinition
                                name="value"
                                value="{value}"
                            />
                        </viz.data:measures>
                    </viz.data:FlattenedDataset>
                </viz:dataset>
                <viz:feeds>
                    <viz.feeds:FeedItem
                        uid="valueAxis"
                        type="Measure"
                        values="value"
                    />
                    <viz.feeds:FeedItem
                        uid="categoryAxis"
                        type="Dimension"
                        values="label"
                    />
                </viz:feeds>
                <viz:dependents>
                    <viz:Popover id="idPopOver" />
                </viz:dependents>
            </viz:VizFrame>
        </content>
        <endButton>
            <Button
                text="{i18n>CANCEL}"
                press=".onUploadDialogClose"
            />
        </endButton>
    </Dialog>
</core:FragmentDefinition>
`;

function patchAnnotations(appPath) {
  const annotationsPath = path.join(ROOT, appPath, 'annotations.cds');
  let content = fs.readFileSync(annotationsPath, 'utf8');

  if (content.includes('EntityContainer/checkAI')) {
    return false;
  }

  if (appPath === 'app/risk-analysis') {
    content += `

annotate service.RiskScoreDistribution with @(
  UI.LineItem: [
${CHECK_AI_BLOCK}
    { $Type: 'UI.DataField', Value: Year,           Label: 'Year' },
    { $Type: 'UI.DataField', Value: State,          Label: 'State' },
    { $Type: 'UI.DataField', Value: ProviderType,   Label: 'Specialty' },
    { $Type: 'UI.DataField', Value: RiskBand,       Label: 'Risk Band' },
    { $Type: 'UI.DataField', Value: ProviderCount,  Label: 'Provider Count' },
    { $Type: 'UI.DataField', Value: TotalPaid,      Label: 'Total Medicare Paid' },
    { $Type: 'UI.DataField', Value: AvgRiskScore,   Label: 'Avg Risk Score' }
  ]
);
`;
    fs.writeFileSync(annotationsPath, content);
    return true;
  }

  content = content.replace(/UI\.LineItem:\s*\[/, `UI.LineItem: [\n${CHECK_AI_BLOCK}`);
  fs.writeFileSync(annotationsPath, content);
  return true;
}

function patchI18n(appPath, componentId) {
  const i18nPath = path.join(ROOT, appPath, 'webapp/i18n/i18n.properties');
  let content = fs.readFileSync(i18nPath, 'utf8');
  if (content.includes('Evaluate_AI=')) {
    return false;
  }
  content += I18N_LINES;
  fs.writeFileSync(i18nPath, content);
  return true;
}

function findListReportSettings(manifest) {
  for (const target of Object.values(manifest['sap.ui5'].routing.targets)) {
    if (target.name === 'sap.fe.templates.ListReport') {
      return target.options.settings;
    }
  }
  throw new Error('ListReport target not found');
}

function patchManifest(appPath, componentId) {
  const manifestPath = path.join(ROOT, appPath, 'webapp/manifest.json');
  const manifest = readJson(manifestPath);
  const libs = manifest['sap.ui5'].dependencies.libs;
  libs['sap.ui.layout'] = {};
  libs['sap.viz'] = {};

  manifest['sap.ui5'].extends = {
    extensions: {
      'sap.ui.controllerExtensions': {
        'sap.fe.templates.ListReport.ListReportController': {
          controllerName: `${componentId}.controller.ListReportExt`,
        },
      },
    },
  };

  const settings = findListReportSettings(manifest);
  settings.controlConfiguration = settings.controlConfiguration || {};
  const lineItemKey = '@com.sap.vocabularies.UI.v1.LineItem';
  settings.controlConfiguration[lineItemKey] = settings.controlConfiguration[lineItemKey] || {};
  settings.controlConfiguration[lineItemKey].actions = {
    openDiagram: {
      id: 'openAiDiagram',
      text: '{{Generate_Diagram}}',
      press: `.extension.${componentId}.controller.ListReportExt.openDiagram`,
      requiresSelection: false,
    },
  };

  writeJson(manifestPath, manifest);
  return true;
}

function applyApp({ path: appPath, diagramQuery }) {
  const manifestPath = path.join(ROOT, appPath, 'webapp/manifest.json');
  const componentId = readJson(manifestPath)['sap.app'].id;

  const controllerDir = path.join(ROOT, appPath, 'webapp/controller');
  const fragmentDir = path.join(ROOT, appPath, 'webapp/ext/fragment');
  ensureDir(controllerDir);
  ensureDir(fragmentDir);

  fs.writeFileSync(
    path.join(controllerDir, 'ListReportExt.controller.js'),
    controllerSource(componentId, diagramQuery)
  );
  fs.writeFileSync(path.join(fragmentDir, 'UploadDiagram.fragment.xml'), FRAGMENT_XML);

  const results = {
    annotations: patchAnnotations(appPath),
    i18n: patchI18n(appPath, componentId),
    manifest: patchManifest(appPath, componentId),
  };

  console.log(`Updated ${appPath}:`, results);
}

for (const app of ALP_APPS) {
  applyApp(app);
}

console.log('AI extensions applied to all ALP apps.');

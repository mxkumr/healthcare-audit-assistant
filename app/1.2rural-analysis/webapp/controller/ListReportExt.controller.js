sap.ui.define([
  'sap/m/MessageBox',
  'sap/ui/core/mvc/ControllerExtension',
  'sap/ui/model/json/JSONModel',
  'sap/ui/core/Fragment'
], (MessageBox, ControllerExtension, JSONModel, Fragment) =>
  ControllerExtension.extend('com.medicare.12ruralanalysis.controller.ListReportExt', {
    metadata: {
      methods: {
        openDiagram: { public: true }
      }
    },

    override: {
      onBeforeRendering() {
        const dataModel = new JSONModel({
          Query: 'Show the top procedure codes by rejection rate for a bar chart.'
        });
        this.getView().setModel(dataModel, 'data');
      }
    },

    openDiagram() {
      const oView = this.getView();
      if (!this._oDiagramDialog) {
        this._oDiagramDialog = Fragment.load({
          id: oView.getId(),
          name: 'com.medicare.12ruralanalysis.ext.fragment.UploadDiagram',
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

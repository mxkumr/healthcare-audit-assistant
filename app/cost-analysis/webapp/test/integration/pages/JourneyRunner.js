sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/medicare/costanalysis/test/integration/pages/CostByStateProviderTypeList",
	"com/medicare/costanalysis/test/integration/pages/CostByStateProviderTypeObjectPage"
], function (JourneyRunner, CostByStateProviderTypeList, CostByStateProviderTypeObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/medicare/costanalysis') + '/test/flp.html#app-preview',
        pages: {
			onTheCostByStateProviderTypeList: CostByStateProviderTypeList,
			onTheCostByStateProviderTypeObjectPage: CostByStateProviderTypeObjectPage
        },
        async: true
    });

    return runner;
});


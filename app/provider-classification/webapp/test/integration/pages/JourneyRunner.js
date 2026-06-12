sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/medicare/providerclassification/test/integration/pages/ProviderCostEfficiencyList",
	"com/medicare/providerclassification/test/integration/pages/ProviderCostEfficiencyObjectPage"
], function (JourneyRunner, ProviderCostEfficiencyList, ProviderCostEfficiencyObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/medicare/providerclassification') + '/test/flp.html#app-preview',
        pages: {
			onTheProviderCostEfficiencyList: ProviderCostEfficiencyList,
			onTheProviderCostEfficiencyObjectPage: ProviderCostEfficiencyObjectPage
        },
        async: true
    });

    return runner;
});


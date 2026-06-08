sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"task1costanalysis/test/integration/pages/ProviderAnalyticsList",
	"task1costanalysis/test/integration/pages/ProviderAnalyticsObjectPage"
], function (JourneyRunner, ProviderAnalyticsList, ProviderAnalyticsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('task1costanalysis') + '/test/flp.html#app-preview',
        pages: {
			onTheProviderAnalyticsList: ProviderAnalyticsList,
			onTheProviderAnalyticsObjectPage: ProviderAnalyticsObjectPage
        },
        async: true
    });

    return runner;
});


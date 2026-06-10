sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/medicare/ruralanalysis/test/integration/pages/RuralUrbanDistributionList",
	"com/medicare/ruralanalysis/test/integration/pages/RuralUrbanDistributionObjectPage"
], function (JourneyRunner, RuralUrbanDistributionList, RuralUrbanDistributionObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/medicare/ruralanalysis') + '/test/flp.html#app-preview',
        pages: {
			onTheRuralUrbanDistributionList: RuralUrbanDistributionList,
			onTheRuralUrbanDistributionObjectPage: RuralUrbanDistributionObjectPage
        },
        async: true
    });

    return runner;
});


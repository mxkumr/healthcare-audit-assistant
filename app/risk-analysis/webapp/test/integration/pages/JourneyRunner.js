sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/medicare/riskanalysis/test/integration/pages/RiskScoreDistributionList",
	"com/medicare/riskanalysis/test/integration/pages/RiskScoreDistributionObjectPage"
], function (JourneyRunner, RiskScoreDistributionList, RiskScoreDistributionObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/medicare/riskanalysis') + '/test/flp.html#app-preview',
        pages: {
			onTheRiskScoreDistributionList: RiskScoreDistributionList,
			onTheRiskScoreDistributionObjectPage: RiskScoreDistributionObjectPage
        },
        async: true
    });

    return runner;
});


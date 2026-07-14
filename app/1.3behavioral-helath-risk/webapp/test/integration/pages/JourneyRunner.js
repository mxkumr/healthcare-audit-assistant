sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/medicare/13behavioralhelathrisk/test/integration/pages/BehavioralHealthRiskProfileList.gen",
	"com/medicare/13behavioralhelathrisk/test/integration/pages/BehavioralHealthRiskProfileObjectPage.gen"
], function (JourneyRunner, BehavioralHealthRiskProfileListGenerated, BehavioralHealthRiskProfileObjectPageGenerated) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/medicare/13behavioralhelathrisk') + '/test/flp.html#app-preview',
        pages: {
			onTheBehavioralHealthRiskProfileListGenerated: BehavioralHealthRiskProfileListGenerated,
			onTheBehavioralHealthRiskProfileObjectPageGenerated: BehavioralHealthRiskProfileObjectPageGenerated
        },
        async: true
    });

    return runner;
});


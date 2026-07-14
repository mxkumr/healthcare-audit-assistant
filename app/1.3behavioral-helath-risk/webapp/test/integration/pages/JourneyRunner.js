sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"behavioralhealthrisk/behavioralhealthrisk/test/integration/pages/BehavioralHealthRiskProfileList.gen",
	"behavioralhealthrisk/behavioralhealthrisk/test/integration/pages/BehavioralHealthRiskProfileObjectPage.gen"
], function (JourneyRunner, BehavioralHealthRiskProfileListGenerated, BehavioralHealthRiskProfileObjectPageGenerated) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('behavioralhealthrisk/behavioralhealthrisk') + '/test/flp.html#app-preview',
        pages: {
			onTheBehavioralHealthRiskProfileListGenerated: BehavioralHealthRiskProfileListGenerated,
			onTheBehavioralHealthRiskProfileObjectPageGenerated: BehavioralHealthRiskProfileObjectPageGenerated
        },
        async: true
    });

    return runner;
});


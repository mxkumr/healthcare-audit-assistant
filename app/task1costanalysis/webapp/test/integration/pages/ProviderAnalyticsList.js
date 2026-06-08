sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'task1costanalysis',
            componentId: 'ProviderAnalyticsList',
            contextPath: '/ProviderAnalytics'
        },
        CustomPageDefinitions
    );
});
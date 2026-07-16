sap.ui.define([], function () {
  'use strict';

  // BTP html5 archive paths → cds-plugin-ui5 local mount paths
  var LOCAL_ROUTES = {
    '/commedicareaudithome/index.html': '/com.medicare.audithome/index.html',
    '/commedicaretask1overview/index.html': '/com.medicare.task1overview/index.html',
    '/commedicaretask2overview/index.html': '/com.medicare.task2overview/index.html',
    '/commedicaretask3overview/index.html': '/com.medicare.task3overview/index.html',
    '/commedicare11costanalysis/index.html': '/com.medicare.11costanalysis/index.html',
    '/commedicare12ruralanalysis/index.html': '/com.medicare.12ruralanalysis/index.html',
    '/commedicare13behavioralhelathrisk/index.html': '/com.medicare.13behavioralhelathrisk/index.html',
    '/commedicare21providerclassification/index.html': '/com.medicare.21providerclassification/index.html',
    '/commedicare22aspecialtyprofiling/index.html': '/com.medicare.22aspecialtyprofiling/index.html',
    '/commedicare22borganizationprofiling/index.html': '/com.medicare.22borganizationprofiling/index.html',
    '/commedicare31riskdynamics/index.html': '/com.medicare.31riskdynamics/index.html',
    '/commedicare32placeofservice/index.html': '/com.medicare.32placeofservice/index.html',
    '/commedicare33credentialdiscrepancies/index.html': '/com.medicare.33credentialdiscrepancies/index.html',
    '/commedicareriskanalysis/index.html': '/com.medicare.riskanalysis/index.html'
  };

  function isLocalDev() {
    var host = window.location.hostname;
    return host === 'localhost' || host === '127.0.0.1';
  }

  function resolveUrl(url) {
    if (!url || !isLocalDev()) {
      return url;
    }
    return LOCAL_ROUTES[url] || url;
  }

  return {
    /**
     * OVP extension: map BTP html5 paths to local cds watch paths on localhost.
     * @param {string} sCardId
     * @param {object} oContext
     * @param {object} oNavigationEntry
     * @returns {object|undefined}
     */
    doCustomNavigation: function (sCardId, oContext, oNavigationEntry) {
      var url = oNavigationEntry && (oNavigationEntry.url || oNavigationEntry.Url);
      if (!url) {
        return oNavigationEntry;
      }

      var target = resolveUrl(url);
      if (target === url) {
        return oNavigationEntry;
      }

      return {
        type: 'com.sap.vocabularies.UI.v1.DataFieldWithUrl',
        url: target,
        label: oNavigationEntry.label || oNavigationEntry.Label || ''
      };
    }
  };
});

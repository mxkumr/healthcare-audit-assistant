const cds = require('@sap/cds');

module.exports = class MedicareService extends cds.ApplicationService {
    init() {
        // We leave this pristine. Joule Studio will query these entities via OData!
        return super.init();
    }
}
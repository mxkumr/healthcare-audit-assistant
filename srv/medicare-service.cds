using medicare from '../db/medicare-schema';

service MedicareService @(path:'/medicare') {
  entity ProviderSummary as projection on medicare.ProviderSummary;
  entity ServiceDetails  as projection on medicare.ServiceDetails;
  entity GeoReference    as projection on medicare.GeoReference;
}

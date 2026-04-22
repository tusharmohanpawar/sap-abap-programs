@AbapCatalog.sqlViewName: 'ZV_SALESORD'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order CDS View'

define view Z_CDS_SALESORDER
  as select from vbak
  association [0..*] to vbap as _Item
    on $projection.vbeln = _Item.vbeln
{
  key vbak.vbeln        as SalesOrder,
      vbak.erdat        as CreatedOn,
      vbak.auart        as OrderType,
      vbak.vkorg        as SalesOrg,

      _Item
}

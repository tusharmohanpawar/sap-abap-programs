@AbapCatalog.sqlViewName: 'ZV_MAT_UI'
@EndUserText.label: 'Material CDS with UI Annotations'

@UI.headerInfo: {
  typeName: 'Material',
  typeNamePlural: 'Materials'
}

define view Z_CDS_MATERIAL_UI
  as select from mara
{
  @UI.lineItem: [{ position: 10 }]
  key matnr as Material,

  @UI.lineItem: [{ position: 20 }]
  mtart as MaterialType,

  @UI.lineItem: [{ position: 30 }]
  matkl as MaterialGroup
}

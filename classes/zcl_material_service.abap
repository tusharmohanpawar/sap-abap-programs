CLASS zcl_material_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_mara,
             matnr TYPE mara-matnr,
             mtart TYPE mara-mtart,
             matkl TYPE mara-matkl,
           END OF ty_mara.

    METHODS:
      get_materials
        IMPORTING
          iv_matnr TYPE mara-matnr
        RETURNING
          VALUE(rt_mara) TYPE STANDARD TABLE OF ty_mara.

ENDCLASS.

CLASS zcl_material_service IMPLEMENTATION.

  METHOD get_materials.

    SELECT matnr mtart matkl
      INTO TABLE rt_mara
      FROM mara
      WHERE matnr = iv_matnr.

  ENDMETHOD.

ENDCLASS.

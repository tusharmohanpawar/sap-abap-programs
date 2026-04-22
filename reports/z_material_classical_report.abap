REPORT z_material_classical_report.

TABLES: mara.

SELECT-OPTIONS: s_matnr FOR mara-matnr.

DATA: BEGIN OF it_mara OCCURS 0,
        matnr TYPE mara-matnr,
        mtart TYPE mara-mtart,
        matkl TYPE mara-matkl,
      END OF it_mara.

START-OF-SELECTION.

  SELECT matnr mtart matkl
    INTO TABLE it_mara
    FROM mara
    WHERE matnr IN s_matnr.

  LOOP AT it_mara.
    WRITE: / it_mara-matnr, it_mara-mtart, it_mara-matkl.
  ENDLOOP.

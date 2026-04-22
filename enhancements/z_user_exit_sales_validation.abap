*---------------------------------------------------------------------*
* Enhancement : Sales Order Validation
* Description : Prevent order creation for blocked materials
* Where used: MV45AFZZ (Sales Order User Exit)
*---------------------------------------------------------------------*

FORM userexit_check_material.

  DATA: lv_matnr TYPE mara-matnr,
        lv_status TYPE mara-mstde.

  lv_matnr = vbap-matnr.

  SELECT SINGLE mstde
    INTO lv_status
    FROM mara
    WHERE matnr = lv_matnr.

  IF lv_status = 'X'.
    MESSAGE 'Material is blocked for sales' TYPE 'E'.
  ENDIF.

ENDFORM.

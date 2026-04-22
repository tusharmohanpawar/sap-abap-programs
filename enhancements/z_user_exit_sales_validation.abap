*---------------------------------------------------------------------*
* Object Type : User Exit
* Enhancement : MV45AFZZ
* Transaction : VA01 / VA02
* Description : Prevent order creation for blocked materials
* Business Use: Validation
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

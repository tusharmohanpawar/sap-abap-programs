*---------------------------------------------------------------------*
* Object Type : User Exit
* Enhancement : MV45AFZZ
* Transaction : VA01 / VA02
* Description : Block delivery if credit limit exceeded
* Business Use: Control
*---------------------------------------------------------------------*

FORM userexit_delivery_block.

  DATA: lv_credit   TYPE knkk-klimk,
        lv_exposure TYPE knkk-klimg.

  SELECT SINGLE klimk klimg
    INTO (lv_credit, lv_exposure)
    FROM knkk
    WHERE kunnr = vbak-kunnr.

  IF lv_exposure > lv_credit.
    vbak-lifsk = '01'. "Delivery block
  ENDIF.

ENDFORM.

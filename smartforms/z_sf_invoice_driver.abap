*---------------------------------------------------------------------*
* Object Type : Smartform Driver Program
* Smartform   : Z_SF_INVOICE
* Transaction : VA03 / VF03
* Description : Print invoice using Smartform
* Business Use: Output / Form Printing
*---------------------------------------------------------------------*

REPORT z_sf_invoice_driver.

DATA: lv_fm_name TYPE rs38l_fnam.

DATA: ls_vbak TYPE vbak,
      lt_vbap TYPE TABLE OF vbap.

PARAMETERS: p_vbeln TYPE vbak-vbeln.

START-OF-SELECTION.

* Fetch header data
SELECT SINGLE * INTO ls_vbak
  FROM vbak
  WHERE vbeln = p_vbeln.

* Fetch item data
SELECT * INTO TABLE lt_vbap
  FROM vbap
  WHERE vbeln = p_vbeln.

* Get Smartform FM
CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname = 'Z_SF_INVOICE'
  IMPORTING
    fm_name  = lv_fm_name.

* Call Smartform
CALL FUNCTION lv_fm_name
  EXPORTING
    vbak = ls_vbak
  TABLES
    vbap = lt_vbap.

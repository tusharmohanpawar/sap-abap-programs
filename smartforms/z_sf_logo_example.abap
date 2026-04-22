*---------------------------------------------------------------------*
* Object Type : Smartform Driver
* Description : Smartform with Logo Handling
*---------------------------------------------------------------------*

REPORT z_sf_logo_example.

DATA: lv_fm_name TYPE rs38l_fnam.

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname = 'Z_SF_LOGO'
  IMPORTING
    fm_name  = lv_fm_name.

CALL FUNCTION lv_fm_name.

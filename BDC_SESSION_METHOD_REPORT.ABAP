REPORT ZFEB_BDC_SESSION.

* Include bdcrecx1_s:
* The call transaction using is called WITH AUTHORITY-CHECK!
* If you have own auth.-checks you can use include bdcrecx1 instead.

*include bdcrecx1_s.

TYPES: BEGIN OF STR_MARA,
       MBRSH TYPE MARA-MBRSH,
       MTART TYPE MARA-MTART,
       MAKTX TYPE MAKT-MAKTX,
       MEINS TYPE MARA-MEINS,
       MATKL TYPE MARA-MATKL,
       BRGEW TYPE STRING,
       GEWEI TYPE MARA-GEWEI,
       NTGEW TYPE STRING,
  END OF STR_MARA.

DATA: IT_MARA TYPE TABLE OF STR_MARA,
      WA_MARA TYPE STR_MARA,
      RAW_DATA TYPE TRUXS_T_TEXT_DATA.

DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

PARAMETERS: P_FILE TYPE RLGRAP-FILENAME.
PARAMETERS: P_GROUP(12).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

*DATA PROGRAM_NAME  TYPE SY-REPID.
*DATA DYNPRO_NUMBER TYPE SY-DYNNR.
*DATA FIELD_NAME    TYPE DYNPREAD-FIELDNAME.
*DATA FILE_NAME     TYPE IBIPPARMS-PATH.

CALL FUNCTION 'F4_FILENAME'
 EXPORTING
    PROGRAM_NAME        = SYST-CPROG
*   DYNPRO_NUMBER       = SYST-DYNNR
*   FIELD_NAME          = ' '
 IMPORTING
   FILE_NAME           = P_FILE
          .

*DATA I_FIELD_SEPERATOR    TYPE CHAR01.
*DATA I_LINE_HEADER        TYPE CHAR01.
*DATA I_TAB_RAW_DATA       TYPE TRUXS_T_TEXT_DATA.
*DATA I_FILENAME           TYPE RLGRAP-FILENAME.
*DATA I_TAB_CONVERTED_DATA TYPE STANDARD TABLE.

CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
  EXPORTING
*   I_FIELD_SEPERATOR          = I_FIELD_SEPERATOR
    I_LINE_HEADER              = 'X'
    I_TAB_RAW_DATA             = RAW_DATA
    I_FILENAME                 = P_FILE
  TABLES
    I_TAB_CONVERTED_DATA       = IT_MARA
* EXCEPTIONS
*   CONVERSION_FAILED          = 1
*   OTHERS                     = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.


start-of-selection.

perform open_group.

LOOP AT IT_MARA INTO WA_MARA.

perform bdc_dynpro      using 'SAPLMGMM' '0060'.
perform bdc_field       using 'BDC_OKCODE'
                              '=AUSW'.
perform bdc_field       using 'RMMG1-MBRSH'
                              WA_MARA-MBRSH."'C'.
perform bdc_field       using 'RMMG1-MTART'
                              WA_MARA-MTART."'ROH'.
perform bdc_dynpro      using 'SAPLMGMM' '0070'.
perform bdc_field       using 'BDC_CURSOR'
                              'MSICHTAUSW-DYTXT(02)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_field       using 'MSICHTAUSW-KZSEL(01)'
                              'X'.
perform bdc_field       using 'MSICHTAUSW-KZSEL(02)'
                              'X'.
perform bdc_dynpro      using 'SAPLMGMM' '4004'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'MAKT-MAKTX'
                              WA_MARA-MAKTX."'FOR FEB MATERIAL USING RECORDING'.
perform bdc_field       using 'MARA-MEINS'
                              WA_MARA-MEINS."'KG'.
perform bdc_field       using 'MARA-MATKL'
                              WA_MARA-MATKL."'001'.
perform bdc_field       using 'BDC_CURSOR'
                              'MARA-NTGEW'.
perform bdc_field       using 'MARA-BRGEW'
                              WA_MARA-BRGEW."'20'.
perform bdc_field       using 'MARA-GEWEI'
                              WA_MARA-GEWEI."'KG'.
perform bdc_field       using 'MARA-NTGEW'
                              WA_MARA-NTGEW."'10'.
perform bdc_dynpro      using 'SAPLMGMM' '4004'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BDC_CURSOR'
                              'MAKT-MAKTX'.
perform bdc_field       using 'MAKT-MAKTX'
                              'FOR FEB MATERIAL USING RECORDING'.
perform bdc_dynpro      using 'SAPLSPO1' '0300'.
perform bdc_field       using 'BDC_OKCODE'
                              '=YES'.

 perform bdc_transaction using 'MM01'.

CLEAR: WA_MARA.
REFRESH: BDCDATA.

ENDLOOP.

perform close_group.

FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.

    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.

ENDFORM.


FORM OPEN_GROUP.

    CALL FUNCTION 'BDC_OPEN_GROUP'
         EXPORTING  CLIENT   = SY-MANDT
                    GROUP    = P_GROUP
                    USER     = SY-UNAME
                    KEEP     = 'X'
                    .

ENDFORM.

FORM BDC_TRANSACTION USING VALUE(TCODE).
    CALL FUNCTION 'BDC_INSERT'
         EXPORTING TCODE     = TCODE
         TABLES    DYNPROTAB = BDCDATA.
ENDFORM.

FORM CLOSE_GROUP.
*   close batchinput group
    CALL FUNCTION 'BDC_CLOSE_GROUP'.
    WRITE: /(30) 'BDC_CLOSE_GROUP'(I04),
            (12) 'returncode:'(I05),
                 SY-SUBRC.

ENDFORM.


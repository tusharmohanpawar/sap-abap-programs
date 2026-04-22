REPORT ZFEB_ALVBLOCK.

TABLES: EKKO,EKPO.

TYPES: BEGIN OF STR_EKKO,
        EBELN TYPE EKKO-EBELN,
        BUKRS TYPE EKKO-BUKRS,
        BSART TYPE EKKO-BSART,
        ERNAM TYPE EKKO-ERNAM,
        LIFNR TYPE EKKO-LIFNR,
      END OF STR_EKKO.

TYPES: BEGIN OF STR_EKPO,
        EBELN TYPE EKPO-EBELN,
        EBELP TYPE EKPO-EBELP,
        MATNR TYPE EKPO-MATNR,
        WERKS TYPE EKPO-WERKS,
      END OF STR_EKPO.


DATA: IT_EKKO TYPE TABLE OF STR_EKKO,
      WA_EKKO TYPE STR_EKKO,
      IT_EKPO TYPE TABLE OF STR_EKPO,
      WA_EKPO TYPE STR_EKPO,
      IT_FCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FCAT TYPE SLIS_FIELDCAT_ALV,
      IT_FCAT1 TYPE SLIS_T_FIELDCAT_ALV,
      IS_LAYOUT TYPE SLIS_LAYOUT_ALV,
      IT_EVENTS TYPE SLIS_T_EVENT,
      WA_EVENTS TYPE slis_alv_event.

SELECT-OPTIONS: P_EBELN FOR EKKO-EBELN.

START-OF-SELECTION.
    SELECT
      EBELN
      BUKRS
      BSART
      ERNAM
      LIFNR
      FROM EKKO INTO TABLE IT_EKKO UP TO 10 ROWS
      WHERE EBELN IN P_EBELN.

      IF SY-SUBRC EQ 0.
        SELECT
          EBELN
          EBELP
          MATNR
          WERKS
          FROM EKPO INTO TABLE IT_EKPO UP TO 10 ROWS FOR ALL ENTRIES IN IT_EKKO
          WHERE EBELN = IT_EKKO-EBELN.
       ENDIF.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""" FCAT FOR EKKO TABLE """""""""""""""""""""""""""""""""""""""
   WA_FCAT-COL_POS = '1'.
   WA_FCAT-FIELDNAME = 'EBELN'.
   WA_FCAT-SELTEXT_L = 'PO NO'.
   APPEND WA_FCAT TO IT_FCAT.
   CLEAR: WA_FCAT.

   WA_FCAT-COL_POS = '2'.
   WA_FCAT-FIELDNAME = 'BUKRS'.
   WA_FCAT-SELTEXT_L = 'COMP CODE'.
   APPEND WA_FCAT TO IT_FCAT.
   CLEAR: WA_FCAT.

   WA_FCAT-COL_POS = '3'.
   WA_FCAT-FIELDNAME = 'BSART'.
   WA_FCAT-SELTEXT_L = 'PO TYPE'.
   APPEND WA_FCAT TO IT_FCAT.
   CLEAR: WA_FCAT.

   WA_FCAT-COL_POS = '4'.
   WA_FCAT-FIELDNAME = 'ERNAM'.
   WA_FCAT-SELTEXT_L = 'USER NO'.
   APPEND WA_FCAT TO IT_FCAT.
   CLEAR: WA_FCAT.

   WA_FCAT-COL_POS = '5'.
   WA_FCAT-FIELDNAME = 'LIFNR'.
   WA_FCAT-SELTEXT_L = 'VENDOR NO'.
   APPEND WA_FCAT TO IT_FCAT.
   CLEAR: WA_FCAT.

   """"""""""""""""""""""""""""""""""""""""""""""""""""" FCAT FOR EKPO TABLE """""""""""""""""""""""""""""""""""""""""""

   WA_FCAT-COL_POS = '1'.
   WA_FCAT-FIELDNAME = 'EBELN'.
   WA_FCAT-SELTEXT_L = 'PO NO'.
   APPEND WA_FCAT TO IT_FCAT1.
   CLEAR: WA_FCAT.

   WA_FCAT-COL_POS = '2'.
   WA_FCAT-FIELDNAME = 'EBELP'.
   WA_FCAT-SELTEXT_L = 'PO ITEM'.
   APPEND WA_FCAT TO IT_FCAT1.
   CLEAR: WA_FCAT.

   WA_FCAT-COL_POS = '3'.
   WA_FCAT-FIELDNAME = 'MATNR'.
   WA_FCAT-SELTEXT_L = 'MATERIAL NO'.
   APPEND WA_FCAT TO IT_FCAT1.
   CLEAR: WA_FCAT.

   WA_FCAT-COL_POS = '4'.
   WA_FCAT-FIELDNAME = 'WERKS'.
   WA_FCAT-SELTEXT_L = 'PLANT'.
   APPEND WA_FCAT TO IT_FCAT1.
   CLEAR: WA_FCAT.

   CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
     EXPORTING
       I_CALLBACK_PROGRAM             = SY-REPID
*      I_CALLBACK_PF_STATUS_SET       = ' '
*      I_CALLBACK_USER_COMMAND        = ' '
*      IT_EXCLUDING                   = IT_EXCLUDING
             .

*DATA IS_LAYOUT   TYPE SLIS_LAYOUT_ALV.
*DATA IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
*DATA I_TABNAME   TYPE SLIS_TABNAME.
*DATA IT_EVENTS   TYPE SLIS_T_EVENT.
*DATA IT_SORT     TYPE SLIS_T_SORTINFO_ALV.
*DATA I_TEXT      TYPE SLIS_TEXT40.

IS_LAYOUT-ZEBRA = 'X'.
IS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

WA_EVENTS-FORM = 'HEADING'.
WA_EVENTS-NAME = 'TOP_OF_PAGE'.
APPEND WA_EVENTS TO IT_EVENTS.
CLEAR: WA_EVENTS.

      CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
        EXPORTING
          IS_LAYOUT                        = IS_LAYOUT
          IT_FIELDCAT                      = IT_FCAT
          I_TABNAME                        = 'IT_EKKO'
          IT_EVENTS                        = IT_EVENTS
*         IT_SORT                          = IT_SORT
*         I_TEXT                           = ' '
        TABLES
          T_OUTTAB                         = IT_EKKO
*       EXCEPTIONS
*         PROGRAM_ERROR                    = 1
*         MAXIMUM_OF_APPENDS_REACHED       = 2
*         OTHERS                           = 3
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.


"""""""""""""""""""""""""""""""""""""""""" FOR EKPO TABEL """""""""""""""""""""""""""""""""""""""""""""""""""

CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
        EXPORTING
          IS_LAYOUT                        = IS_LAYOUT
          IT_FIELDCAT                      = IT_FCAT1
          I_TABNAME                        = 'IT_EKPO'
          IT_EVENTS                        = IT_EVENTS
*         IT_SORT                          = IT_SORT
*         I_TEXT                           = ' '
        TABLES
          T_OUTTAB                         = IT_EKPO
*       EXCEPTIONS
*         PROGRAM_ERROR                    = 1
*         MAXIMUM_OF_APPENDS_REACHED       = 2
*         OTHERS                           = 3
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'
*       EXPORTING
*         I_INTERFACE_CHECK             = ' '
*         IS_PRINT                      = IS_PRINT
*         I_SCREEN_START_COLUMN         = 0
*         I_SCREEN_START_LINE           = 0
*         I_SCREEN_END_COLUMN           = 0
*         I_SCREEN_END_LINE             = 0
*       IMPORTING
*         E_EXIT_CAUSED_BY_CALLER       = E_EXIT_CAUSED_BY_CALLER
*         ES_EXIT_CAUSED_BY_USER        = ES_EXIT_CAUSED_BY_USER
*       EXCEPTIONS
*         PROGRAM_ERROR                 = 1
*         OTHERS                        = 2
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      FORM HEADING.
        WRITE: 'PURCHASE ORDER HEADER DATA INFO'.
      ENDFORM.

REPORT ZFEB_DOUBLCLICKEVENT.

TABLES: VBAK.

TYPES: BEGIN OF STR_VBAK,
        VBELN TYPE VBAK-VBELN,
        ERNAM TYPE VBAK-ERNAM,
        AUART TYPE VBAK-AUART,
        KUNNR TYPE VBAK-KUNNR,
      END OF STR_VBAK.

DATA: IT_VBAK TYPE TABLE OF STR_VBAK,
      WA_VBAK TYPE STR_VBAK,
      IT_FCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FCAT TYPE SLIS_FIELDCAT_ALV.

SELECT-OPTIONS: P_VBELN FOR VBAK-VBELN.

START-OF-SELECTION.
    SELECT
      VBELN
      ERNAM
      AUART
      KUNNR
      FROM VBAK INTO TABLE IT_VBAK
      WHERE VBELN IN P_VBELN.

      WA_FCAT-COL_POS = '1'.
      WA_FCAT-FIELDNAME = 'VBELN'.
      WA_FCAT-HOTSPOT   = 'X'.
      WA_FCAT-SELTEXT_L = 'SALE ORDER NO'.
      APPEND WA_FCAT TO IT_FCAT.
      CLEAR: WA_FCAT.

      WA_FCAT-COL_POS = '2'.
      WA_FCAT-FIELDNAME = 'ERNAM'.
      WA_FCAT-SELTEXT_L = 'CREATED BY'.
      APPEND WA_FCAT TO IT_FCAT.
      CLEAR: WA_FCAT.

      WA_FCAT-COL_POS = '3'.
      WA_FCAT-FIELDNAME = 'AUART'.
      WA_FCAT-SELTEXT_L = 'SALE DOC TYPE'.
      APPEND WA_FCAT TO IT_FCAT.
      CLEAR: WA_FCAT.

      WA_FCAT-COL_POS = '4'.
      WA_FCAT-FIELDNAME = 'KUNNR'.
      WA_FCAT-SELTEXT_L = 'SOLD TO PARTY'.
      APPEND WA_FCAT TO IT_FCAT.
      CLEAR: WA_FCAT.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
*         I_INTERFACE_CHECK                 = ' '
*         I_BYPASSING_BUFFER                = ' '
*         I_BUFFER_ACTIVE                   = ' '
          I_CALLBACK_PROGRAM                = SY-REPID
*         I_CALLBACK_PF_STATUS_SET          = ' '
          I_CALLBACK_USER_COMMAND           = 'DISPLAY_SALE'
*         I_CALLBACK_TOP_OF_PAGE            = ' '
*         I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*         I_CALLBACK_HTML_END_OF_LIST       = ' '
*         I_STRUCTURE_NAME                  = I_STRUCTURE_NAME
*         I_BACKGROUND_ID                   = ' '
*         I_GRID_TITLE                      = I_GRID_TITLE
*         I_GRID_SETTINGS                   = I_GRID_SETTINGS
*         IS_LAYOUT                         = IS_LAYOUT
          IT_FIELDCAT                       = IT_FCAT
*         IT_EXCLUDING                      = IT_EXCLUDING
*         IT_SPECIAL_GROUPS                 = IT_SPECIAL_GROUPS
*         IT_SORT                           = IT_SORT
*         IT_FILTER                         = IT_FILTER
*         IS_SEL_HIDE                       = IS_SEL_HIDE
*         I_DEFAULT                         = 'X'
*         I_SAVE                            = ' '
*         IS_VARIANT                        = IS_VARIANT
*         IT_EVENTS                         = IT_EVENTS
*         IT_EVENT_EXIT                     = IT_EVENT_EXIT
*         IS_PRINT                          = IS_PRINT
*         IS_REPREP_ID                      = IS_REPREP_ID
*         I_SCREEN_START_COLUMN             = 0
*         I_SCREEN_START_LINE               = 0
*         I_SCREEN_END_COLUMN               = 0
*         I_SCREEN_END_LINE                 = 0
*         I_HTML_HEIGHT_TOP                 = 0
*         I_HTML_HEIGHT_END                 = 0
*         IT_ALV_GRAPHICS                   = IT_ALV_GRAPHICS
*         IT_HYPERLINK                      = IT_HYPERLINK
*         IT_ADD_FIELDCAT                   = IT_ADD_FIELDCAT
*         IT_EXCEPT_QINFO                   = IT_EXCEPT_QINFO
*         IR_SALV_FULLSCREEN_ADAPTER        = IR_SALV_FULLSCREEN_ADAPTER
*       IMPORTING
*         E_EXIT_CAUSED_BY_CALLER           = E_EXIT_CAUSED_BY_CALLER
*         ES_EXIT_CAUSED_BY_USER            = ES_EXIT_CAUSED_BY_USER
        TABLES
          T_OUTTAB                          = IT_VBAK
*       EXCEPTIONS
*         PROGRAM_ERROR                     = 1
*         OTHERS                            = 2
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

 FORM DISPLAY_SALE USING RCOMM TYPE SY-UCOMM SEL_FIELD TYPE SLIS_SELFIELD.
   CASE RCOMM.
     WHEN '&IC1'.
       SET PARAMETER ID 'AUN' FIELD SEL_FIELD-VALUE.
       CALL TRANSACTION 'VA03'.
   ENDCASE.
 ENDFORM.

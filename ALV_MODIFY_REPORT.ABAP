REPORT ZFEB_ALVMODIFY.

TABLES: ZSTUD_FEB26.

TYPES: BEGIN OF STR_STUD,
        STUD_ID TYPE ZSTUD_FEB26-STUD_ID,
        NAME    TYPE ZSTUD_FEB26-NAME,
        ADDRESS TYPE ZSTUD_FEB26-ADDRESS,
        GENDER  TYPE ZSTUD_FEB26-GENDER,
      END OF STR_STUD.

DATA: IT_STUD TYPE TABLE OF STR_STUD,
      WA_STUD TYPE STR_STUD,
      IT_FCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FCAT TYPE SLIS_FIELDCAT_ALV,
      IT_TEMP TYPE TABLE OF STR_STUD,
      WA_TEMP TYPE STR_STUD,
      WA_FINAL TYPE ZSTUD_FEB26.

SELECT-OPTIONS: P_STUDID FOR ZSTUD_FEB26-STUD_ID.

START-OF-SELECTION.
   SELECT
     STUD_ID
     NAME
     ADDRESS
     GENDER
     FROM ZSTUD_FEB26 INTO TABLE IT_STUD
     WHERE STUD_ID IN P_STUDID.

     IT_TEMP = IT_STUD.

     WA_FCAT-COL_POS = '1'.
     WA_FCAT-FIELDNAME = 'STUD_ID'.
     WA_FCAT-SELTEXT_L = 'STUD_ID'.
     APPEND WA_FCAT TO IT_FCAT.
     CLEAR: WA_FCAT.

     WA_FCAT-COL_POS = '2'.
     WA_FCAT-FIELDNAME = 'NAME'.
     WA_FCAT-SELTEXT_L = 'NAME'.
     WA_FCAT-EDIT      = 'X'.
     APPEND WA_FCAT TO IT_FCAT.
     CLEAR: WA_FCAT.

     WA_FCAT-COL_POS = '3'.
     WA_FCAT-FIELDNAME = 'ADDRESS'.
     WA_FCAT-SELTEXT_L = 'ADDRESS'.
     WA_FCAT-EDIT      = 'X'.
     APPEND WA_FCAT TO IT_FCAT.
     CLEAR: WA_FCAT.

     WA_FCAT-COL_POS = '4'.
     WA_FCAT-FIELDNAME = 'GENDER'.
     WA_FCAT-SELTEXT_L = 'GENDER'.
     WA_FCAT-EDIT      = 'X'.
     APPEND WA_FCAT TO IT_FCAT.
     CLEAR: WA_FCAT.

     CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*        I_INTERFACE_CHECK                 = ' '
*        I_BYPASSING_BUFFER                = ' '
*        I_BUFFER_ACTIVE                   = ' '
         I_CALLBACK_PROGRAM                = SY-REPID
*        I_CALLBACK_PF_STATUS_SET          = ' '
         I_CALLBACK_USER_COMMAND           = 'SAVE'
*        I_CALLBACK_TOP_OF_PAGE            = ' '
*        I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*        I_CALLBACK_HTML_END_OF_LIST       = ' '
*        I_STRUCTURE_NAME                  = I_STRUCTURE_NAME
*        I_BACKGROUND_ID                   = ' '
*        I_GRID_TITLE                      = I_GRID_TITLE
*        I_GRID_SETTINGS                   = I_GRID_SETTINGS
*        IS_LAYOUT                         = IS_LAYOUT
         IT_FIELDCAT                       = IT_FCAT
*        IT_EXCLUDING                      = IT_EXCLUDING
*        IT_SPECIAL_GROUPS                 = IT_SPECIAL_GROUPS
*        IT_SORT                           = IT_SORT
*        IT_FILTER                         = IT_FILTER
*        IS_SEL_HIDE                       = IS_SEL_HIDE
*        I_DEFAULT                         = 'X'
*        I_SAVE                            = ' '
*        IS_VARIANT                        = IS_VARIANT
*        IT_EVENTS                         = IT_EVENTS
*        IT_EVENT_EXIT                     = IT_EVENT_EXIT
*        IS_PRINT                          = IS_PRINT
*        IS_REPREP_ID                      = IS_REPREP_ID
*        I_SCREEN_START_COLUMN             = 0
*        I_SCREEN_START_LINE               = 0
*        I_SCREEN_END_COLUMN               = 0
*        I_SCREEN_END_LINE                 = 0
*        I_HTML_HEIGHT_TOP                 = 0
*        I_HTML_HEIGHT_END                 = 0
*        IT_ALV_GRAPHICS                   = IT_ALV_GRAPHICS
*        IT_HYPERLINK                      = IT_HYPERLINK
*        IT_ADD_FIELDCAT                   = IT_ADD_FIELDCAT
*        IT_EXCEPT_QINFO                   = IT_EXCEPT_QINFO
*        IR_SALV_FULLSCREEN_ADAPTER        = IR_SALV_FULLSCREEN_ADAPTER
*      IMPORTING
*        E_EXIT_CAUSED_BY_CALLER           = E_EXIT_CAUSED_BY_CALLER
*        ES_EXIT_CAUSED_BY_USER            = ES_EXIT_CAUSED_BY_USER
       TABLES
         T_OUTTAB                          = IT_STUD
*      EXCEPTIONS
*        PROGRAM_ERROR                     = 1
*        OTHERS                            = 2
               .
     IF SY-SUBRC <> 0.
* Implement suitable error handling here
     ENDIF.

 FORM SAVE USING RCOMM TYPE SY-UCOMM SEL_FIELD TYPE SLIS_SELFIELD.
   CASE RCOMM.
     WHEN '&DATA_SAVE'.
       LOOP AT IT_STUD INTO WA_STUD.
         CLEAR: WA_TEMP.
         READ TABLE IT_TEMP INTO WA_TEMP INDEX SY-TABIX.
         IF WA_STUD NE WA_TEMP.
           WA_FINAL-STUD_ID = WA_STUD-STUD_ID.
           WA_FINAL-NAME    = WA_STUD-NAME.
           WA_FINAL-ADDRESS = WA_STUD-ADDRESS.
           WA_FINAL-GENDER  = WA_STUD-GENDER.

           MODIFY ZSTUD_FEB26 FROM WA_FINAL.
           IF SY-SUBRC EQ 0.
             MESSAGE: 'DATA IS UPDATE' TYPE 'S'.
           ENDIF.
         ENDIF.
          MESSAGE: 'DATA IS NOT UPDATE' TYPE 'S'.
          CLEAR: WA_FINAL,WA_STUD.
       ENDLOOP.
   ENDCASE.
 ENDFORM.

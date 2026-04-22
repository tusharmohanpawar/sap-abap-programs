CLASS zcl_bdc_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS:
      add_dynpro
        IMPORTING
          iv_program TYPE progname
          iv_dynpro  TYPE dynr
        CHANGING
          ct_bdcdata TYPE STANDARD TABLE.

      add_field
        IMPORTING
          iv_fnam TYPE fnam
          iv_fval TYPE any
        CHANGING
          ct_bdcdata TYPE STANDARD TABLE.

ENDCLASS.

CLASS zcl_bdc_helper IMPLEMENTATION.

  METHOD add_dynpro.

    DATA: ls_bdc TYPE bdcdata.

    ls_bdc-program  = iv_program.
    ls_bdc-dynpro   = iv_dynpro.
    ls_bdc-dynbegin = 'X'.

    APPEND ls_bdc TO ct_bdcdata.

  ENDMETHOD.

  METHOD add_field.

    DATA: ls_bdc TYPE bdcdata.

    ls_bdc-fnam = iv_fnam.
    ls_bdc-fval = iv_fval.

    APPEND ls_bdc TO ct_bdcdata.

  ENDMETHOD.

ENDCLASS.

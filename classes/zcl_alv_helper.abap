CLASS zcl_alv_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS:
      display_alv
        IMPORTING
          it_data TYPE STANDARD TABLE.

ENDCLASS.

CLASS zcl_alv_helper IMPLEMENTATION.

  METHOD display_alv.

    DATA: lo_alv TYPE REF TO cl_salv_table.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = lo_alv
          CHANGING
            t_table      = it_data ).

        lo_alv->display( ).

      CATCH cx_salv_msg.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

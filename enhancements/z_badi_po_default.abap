*---------------------------------------------------------------------*
* Object Type : BADI
* BADI Name   : ME_PROCESS_PO_CUST
* Transaction : ME21N / ME22N
* Description : Default plant in purchase order item
* Business Use: Defaulting
*---------------------------------------------------------------------*

METHOD if_ex_me_process_po_cust~process_item.

  DATA: ls_item TYPE mepoitem.

  ls_item = im_item->get_data( ).

  IF ls_item-werks IS INITIAL.
    ls_item-werks = '1000'.
    im_item->set_data( ls_item ).
  ENDIF.

ENDMETHOD.

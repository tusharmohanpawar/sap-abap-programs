REPORT zsaab_bom_alv_rp_1.

TABLES: afru, afko.

TYPES: BEGIN OF ty_afru,
         aufnr TYPE afru-aufnr,
         budat TYPE afru-budat,
         werks TYPE afru-werks,
       END OF ty_afru.
TYPES: BEGIN OF ty_afko,
         aufnr  TYPE afko-aufnr,
         plnbez TYPE afko-plnbez,
       END OF ty_afko.
TYPES: BEGIN OF ty_final,
         aufnr  TYPE afru-aufnr,
         budat  TYPE afru-budat,
         werks  TYPE afru-werks,
         plnbez TYPE afko-plnbez,
         idnrk  TYPE stpo-idnrk,
         matcat TYPE stpo-postp,
       END OF ty_final.
TYPES: BEGIN OF ty_mseg,
         aufnr      TYPE mseg-aufnr,
         matnr      TYPE mseg-matnr,
         werks      TYPE mseg-werks,
         budat_mkpf TYPE mkpf-budat,
         menge      TYPE mseg-erfmg,
         bwart      TYPE mseg-bwart,
       END OF ty_mseg.
TYPES: BEGIN OF ty_output,
         budat_mkpf TYPE mkpf-budat,    "Col 1 - Posting Date
         werks      TYPE mseg-werks,    "Col 2 - Plant
         aufnr      TYPE mseg-aufnr,    "Col 3 - Order
         matnr      TYPE mseg-matnr,    "Col 4 - Material
         act_qty    TYPE mseg-menge,    "Col 5 - Actual Production Qty
         mat_price  TYPE mbew-stprs,    "Col 6 - Material Price
         prod_price TYPE mbew-stprs,    "Col 7 - Production Price (Qty * Price)
         op_cost    TYPE afru-ism01,    "Col 8 - Operation Cost
       END OF ty_output.
TYPES: BEGIN OF ty_aufm,
         aufnr TYPE aufm-aufnr,
         mblnr TYPE aufm-mblnr,
         mjahr TYPE aufm-mjahr,
       END OF ty_aufm.
TYPES: BEGIN OF ty_price,
         matnr TYPE mbew-matnr,
         bwkey TYPE mbew-bwkey,
         stprs TYPE mbew-stprs,
       END OF ty_price.
       " Custom type for operation cost.
TYPES: BEGIN OF ty_cost,
         aufnr   TYPE afru-aufnr,
         op_cost TYPE afru-ism01,
       END OF ty_cost.

DATA: it_aufm TYPE TABLE OF ty_aufm.
DATA: it_afru  TYPE TABLE OF ty_afru,
      it_afko  TYPE TABLE OF ty_afko,
      it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final.
DATA: lt_stb TYPE TABLE OF stpox,
      ls_stb TYPE stpox.
DATA: it_mseg   TYPE TABLE OF ty_mseg,
      it_output TYPE TABLE OF ty_output,
      wa_output TYPE ty_output.
DATA: it_bom_final TYPE TABLE OF ty_final,
      wa_bom_final TYPE ty_final.
DATA: lt_prices TYPE TABLE OF ty_price,
      lt_costs  TYPE TABLE OF ty_cost.

SELECT-OPTIONS: s_budat FOR afru-budat  OBLIGATORY,
                s_werks FOR afru-werks  OBLIGATORY,
                s_aufnr FOR afru-aufnr,
                s_matnr FOR afko-plnbez.

CONSTANTS: gc_golive TYPE sy-datum VALUE '20220101'. " go-live date
DATA(lv_low)  = s_budat-low.
DATA(lv_high) = COND #( WHEN s_budat-high IS INITIAL
                         THEN s_budat-low
                         ELSE s_budat-high ).

START-OF-SELECTION.

IF lv_low < gc_golive OR lv_high < gc_golive.
  MESSAGE 'Please enter date from 2022 onward.'
    TYPE 'E'.
  STOP.
ENDIF.

  SELECT aufnr budat werks
    FROM afru
    INTO CORRESPONDING FIELDS OF TABLE it_afru
    WHERE budat IN s_budat
      AND werks IN s_werks
  AND aufnr IN s_aufnr.

  IF it_afru IS NOT INITIAL.
    SELECT aufnr plnbez
      FROM afko
      INTO CORRESPONDING FIELDS OF TABLE it_afko
      FOR ALL ENTRIES IN it_afru
      WHERE aufnr = it_afru-aufnr
    AND plnbez IN s_matnr.
  ENDIF.

  LOOP AT it_afru INTO DATA(wa_afru).
    READ TABLE it_afko INTO DATA(wa_afko) WITH KEY aufnr = wa_afru-aufnr.
    wa_final-aufnr = wa_afru-aufnr.
    wa_final-budat = wa_afru-budat.
    wa_final-werks = wa_afru-werks.
    wa_final-plnbez = wa_afko-plnbez.
    APPEND wa_final TO it_final.
    CLEAR wa_final.
  ENDLOOP.

*---------------------------------------------------------------------*
*  KEEP unique materials
*---------------------------------------------------------------------*
  SORT it_final BY aufnr werks plnbez.
  DELETE ADJACENT DUPLICATES FROM it_final
  COMPARING aufnr werks plnbez .

*---------------------------------------------------------------------*
*  BOM EXPLOSION
*---------------------------------------------------------------------*
  LOOP AT it_final INTO wa_final.
    CLEAR lt_stb.
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        capid                 = 'PP01'
        datuv                 = wa_final-budat
        ehndl                 = '1'
        emeng                 = '1'
        mktls                 = 'X'
        mehrs                 = 'X'
        mtnrv                 = wa_final-plnbez
        stlan                 = '1'
        stpst                 = '0'
        svwvo                 = 'X'
        werks                 = wa_final-werks
        vrsvo                 = 'X'
      TABLES
        stb                   = lt_stb
      EXCEPTIONS
        alt_not_found         = 1
        call_invalid          = 2
        material_not_found    = 3
        missing_authorization = 4
        no_bom_found          = 5
        no_plant_data         = 6
        no_suitable_bom_found = 7
        conversion_error      = 8
        OTHERS                = 9.

   LOOP AT lt_stb INTO ls_stb.
      IF ls_stb-idnrk CP '*SCRAP*'.
        CONTINUE.
      ENDIF.
      CLEAR wa_bom_final.
      wa_bom_final-aufnr  = wa_final-aufnr.
      wa_bom_final-budat  = wa_final-budat.
      wa_bom_final-werks  = ls_stb-werks.
      wa_bom_final-plnbez = wa_final-plnbez.
      wa_bom_final-idnrk  = ls_stb-idnrk.
      wa_bom_final-matcat = ls_stb-postp.
      APPEND wa_bom_final TO it_bom_final.
   ENDLOOP.

  ENDLOOP.

SORT it_bom_final BY aufnr werks plnbez idnrk matcat. DELETE ADJACENT DUPLICATES FROM it_bom_final
           COMPARING aufnr werks plnbez idnrk matcat.

SELECT a~aufnr,
       a~matnr,
       a~werks,
       a~menge,
       a~bwart,
       a~mblnr,
       a~mjahr,
       b~budat as budat_mkpf
 FROM mseg AS a
INNER JOIN mkpf AS b
   ON a~mblnr = b~mblnr
  AND a~mjahr = b~mjahr
 INTO CORRESPONDING FIELDS OF TABLE @it_mseg
  FOR ALL ENTRIES IN @it_bom_final
WHERE a~aufnr  = @it_bom_final-aufnr
  AND a~werks  = @it_bom_final-werks
  AND a~aufnr <> ''
  AND a~bwart IN ('101', '102')
  AND b~budat IN @s_budat.

*--------------------------------------------------------------------*
*  STEP 2: CALCULATE ACTUAL PRODUCTION QTY (101 - 102) PER ORDER Build a helper table keyed by AUFNR + MATNR + WERKS + BUDAT
*---------------------------------------------------------------------*
  TYPES: BEGIN OF ty_actqty,
           aufnr      TYPE mseg-aufnr,
           matnr      TYPE mseg-matnr,
           werks      TYPE mseg-werks,
           budat_mkpf TYPE mkpf-budat,
           act_qty    TYPE mseg-menge,
         END OF ty_actqty.

  DATA: lt_actqty TYPE TABLE OF ty_actqty,
        wa_actqty TYPE ty_actqty.

  LOOP AT it_mseg INTO DATA(ls_mseg).
    CLEAR wa_actqty.
    wa_actqty-aufnr      = ls_mseg-aufnr.
    wa_actqty-matnr      = ls_mseg-matnr.
    wa_actqty-werks      = ls_mseg-werks.
    wa_actqty-budat_mkpf = ls_mseg-budat_mkpf.

    "  101 adds qty, 102 subtracts

    IF ls_mseg-bwart = '102' .
      wa_actqty-act_qty = ls_mseg-menge * -1.
    ELSE.
      wa_actqty-act_qty = ls_mseg-menge.
    ENDIF.

    COLLECT wa_actqty INTO lt_actqty.
  ENDLOOP.

*---------------------------------------------------------------------*
*  STEP 3: FETCH MATERIAL PRICES FROM MBEW
*---------------------------------------------------------------------*
  IF lt_actqty IS NOT INITIAL.
    SELECT matnr bwkey stprs
       FROM mbew
      INTO CORRESPONDING FIELDS OF TABLE lt_prices
      FOR ALL ENTRIES IN lt_actqty
      WHERE matnr = lt_actqty-matnr
    AND bwkey = lt_actqty-werks.
  ENDIF.

*---------------------------------------------------------------------*
*  STEP 4: FETCH OPERATION COSTS FROM AFRU (SUM OF ISM01 PER ORDER)
*          GROUP BY is not allowed with FOR ALL ENTRIES — use COLLECT
*---------------------------------------------------------------------*
  IF lt_actqty IS NOT INITIAL.
    DATA: lt_afru_raw TYPE TABLE OF afru,
          wa_cost     TYPE ty_cost.

    SELECT aufnr ism01
      FROM afru
      INTO CORRESPONDING FIELDS OF TABLE lt_afru_raw
      FOR ALL ENTRIES IN lt_actqty
    WHERE aufnr = lt_actqty-aufnr.

    LOOP AT lt_afru_raw INTO DATA(ls_afru_raw).
      CLEAR wa_cost.
      wa_cost-aufnr   = ls_afru_raw-aufnr.
      wa_cost-op_cost = ls_afru_raw-ism01.
      COLLECT wa_cost INTO lt_costs.  "COLLECT sums op_cost per aufnr
    ENDLOOP.
  ENDIF.

*---------------------------------------------------------------------*
*  STEP 5: BUILD OUTPUT TABLE (8 COLUMNS)
*          BUDAT_MKPF | WERKS | AUFNR | MATNR |
*          ACT_QTY | MAT_PRICE | PROD_PRICE | OP_COST
*---------------------------------------------------------------------*
  LOOP AT lt_actqty INTO wa_actqty.
    CLEAR wa_output.

    wa_output-budat_mkpf = wa_actqty-budat_mkpf.
    wa_output-werks      = wa_actqty-werks.
    wa_output-aufnr      = wa_actqty-aufnr.
    wa_output-matnr      = wa_actqty-matnr.
    wa_output-act_qty    = wa_actqty-act_qty.

    " Material Standard Price
    READ TABLE lt_prices INTO DATA(ls_price)
      WITH KEY matnr = wa_actqty-matnr
               bwkey = wa_actqty-werks.
    IF sy-subrc = 0.
      wa_output-mat_price  = ls_price-stprs.
      wa_output-prod_price = wa_actqty-act_qty * ls_price-stprs.
    ENDIF.

    " Operation Cost
    READ TABLE lt_costs INTO DATA(ls_cost) WITH KEY aufnr = wa_actqty-aufnr.
    IF sy-subrc = 0.
      wa_output-op_cost = ls_cost-op_cost.
    ENDIF.
    APPEND wa_output TO it_output.
  ENDLOOP.

*---------------------------------------------------------------------*
  DELETE it_output WHERE act_qty = 0.
  PERFORM display_alv.
*---------------------------------------------------------------------*
FORM display_alv.

  DATA: lt_fc2 TYPE slis_t_fieldcat_alv,
        ls_fc2 TYPE slis_fieldcat_alv.

  " --- Field 1: Posting Date ---
  CLEAR ls_fc2.
  ls_fc2-fieldname = 'BUDAT_mkpf'.
  ls_fc2-seltext_m = 'Post. Date'.
  APPEND ls_fc2 TO lt_fc2.

  " --- Field 2: Plant ---
  CLEAR ls_fc2.
  ls_fc2-fieldname = 'WERKS'.
  ls_fc2-seltext_m = 'Plant'.
  APPEND ls_fc2 TO lt_fc2.

  " --- Field 3: Order ---
  CLEAR ls_fc2.
  ls_fc2-fieldname = 'AUFNR'.
  ls_fc2-seltext_m = 'Order'.
  APPEND ls_fc2 TO lt_fc2.

  " --- Field 4: Material ---
  CLEAR ls_fc2.
  ls_fc2-fieldname = 'MATNR'.
  ls_fc2-seltext_m = 'Material'.
  APPEND ls_fc2 TO lt_fc2.

  " --- Field 5: Act Prod Qty (with Sum) ---
  CLEAR ls_fc2.
  ls_fc2-fieldname = 'ACT_QTY'.
  ls_fc2-seltext_m = 'Act Prod Qty'.
  ls_fc2-do_sum    = 'X'.
  APPEND ls_fc2 TO lt_fc2.

  " --- Field 6: Mat Price ---
  CLEAR ls_fc2.
  ls_fc2-fieldname = 'MAT_PRICE'.
  ls_fc2-seltext_m = 'Mat Price'.
  APPEND ls_fc2 TO lt_fc2.

  " --- Field 7: Prod Price (with Sum) ---
  CLEAR ls_fc2.
  ls_fc2-fieldname = 'PROD_PRICE'.
  ls_fc2-seltext_m = 'Prod Price'.
  ls_fc2-do_sum    = 'X'.
  APPEND ls_fc2 TO lt_fc2.

  " --- Field 8: Operation Cost (with Sum) ---
  CLEAR ls_fc2.
  ls_fc2-fieldname = 'OP_COST'.
  ls_fc2-seltext_m = 'Operation Cost'.
  ls_fc2-do_sum    = 'X'.
  APPEND ls_fc2 TO lt_fc2.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat = lt_fc2
    TABLES
      t_outtab    = it_output.

ENDFORM.



































*REPORT z_prod_bom_explosion.
*
**---------------------------------------------------------------------*
*TABLES: afru, afko.
**---------------------------------------------------------------------*
*SELECT-OPTIONS: s_budat FOR afru-budat OBLIGATORY,
*                s_werks FOR afru-werks OBLIGATORY,
*                s_aufnr FOR afru-aufnr,
*                s_matnr FOR afko-plnbez.
*
**---------------------------------------------------------------------*
**  TYPES
**---------------------------------------------------------------------*
*TYPES: BEGIN OF ty_afru,
*         aufnr TYPE afru-aufnr,
*         budat TYPE afru-budat,
*         werks TYPE afru-werks,
*       END OF ty_afru.
*
*TYPES: BEGIN OF ty_afko,
*         aufnr  TYPE afko-aufnr,
*         plnbez TYPE afko-plnbez,
*       END OF ty_afko.
*
*TYPES: BEGIN OF ty_final,
*         aufnr   TYPE afru-aufnr,
*         budat   TYPE afru-budat,
*         werks   TYPE afru-werks,
*         plnbez  TYPE afko-plnbez,
*         idnrk   TYPE stpo-idnrk,   "Component
*         matcat  TYPE stpo-postp,   "Category
*       END OF ty_final.
*
**---------------------------------------------------------------------*
**  DATA
**---------------------------------------------------------------------*
*DATA: it_afru  TYPE TABLE OF ty_afru,
*      it_afko  TYPE TABLE OF ty_afko,
*      it_final TYPE TABLE OF ty_final,
*      wa_final TYPE ty_final.
*
*DATA: lt_stb TYPE TABLE OF stpox,
*      ls_stb TYPE stpox.
*
**---------------------------------------------------------------------*
**  START-OF-SELECTION
**---------------------------------------------------------------------*
*START-OF-SELECTION.
*
**---------------------------------------------------------------------*
**  FETCH AFRU
**---------------------------------------------------------------------*
*  SELECT aufnr budat werks
*    INTO TABLE it_afru
*    FROM afru
*    WHERE budat IN s_budat
*      AND werks IN s_werks
*      AND aufnr IN s_aufnr.
*
**---------------------------------------------------------------------*
**  FETCH AFKO
**---------------------------------------------------------------------*
*  IF it_afru IS NOT INITIAL.
*    SELECT aufnr plnbez
*      INTO TABLE it_afko
*      FROM afko
*      FOR ALL ENTRIES IN it_afru
*      WHERE aufnr = it_afru-aufnr
*        AND plnbez IN s_matnr.
*  ENDIF.
*
**---------------------------------------------------------------------*
**  BUILD BASE FINAL TABLE
**---------------------------------------------------------------------*
*  LOOP AT it_afru INTO DATA(wa_afru).
*
*    READ TABLE it_afko INTO DATA(wa_afko)
*      WITH KEY aufnr = wa_afru-aufnr.
*
*    CLEAR wa_final.
*    wa_final-aufnr  = wa_afru-aufnr.
*    wa_final-budat  = wa_afru-budat.
*    wa_final-werks  = wa_afru-werks.
*
*    IF sy-subrc = 0.
*      wa_final-plnbez = wa_afko-plnbez.
*    ENDIF.
*
*    APPEND wa_final TO it_final.
*
*  ENDLOOP.
*
**---------------------------------------------------------------------*
**  KEEP LATEST RECORD
**---------------------------------------------------------------------*
*SORT it_final BY aufnr werks plnbez budat DESCENDING.
*
*DELETE ADJACENT DUPLICATES FROM it_final
*  COMPARING aufnr werks plnbez.
*
**---------------------------------------------------------------------*
**  BOM EXPLOSION 🔥
**---------------------------------------------------------------------*
*DATA: it_bom_final TYPE TABLE OF ty_final,
*      wa_bom_final TYPE ty_final.
*
*LOOP AT it_final INTO wa_final.
*
*  CLEAR lt_stb.
*
*  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
*    EXPORTING
*      capid = 'PP01'
*      datuv = wa_final-budat
*      ehndl = '1'
*      emeng = '1'
*      mktls = 'X'
*      mehrs = 'X'
*      mtnrv = wa_final-plnbez
*      stlal = '1'
*      stlan = '1'
*      stpst = '0'
*      svwvo = 'X'
*      werks = wa_final-werks
*      vrsvo = 'X'
*    TABLES
*      stb   = lt_stb.
*
**--- Read components
*  LOOP AT lt_stb INTO ls_stb.
*
*    CLEAR wa_bom_final.
*
*    wa_bom_final-aufnr  = wa_final-aufnr.
*    wa_bom_final-budat  = wa_final-budat.
*    wa_bom_final-werks  = wa_final-werks.
*    wa_bom_final-plnbez = wa_final-plnbez.
*
*    wa_bom_final-idnrk  = ls_stb-idnrk.
*    wa_bom_final-matcat = ls_stb-postp.
*
*    APPEND wa_bom_final TO it_bom_final.
*
*  ENDLOOP.
*
*ENDLOOP.
*
**---------------------------------------------------------------------*
**  REMOVE DUPLICATES (FINAL OUTPUT)
**---------------------------------------------------------------------*
*SORT it_bom_final BY aufnr werks plnbez idnrk matcat.
*
*DELETE ADJACENT DUPLICATES FROM it_bom_final
*  COMPARING aufnr werks plnbez idnrk matcat.
*
**---------------------------------------------------------------------*
**  DISPLAY ALV
**---------------------------------------------------------------------*
*PERFORM display_alv.
*
**---------------------------------------------------------------------*
**  FORM DISPLAY ALV
**---------------------------------------------------------------------*
*FORM display_alv.
*
*  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
*        ls_fieldcat TYPE slis_fieldcat_alv.
*
**--- Order
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'AUFNR'.
*  ls_fieldcat-seltext_m = 'Order'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**--- Date
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'BUDAT'.
*  ls_fieldcat-seltext_m = 'Date'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**--- Plant
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'WERKS'.
*  ls_fieldcat-seltext_m = 'Plant'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**--- Material
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'PLNBEZ'.
*  ls_fieldcat-seltext_m = 'Material'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**--- Component
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'IDNRK'.
*  ls_fieldcat-seltext_m = 'Component'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**--- Category
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'MATCAT'.
*  ls_fieldcat-seltext_m = 'Category'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**--- ALV
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
*      it_fieldcat = lt_fieldcat
*    TABLES
*      t_outtab    = it_bom_final.
*
*ENDFORM.

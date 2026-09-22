###### below code for make module pool button invisible 
AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'BUT5'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
 ENDLOOP.
##### below code for make radio button grey put
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
IF screen-name = 'BUT5'.
  screen-input = 0.
  MODIFY SCREEN.
ENDIF.
  ENDLOOP.

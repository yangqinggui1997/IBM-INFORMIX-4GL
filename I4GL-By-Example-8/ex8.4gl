########################################
MAIN
########################################
 OPTIONS
 COMMENT LINE 7,
 MESSAGE LINE LAST
 DEFER INTERRUPT
 OPEN WINDOW w_stock AT 5, 3
 WITH FORM "f_stock"
 ATTRIBUTE (BORDER)
 DISPLAY "ADD STOCK ITEM" AT 2, 25
 IF input_stock2() THEN
 CALL insert_stock()
 CLEAR FORM
 END IF
 CLOSE WINDOW w_stock
 CLEAR SCREEN
END MAIN

########################################
FUNCTION insert_stock()
########################################
 WHENEVER ERROR CONTINUE
 INSERT INTO stock (stock_num, description, manu_code, unit,
 unit_price)
 VALUES (gr_stock.stock_num, gr_stock.description, gr_stock.manu_code,
 gr_stock.unit, gr_stock.unit_price)
WHENEVER ERROR STOP
 IF status < 0 THEN
 ERROR status USING "-<<<<<<<<<<<",
 ": Unable to save stock item in database."
 ELSE
 CALL msg("Stock item added to database.")
 END IF
END FUNCTION -- insert_stock --

########################################
FUNCTION input_stock2()
########################################
 BEFORE FIELD manu_code
 MESSAGE "Enter a manufacturer code or press F5 (CTRL-F) for a list."
 AFTER FIELD manu_code
 IF gr_stock.manu_code IS NULL THEN
 ERROR "You must enter a manufacturer code. Please try again."
 NEXT FIELD manu_code
 END IF
 SELECT manu_name
 INTO gr_stock.manu_name
 FROM manufact
 WHERE manu_code = gr_stock.manu_code
 IF (status = NOTFOUND) THEN
 ERROR
 "Unknown manufacturer's code. Use F5 (CTRL-F) to see valid codes."
 LET gr_stock.manu_code = NULL
 NEXT FIELD manu_code
 END IF
 DISPLAY BY NAME gr_stock.manu_name
 MESSAGE ""
 END IF
 ON KEY (F5, CONTROL-F)
 IF INFIELD(manu_code) THEN
 CALL manuf_popup() RETURNING gr_stock.manu_code, gr_stock.manu_name
 IF gr_stock.manu_code IS NULL THEN
 NEXT FIELD manu_code
 ELSE
 DISPLAY BY NAME gr_stock.manu_code
 END IF
 MESSAGE ""
 IF unique_stock() THEN
 DISPLAY BY NAME gr_stock.manu_name
 NEXT FIELD unit
 ELSE
 DISPLAY BY NAME gr_stock.description, gr_stock.manu_code,
 gr_stock.manu_name
 NEXT FIELD stock_num
 END IF
 END IF
 END INPUT
 IF int_flag THEN
 LET int_flag = FALSE
 CALL msg("Stock input terminated.")
 RETURN (FALSE)
 END IF
RETURN (TRUE)
END FUNCTION -- input_stock2 --

########################################
FUNCTION manuf_popup()
########################################
 DEFINE pa_manuf ARRAY[200] OF RECORD
 manu_code LIKE manufact.manu_code,
 manu_name LIKE manufact.manu_name
 END RECORD,
 idx SMALLINT,
 manuf_cnt SMALLINT,
 array_sz SMALLINT,
 over_size SMALLINT
 LET array_sz = 200 --* match size of pa_manuf array
 OPEN WINDOW w_manufpop AT 7, 13
 WITH 12 ROWS, 44 COLUMNS
 ATTRIBUTE(BORDER, FORM LINE 4)
 OPEN FORM f_manufsel FROM "f_manufsel"
 DISPLAY FORM f_manufsel
 DISPLAY "Move cursor using F3, F4, and arrow keys."
 AT 1,2
 DISPLAY "Press Accept to select a manufacturer."
 AT 2,2
 DECLARE c_manufpop CURSOR FOR
 SELECT manu_code, manu_name
 FROM manufact
 ORDER BY manu_code
 LET over_size = FALSE
 LET manuf_cnt = 1
 FOREACH c_manufpop INTO pa_manuf[manuf_cnt].*
 LET manuf_cnt = manuf_cnt + 1
 IF manuf_cnt > array_sz THEN
 LET over_size = TRUE
 EXIT FOREACH
 END IF
 END FOREACH
 IF (manuf_cnt = 1) THEN
 CALL msg("No manufacturers exist in the database.")
 LET idx = 1
 LET pa_manuf[idx].manu_code = NULL
 ELSE
 IF over_size THEN
 MESSAGE "Manuf array full: can only display ",
 array_sz USING "<<<<<<"
 END IF
 CALL SET_COUNT(manuf_cnt-1)
 LET int_flag = FALSE
 DISPLAY ARRAY pa_manuf TO sa_manuf.*
 LET idx = ARR_CURR()
 IF int_flag THEN
 LET int_flag = FALSE
 CALL msg("No manufacturer code selected.")
 LET pa_manuf[idx].manu_code = NULL
 END IF
 END IF
 CLOSE WINDOW w_manufpop
 RETURN pa_manuf[idx].manu_code, pa_manuf[idx].manu_name
END FUNCTION -- manuf_popup --

########################################
FUNCTION unique_stock()
########################################
 DEFINE stk_cnt SMALLINT
 SELECT COUNT(*)
 INTO stk_cnt
 FROM stock
 WHERE stock_num = gr_stock.stock_num
 AND manu_code = gr_stock.manu_code
 IF (stk_cnt > 0) THEN
 ERROR "A stock item with stock number ", gr_stock.stock_num,
 " and manufacturer code ", gr_stock.manu_code, " exists."
 LET gr_stock.stock_num = NULL
 LET gr_stock.description = NULL
 LET gr_stock.manu_code = NULL
 LET gr_stock.manu_name = NULL
 RETURN (FALSE)
 END IF
 RETURN (TRUE)
END FUNCTION -- unique_stock --

########################################
FUNCTION msg(str)
########################################
 DEFINE str CHAR(78)
MESSAGE str
 SLEEP 3
 MESSAGE ""
END FUNCTION -- msg --
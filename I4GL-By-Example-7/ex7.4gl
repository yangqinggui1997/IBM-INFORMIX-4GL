DATABASE test4gl
 GLOBALS
 DEFINE gr_stock RECORD
 stock_num LIKE stock.stock_num,
 description LIKE stock.description,
 manu_code LIKE manufact.manu_code,
 manu_name LIKE manufact.manu_name,
 unit LIKE stock.unit,
 unit_price LIKE stock.unit_price
 END RECORD
END GLOBALS

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
 IF input_stock() THEN
 CALL insert_stock()
 CLEAR FORM
 END IF
 CLOSE WINDOW w_stock
 CLEAR SCREEN
END MAIN

########################################
FUNCTION msg(str)
########################################
 DEFINE str CHAR(78)
MESSAGE str
 SLEEP 3
 MESSAGE ""
END FUNCTION -- msg --

########################################
FUNCTION input_stock()
########################################
 DISPLAY
 " Press Accept to save stock data, Cancel to exit w/out saving."
 AT 1, 1 ATTRIBUTE (REVERSE, YELLOW)
 INPUT BY NAME gr_stock.stock_num, gr_stock.description,
 gr_stock.manu_code, gr_stock.unit,
 gr_stock.unit_price
 AFTER FIELD stock_num
 IF gr_stock.stock_num IS NULL THEN
 ERROR "You must enter a stock number. Please try again."
 NEXT FIELD stock_num
 END IF
 AFTER FIELD manu_code
 IF gr_stock.manu_code IS NULL THEN
 ERROR "You must enter a manufacturer code. Please try again."
 NEXT FIELD manu_code
 END IF
 IF gr_stock.manu_name IS NULL THEN
 SELECT manu_name
 INTO gr_stock.manu_name
 FROM manufact
 WHERE manu_code = gr_stock.manu_code
 IF (status = NOTFOUND) THEN
 ERROR "Unknown manufacturer's code. Please try again."
 LET gr_stock.manu_code = NULL
 NEXT FIELD manu_code
 END IF
 DISPLAY BY NAME gr_stock.manu_name
 IF unique_stock() THEN
 DISPLAY BY NAME gr_stock.manu_code, gr_stock.manu_name
 NEXT FIELD unit
 ELSE
 DISPLAY BY NAME gr_stock.description, gr_stock.manu_code,
 gr_stock.manu_name
 NEXT FIELD stock_num
 END IF
 END IF
  BEFORE FIELD unit
 MESSAGE "Enter a unit or press RETURN for 'EACH'"
 AFTER FIELD unit
 IF gr_stock.unit IS NULL THEN
 LET gr_stock.unit = "EACH"
 DISPLAY BY NAME gr_stock.unit
 END IF
 MESSAGE ""
 BEFORE FIELD unit_price
 IF gr_stock.unit_price IS NULL THEN
 LET gr_stock.unit_price = 0.00
 END IF
 AFTER FIELD unit_price
 IF gr_stock.unit_price IS NULL THEN
 ERROR "You must enter a unit price. Please try again."
 NEXT FIELD unit_price
 END IF
 END INPUT
 IF int_flag THEN
 LET int_flag = FALSE
 CALL msg("Stock input terminated.")
 RETURN (FALSE)
 END IF
RETURN (TRUE)
END FUNCTION -- input_stock --

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


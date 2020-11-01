DATABASE test4gl
GLOBALS
    DEFINE _grStock RECORD
            stock_num LIKE stock.stock_num,
            description LIKE stock.description,
            manu_code LIKE manufact.manu_code,
            manu_name LIKE manufact.manu_name,
            unit LIKE stock.unit,
            unit_price LIKE stock.unit_price
    END RECORD
END GLOBALS

MAIN
    OPTIONS
        COMMENT LINE 7,
        MESSAGE LINE LAST
    DEFER INTERRUPT
 
    OPEN WINDOW _wStock AT 5, 3 WITH FORM "f_stock" ATTRIBUTE (BORDER)
    DISPLAY "ADD STOCK ITEM" AT 2, 25
 
    IF inputStock()
    THEN
        CALL insertStock()
        CLEAR FORM
    END IF
    CLOSE WINDOW _wStock
    CLEAR SCREEN
END MAIN

FUNCTION msg(_str)
    DEFINE _str CHAR(78)
    MESSAGE _str
    SLEEP 3
    MESSAGE ""
END FUNCTION -- msg --

FUNCTION inputStock()
    DISPLAY " Press Accept to save stock data, Cancel to exit w/out saving." AT 1, 1 ATTRIBUTE (REVERSE, YELLOW)
    INPUT BY NAME _grStock.stock_num, _grStock.description,
                _grStock.manu_code, _grStock.unit,
                _grStock.unit_price
    AFTER FIELD stock_num
        IF _grStock.stock_num IS NULL 
        THEN
            ERROR "You must enter a stock number. Please try again."
            NEXT FIELD stock_num
        END IF
    AFTER FIELD manu_code
        IF _grStock.manu_code IS NULL 
        THEN
            ERROR "You must enter a manufacturer code. Please try again."
            NEXT FIELD manu_code
        END IF
        IF _grStock.manu_name IS NULL 
        THEN
            SELECT manu_name
            INTO _grStock.manu_name
            FROM manufact
            WHERE manu_code = _grStock.manu_code
            IF (status = NOTFOUND) 
            THEN
                ERROR "Unknown manufacturer's code. Please try again."
                LET _grStock.manu_code = NULL
                NEXT FIELD manu_code
            END IF

            DISPLAY BY NAME _grStock.manu_name
            IF _uniqueStock() 
            THEN
                DISPLAY BY NAME _grStock.manu_code, _grStock.manu_name
                NEXT FIELD unit
            ELSE
                DISPLAY BY NAME _grStock.description, _grStock.manu_code,
                                _grStock.manu_name
                NEXT FIELD stock_num
            END IF
        END IF
    BEFORE FIELD unit
        MESSAGE "Enter a unit or press RETURN for 'EACH'"
    AFTER FIELD unit
        IF _grStock.unit IS NULL 
        THEN
            LET _grStock.unit = "EACH"
            DISPLAY BY NAME _grStock.unit
        END IF
        MESSAGE ""
    BEFORE FIELD unit_price
        IF _grStock.unit_price IS NULL 
        THEN
            LET _grStock.unit_price = 0.00
        END IF
    AFTER FIELD unit_price
        IF _grStock.unit_price IS NULL 
        THEN
            ERROR "You must enter a unit price. Please try again."
            NEXT FIELD unit_price
        END IF
    END INPUT
    IF int_flag 
    THEN
        LET int_flag = FALSE
        CALL msg("Stock input terminated.")
        RETURN (FALSE)
    END IF
    RETURN (TRUE)
END FUNCTION -- inputStock --

FUNCTION _uniqueStock()
    DEFINE _stkCnt SMALLINT

    SELECT COUNT(*)
    INTO _stkCnt
    FROM stock
    WHERE stock_num = _grStock.stock_num AND manu_code = _grStock.manu_code
 
    IF (_stkCnt > 0) 
    THEN
        ERROR "A stock item with stock number ", _grStock.stock_num, " and manufacturer code ", _grStock.manu_code, " exists."
        LET _grStock.stock_num = NULL
        LET _grStock.description = NULL
        LET _grStock.manu_code = NULL
        LET _grStock.manu_name = NULL
        RETURN (FALSE)
    END IF
    RETURN (TRUE)
END FUNCTION -- _uniqueStock --

FUNCTION insertStock()
    WHENEVER ERROR CONTINUE
    INSERT INTO stock (stock_num, description, manu_code, unit, unit_price)
    VALUES (_grStock.stock_num, _grStock.description, _grStock.manu_code,_grStock.unit, _grStock.unit_price)
    WHENEVER ERROR STOP

    IF status < 0
    THEN
        ERROR status USING "-<<<<<<<<<<<", ": Unable to save stock item in database."
    ELSE
        CALL msg("Stock item added to database.")
    END IF
END FUNCTION -- insertStock --


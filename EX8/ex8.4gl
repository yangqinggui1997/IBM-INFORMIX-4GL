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
    
    OPEN WINDOW w_stock AT 5, 3 WITH FORM "../EX7/f_stock" ATTRIBUTE (BORDER)
    DISPLAY "ADD STOCK ITEM" AT 2, 25
    IF inputStock2() 
    THEN
        CALL insertStock()
 CLEAR FORM
 END IF
 CLOSE WINDOW w_stock
 CLEAR SCREEN
END MAIN

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

FUNCTION inputStock2()
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
    BEFORE FIELD manu_code
        MESSAGE "Enter a manufacturer code or press F5 (CTRL-F) for a list."
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
            IF (status = NOTFOUND) THEN
                ERROR "Unknown manufacturer's code. Use F5 (CTRL-F) to see valid codes."
                LET _grStock.manu_code = NULL
                NEXT FIELD manu_code
            END IF
            
            DISPLAY BY NAME _grStock.manu_name
            IF uniqueStock() 
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
    ON KEY (F5, CONTROL-F)
        IF INFIELD(manu_code) 
        THEN
            CALL manufPopup() RETURNING _grStock.manu_code, _grStock.manu_name
            IF _grStock.manu_code IS NULL 
            THEN
                NEXT FIELD manu_code
            ELSE
                DISPLAY BY NAME _grStock.manu_code
            END IF

            MESSAGE ""
            IF uniqueStock() 
            THEN
                DISPLAY BY NAME _grStock.manu_name
                NEXT FIELD unit
            ELSE
                DISPLAY BY NAME _grStock.description, _grStock.manu_code,
                                _grStock.manu_name
                NEXT FIELD stock_num
            END IF
        END IF
    END INPUT
    IF int_flag 
    THEN
        LET int_flag = FALSE
        CALL msg("Stock input terminated.")
        RETURN (FALSE)
    END IF
    RETURN (TRUE)
END FUNCTION -- inputStock2 --

FUNCTION manufPopup()
    DEFINE _paManuf ARRAY[200] OF RECORD
            manu_code LIKE manufact.manu_code,
            manu_name LIKE manufact.manu_name
            END RECORD,
            _idx SMALLINT,
            _manufCnt SMALLINT,
            _arraySz SMALLINT,
            _overSize SMALLINT

    LET _arraySz = 200 --* match size of _paManuf array
    OPEN WINDOW _wManufPop AT 7, 13 WITH 12 ROWS, 44 COLUMNS ATTRIBUTE(BORDER, FORM LINE 4)
    OPEN FORM _fManufSel FROM "f_manufsel"
    DISPLAY FORM _fManufSel

    DISPLAY "Move cursor using F3, F4, and arrow keys." AT 1,2
    DISPLAY "Press Accept to select a manufacturer." AT 2,2

    DECLARE _cManufPop CURSOR FOR
    SELECT manu_code, manu_name
    FROM manufact
    ORDER BY manu_code

    LET _overSize = FALSE
    LET _manufCnt = 1
    FOREACH _cManufPop INTO _paManuf[_manufCnt].*
        LET _manufCnt = _manufCnt + 1
        IF _manufCnt > _arraySz 
        THEN
            LET _overSize = TRUE
            EXIT FOREACH
        END IF
    END FOREACH

    IF (_manufCnt = 1) 
    THEN
        CALL msg("No manufacturers exist in the database.")
        LET _idx = 1
        LET _paManuf[_idx].manu_code = NULL
    ELSE
        IF _overSize 
        THEN
            MESSAGE "Manuf array full: can only display ", _arraySz USING "<<<<<<"
        END IF
        CALL SET_COUNT(_manufCnt - 1)
        LET int_flag = FALSE
        DISPLAY ARRAY _paManuf TO _saManuf.*
        LET _idx = ARR_CURR()
        IF int_flag 
        THEN
            LET int_flag = FALSE
            CALL msg("No manufacturer code selected.")
            LET _paManuf[_idx].manu_code = NULL
        END IF
    END IF
    CLOSE WINDOW _wManufPop
    RETURN _paManuf[_idx].manu_code, _paManuf[_idx].manu_name
END FUNCTION -- manufPopup --

FUNCTION uniqueStock()
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
END FUNCTION -- uniqueStock --

FUNCTION msg(_str)
    DEFINE _str CHAR(78)
    MESSAGE _str
    SLEEP 3
    MESSAGE ""
END FUNCTION -- msg --

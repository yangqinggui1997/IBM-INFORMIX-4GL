DATABASE test4gl
GLOBALS
    DEFINE _grStock RECORD
            stock_num LIKE stock.stock_num,
            description LIKE stock.description,
            _manuCode LIKE manufact._manuCode,
            _manuName LIKE manufact._manuName,
            unit LIKE stock.unit,
            unit_price LIKE stock.unit_price
    END RECORD
END GLOBALS

MAIN
    OPTIONS
        COMMENT LINE 7,
        MESSAGE LINE LAST
    DEFER INTERRUPT
    
    OPEN WINDOW w_stock AT 5, 3 WITH FORM "f_stock" ATTRIBUTE (BORDER)
    DISPLAY "ADD STOCK ITEM" AT 2, 25
    IF inputStock2() 
    THEN
        CALL insert_stock()
 CLEAR FORM
 END IF
 CLOSE WINDOW w_stock
 CLEAR SCREEN
END MAIN

FUNCTION insertStock()
    WHENEVER ERROR CONTINUE
    INSERT INTO stock (stock_num, description, _manuCode, unit, unit_price)
    VALUES (_grStock.stock_num, _grStock.description, _grStock._manuCode,_grStock.unit, _grStock.unit_price)
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
                _grStock._manuCode, _grStock.unit,
                _grStock.unit_price
    AFTER FIELD stock_num
        IF _grStock.stock_num IS NULL 
        THEN
            ERROR "You must enter a stock number. Please try again."
            NEXT FIELD stock_num
        END IF
    BEFORE FIELD _manuCode
        MESSAGE "Enter a manufacturer code or press F5 (CTRL-F) for a list."
    AFTER FIELD _manuCode
        IF _grStock._manuCode IS NULL 
        THEN
            ERROR "You must enter a manufacturer code. Please try again."
            NEXT FIELD _manuCode
        END IF
        IF _grStock._manuName IS NULL 
        THEN
            SELECT _manuName
            INTO _grStock._manuName
            FROM manufact
            WHERE _manuCode = _grStock._manuCode
            IF (status = NOTFOUND) THEN
                ERROR "Unknown manufacturer's code. Use F5 (CTRL-F) to see valid codes."
                LET _grStock._manuCode = NULL
                NEXT FIELD _manuCode
            END IF
            
            DISPLAY BY NAME _grStock._manuName
            IF uniqueStock() 
            THEN
                DISPLAY BY NAME _grStock._manuCode, _grStock._manuName
                NEXT FIELD unit
            ELSE
                DISPLAY BY NAME _grStock.description, _grStock._manuCode,
                                _grStock._manuName
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
        IF INFIELD(_manuCode) 
        THEN
            CALL manufPopup() RETURNING _grStock._manuCode, _grStock._manuName
            IF _grStock._manuCode IS NULL 
            THEN
                NEXT FIELD _manuCode
            ELSE
                DISPLAY BY NAME _grStock._manuCode
            END IF

            MESSAGE ""
            IF uniqueStock() 
            THEN
                DISPLAY BY NAME _grStock._manuName
                NEXT FIELD unit
            ELSE
                DISPLAY BY NAME _grStock.description, _grStock._manuCode,
                                _grStock._manuName
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
            _manuCode LIKE manufact._manuCode,
            _manuName LIKE manufact._manuName
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
    SELECT _manuCode, _manuName
    FROM manufact
    ORDER BY _manuCode

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
        LET _paManuf[_idx]._manuCode = NULL
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
            LET _paManuf[_idx]._manuCode = NULL
        END IF
    END IF
    CLOSE WINDOW _wManufPop
    RETURN _paManuf[_idx]._manuCode, _paManuf[_idx]._manuName
END FUNCTION -- manufPopup --

FUNCTION uniqueStock()
    DEFINE _stkCnt SMALLINT

    SELECT COUNT(*)
    INTO _stkCnt
    FROM stock
    WHERE stock_num = _grStock.stock_num AND _manuCode = _grStock._manuCode
 
    IF (_stkCnt > 0) 
    THEN
        ERROR "A stock item with stock number ", _grStock.stock_num, " and manufacturer code ", _grStock._manuCode, " exists."
        LET _grStock.stock_num = NULL
        LET _grStock.description = NULL
        LET _grStock._manuCode = NULL
        LET _grStock._manuName = NULL
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

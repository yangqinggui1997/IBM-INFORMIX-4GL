DATABASE test4gl
GLOBALS
    DEFINE _grOrdShip RECORD
                customer_num LIKE customer.customer_num,
                company LIKE customer.company,
                order_num INTEGER,
                order_date LIKE orders.order_date
            END RECORD,
        _grChanges RECORD
                tax_rate DECIMAL(5,3),
                ship_charge LIKE orders.ship_charge,
                sales_tax MONEY(9),
                order_total MONEY(11)
            END RECORD,
            _grCharges RECORD
                tax_rate DECIMAL(5,3),
                ship_charge LIKE orders.ship_charge,
                sales_tax MONEY(9),
                order_total MONEY(11)
           	END RECORD,
        _grShip RECORD
                ship_date LIKE orders.ship_date,
                ship_instruct LIKE orders.ship_instruct,
                ship_weight LIKE orders.ship_weight,
                ship_charge LIKE orders.ship_charge
            END RECORD
    DEFINE _message ARRAY[5] OF CHAR(48)
END GLOBALS

MAIN
    DEFINE _updStat INTEGER
    OPTIONS
        #HELP FILE "hlpmsgs",
        COMMENT LINE 1,
        MESSAGE LINE LAST
    DEFER INTERRUPT
    OPEN WINDOW _wMain AT 2,3 WITH 19 ROWS, 76 COLUMNS ATTRIBUTE (BORDER)
    OPEN FORM _frmShip FROM "../EX11/f_ship"
    DISPLAY FORM _frmShip
    IF findOrder() 
    THEN
        DISPLAY " Press Accept to save shipping info. Press CTRL-W for Help." AT 17, 1 ATTRIBUTE (REVERSE, YELLOW)
        DISPLAY " Press Cancel to exit w/out saving." AT 18, 1 ATTRIBUTE (REVERSE, YELLOW)

        CALL calcOrder(_grOrdShip.order_num)

        SELECT ship_date, ship_instruct, ship_weight, ship_charge
        INTO _grShip.*
        FROM orders
        WHERE order_num = _grOrdShip.order_num
        
        IF inputShip()
        THEN
            LET _updStat = updOrder(_grOrdShip.order_num)
            IF (_updStat < 0) 
            THEN
                ERROR _updStat USING "-<<<<<<<<<<<", ": Unable to update the order."
            ELSE
                CALL msg("Order updated with shipping information.")
            END IF
        END IF
    END IF
    CLOSE FORM _frmShip
    CLOSE WINDOW _wMain
    CLEAR SCREEN
END MAIN

FUNCTION findOrder()
    DEFINE _custNum LIKE customer.customer_num,
        _lastKey SMALLINT
    
    CALL clearLines(1, 3)
    DISPLAY "ORDER SEARCH" AT 2, 34
    
    CALL clearLines(2, 17)
    DISPLAY " Enter customer number and order number then press Accept." AT 17, 1 ATTRIBUTE (REVERSE, YELLOW)
    DISPLAY " Press Cancel to exit without searching. Press CTRL-W for Help." AT 18, 1 ATTRIBUTE (REVERSE, YELLOW)

    LET INT_FLAG = FALSE
    INPUT BY NAME _grOrdShip.customer_num, _grOrdShip.order_num HELP 110
        BEFORE FIELD customer_num
            MESSAGE "Enter a customer number or press F5 (CTRL-F) for a list."
            AFTER FIELD customer_num
                IF _grOrdShip.customer_num IS NULL 
                THEN
                    ERROR "You must enter a customer number. Please try again."
                    NEXT FIELD customer_num
                END IF
                
                SELECT company
                INTO _grOrdShip.company
                FROM customer
                WHERE customer_num = _grOrdShip.customer_num
                
                IF (STATUS = NOTFOUND) 
                THEN
                    ERROR "Unknown customer number. Use F5 (CTRL-F) to see valid customers."
                    LET _grOrdShip.customer_num = NULL
                    NEXT FIELD customer_num
                END IF
                
                DISPLAY BY NAME _grOrdShip.company
                MESSAGE ""
        BEFORE FIELD order_num
            MESSAGE "Enter order number or press F5 (CTRL-F) for a list."
        AFTER FIELD order_num
            LET _lastKey = FGL_LASTKEY()
            IF (_lastKey <> FGL_KEYVAL("left") ) AND (_lastKey <> FGL_KEYVAL("up") )
            THEN
                IF _grOrdShip.order_num IS NULL 
                THEN
                    ERROR "You must enter an order number. Please try again."
                    NEXT FIELD order_num
                END IF
                
                SELECT order_date, customer_num
                INTO _grOrdShip.order_date, _custNum
                FROM orders
                WHERE order_num = _grOrdShip.order_num
                
                IF (STATUS = NOTFOUND) 
                THEN
                    ERROR "Unknown order number. Use F5 (CTRL-F) to see valid orders."
                    LET _grOrdShip.order_num = NULL
                    NEXT FIELD order_num
                END IF
                IF (_custNum <> _grOrdShip.customer_num) 
                THEN
                    ERROR "Order ", _grOrdShip.order_num USING "<<<<<<<<<<<", " is not for customer ", _grOrdShip.customer_num USING "<<<<<<<<<<<"
                    LET _grOrdShip.order_num = NULL
                    DISPLAY BY NAME _grOrdShip.order_num
                    NEXT FIELD customer_num
                END IF
                
                DISPLAY BY NAME _grOrdShip.order_date
            ELSE
                LET _grOrdShip.order_num = NULL
                DISPLAY BY NAME _grOrdShip.order_num
            END IF
            
            MESSAGE ""
            ON KEY (F5, CONTROL-F)
                IF INFIELD(customer_num) 
                THEN
                    CALL custPopup2()
                    RETURNING _grOrdShip.customer_num, _grOrdShip.company
                    IF _grOrdShip.customer_num IS NULL 
                    THEN
                        IF _grOrdShip.company IS NULL 
                        THEN
                            LET _message[1] = "No customers exist in the database!"
                            CALL messageWindow(11, 12)
                        END IF
                        NEXT FIELD customer_num
                    END IF
                    DISPLAY BY NAME _grOrdShip.customer_num, _grOrdShip.company
                    MESSAGE ""
                    NEXT FIELD order_num
                END IF
                IF INFIELD(order_num) 
                THEN
                    CALL orderPopup(_grOrdShip.customer_num)
                    RETURNING _grOrdShip.order_num, _grOrdShip.order_date
                    IF _grOrdShip.order_num IS NULL 
                    THEN
                        IF _grOrdShip.order_date IS NULL 
                        THEN
                            LET _message[1] = "No orders exists for customer ",
                            _grOrdShip.customer_num USING "<<<<<<<<<<<", "."
                            CALL messageWindow(11, 12)
                            LET _grOrdShip.customer_num = NULL
                            LET _grOrdShip.company = NULL
                            DISPLAY BY NAME _grOrdShip.company
                            NEXT FIELD customer_num
                        ELSE
                            NEXT FIELD order_num
                        END IF
                    END IF
                    DISPLAY BY NAME _grOrdShip.order_num, _grOrdShip.order_date
                    MESSAGE ""
                    EXIT INPUT
                END IF
    AFTER INPUT
        IF NOT INT_FLAG 
        THEN
            IF (_grOrdShip.customer_num IS NULL) OR (_grOrdShip.order_num IS NULL) 
            THEN
                ERROR "Enter the customer and order numbers or press Cancel to exit."
                NEXT FIELD customer_num
            END IF
        END IF
    END INPUT

    IF INT_FLAG 
    THEN
        LET INT_FLAG = FALSE
        CALL clearLines(2, 17)
        CALL msg("Order search terminated.")
        RETURN (FALSE)
    END IF
    CALL clearLines(2, 17)
    RETURN (TRUE)
END FUNCTION -- findOrder --

FUNCTION custPopup2()
    DEFINE _paCust ARRAY[10] OF RECORD
        customer_num LIKE customer.customer_num,
        company LIKE customer.company
            END RECORD,
        _idx SMALLINT,
        i SMALLINT,
        _custCnt SMALLINT,
        _fetchCusts SMALLINT,
        _arraySize SMALLINT,
        _totalCusts INTEGER,
        _numberToSee INTEGER,
        _currPa SMALLINT
    
    LET _arraySize = 10
    LET _fetchCusts = FALSE

    SELECT COUNT(*)
    INTO _totalCusts
    FROM customer

    IF _totalCusts = 0 
    THEN
        LET _paCust[1].customer_num = NULL
        LET _paCust[1].company = NULL
        RETURN _paCust[1].customer_num, _paCust[1].company
    END IF

    OPEN WINDOW _wCustpop AT 8, 13 WITH 12 ROWS, 50 COLUMNS ATTRIBUTE(BORDER, FORM LINE 4)
    OPEN FORM f_custsel FROM "../EX11/f_custsel"
    DISPLAY FORM f_custsel
    DISPLAY "Move cursor using F3, F4, and arrow keys." AT 1,2
    DISPLAY "Press Accept to select a customer." AT 2,2
    
    LET _numberToSee = _totalCusts
    LET _idx = 0
    DECLARE _cCustpop CURSOR FOR
    SELECT customer_num, company
    FROM customer
    ORDER BY customer_num
    
    WHENEVER ERROR CONTINUE
    OPEN _cCustpop
    WHENEVER ERROR STOP
 
    IF (STATUS = 0) 
    THEN
        LET _fetchCusts = TRUE
    ELSE
        CALL msg("Unable to open cursor.")
        LET _idx = 1
        LET _paCust[_idx].customer_num = NULL
        LET _paCust[_idx].company = NULL
    END IF
    WHILE _fetchCusts
        WHILE (_idx < _arraySize)
            LET _idx = _idx + 1
            FETCH _cCustpop INTO _paCust[_idx].*
            IF (STATUS = NOTFOUND) 
            THEN --* no more orders to see
                LET _fetchCusts = FALSE
                LET _idx = _idx - 1
                EXIT WHILE
            END IF
        END WHILE

        IF (_numberToSee > _arraySize) 
        THEN
            MESSAGE "On last row, press F5 (CTRL-B) for more customers."
        END IF
        IF (_idx = 0) 
        THEN
            CALL msg("No customers exist in the database.")
            LET _idx = 1
            LET _paCust[_idx].customer_num = NULL
        ELSE
            CALL SET_COUNT(_idx)
            LET INT_FLAG = FALSE
            DISPLAY ARRAY _paCust TO _saCust.*
            ON KEY (F5, CONTROL-B)
                LET _currPa = ARR_CURR()
                IF (_currPa = _idx) THEN
                    LET _numberToSee = _numberToSee - _idx
                    IF (_numberToSee > 0) 
                    THEN
                        LET _idx = 0
                        EXIT DISPLAY
                    ELSE
                        CALL msg("No more customers to see.")
                    END IF
                ELSE
                    CALL msg("Not on last customer row.")
                    MESSAGE "On last row, press F5 (CTRL-B) for more customers."
                END IF
                END DISPLAY

                IF (_idx <> 0) 
                THEN
                    LET _idx = ARR_CURR()
                    LET _fetchCusts = FALSE
                END IF

                IF INT_FLAG 
                THEN
                    LET INT_FLAG = FALSE
                    CALL msg("No customer number selected.")
                    LET _paCust[_idx].customer_num = NULL
                END IF
        END IF
    END WHILE
    CLOSE FORM f_custsel
    CLOSE WINDOW _wCustpop
    RETURN _paCust[_idx].customer_num, _paCust[_idx].company
END FUNCTION -- custPopup2 --

FUNCTION orderPopup(_custNum)
    DEFINE _custNum LIKE customer.customer_num,
            _paOrder ARRAY[10] OF RECORD
            order_num LIKE orders.order_num,
            order_date LIKE orders.order_date,
            po_num LIKE orders.po_num,
            ship_date LIKE orders.ship_date,
            paid_date LIKE orders.paid_date
            END RECORD,
        _idx SMALLINT,
        i SMALLINT,
        _orderCnt SMALLINT,
        _fetchOrders SMALLINT,
        _arraySize SMALLINT,
        _totalOrders INTEGER,
        _numberToSee INTEGER,
        _currPa SMALLINT

    LET _arraySize = 10
    LET _fetchOrders = FALSE

    SELECT COUNT(*)
    INTO _totalOrders
    FROM orders
    WHERE customer_num = _custNum

    IF _totalOrders = 0 
    THEN
        LET _paOrder[1].order_num = NULL
        LET _paOrder[1].order_date = NULL
        RETURN _paOrder[1].order_num, _paOrder[1].order_date
    END IF

    OPEN WINDOW _wOrderpop AT 9, 5 WITH 12 ROWS, 71 COLUMNS ATTRIBUTE(BORDER, FORM LINE 4)
    OPEN FORM _frmOrderSel FROM "f_ordersel"
    DISPLAY FORM _frmOrderSel
    DISPLAY "Move cursor using F3, F4, and arrow keys." AT 1,2
    DISPLAY "Press Accept to select an order." AT 2,2
    
    LET _numberToSee = _totalOrders
    LET _idx = 0
    DECLARE _cOrderPop CURSOR FOR
    SELECT order_num, order_date, po_num, ship_date, paid_date
    FROM orders
    WHERE customer_num = _custNum
    ORDER BY order_num
    WHENEVER ERROR CONTINUE
    OPEN _cOrderPop
    WHENEVER ERROR STOP

    IF (STATUS = 0) 
    THEN
        LET _fetchOrders = TRUE
    ELSE
        CALL msg("Unable to open cursor.")
        LET _idx = 1
        LET _paOrder[_idx].order_num = NULL
        LET _paOrder[_idx].order_date = NULL
    END IF
    WHILE _fetchOrders
        WHILE (_idx < _arraySize)
            LET _idx = _idx + 1
            FETCH _cOrderPop INTO _paOrder[_idx].*
            IF (STATUS = NOTFOUND) 
            THEN --* no more orders to see
                LET _fetchOrders = FALSE
                LET _idx = _idx - 1
                EXIT WHILE
            END IF
        END WHILE

        IF (_numberToSee > _arraySize) 
        THEN
            MESSAGE "On last row, press F5 (CTRL-B) for more orders."
        END IF
        IF (_idx = 0) 
        THEN
            CALL msg("No orders exist in the database.")
            LET _idx = 1
            LET _paOrder[_idx].order_num = NULL
        ELSE
            CALL SET_COUNT(_idx)
            LET INT_FLAG = FALSE
            DISPLAY ARRAY _paOrder TO _saOrder.*
            ON KEY (F5, CONTROL-B)
                LET _currPa = ARR_CURR()
                IF (_currPa = _idx) 
                THEN
                    LET _numberToSee = _numberToSee - _idx
                    IF (_numberToSee > 0) 
                    THEN
                        LET _idx = 0
                        EXIT DISPLAY
                    ELSE
                        CALL msg("No more orders to see.")
                    END IF
                ELSE
                    CALL msg("Not on last order row.")
                    MESSAGE "On last row, press F5 (CTRL-B) for more orders."
                END IF
                
                END DISPLAY
                
                IF _idx <> 0 
                THEN
                    LET _idx = ARR_CURR()
                    LET _fetchOrders = FALSE
                END IF
                IF INT_FLAG 
                THEN
                    LET INT_FLAG = FALSE
                    CALL msg("No order number selected.")
                    LET _paOrder[_idx].order_num = NULL
                END IF
        END IF
    END WHILE
    CLOSE FORM _frmOrderSel
    CLOSE WINDOW _wOrderpop
    RETURN _paOrder[_idx].order_num, _paOrder[_idx].order_date
END FUNCTION -- orders_popup --

FUNCTION calcOrder(_ordNum)
    DEFINE _ordNum LIKE orders.order_num,
            state_code LIKE customer.state
    
    SELECT ship_charge, state
    INTO _grChanges.ship_charge, state_code
    FROM orders, customer
    WHERE order_num = _ordNum AND orders.customer_num = customer.customer_num

    IF _grChanges.ship_charge IS NULL 
    THEN
        LET _grChanges.ship_charge = 0.00
    END IF
    
    SELECT SUM(total_price)
    INTO _grChanges.order_total
    FROM items
    WHERE order_num = _ordNum
    
    IF _grChanges.order_total IS NULL 
    THEN
        LET _grChanges.order_total = 0.00
    END IF
    
    CALL taxRates(state_code) RETURNING _grChanges.tax_rate
    LET _grChanges.sales_tax = _grChanges.order_total * (_grChanges.tax_rate / 100)
    LET _grChanges.order_total = _grChanges.order_total + _grChanges.sales_tax
END FUNCTION -- calcOrder --

FUNCTION updOrder(_ordNum)
    DEFINE _ordNum LIKE orders.order_num
    
    WHENEVER ERROR CONTINUE
    UPDATE orders SET (ship_date, ship_instruct, ship_weight, ship_charge) = (_grShip.ship_date, _grShip.ship_instruct, _grShip.ship_weight, _grShip.ship_charge)
    WHERE order_num = _ordNum
    WHENEVER ERROR STOP
    RETURN (STATUS)
END FUNCTION -- updOrder --

FUNCTION inputShip()
	DISPLAY _grCharges.order_total TO order_amount
	IF _grCharges.ship_charge IS NULL 
	THEN 
		LET _grCharges.ship_charge = 0.00
	END IF
	
	LET _grShip.ship_charge = _grCharges.ship_charge
	LET _grCharges.order_total = _grCharges.order_total + _grCharges.ship_charge;
	
	INPUT BY NAME _grShip.ship_date, _grShip.ship_instruct, _grShip.ship_weight, _grShip.ship_charge WITHOUT DEFAULTS
		BEFORE FIELD ship_date
			IF _grShip.ship_date IS NULL
			THEN
				LET _grShip.ship_date = TODAY
			END IF
		AFTER FIELD ship_date
			IF _grShip.ship_date IS NULL
			THEN
				LET _grShip.ship_date = TODAY
				DISPLAY BY NAME _grShip.ship_date
			END IF
		BEFORE FIELD ship_weight
			IF _grShip.ship_weight IS NULL
			THEN
				LET _grShip.ship_weight = 0.00
			END IF
		AFTER FIELD ship_weight
			IF _grShip.ship_weight IS NULL
			THEN
				LET _grShip.ship_weight = 0.00
				DISPLAY BY NAME _grShip.ship_weight
			END IF
			
			IF _grShip.ship_weight < 0.00 
			THEN
				ERROR "Shipping Weight cannot be less than 0.00 lbs. Please try again."
				LET _grShip.ship_weight = 0.00
				NEXT FIELD ship_weight
			END IF
		BEFORE FIELD ship_charge
			IF _grShip.ship_charge = 0.00 
			THEN
				LET _grShip.ship_charge = 1.5 * _grShip.ship_weight
			END IF
		AFTER FIELD ship_charge
			IF _grShip.ship_charge IS NULL
			THEN
				LET _grShip.ship_charge = 0.00
				DISPLAY BY NAME _grShip.ship_charge
			END IF
			IF _grShip.ship_charge < 0.00
			THEN
				ERROR "Shipping Charge cannot be less than $0.00. Please try again."
				NEXT FIELD ship_charge
			END IF
			LET _grCharges.order_total = _grCharges.order_total + _grShip.ship_charge
			DISPLAY BY NAME _grCharges.order_total
	END INPUT
	
	IF INT_FLAG 
	THEN 
		LET INT_FLAG = FALSE
		CALL msg("Shipping input terminated.")
		RETURN (FALSE)
	END IF 
	
	RETURN (TRUE)
END FUNCTION

FUNCTION msg(_str)
    DEFINE _str CHAR(78)
    MESSAGE _str
    SLEEP 3
    MESSAGE ""
END FUNCTION -- msg --

FUNCTION messageWindow(x,y)
    DEFINE _numRows SMALLINT,
        x,y SMALLINT,
        _rowNum,i SMALLINT,
        _answer CHAR(1),
        _arraySz SMALLINT -- size of the _message array

    LET _arraySz = 5
    LET _numRows = 4 -- * _numRows value:
 -- * 1 (for the window header)
 -- * 1 (for the window border)
 -- * 1 (for the empty line before
 -- * the first line of message)
 -- * 1 (for the empty line after
 -- * the last line of message)
 
    FOR i = 1 TO _arraySz
        IF _message[i] IS NOT NULL 
        THEN
            LET _numRows = _numRows + 1
        END IF
    END FOR
    
    OPEN WINDOW _wMsg AT x, y WITH _numRows ROWS, 52 COLUMNS ATTRIBUTE (BORDER, PROMPT LINE LAST)
    DISPLAY " APPLICATION MESSAGE" AT 1, 17
    ATTRIBUTE (REVERSE, BLUE)
    LET _rowNum = 3 -- * start text display at third line
    
    FOR i = 1 TO _arraySz
        IF _message[i] IS NOT NULL 
        THEN
            DISPLAY _message[i] CLIPPED AT _rowNum, 2
            LET _rowNum = _rowNum + 1
        END IF
    END FOR
    
    PROMPT " Press RETURN to continue." FOR _answer
    
    CLOSE WINDOW _wMsg
    CALL initMsgs()
END FUNCTION -- messageWindow --

FUNCTION initMsgs()
 	DEFINE i SMALLINT

 	FOR i = 1 TO 5
 		LET _message[i] = NULL
 	END FOR
END FUNCTION -- initMsgs --

FUNCTION clearLines(_numLines, _mRows)
 	DEFINE _numLines SMALLINT,
 			_mRows SMALLINT,
 			i SMALLINT

 	FOR i = 1 TO _numLines
 		DISPLAY " " AT _mRows,1
 		LET _mRows = _mRows + 1
	END FOR
END FUNCTION -- clearLines --

FUNCTION taxRates(_stateCode)
 DEFINE _stateCode LIKE state.code,
    _taxRate DECIMAL(4,2)
    CASE _stateCode[1]
    WHEN "A"
        CASE _stateCode
        WHEN "AK"
            LET _taxRate = 0.0
        WHEN "AL"
            LET _taxRate = 0.0
        WHEN "AR"
            LET _taxRate = 0.0
        WHEN "AZ"
            LET _taxRate = 5.5
        END CASE
    WHEN "C"
        CASE _stateCode
        WHEN "CA"
            LET _taxRate = 6.5
        WHEN "CO"
            LET _taxRate = 3.7
        WHEN "CT"
            LET _taxRate = 8.0
        END CASE
    WHEN "D"
        LET _taxRate = 0.0
    OTHERWISE
        LET _taxRate = 0.0
    END CASE
RETURN (_taxRate)
END FUNCTION -- tax_rates --
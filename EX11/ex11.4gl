DATABASE test4gl
GLOBALS
    DEFINE _grCustomer RECORD LIKE customer.*,
            _grOrders RECORD
                        order_num LIKE orders.order_num,
                        order_date LIKE orders.order_date,
                        po_num LIKE orders.po_num,
                        order_amount MONEY(8,2),
                        order_total MONEY(10,2)
                    END RECORD,
            _gaItems ARRAY[10] OF RECORD
                        item_num LIKE items.item_num,
                        stock_num LIKE items.stock_num,
                        manu_code LIKE items.manu_code,
                        description LIKE stock.description,
                        quantity LIKE items.quantity,
                        unit_price LIKE stock.unit_price,
                        total_price LIKE items.total_price
                    END RECORD,
            _grCharges RECORD
                        tax_rateDECIMAL(5,3),
                        ship_chargeLIKE orders.ship_charge,
                        sales_taxMONEY(9),
                        order_totalMONEY(11)
                    END RECORD,
            _grShip RECORD
                        ship_date LIKE orders.ship_date,
                        ship_instruct LIKE orders.ship_instruct,
                        ship_weight LIKE orders.ship_weight,
                        ship_charge LIKE orders.ship_charge
                    END RECORD
# used by init_msgs(), message_window(), and prompt_window() to allow
# user to display text in a message or prompt window.
    DEFINE _message ARRAY[5] OF CHAR(48)
END GLOBALS

MAIN
    OPTIONS
        FORM LINE 2,
        COMMENT LINE 1,
        MESSAGE LINE LAST
    DEFER INTERRUPT

    OPEN WINDOW _wMain AT 2, 3 WITH 18 ROWS, 76 COLUMNS ATTRIBUTE (BORDER)
    OPEN FORM _frmOrders FORM "f_orders"
    DISPLAY FORM _frmOrders

    CALL addOrder()
    CLOSE FORM _frmOrders
    CLOSE WINDOW _wMain
    CLEAR SCREEN
END MAIN

FUNCTION addOrder(parametros)
    INITIALIZE _grOrders.* TO NULL

    DISPLAY "ORDER ADD" AT 2, 34
    CALL clearLines(2, 16)
    DISPLAY "Press Cancel to exit without saving." AT 17, 1 ATTRIBUTE(REVERSE, YELLOW)

    IF inputCust()
    THEN
        IF inputOrders()
        THEN
            IF inputItems()
            THEN
                CALL dsplyTaxes()
                IF promptWindow("Do you want to ship this order now?", 8, 12)
                THEN
                    CALL shipOrder()
                ELSE
                    LET _grShip.ship_date = NULL
                END IF

                CALL clearLines(2, 16)
                LET _message[1] = "Order entry complete."
                IF promptWindow("Are you ready to save this order?", 8, 12)
                THEN
                    IF orderTx()
                    THEN
                        CALL clearLines(2, 16)
                        LET _message[1] = "Order Number: ", _grOrders.order_num USING "<<<<<<<<<<<"
                        LET _message[2] = " has been placed for Customer: ", _grCustomer.customer_num USING "<<<<<<<<<<<"
                        LET _message[3] = "Order date: ", _grOrders.order_date
                        CALL messageWindow(9, 13)
                        CLEAR FORM
                    END IF
                ELSE
                    CLEAR FORM
                    CALL msg("Order has been terminated.")
                END IF
            END IF
        END IF
    END IF
END FUNCTION

FUNCTION inputCust()
	DISPLAY " Enter the Customer number and press Return. Press CTRL-W for Help." AT 16, 1 ATTRIBUTE (REVERSE, YELLOW)
	
	LET INT_FLAG = FALSE
	INPUT BY NAME _grCustomer.customer_num
	BEFORE FIELD customer_num
		MESSAGE "Enter a customer number or press F5 (CTRL-F) for a list."
	AFTER FIELD customer_num
		IF _grCustomer.customer_num IS NULL
		THEN 
			ERROR "You must enter a customer number. Please try again."
			NEXT FIELD customer_num
		END IF
		DISPLAY BY NAME _grCustomer.company
		MESSAGE ""
		EXIT INPUT
	ON KEY (CONTROL-F, F5)
		IF INFIELD(customer_num)
		THEN
			CALL custPopup() RETURNING _grCustomer.customer_num, _grCustomer.company
			IF _grCustomer.customer_num IS NULL
			THEN
				NEXT FIELD customer_num
			ELSE
				SELECT state 
				INTO _grCustomer.state
				FROM customer
				WHERE customer_num = _grCustomer.customer_num
				DISPLAY BY NAME _grCustomer.customer_num, _grCustomer.company
			END IF
		END IF
	END INPUT
	
	IF INT_FLAG
	THEN
		LET INT_FLAG = FALSE
		CALL clearLines(2, 16)
		CLEAR FORM
		CALL msg("Order input terminated.")
		RETURN (FALSE)
	END IF
	RETURN (TRUE)
END FUNCTION

FUNCTION custPopup()
	DEFINE _paCust ARRAY[200] OF RECORD
					customer_num LIKE customer.customer_num,
					company LIKE customer.company
					END RECORD,
	_idx INTEGER,
	_arraySz SMALLINT,
	_custCnt SMALLINT,
	_overSize SMALLINT
	
	LET _arraySz = 200
	OPEN WINDOW _wCustPop AT 7, 5 WITH 12 ROWS, 44 COLUMNS ATTRIBUTE(BORDER, FORM LINE 4)
	OPEN FORM _frmCustSel FROM "f_custsel"
	DISPLAY FORM _frmCustSel
	DISPLAY "Move cursor using F3, F4, and arrow keys." AT 1, 2
	DISPLAY "Press Accept to select 1 company." AT 2, 2
	
	DECLARE _cCustpop CURSOR FOR 
	SELECT customer_num, company
	FROM customer
	ORDER BY customer_num
	
	LET  _overSize = FALSE
	LET _custCnt = 1
	FOREACH _cCustpop INTO _paCust[_custCnt].*
		LET _custCnt = _custCnt + 1
		IF _custCnt > _arraySz 
		THEN
			LET _overSize = TRUE
			EXIT FOREACH
		END IF
	END FOREACH
	IF _custCnt = 1 
	THEN
		CALL msg("No customer exists in the database.")
		LET _idx = 1
		LET _paCust[_idx].customer_num = NULL
	ELSE
		IF _overSize 
		THEN
			MESSAGE "Customer array full: can only display ", _arraySz USING "<<<<<<"
		END IF
		
		CALL SET_COUNT(_custCnt - 1)
		LET INT_FLAG = FALSE
		DISPLAY ARRAY _paCust TO _saCust.*
		
		LET _idx = ARR_CURR()
		IF INT_FLAG 
		THEN
			LET INT_FLAG =  FALSE
			CLEAR FORM
			CALL msg("No customer selected.")
			LET _paCust[_idx].customer_num = NULL
		END IF
	END IF
	CLOSE WINDOW _wCustPop
	RETURN _paCust[_idx].customer_num, _paCust[_idx].company
END FUNCTION

FUNCTION inputCust()
	CALL clearLines(1, 16)
	DISPLAY " Enter the order information and press RETURN. Press CTRL-W for help." AT 16, 1 ATTRIBUTE(REVERSE, YELLOW)
	
	LET INT_FLAG = FALSE
	INPUT BY NAME _grOrders.order_date , _grOrders.po_num
		BEFORE  FIELD order_date
			IF _grOrders.order_date IS NULL
			THEN 
				LET _grOrders.order_date = TODAY
			END IF
		AFTER FIELD order_date
			IF _grOrders.order_date IS NULL
			THEN
				LET _grOrders.order_date = TODAY
			END IF
	END INPUT
	
	IF INT_FLAG
	THEN
		LET INT_FLAG = FALSE
		CALL clearLines(2, 16)
		CLEAR FORM
		CALL msg("Order input terminated.")
		RETURN (FALSE)
	END IF
	
	RETURN (TRUE)
END FUNCTION

FUNCTION intputItems()
	DEFINE _currPa INTEGER,
					_currSa INTEGER,
					_stockCnt INTEGER,
					stock_item LIKE stock.stock_item,
					_popup SMALLINT,
					_keyval INTEGER,
					_validKey SMALLINT
					
					
	CALL clearLines(1, 16)
	DISPLAY " Enter the item information and press Accept. Press CTRL-W for help." AT 16, 1 ATTRIBUTE(REVERSE, YELLOW)
	LET INT_FLAG = FALSE
	
	INPUT ARRAY _gaItems FROM _saItems.*
		BEFORE ROWID
			LET _currPa = ARR_COUNT()
			LET _currSa = SCR_LINE()
		BEFORE INSERT
			CALL renumItems()
		BEFORE FIELD stock_num
			MESSAGE "Enter a stock number or [ress F5 (CTRL-F) for a list."
			LET _popup = FALSE
		AFTER FIELD stock_num
			IF _gaItems[_currPa].stock_num IS NULL
			THEN
				LET _keyval = FGL_LASTKEY()
				IF _keyval = FGL_KEYVAL("accept")
				THEN 
					IF _currPa = 1 
					THEN
						LET INT_FLAG = TRUE
						EXIT INPUT
					END IF
				ELSE
					LET _validKey = (_keyval = FGL_KEYVAL("up")) OR (_keyval = FGL_KEYVAL("prevpage"))
					IF NOT _validKey
					THEN
						ERROR "You must enter a stock number. Please try again."
						NEXT FIELD stock_num
					END IF
				END IF
						
END FUNCTION
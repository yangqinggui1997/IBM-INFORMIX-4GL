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
			ELSE --* stock number is not null, continue
 				IF NOT _popup 
				THEN
 					LET _stockCnt = 0
 					SELECT COUNT(*)
 					INTO _stockCnt
 					FROM stock
 					WHERE stock_num = _gaItems[_currPa].stock_num
 					
					IF (_stockCnt = 0) 
					THEN
 						ERROR "Unknown stock number. Use F5 (CTRL-F) to see valid stock numbers."
 						LET _gaItems[_currPa].stock_num = NULL
 						NEXT FIELD stock_num
 					END IF
 				END IF
 			END IF
 			MESSAGE ""
		BEFORE FIELD manu_code
 			MESSAGE "Enter the manufacturer code or press F5 (CTRL-F) for a list."
		AFTER FIELD manu_code
 			IF _gaItems[_currPa].manu_code IS NULL 
			THEN
 				ERROR "You must enter a manufacturer code. Use F5 (CTRL-F) to see valid codes."
 				LET _gaItems[_currPa].manu_code = NULL
 				NEXT FIELD manu_code
			ELSE
	 			IF NOT _popup 
				THEN
 					SELECT description, unit_price
 					INTO _gaItems[_currPa].description, _gaItems[_currPa].unit_price
 					FROM stock
 					WHERE stock_num = _gaItems[_currPa].stock_num AND manu_code = _gaItems[_currPa].manu_code
 					
					IF (STATUS = NOTFOUND) 
					THEN
 						ERROR "Unknown manuf code for this stock number. Use F5 (CTRL-F) to see valid codes."
						LET _gaItems[_currPa].manu_code = NULL
 						NEXT FIELD manu_code
 					END IF
					
					DISPLAY _gaItems[_currPa].description, _gaItems[_currPa].unit_price TO _saItems[_currSa].description, _saItems[_currSa].unit_price
 					MESSAGE ""
 					NEXT FIELD quantity
 				END IF
 			END IF
 			MESSAGE ""	
		BEFORE FIELD quantity
 			IF _gaItems[_currPa].quantity IS NULL 
			THEN
 				LET _gaItems[_currPa].quantity = 1
 			END IF
		AFTER FIELD quantity
 			IF _gaItems[_currPa].quantity IS NULL OR _gaItems[_currPa].quantity < 0
 			THEN
 				ERROR "Quantity must be greater than 0. Please try again."
 				NEXT FIELD quantity
 			END IF
 			
			LET _gaItems[_currPa].total_price = _gaItems[_currPa].quantity * _gaItems[_currPa].unit_price
 			DISPLAY _gaItems[_currPa].total_price TO _saItems[_currSa].total_price
			CALL orderAmount() RETURNING _grOrders.order_amount
 			DISPLAY BY NAME _grOrders.order_amount
		AFTER INSERT
 			CALL orderAmount() RETURNING _grOrders.order_amount
 			DISPLAY BY NAME _grOrders.order_amount
		AFTER DELETE
 			CALL renumItems()
 			CALL orderAmount() RETURNING _grOrders.order_amount
 			DISPLAY BY NAME _grOrders.order_amount
 		AFTER INPUT
 			CALL clearLines(1, 16)
 			MESSAGE ""
		ON KEY (CONTROL-F, F5)
 			IF INFIELD(stock_num) OR INFIELD(manu_code) 
			THEN
				IF INFIELD(stock_num) 
				THEN
 					LET stock_item = NULL
 				ELSE
 					LET stock_item = _gaItems[_currPa].stock_num
 				END IF
 				CALL stockPopup(stock_item) RETURNING _gaItems[_currPa].stock_num, _gaItems[_currPa].manu_code, _gaItems[_currPa].description, _gaItems[_currPa].unit_price
				
				IF _gaItems[_currPa].stock_num IS NULL 
				THEN
 					NEXT FIELD stock_num
 				ELSE
 					IF _gaItems[_currPa].manu_code IS NULL 
					THEN
 						NEXT FIELD manu_code
 					END IF
 				END IF
				
				DISPLAY _gaItems[_currPa].stock_num TO _saItems[_currSa].stock_num
 				DISPLAY _gaItems[_currPa].manu_code TO _saItems[_currSa].manu_code
 				DISPLAY _gaItems[_currPa].description TO _saItems[_currSa].description
 				DISPLAY _gaItems[_currPa].unit_price TO _saItems[_currSa].unit_price
 				NEXT FIELD quantity
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
END FUNCTION -- input_items --

FUNCTION
	DEFINE _pCurr INTEGER,
				_pTotal INTEGER,
				_sCurr INTEGER,
				_sTotal INTEGER,
				_k INTEGER
	
	LET _pCurr = ARR_CURR()
	LET _pTotal = ARR_COUNT()
	LET _sCurr = SCR_LINE()
	LET _sTotal = 4
	
	FOR _k = _pCurr TO _pTotal
		LET _gaItems[k].item_num = _k
		IF _sCurr <= _sTotal
		THEN
			DISPLAY _k TO _saItems[_sCurr].item_num
			LET _sCurr = _sCurr + 1
		END IF
	END FOR
END FUNCTION

FUNCTION stockPopup(_stockItem)
	DEFINE _paStock ARRAY[200] OF RECORD
				stock_num LIKE stock.stock_num,
				description LIKE stock.description,
				manu_code LIKE stock.manu_code,
				manu_name LIKE manufact.manu_name,
				unit LIKE stock.unit,
				unit_price LIKE stock.unit_price
			END RECORD,
		_idx INTEGER,
		_stockCnt INTEGER,
		_stStock CHAR(300),
		_arraySz SMALLINT,
		_overSize SMALLINT
		
		LET _arraySz = 200
		OPEN WINDOW _wStockPop AT 7, 4 WITH 12 ROWS, 73 COLUMNS ATTRIBUTE (BORDER, FROM LINE 4)
		OPEN FORM _frmStockSel FROM "f_stocksel"
		DISPLAY FORM _frmStockSel 
		
		DISPLAY "Move cursor using F3, F4, and arrow keys." AT 1, 200
		DISPLAY "Press Accept to select a stock item." AT 2,2
		
		LET _stStock = "SELECT stock_num, description, stock.manu_code, manufact.manu_name, unit, unit_price FROM stock, manufact"
		
		IF _stockItem IS NOT NULL
		THEN
			LET _stStock = _stStock CLIPPED, " WHERE stock_num = ", stock_item, " AND stock.manu_code = manufact.manu_code ORDER BY 1, 3"
		ELSE
			LET _stStock = _stStock CLIPPED, " WHERE stock.manu_code = manufact.manu_code ORDER BY 1, 3"
		END IF
		
		PREPARE _preapareCursor FROM _stStock
		DECLARE _cursorStock SCROLL CURSOR FOR _preapareCursor
		
		LET _overSize  = FALSE
		LET _stockCnt = 1
		
		FOREACH _cursorStock INTO _paStock[_stockCnt].*
			LET _stockCnt = _stockCnt + 1
			IF _stockCnt > _arraySz
			THEN
				LET _overSize = TRUE
				EXIT FOREACH
			END IF
		END FOREACH
		
		IF _stockCnt = 1
		THEN
			CALL msg("No stock data in the database.")
			LET _idx = 10LET _paStock[_idx].stock_num = NULL
		ELSE
			IF _overSize
			THEN
				MESSAGE "Stock array full: can only display.", _arraySz USING "<<<<<<"
			END IF
			CALL SET_COUNT(_stockCnt -1)
			LET INT_FLAG = FALSE
			DISPLAY ARRAY _paStock TO _saStock.*
			LET _idx =ARR_CURR()
			
			IF INT_FLAG
			THEN 
				LET INT_FLAG = FALSE
				CLEAR FORM
				CALL msg("No stock item selected.")
				LET _paStock[_idx].manu_code = NULL
				IF _stockItem IS NULL
				THEN
					LET _stockItem[_idx].stock_num = NULL
				END IF
			END IF
		END IF
		CLOSE WINDOW _wStockPop
		RETURN _paStock[_idx].stock_num, _paStock[_idx].manu_code, _paStock[_idx].description, _paStock[_idx].unit_price
END FUNCTION  -- stock_popup --

FUNCTION dsplyTaxes()
	LET _grCharges.tax_rate = taxRates(_grCustomer.state)
	DISPLAY _grCustomer.state TO code
	DISPLAY BY NAME _grCharges.tax_rate
	LET _grCharges.sales_tax = _grOrders.order_amount * (_grCharges.tax_rate / 100)
	DISPLAY BY NAME _grCharges.sales_tax
	
	LET _grCharges.order_total = _grOrders.orderAmount + _grCharges.sales_tax
	
	DISPLAY BY NAME _grCharges.order_total
END FUNCTION -- dsply_taxes --

FUNCTION orderAmount()
	DEFINE _ordAmount MONEY(8),
					_idx INTEGER
		
	FOR _idx = 1 TO ARR_COUNT()
		IF _gaItems[_idx].total_price IS NOT NULL
		THEN
			LET _ordAmount = _ordAmount + _gaItems[_idx].total_price
		END IF
	END FOREACH
	
	RETURN (_ordAmount)
END FUNCTION

FUNCTION shipOrder()
	CALL clearLines(1,1)
	OPEN WIN _wShip AT 7, 6 WITH FORM "f_ship" ATTRIBUTE (BORDER, COMMENT LINE 3, PROMPT LINE 4)
	DISPLAY "Press Accept to save shiping information." AT 1, 1 ATTRIBUTE (REVERSE, YELLOW)
	DISPLAY " Press Cancle to exit w/out saving. Press CTRL-W for Help." AT 2,1 ATTRIBUTE (REVERSE, YELLOW)
	
	DISPLAY BY NAME _grOrders.order_num, _grOrders.order_date, _grCustomer.customer_num, _grCustomer.company
	
	INITIALIZE _grShip.* TO NULL
	IF inputShip()
	THEN
		CALL msg("Shipping information entered.")
	END IF
	CLOSE WINDOW _wShip
END FUNCTION -- ship_order --

FUNCTION inputShip()
	DISPLAY _grCharges.order_total TO order_amount
	IF _grCharges.ship_charge IS NULL 
	THEN 
		LET _grCharges.ship_charge = 0.00
	END IF
	
	LET _grShip.ship_charge = _grCharges.ship_charge
	LET _grCharges.order_total = _grCharges.order_total + _grCharges.ship_charge;
	
	DISPLAY BY NAME _grShip.ship_date, _grShip.ship_instruct, _grShip.ship_weight, _grShip.ship_charge WITHOUT DEFAULTS
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
				DISPLAY BY NAME _gr.ship_weight
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

FUNCTION orderTx()
	DEFINE _txStat INTEGER,
				_txTable CHAR(5)
	
	BEGIN WORK
		LET _txTable = "order"
		LET _txStat = insertOrder()
		IF (_txStat = 0)
		THEN
			LET _txTable = "items"
			LET _txStat = insertItems()
		END IF
		
		IF (_txStat < 0)
		THEN
			ROLLBACK WORK
			ERROR _txStat USING "-<<<<<<<<<<<", ": Unable to save order: ", _txTable, " insert failed."
			RETURN (FALSE)
		END IF	
	COMMIT WORK
	RETURN (TRUE)		
END FUNCTION -- order_tx --
FUNCTION insertOrder()
	DEFINE _insStat INTEGER
	
	LET _insStat = 00
	WHENEVER ERROR CONTINUE
	INSERT INTO orders (order_num, order_date, customer_num, po_num, ship_date, ship_instruct, ship_weight, ship_charge) VALUES(0, _grOrders.order_date, _grCustomer.customer_num, _grOrders. po_num, _grShip.ship_date, _grShip.ship_instruct, _grOrders.ship_weight, _grOrders.ship_charge)
	WHENEVER ERROR STOP
	IF STATUS < 0
	THEN
		LET _insStat = STATUS
	ELSE
		LET _grOrders.order_num = SQLCA.SQLERRD[2]
		DISPLAY BY NAME _grOrders.order_num ATTRIBUTE (REVERSE, BLUE)
	END IF
	RETURN (_insStat)
END FUNCTION -- insert_order --

FUNCTION insert_order()
	DEFINE _idx INTEGER,
			_insStat INTEGER
	
	LET _insStat = 00
	
	FOR _idx = 1 TO ARR_COUNT()
		IF _gaItems[_idx].stock_num IS NOT NULL
		THEN
			WHENEVER ERROR CONTINUE
			INSERT INTO items VALUES (_gaItems[_idx].item_num, _grOrders.order_num, _gaItems[_idx].stock_num, _gaItems[_idx].manu_code, _gaItems[_idx].quantity, _gaItems[_idx].total_price)
			WHENEVER ERROR STOP
		
			IF STATUS < 0
			THEN
				LET _insStat = STATUS
				EXIT FOR
			END IF
		END IF
	END FOR
	RETURN (_insStat)	
END FUNCTION
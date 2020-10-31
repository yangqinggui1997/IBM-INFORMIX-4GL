DATABASE test4gl
GLOBALS
	DEFINE _custSumRecord RECORD
					customer_num LIKE customer.customer_num,
					company LIKE customer.company,
					_unpaidOrders SMALLINT,
					_amountDue MONEY(11),
					_openCalls SMALLINT
	END RECORD 
	DEFINE _message ARRAY[5] OF CHAR(100)
END GLOBALS

MAIN
	OPTIONS
		INPUT ATTRIBUTE (REVERSE, BLUE),
		PROMPT LINE 13,
		MESSAGE LINE LAST
	CALL custSummary()
END MAIN

FUNCTION custSummary()
	DEFINE _searchAgain SMALLINT
	LET _searchAgain = TRUE
	WHILE _searchAgain
		CALL getCustNum() RETURNING _custSumRecord.customer_num
		CALL displySummary() RETURNING _searchAgain
	END WHILE
	CLEAR SCREEN
END FUNCTION

FUNCTION getCustNum()
	DEFINE _custNum INTEGER,
					_custCount SMALLINT
	OPEN FORM _frmCustkey FROM "f_custkey"
	DISPLAY FORM _frmCustkey
	DISPLAY " " AT 2, 30
	DISPLAY " CUSTOMER KEY LOOKUP" AT 2,20
	DISPLAY " Enter customer number and press Accept." AT 5,1 ATTRIBUTE (REVERSE, YELLOW)

	INPUT _custNum FROM customer_num
		AFTER FIELD customer_num
			IF _custNum IS NULL 
			THEN
				ERROR "You must enter a customer number. Please try again."
				SLEEP 5
				NEXT FIELD customer_num
			END IF
			SELECT COUNT(*) INTO _custCount FROM customer WHERE customer_num = _custNum
			IF _custCount == 0
			THEN
				ERROR "Unknown customer number. Please try again."
				LET _custNum = 0
				NEXT FIELD customer_num
			END IF
	END INPUT
	CLOSE FORM _frmCustkey
	RETURN _custNum
END FUNCTION

FUNCTION getSummary()
	DEFINE _custSate LIKE state.code,
					_itemTotal MONEY(12),
					_shipTotal MONEY(7),
					_salesTax MONEY(9),
					_taxRate DECIMAL(5,3)
	
	SELECT company, state
	INTO _custSumRecord.company, _custSate
	FROM customer
	WHERE customer_num = _custSumRecord.customer_num
	
	SELECT COUNT(*)
	INTO _custSumRecord._unpaidOrders
	FROM orders
	WHERE customer_num = _custSumRecord.customer_num AND paid_date IS NULL
	
	IF _custSumRecord._unpaidOrders > 0 
	THEN
		SELECT SUM(total_price)
		INTO _itemTotal
		FROM items, orders
		WHERE orders.order_num = items.order_num AND customer_num = _custSumRecord.customer_num AND paid_date IS NULL
		
		SELECT SUM(ship_charge)
		INTO _shipTotal
		FROM orders
		WHERE customer_num = _custSumRecord.customer_num AND paid_date IS NULL
		
		LET _taxRate = 0.00
		CALL getTaxRate(_custSate) RETURNING _taxRate
		LET _salesTax = _itemTotal * (_taxRate + _shipTotal)
		LET _custSumRecord._amountDue = _itemTotal + _salesTax + _shipTotal
	ELSE
		LET _custSumRecord._amountDue = 0.00
	END IF
		
	SELECT COUNT(*)
	INTO _custSumRecord._openCalls
	FROM cust_calls
	WHERE customer_num = _custSumRecord.customer_num AND res_dtime IS NULL
END FUNCTION

FUNCTION displySummary()
	DEFINE _getMore SMALLINT
	
	{OPEN FORM _frmcustomer FROM "f_custsum"
	DISPLAY FORM _frmcustomer}
	DISPLAY " " AT 2, 20
	CALL getSummary()
	#DISPLAY BY NAME _custSumRecord.*
	LET _message[1] = "Customer summary for customer ", _custSumRecord.customer_num CLIPPED USING "<<<<<<<<<<<"
	LET _message[2] = " (", _custSumRecord.company CLIPPED, ") complete."
	LET _getMore = TRUE
	IF NOT promptWindow("Do you want to see another summary?", 14, 25)
	THEN
		LET _getMore = FALSE
	END IF
	RETURN (_getMore)
END FUNCTION

FUNCTION getTaxRate(_stateCode)
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
 	LET _taxRate = 0.0 -- * tax rate for "DE"
 OTHERWISE
 	LET _taxRate = 0.0
 END CASE
 
 RETURN (_taxRate)
END FUNCTION

FUNCTION promptWindow(question, x, y)
	{DEFINE _question CHAR(48),
	_x,_y SMALLINT,
	_numRows SMALLINT,
	_rowNum, _i SMALLINT,
	_answer CHAR(1),
	_yesAns SMALLINT,
	_nyAdded SMALLINT,
	_invalidResp SMALLINT,
	_quesLngth SMALLINT,
	_upOpen SMALLINT,
	_arraySz SMALLINT,
	_localStat SMALLINT
	
	LET _arraySz = 5
	LET _numRows = 4
	FOR _i = 1 TO _arraySz
		IF _message[_i] IS NOT NULL
		THEN
			LET _numRows = _numRows + 1
		END IF
	END FOR
	
	LET _upOpen = TRUE
	
	WHILE _upOpen
		WHENEVER ERROR CONTINUE
		OPEN WINDOW _wPrompt AT _x,_y WITH _numRows ROWS, 52 COLUMNS
		ATTRIBUTE (BORDER, PROMPT LINE LAST)
		WHENEVER ERROR STOP
		LET _localStat = STATUS
		IF _localStat < 0
		THEN 
			IF _localStat == -1138 OR _localStat == -1114
			THEN
				MESSAGE "promtWindow() error: changing coodinates to 3,3."
				SLEEP 2
				LET _X = _y = 3
			ELSE
				MESSAGE "promtWindow() error: ", _localStat USING "-<<<<<<<<<<"
				SLEEP 2
				EXIT PROGRAM
			END IF
		ELSE
			LET _upOpen = FALSE
		END IF
	END WHILE
	DISPLAY " APPLICATION PROMPT" AT 1, 17 ATTRIBUTE (REVERSE, BLUE)
	
	LET _rowNum = 3
	FOR _i = 1 TO _arraySz
		IF _message[_i] IS NOT NULL
		THEN
			DISPLAY _message[_i] CLIPPED AT _rowNum, 2
			LET _rowNum = _rowNum + 1
		END IF
	END FOR
	
	LET _yesAns = FALSE
	LET _quesLngth = LENGTH(_question)
	IF _quesLngth < 41
	THEN
		LET _question[_quesLngth + 2, _quesLngth + 7] = "(n/y): "
	END IF
	
	LET _invalidResp = TRUE
	WHILE _invalidResp
		PROMPT _question CLIPPED, " " FOR _answer
		IF _answer MATCHES "[nNyY]"
		THEN
			LET _invalidResp = FALSE
			IF _answer MATCHES "[yY]"
			THEN
				LET _yesAns = TRUE
			END IF
		END IF
	END WHILE
	CALL initMsg()
	CLOSE WINDOW _wPrompt
	RETURN (_yesAns)}
	DEFINE question CHAR(48),
 x,y SMALLINT,
 numrows SMALLINT,
 rownum,i SMALLINT,
 answer CHAR(1),
 _yesAns SMALLINT,
 ny_added SMALLINT,
 _invalidResp SMALLINT,
 _quesLngth SMALLINT,
 unopen SMALLINT,
 array_sz SMALLINT,
 _localStat SMALLINT
 LET array_sz = 5
 LET numrows = 4 -- * numrows value:
 -- * 1 (for the window header)
 -- * 1 (for the window border)
 -- * 1 (for the empty line before
 -- * the first line of message)
 -- * 1 (for the empty line after
 -- * the last line of message)
 FOR i = 1 TO array_sz
 IF _message[i] IS NOT NULL THEN
 LET numrows = numrows + 1
 END IF
 END FOR
 LET unopen = TRUE
 WHILE unopen
 WHENEVER ERROR CONTINUE
 OPEN WINDOW w_prompt AT x, y
 WITH numrows ROWS, 52 COLUMNS
 ATTRIBUTE (BORDER, PROMPT LINE LAST)
WHENEVER ERROR STOP
 LET _localStat = status
 IF (_localStat < 0) THEN
 IF (_localStat = -1138) OR (_localStat = -1144) THEN
 MESSAGE "prompt_window() error: changing coordinates to 3,3."
 SLEEP 2
 LET x = 3
 LET y = 3
 ELSE
 MESSAGE "prompt_window() error: ", _localStat USING "-<<<<<<<<<<<"
 SLEEP 2
 EXIT PROGRAM
 END IF
 ELSE
 LET unopen = FALSE
 END IF
 END WHILE
 DISPLAY " APPLICATION PROMPT" AT 1, 17
 ATTRIBUTE (REVERSE, BLUE)
 LET rownum = 3 -- * start text display at third line
 FOR i = 1 TO array_sz
 IF _message[i] IS NOT NULL THEN
 DISPLAY _message[i] CLIPPED AT rownum, 2
 LET rownum = rownum + 1
 END IF
 END FOR
 LET _yesAns = FALSE
 LET _quesLngth = LENGTH(question)
 IF _quesLngth <= 41 THEN -- * room enough to add "(n/y)" string
 LET question [_quesLngth + 2, _quesLngth + 7] = "(n/y):"
 END IF
 LET _invalidResp = TRUE
 WHILE _invalidResp
 PROMPT question CLIPPED, " " FOR answer
 IF answer MATCHES "[nNyY]" THEN
 LET _invalidResp = FALSE
 IF answer MATCHES "[yY]" THEN
 LET _yesAns = TRUE
 END IF
 END IF
 END WHILE
 CALL initMsg()
 CLOSE WINDOW w_prompt
 RETURN (_yesAns)
END FUNCTION

FUNCTION initMsg()
	DEFINE _i SMALLINT
	
	FOR _i = 1 TO 5
		LET _message[_i] = NULL
	END FOR
END FUNCTION
				
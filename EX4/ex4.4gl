DATABASE test4gl
GLOBALS
    DEFINE _grCustSum RECORD
            customer_num LIKE customer.customer_num,
            company LIKE customer.company,
            unpaid_ords SMALLINT,
            amount_due MONEY(11),
            open_calls SMALLINT
    END RECORD
    DEFINE _gaDsplymsg ARRAY[5] OF CHAR(100)
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
        CALL getCustnum() RETURNING _grCustSum.customer_num
        CALL dsplySummary() RETURNING _searchAgain
    END WHILE

    CLEAR SCREEN
END FUNCTION

FUNCTION getCustnum()
    DEFINE _custNum INTEGER,
        _custCnt SMALLINT

    OPEN FORM _frmCustkey FROM "f_custkey"
    DISPLAY FORM _frmCustkey

    DISPLAY " " AT 2, 30    
    DISPLAY "CUSTOMER KEY LOOKUP" AT 2, 20
    DISPLAY " Enter customer number and press Accept." AT 4, 1 ATTRIBUTE (REVERSE, YELLOW)
    
    INPUT _custNum FROM customer_num 
        AFTER FIELD customer_num
            IF _custNum IS NULL 
            THEN
                ERROR "You must enter a customer number. Please try again."
                NEXT FIELD customer_num
            END IF
            SELECT COUNT(*)
            INTO _custCnt
            FROM customer
            WHERE customer_num = _custNum
            IF (_custCnt = 0) THEN
                ERROR "Unknown customer number. Please try again."
                LET _custNum = NULL
                NEXT FIELD customer_num
            END IF
            END INPUT
    CLOSE FORM _frmCustkey
    RETURN (_custNum)
END FUNCTION -- getCustnum --

FUNCTION getSummary()
    DEFINE _custState LIKE state.code,
            _itemTotal MONEY(12),
            _shipTotal MONEY(7),
            _salesTax MONEY(9),
            _taxRate DECIMAL(5,3)
--* Get customer's company name and state (for later tax evaluation)
    SELECT company, state
    INTO _grCustSum.company, _custState
    FROM customer
    WHERE customer_num = _grCustSum.customer_num
--* Calculate number of unpaid orders for customer
    SELECT COUNT(*)
    INTO _grCustSum.unpaid_ords
    FROM orders
    WHERE customer_num = _grCustSum.customer_num AND paid_date IS NULL
--* If customer has unpaid orders, calculate total amount due
    IF (_grCustSum.unpaid_ords > 0) 
    THEN
        SELECT SUM(total_price)
        INTO _itemTotal
        FROM items, orders
        WHERE orders.order_num = items.order_num
            AND customer_num = _grCustSum.customer_num
            AND paid_date IS NULL

        SELECT SUM(ship_charge)
        INTO _shipTotal
        FROM orders
        WHERE customer_num = _grCustSum.customer_num
            AND paid_date IS NULL

        LET _taxRate = 0.00
        CALL taxRates(_custState) RETURNING _taxRate
        LET _salesTax = _itemTotal * (_taxRate / 100)
        LET _grCustSum.amount_due = _itemTotal + _salesTax + _shipTotal
--* If customer has no unpaid orders, total amount due = $0.00
    ELSE
        LET _grCustSum.amount_due = 0.00
    END IF
 --* Calculate number of open calls for this customer
    SELECT COUNT(*)
    INTO _grCustSum.open_calls
    FROM cust_calls
    WHERE customer_num = _grCustSum.customer_num
        AND res_dtime IS NULL
END FUNCTION -- getSummary --

FUNCTION dsplySummary()
    DEFINE _getMore SMALLINT
    OPEN FORM _fCustSum FROM "f_custsum"

    DISPLAY FORM _fCustSum
    DISPLAY " " AT 2, 20
    CALL getSummary()
    DISPLAY BY NAME _grCustSum.*
 
    LET _gaDsplymsg[1] = "Customer summary for customer ", _grCustSum.customer_num USING "<<<<<<<<<<<"
    LET _gaDsplymsg[2] = " (", _grCustSum.company CLIPPED, ") complete."
    LET _getMore = TRUE
    IF NOT promptWindow("Do you want to see another summary?",14,12)
    THEN
        LET _getMore = FALSE
    END IF
    RETURN _getMore
    CLOSE FORM _fCustSum
END FUNCTION -- dsplySummary --

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
        LET _taxRate = 0.0 -- * tax rate for "DE"
    OTHERWISE
        LET _taxRate = 0.0
    END CASE
    RETURN (_taxRate)
END FUNCTION -- taxRates --

FUNCTION promptWindow(_question, x,y)
    DEFINE _question CHAR(48),
            x,y SMALLINT,
            _numRows SMALLINT,
            _rowNum,i SMALLINT,
            _answer CHAR(1),
            _yesAns SMALLINT,
            _nyAdded SMALLINT,
            _invalidResp SMALLINT,
            _quesLength SMALLINT,
            _uopen SMALLINT,
            _arraySz SMALLINT,
            _localStat SMALLINT

    LET _arraySz = 5
    LET _numRows = 4 -- * _numRows value:
 -- * 1 (for the window header)
 -- * 1 (for the window border)
 -- * 1 (for the empty line before
 -- * the first line of message)
 -- * 1 (for the empty line after
 -- * the last line of message)
    FOR i = 1 TO _arraySz
        IF _gaDsplymsg[i] IS NOT NULL
        THEN
            LET _numRows = _numRows + 1
        END IF
    END FOR

    LET _uopen = TRUE
    WHILE _uopen
        WHENEVER ERROR CONTINUE
        OPEN WINDOW _wPrompt AT x, y WITH _numRows ROWS, 52 COLUMNS ATTRIBUTE (BORDER, PROMPT LINE LAST)
        WHENEVER ERROR STOP
        LET _localStat = status
        IF (_localStat < 0)
        THEN
            IF (_localStat = -1138) OR (_localStat = -1144)
            THEN
                MESSAGE "promptWindow() error: changing coordinates to 3,3."
                SLEEP 2
                LET x = 3
                LET y = 3
            ELSE
                MESSAGE "promptWindow() error: ", _localStat USING "-<<<<<<<<<<<"
                SLEEP 2
                EXIT PROGRAM
            END IF
        ELSE
            LET _uopen = FALSE
        END IF
    END WHILE
    
    DISPLAY " APPLICATION PROMPT" AT 1, 17 ATTRIBUTE (REVERSE, BLUE)

    LET _rowNum = 3 -- * start text display at third line
    FOR i = 1 TO _arraySz
        IF _gaDsplymsg[i] IS NOT NULL
        THEN
            DISPLAY _gaDsplymsg[i] CLIPPED AT _rowNum, 2
            LET _rowNum = _rowNum + 1
        END IF
    END FOR
    
    LET _yesAns = FALSE
    LET _quesLength = LENGTH(_question)
    IF _quesLength <= 41 
    THEN -- * room enough to add "(n/y)" string
        LET _question [_quesLength + 2, _quesLength + 7] = "(n/y):"
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
    CALL initMsgs()
    CLOSE WINDOW _wPrompt
    RETURN (_yesAns)
END FUNCTION -- promptWindow --

FUNCTION initMsgs()
    DEFINE i SMALLINT

    FOR i = 1 TO 5
        LET _gaDsplymsg[i] = NULL
    END FOR
END FUNCTION -- initMsgs --

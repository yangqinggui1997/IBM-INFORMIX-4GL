DATABASE test4gl
GLOBALS
 	DEFINE _grCustomer RECORD LIKE customer.*,
 			_grWorkCust RECORD LIKE customer.*
 	DEFINE _message ARRAY[5] OF CHAR(100)
END GLOBALS

MAIN
 	DEFINE _stCust CHAR(150)

 	OPTIONS
 		HELP FILE "hlpmsgs",
 		FORM LINE 5,
 		COMMENT LINE 5,
 		MESSAGE LINE 19

 	DEFER INTERRUPT
 	OPEN FORM _frmCustomer FROM "../EX5/f_customer"
 	DISPLAY FORM _frmCustomer
 	
	CALL queryCust2() RETURNING _stCust
 	IF _stCust IS NOT NULL
	THEN
 		CALL browseCusts(_stCust)
 	END IF
 	CLOSE FORM _frmCustomer
 	CLEAR SCREEN
END MAIN

FUNCTION queryCust2()
 	DEFINE _qCust CHAR(100),
 			_selstmt CHAR(150)

 	CALL clearLines(1,4)
 	DISPLAY "CUSTOMER QUERY-BY-EXAMPLE 2" AT 4, 24
 	CALL clearLines(2,16)
 	DISPLAY " Enter search criteria and press Accept. Press CTRL-W for Help." AT 16,1 ATTRIBUTE (REVERSE, YELLOW)
 	DISPLAY " Press Cancel to exit w/out searching." AT 17,1 ATTRIBUTE (REVERSE, YELLOW)

 	LET int_flag = FALSE
 	CONSTRUCT BY NAME _qCust ON customer.customer_num, customer.company,
 								customer.address1, customer.address2,
 								customer.city, customer.state,
 								customer.zipcode, customer.fname,
 								customer.lname, customer.phone
 	HELP 30
 	AFTER CONSTRUCT
 	IF (NOT int_flag)
	THEN
 		IF (NOT FIELD_TOUCHED(customer.*))
		THEN
 			LET _message[1] = "You did not enter any search criteria."
 			IF NOT promptWindow("Do you really want to see all rows?", 9, 15)
 			THEN
 				CONTINUE CONSTRUCT
 			END IF
 		END IF
 	END IF
 	END CONSTRUCT
	
 	IF int_flag 
	THEN
 		LET int_flag = FALSE
 		CALL clearLines(2,16)
 		CALL msg("Customer query terminated.")
 		LET _selstmt = NULL
 	ELSE
 		LET _selstmt = "SELECT * FROM customer WHERE ", _qCust CLIPPED
 	END IF
 	CALL clearLines(1,4)
 	CALL clearLines(2,16)
  	RETURN (_selstmt)
END FUNCTION -- queryCust2 --

FUNCTION browseCusts(_selstmt)
 	DEFINE _selstmt CHAR(150),
 			_fndCusts SMALLINT,
 			_endList SMALLINT

 	PREPARE _stSelCust FROM _selstmt
 	DECLARE _cCust CURSOR FOR _stSelCust

 	LET _fndCusts = FALSE
 	LET _endList = FALSE
 	INITIALIZE _grWorkCust.* TO NULL
 	FOREACH _cCust INTO _grCustomer.*
 		LET _fndCusts = TRUE
 		DISPLAY BY NAME _grCustomer.*
 		IF NOT nextAction()
		THEN
 			LET _endList = FALSE
 			EXIT FOREACH
 		ELSE
 			LET _endList = TRUE
 		END IF
 		LET _grWorkCust.* = _grCustomer.*
 	END FOREACH

 	CALL clearLines(2,16)
 	IF NOT _fndCusts
	THEN
 		CALL msg("No customers match search criteria.")
 	END IF
 	IF _endList 
	THEN
 		CALL msg("No more customer rows.")
 	END IF
 	CLEAR FORM
END FUNCTION -- browseCusts --

FUNCTION nextAction()
 	DEFINE _nxtAction SMALLINT

 	CALL clearLines(1,16)
 	LET _nxtAction = TRUE
 	DISPLAY "---------------------------------------Press CTRL-W for Help----------" AT 3, 1
 	
	MENU "CUSTOMER MODIFICATION"
 		COMMAND "Next" "View next selected customer." HELP 20
 			EXIT MENU
 		COMMAND "Update" "Update current customer on screen." HELP 21
 			IF changeCust() 
			THEN
 				CALL updateCust()
 				CALL clearLines(1,16)
 			END IF
 			NEXT OPTION "Next"
 		COMMAND "Delete" "Delete current customer on screen." HELP 22
			CALL deleteCust()
 			IF _grWorkCust.customer_num IS NOT NULL 
			THEN
 				LET _grCustomer.* = _grWorkCust.*
 				DISPLAY BY NAME _grCustomer.*
 			ELSE
 				INITIALIZE _grCustomer.* TO NULL
 				LET _nxtAction = FALSE
 				EXIT MENU
 			END IF
 			NEXT OPTION "Next"
 		COMMAND "Exit" "Exit the program." HELP 100
 			LET _nxtAction = FALSE
 			EXIT MENU
 	END MENU
 	RETURN _nxtAction
END FUNCTION -- nextAction --

FUNCTION changeCust()
 	CALL clearLines(2,16)
 	DISPLAY " Press Accept to save new customer data. Press CTRL-W for Help." AT 16, 1 ATTRIBUTE (REVERSE, YELLOW)
 	DISPLAY " Press Cancel to exit w/out saving." AT 17, 1 ATTRIBUTE (REVERSE, YELLOW)

 	INPUT BY NAME _grCustomer.company, _grCustomer.address1,
 				_grCustomer.address2, _grCustomer.city,
 				_grCustomer.state, _grCustomer.zipcode,
 				_grCustomer.fname, _grCustomer.lname, _grCustomer.phone
 	WITHOUT DEFAULTS HELP 40
 		AFTER FIELD company
 			IF _grCustomer.company IS NULL THEN
 				ERROR "You must enter a company name. Please try again."
 				NEXT FIELD company
 			END IF
 	END INPUT

 	IF int_flag 
	THEN
 		LET int_flag = FALSE
 		CALL clearLines(2,16)
 		RETURN (FALSE)
 	END IF
 	RETURN (TRUE)
END FUNCTION -- changeCust --

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
    CALL _initMsgs()
END FUNCTION -- messageWindow --

FUNCTION updateCust()
 	WHENEVER ERROR CONTINUE
 	UPDATE customer SET customer.* = _grCustomer.* WHERE customer_num = _grCustomer.customer_num
	WHENEVER ERROR STOP
 	IF (status < 0) 
	THEN
 		ERROR status USING "-<<<<<<<<<<<",": Unable to complete customer update."
 		RETURN
 	END IF

 	CALL msg("Customer has been updated.")
END FUNCTION -- updateCust --

FUNCTION deleteCust()
 	IF (promptWindow("Are you sure you want to delete this?", 10, 15)) 
	THEN
 		IF verifyDelete() 
		THEN
 			WHENEVER ERROR CONTINUE
 			DELETE FROM customer WHERE customer_num = _grCustomer.customer_num
			WHENEVER ERROR STOP
 			IF (status < 0) 
			THEN
 				ERROR status USING "-<<<<<<<<<<<", ": Unable to complete customer delete."
 			ELSE
 				CALL msg("Customer has been deleted.")
 				CLEAR FORM
 			END IF
 		ELSE
 			LET _message[1] = "Customer ", _grCustomer.customer_num USING "<<<<<<<<<<<", " has placed orders and cannot be"
 			LET _message[2] = " deleted."
 			CALL messageWindow(7, 8)
 		END IF
 	END IF
END FUNCTION -- deleteCust --

FUNCTION verifyDelete()
 	DEFINE _custCnt INTEGER

 	LET _custCnt = 0
 	SELECT COUNT(*)
 	INTO _custCnt
 	FROM orders
 	WHERE customer_num = _grCustomer.customer_num

 	IF (_custCnt IS NOT NULL) AND (_custCnt > 0) 
	THEN
 		RETURN (FALSE)
 	END IF
 	
	LET _custCnt = 0
 	SELECT COUNT(*)
 	INTO _custCnt
 	FROM cust_calls
 	WHERE customer_num = _grCustomer.customer_num

 	IF (_custCnt > 0) 
	THEN
 		RETURN (FALSE)
 	END IF
 	RETURN (TRUE)
END FUNCTION -- verifyDelete --

FUNCTION clearLines(_numLines, _mRows)
 	DEFINE _numLines SMALLINT,
 			_mRows SMALLINT,
 			i SMALLINT

 	FOR i = 1 TO _numLines
 		DISPLAY " " AT _mRows,1
 		LET _mRows = _mRows + 1
	END FOR
END FUNCTION -- clearLines --

FUNCTION initMsgs()
 	DEFINE i SMALLINT

 	FOR i = 1 TO 5
 		LET _message[i] = NULL
 	END FOR
END FUNCTION -- initMsgs --

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

FUNCTION msg(str)
 	DEFINE str CHAR(78)

	MESSAGE str
 	SLEEP 3
 	MESSAGE ""
END FUNCTION -- msg --

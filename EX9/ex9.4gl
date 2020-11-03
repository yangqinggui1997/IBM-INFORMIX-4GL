DATABASE test4gl

GLOBALS
 	DEFINE _grCustomer RECORD LIKE customer.*,
 			_grWorkCust RECORD LIKE customer.*
 	DEFINE _message ARRAY[5] OF CHAR(100)
END GLOBALS

MAIN
	OPTIONS
		FORM LINE 5,
		COMMENT LINE 5,
		MESSAGE LINE LAST
	
	DEFER INTERRUPT
	OPEN WINDOW _wMian AT 2,3 WITH 18 ROWS, 72 COLUMNS ATTRIBUTE (BORDER)
	
	OPEN FORM _frmCustomer FROM "../EX5/f_customer"
	DISPLAY FORM _frmCustomer
	CALL custMenu1()
	CLEAR SCREEN
END MAIN	

FUNCTION custMenu1()
	DEFINE _stCusts CHAR(150)
	DISPLAY "--------------------------------------------Press CTRL-W for Help----------" AT 3, 1
	MENU "CUSTOMER"
		COMMAND "Add" "Add new customer(s) to the database."
			IF addUpdCust("A")
			THEN
				CALL insertCust()
			END IF
			CLEAR FORM
			CALL clearLines(2,16)
			CALL clearLines(1,4)
		COMMAND "Query" "Look up customer(s) in the database." 
			CALL queryCust2() RETURNING _stCusts
			IF _stCusts IS NOT NULL 
			THEN
				CALL browserCust1(_stCusts)
			END IF
			CALL clearLines(1,4)
		COMMAND KEY("!")
			CALL bang()
		COMMAND KEY("E", "X") "Exit" "Exit the program"
			EXIT MENU
		END MENU
END FUNCTION

FUNCTION browserCust1(_selstmt)
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
		IF NOT nextAction2()
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
END FUNCTION

FUNCTION nextAction2()
	DEFINE _nxtAction SMALLINT
	
	CALL clearLines(1,16)
	LET _nxtAction = TRUE
	DISPLAY "---------------------------------------Press CTRL-W for Help----------" AT 3,1
	
	MENU "CUSTOMER MODIFICATION"
		COMMAND "Next" "View next selected customer."
			EXIT MENU
		COMMAND "Update" "Update current customer on screen."
			IF addUpdCust("U")
			THEN
				CALL updateCust()
			END IF
			CALL clearLines(1,16)
			NEXT OPTION "Next"
		COMMAND "Delete" "Delete current customer on screen."
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
		COMMAND "Exit" "Exit the program."
			LET _nxtAction = FALSE
			EXIT MENU
	END MENU
	RETURN _nxtAction
END FUNCTION

FUNCTION addUpdCust(_auFlag)
	DEFINE _auFlag CHAR(1),
					_custCnt INTEGER,
					_stateCode LIKE customer.state,
					_origComp LIKE customer.company
	
	LET _auFlag = UPSHIFT(_auFlag)
	IF _auFlag <> "A" AND _auFlag <> "U"
	THEN
		ERROR "Incorrect agurment to addUpdCust()."
		EXIT PROGRAM
	END IF
	CALL clearLines(1,4)
	IF _auFlag == "A" 
	THEN
		DISPLAY "CUSTOMER AND" AT 4, 29
		INITIALIZE _grCustomer.* TO NULL
	ELSE
		DISPLAY "CUSTOMER UPDATE" AT 4, 29
		LET _grWorkCust.* = _grCustomer.*
	END IF
	CALL clearLines(2,16)
	DISPLAY " Press Accept to save new customer data. Press CTRL-W for Help." AT 16,1 ATTRIBUTE (REVERSE, YELLOW)
	DISPLAY " Press Cancel to exit w/out saving." AT 17,1 ATTRIBUTE (REVERSE, YELLOW)
	
	LET INT_FLAG = FALSE
	INPUT BY NAME _grCustomer.company, _grCustomer.address1, _grCustomer.address2, _grCustomer.city, _grCustomer.state, _grCustomer.zipcode, _grCustomer.fname, _grCustomer.lname, _grCustomer.phone WITHOUT DEFAULTs
		BEFORE FIELD company
			LET _origComp = _grCustomer.company
		AFTER FIELD company
			IF _grCustomer.company IS NULL 
			THEN
				ERROR "You must enter a customer name. Please re-enter."
				NEXT FIELD company
			END IF
			LET _custCnt = 0
	    IF (_auFlag = "A") OR (_auFlag= "U" AND _origComp <> _grCustomer.company)
         THEN
                SELECT COUNT(*)
                INTO _custCnt
                FROM customer
                WHERE company = _grCustomer.company

                IF (_custCnt > 0)
                THEN
                    LET _message[1] = "This company name already exists in the "
                    LET _message[2] = "          database."
                    IF NOT promptWindow("Are you sure you want to add another?", 9, 15)
                    THEN
                        LET _grCustomer.company = _origComp
                        NEXT FIELD company    
                    END IF
                END IF
            END IF
        AFTER FIELD lname
            IF (_grCustomer.lname IS NULL) AND (_grCustomer.fname IS NOT NULL)
            THEN
                ERROR "You must enter a last name with a first name."
                NEXT  FIELD fname
            END IF
        BEFORE FIELD state
            MESSAGE "Enter state code or press F5 (CTRL-F) for list"
        AFTER FIELD state
            IF _grCustomer.state IS NULL THEN
                ERROR "You must enter a state code. Please try again."
                NEXT FIELD state
            END IF

            SELECT COUNT(*)
            INTO _custCnt
            FROM state
            WHERE code = _grCustomer.state
                
            IF (_custCnt = 0)
            THEN
                ERROR "Unknown state code. Use F5 (CTRL-F) to see valid codes."
                LET _grCustomer.state = NULL
                NEXT FIELD state
            END IF

            MESSAGE ""
        ON KEY (CONTROL-F, F5)
            IF INFIELD(company)
            THEN
                CALL SHOWHELP (50)
            END IF
            IF INFIELD(address1) OR INFIELD(address2)
            THEN
                CALL SHOWHELP (51)
            END IF
            IF INFIELD(city)
            THEN
                CALL SHOWHELP (52)
            END IF
            IF INFIELD(state)
            THEN
                CALL SHOWHELP (53)
            END IF
            IF INFIELD(zipcode)
            THEN    
                CALL SHOWHELP(54)
            END IF
            IF INFIELD(fname) OR INFIELD(lname)
            THEN
                CALL SHOWHELP(55)
            END IF
            IF INFIELD(phone)
            THEN
                CALL SHOWHELP(56)
            END IF
    END INPUT

    IF INT_FLAG 
    THEN
        LET INT_FLAG = FALSE
        CALL clearLines(2,16)
        IF _auFlag = "U" THEN
            LET _grCustomer.* = _grWorkCust.*
            DISPLAY BY NAME _grCustomer.*
        END IF
        CALL msg("Customer input terminated.")
        RETURN (FALSE)
    END IF
    RETURN (TRUE)
END FUNCTION

FUNCTION statePopup()
    DEFINE _paState ARRAY[60] OF RECORD
            code    LIKE state.code,
            sname   LIKE state.sname
        END RECORD,
        _idx INTEGER,
        _stateCnt INTEGER,
        _arraySz SMALLINT,
        _overSize SMALLINT
    
    LET _arraySz = 60
    OPEN WINDOW _wStatePop AT 7, 3 WITH 15 ROWS, 45 COLUMNS ATTRIBUTE(BORDER, PROMPT LINE 4)
    OPEN FORM _frmStateSel FROM "f_statessel"
    DISPLAY FORM _frmStateSel
    
    DISPLAY "Moving cursor using F3, F4, and arrows keys." AT 1, 2
    DISPLAY "Press Accept to select state." AT 2, 2

    DECLARE _cStatePop CURSOR FOR 
    SELECT code, sname
    FROM state
    ORDER BY code

    LET _overSize = FALSE
    LET _stateCnt = 1

    FOREACH _cStatePop INTO _paState[_stateCnt].*
        LET _stateCnt = _stateCnt + 1
        IF _stateCnt > _arraySz 
        THEN
            LET _overSize = TRUE
            EXIT FOREACH
        END IF
    END FOREACH

    IF _stateCnt = 1 
    THEN
        CALL msg("No state exists in database.")
        LET _idx = 1
        LET _paState[_idx].code = NULL
    ELSE
        IF _overSize
        THEN
            ERROR "State array full: can only display ", _arraySz USING "<<<<<<"
        END IF
        CALL SET_COUNT(_stateCnt - 1)
        LET INT_FLAG = FALSE
        DISPLAY ARRAY _paState TO _saState.*

        LET _idx = ARR_CURR()
        IF INT_FLAG 
        THEN
            LET INT_FLAG = FALSE
            CALL msg("No state selected")
            LET _paState[_idx].code = NULL
        END IF
    END IF
    CLOSE WINDOW _wStatePop
    RETURN _paState[_idx].code
END FUNCTION

FUNCTION insertCust()
    WHENEVER ERROR CONTINUE
    INSERT INTO customer VALUES(0, _grCustomer.fname, _grCustomer.lname, _grCustomer.company, _grCustomer.address1, _grCustomer.address2, _grCustomer.city, _grCustomer.state, _grCustomer.zipcode, _grCustomer.phone)
    WHENEVER ERROR STOP

    IF (STATUS < 0)
    THEN
        ERROR  STATUS USING "-<<<<<<<<<<<<<", ": Unable to complete customer insert."
    ELSE
        LET _grCustomer.customer_num = SQLCA.SQLERRD[2]
        DISPLAY BY NAME _grCustomer.customer_num

        LET _message[1] = "Customer has been entered in tho database."
        LET _message[2] = "  Number: ", _grCustomer.customer_num USING "<<<<<<<<<<<", " Name: ", _grCustomer.company
        CALL messageWindow(9, 15)
    END IF
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
        IF _message[i] IS NOT NULL
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
        IF _message[i] IS NOT NULL
        THEN
            DISPLAY _message[i] CLIPPED AT _rowNum, 2
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

FUNCTION clearLines(_numLines, _mRows)
 	DEFINE _numLines SMALLINT,
 			_mRows SMALLINT,
 			i SMALLINT

 	FOR i = 1 TO _numLines
 		DISPLAY " " AT _mRows,1
 		LET _mRows = _mRows + 1
	END FOR
END FUNCTION -- clearLines --

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

FUNCTION bang()
    DEFINE _cmd CHAR(80),
            _keyStrroke CHAR(1)
    
    LET _keyStrroke = "!"
    WHILE _keyStrroke = "!"
        PROMPT "unix! " FOR _cmd
        RUN _cmd
        PROMPT "Type RETURN to continue." FOR CHAR _keyStrroke
    END WHILE
END FUNCTION -- bang --

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

FUNCTION initMsgs()
 	DEFINE i SMALLINT

 	FOR i = 1 TO 5
 		LET _message[i] = NULL
 	END FOR
END FUNCTION -- initMsgs --

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
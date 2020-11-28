DATABASE test4GL
GLOBALS
    DEFINE _grCustomer RECORD LIKE customer.*, -- table record
            _grWorkcust RECORD LIKE customer.*, -- screen field record
            _grCustcalls RECORD LIKE cust_calls.*,

            _grViewcall RECORD
            customer_num LIKE customer.customer_num,
            company LIKE customer.company,
            call_time CHAR(5),
            _amPm1 CHAR(2),
            _yrMon1 DATE,
            user_id LIKE cust_calls.user_id,
            call_code LIKE cust_calls.call_code,
            call_flag CHAR(1),
            res_time CHAR(5),
            _amPm2 CHAR(2),
            _yrMon2 DATE,
            res_flag CHAR(1)
            END RECORD,
        _grWorkcall RECORD
            customer_num LIKE customer.customer_num,
            company LIKE customer.company,
            call_time CHAR(5),
            _amPm1 CHAR(2),
            _yrMon1 DATE,
            user_id LIKE cust_calls.user_id,
            call_code LIKE cust_calls.call_code,
            call_flag CHAR(1),
            res_time CHAR(5),
            _amPm2 CHAR(2),
            _yrMon2 DATE,
            res_flag CHAR(1)
        END RECORD
    DEFINE _arrayMessage ARRAY[5] OF CHAR(100)
END GLOBALS

########################################
MAIN
########################################
OPTIONS
    HELP FILE "hlpmsgs",
    FORM LINE 5,
    COMMENT LINE 5,
    MESSAGE LINE LAST
    DEFER INTERRUPT
    OPEN WINDOW w_main AT 2,3
    WITH 18 ROWS, 76 COLUMNS
    ATTRIBUTE (BORDER)
    OPEN FORM _frmCustomer FROM "../EX5/f_customer"
    DISPLAY FORM _frmCustomer
    CALL custMenu2()
    CLOSE FORM _frmCustomer
    CLOSE WINDOW w_main
    CLEAR SCREEN
END MAIN

########################################
FUNCTION custMenu2()
########################################
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
		COMMAND KEY("!")
			CALL bang()
		COMMAND KEY("E", "X") "Exit" "Exit the program"
			EXIT MENU
        COMMAND "Query" "Look up customer(s) in the database." HELP 11
            CALL queryCust2() RETURNING _stCusts
            IF _stCusts IS NOT NULL THEN
                CALL browseCusts2(_stCusts)
            END IF
            CALL clearLines(1, 4)
    END MENU
END FUNCTION -- cust_menu2 --
########################################
FUNCTION browseCusts2(_selstmt)
########################################
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
 		IF NOT nextAction3()
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
END FUNCTION -- browse_custs2 --

########################################
FUNCTION nextAction3()
########################################
    DEFINE _nxtAction SMALLINT
    LET _nxtAction = TRUE
    DISPLAY "--------------------------------------------Press CTRL-W for Help----------" AT 3, 1 
    MENU "CUSTOMER MODIFICATION"
		COMMAND "Add" "Add new customer(s) to the database."
			IF addUpdCust("A")
			THEN
				CALL insertCust()
			END IF
			CLEAR FORM
			CALL clearLines(2,16)
			CALL clearLines(1,4)
		COMMAND KEY("!")
			CALL bang()
		COMMAND KEY("E", "X") "Exit" "Exit the program"
			EXIT MENU
        COMMAND "Calls" "View this customer?s calls." HELP 23
            IF _grCustomer.customer_num IS NULL THEN
                CALL msg("No customer is current. Please use 'Query'.")
            ELSE
                CALL openCalls()
            END IF
    END MENU
    RETURN (FALSE)
END FUNCTION -- next_action3 --

########################################
FUNCTION openCalls()
########################################
    OPEN WINDOW w_call AT 2,3
    WITH 18 ROWS, 76 COLUMNS
    ATTRIBUTE (BORDER)
    OPEN FORM frmCustcall FROM "f_custcall"
    DISPLAY FORM frmCustcall

    DISPLAY "CUSTOMER CALLS" AT 4, 29
    DISPLAY BY NAME _grCustomer.customer_num, _grCustomer.company
    CALL callMenu()
    CLOSE FORM frmCustcall
    CLOSE WINDOW w_call

END FUNCTION -- open_calls --
########################################
FUNCTION callMenu()
########################################
    DISPLAY
    "--------------------------------------------Press CTRL-W for Help----------" AT 3, 1
    MENU "CUSTOMER CALLS"
        COMMAND "Receive" "Add a new customer call to the database."
            HELP 70
            CALL addupdCall("A")
        COMMAND "View" "Look at calls for this customer." HELP 71
            CALL browseCalls(_grCustomer.customer_num)
        COMMAND KEY ("!")
            CALL bang()
        COMMAND KEY ("E","X") "Exit" HELP 72
            ERROR "Return to the CUSTOMER MODIFICATION menu."
            EXIT MENU
    END MENU
END FUNCTION -- callMenu --

########################################
FUNCTION addupdCall(_auFlag)
########################################
    DEFINE _auFlag CHAR(1),
    _keepGoing SMALLINT
    DISPLAY
    " Press Accept to save call. Press CTRL-W for Help."
    AT 16, 1 ATTRIBUTE (REVERSE, YELLOW)
    DISPLAY
    " Press Cancel to exit w/out saving."
    AT 17, 1 ATTRIBUTE (REVERSE, YELLOW)

    IF _auFlag = "A" THEN
        INITIALIZE _grCustcalls.* TO NULL
        INITIALIZE _grViewcall.* TO NULL
        INITIALIZE _grWorkcall.* TO NULL
        LET _grViewcall._yrMon1 = TODAY
    ELSE --* _auFlag = "U"
        LET _grWorkcall.* = _grViewcall.*
    END IF
    LET _grViewcall.customer_num = _grCustomer.customer_num
    LET _keepGoing = TRUE
    IF inputCall() THEN
        LET _arrayMessage[1] = "Customer call entry complete."
        IF promptWindow("Are you ready to save this customer call?", 14, 14)
        THEN
            IF (_auFlag = "A") THEN
                CALL insertCall()
                CLEAR call_time, _amPm1, _yrMon1, user_id, call_code, call_flag, res_time, _amPm2, _yrMon2, res_flag
            ELSE --* _auFlag = ?U?
                CALL updateCall()
            END IF
        ELSE --* user doesn?t want to update
            LET _keepGoing = FALSE
        END IF
    ELSE --* user pressed Cancel/Interrupt
        LET _keepGoing = FALSE
    END IF
    IF NOT _keepGoing THEN
        IF _auFlag = "A" THEN
            CLEAR call_time, _amPm1, _yrMon1, user_id, call_code, call_flag, res_time, _amPm2, _yrMon2, res_flag
        ELSE --* _auFlag = "U"
            LET _grViewcall.* = _grWorkcall.*
            DISPLAY BY NAME _grViewcall.*
        END IF
        CALL msg("Customer call input terminated.")
    END IF
    CALL clearLines(2,16)
END FUNCTION -- addupdCall --

########################################
FUNCTION inputCall()
########################################
    DEFINE _prCalltime RECORD
            _hrs SMALLINT,
            _mins SMALLINT
    END RECORD,
    _prRestime RECORD
        _hrs SMALLINT,
        _mins SMALLINT
    END RECORD,
    _editFld LIKE cust_calls.call_descr,
    _callCnt SMALLINT,
    _fldFlag CHAR(1),
    _newFlag CHAR(1)

    INITIALIZE _prCalltime.* TO NULL
    INITIALIZE _prRestime.* TO NULL
    LET int_flag = FALSE

    INPUT BY NAME _grViewcall.call_time THRU _grViewcall.res_flag
    WITHOUT DEFAULTS
    BEFORE FIELD call_time
        IF _grViewcall.call_time IS NULL THEN
            CALL initTime() RETURNING _grViewcall.call_time, _grViewcall._amPm1
            DISPLAY BY NAME _grViewcall._amPm1
        END IF
    AFTER FIELD call_time
        IF _grViewcall.call_time IS NULL THEN
            CALL initTime() RETURNING _grViewcall.call_time, _grViewcall._amPm1
            DISPLAY BY NAME _grViewcall.call_time
        ELSE
            LET _prCalltime._hrs = _grViewcall.call_time[1,2]
            IF (_prCalltime._hrs < 0) OR (_prCalltime._hrs > 23) THEN
                ERROR "Hour must be between 0 and 23. Please try again."
                LET _grViewcall.call_time[1,2] = "00"
                NEXT FIELD call_time
            END IF
            LET _prCalltime._mins = _grViewcall.call_time[4,5]
            IF (_prCalltime._mins < 0) OR (_prCalltime._mins > 59) THEN
                ERROR "Minutes must be between 0 and 59. Please try again."
                LET _grViewcall.call_time[4,5] = "00"
                NEXT FIELD call_time
            END IF
            IF _prCalltime._hrs > 12 THEN
                LET _grViewcall._amPm1 = "PM"
                DISPLAY BY NAME _grViewcall._amPm1
                NEXT FIELD _yrMon1
            END IF
        END IF
    AFTER FIELD _amPm1
        IF (_grViewcall._amPm1 IS NULL) OR (_grViewcall._amPm1[1] NOT MATCHES "[AP]")
        THEN
            ERROR "Time must be either AM or PM."
            LET _grViewcall._amPm1[1] = "A"
            NEXT FIELD _amPm1
        END IF
    BEFORE FIELD _yrMon1
        IF _grViewcall._yrMon1 IS NULL THEN
            LET _grViewcall._yrMon1 = TODAY
        END IF
    AFTER FIELD _yrMon1
        IF _grViewcall._yrMon1 IS NULL THEN
            LET _grViewcall._yrMon1 = TODAY
            DISPLAY BY NAME _grViewcall._yrMon1
        END IF
        CALL getDatetime(_prCalltime.*, _grViewcall._amPm1,
        _grViewcall._yrMon1)
        RETURNING _grCustcalls.call_dtime

        IF _grWorkcall.customer_num IS NULL THEN
            SELECT COUNT(*)
            INTO _callCnt
            FROM cust_calls
            WHERE customer_num = _grCustcalls.customer_num
            AND call_dtime = _grCustcalls.call_dtime

            IF (_callCnt > 0) THEN
                ERROR "This customer already has a call entered for: ",
                _grCustcalls.call_dtime
                CALL initTime() RETURNING _grViewcall.call_time,
                _grViewcall._amPm1
                NEXT FIELD call_time
            END IF
        END IF
    BEFORE FIELD user_id
        IF _grViewcall.user_id IS NULL THEN
            SELECT USER
            INTO _grViewcall.user_id
            FROM informix.systables
            WHERE tabname = "systables"
        END IF
    AFTER FIELD user_id
        IF _grViewcall.user_id IS NULL THEN
            ERROR "You must enter the name of the person logging the call."
            NEXT FIELD user_id
        END IF
    BEFORE FIELD call_code
        MESSAGE "Valid call codes: B, D, I, L, O "
    AFTER FIELD call_code
        IF _grViewcall.call_code IS NULL THEN
            ERROR "You must enter a call code. Please try again."
            NEXT FIELD call_code
        END IF
        MESSAGE ""
    BEFORE FIELD call_flag
        MESSAGE "Press F2 (CTRL-E) to edit call description."
        IF _grWorkcall.customer_num IS NULL THEN --* doing an insert
            LET _grViewcall.call_flag = editDescr("C")
            DISPLAY BY NAME _grViewcall.call_flag
        END IF
    AFTER FIELD call_flag
        IF _grCustcalls.call_descr IS NULL
        AND (_grViewcall.call_flag = "Y")
        THEN
            ERROR "No call description exists: changing flag to ?N?."
            LET _grViewcall.call_flag = "N"
            DISPLAY BY NAME _grViewcall.call_flag
        END IF
        IF _grCustcalls.call_descr IS NOT NULL
        AND (_grViewcall.call_flag = "N")
        THEN
            ERROR "A call description exists: changing flag to ?Y?."
            LET _grViewcall.call_flag = "Y"
            DISPLAY BY NAME _grViewcall.call_flag
        END IF
        MESSAGE ""
        LET _arrayMessage[1] = "Call receiving information complete."
        IF promptWindow("Enter call resolution now?", 14, 14) THEN
            NEXT FIELD res_time
        ELSE
            EXIT INPUT
        END IF
    BEFORE FIELD res_time
        IF _grViewcall.res_time IS NULL THEN
            CALL initTime() RETURNING _grViewcall.res_time, _grViewcall._amPm2
            DISPLAY BY NAME _grViewcall._amPm2
        END IF
    AFTER FIELD res_time
        IF _grViewcall.res_time IS NULL THEN
            CALL initTime() RETURNING _grViewcall.res_time, _grViewcall._amPm2
        ELSE
            LET _prRestime._hrs = _grViewcall.res_time[1,2]
            IF (_prRestime._hrs < 0) OR (_prRestime._hrs > 23) THEN
                ERROR "Hour must be between 0 and 23. Please try again."
                LET _grViewcall.res_time[1,2] = "00"
                NEXT FIELD res_time
            END IF
            LET _prRestime._mins = _grViewcall.res_time[4,5]
            IF (_prRestime._mins < 0) OR (_prRestime._mins > 59) THEN
                ERROR "Minutes must be between 0 and 59. Please try again."
                LET _grViewcall.res_time[4,5] = "00"
                NEXT FIELD res_time
            END IF
            IF _prRestime._hrs > 12 THEN
                LET _grViewcall._amPm2 = "PM"
                DISPLAY BY NAME _grViewcall._amPm2
                NEXT FIELD _yrMon2
            END IF
        END IF
    AFTER FIELD _amPm2
        IF (_grViewcall._amPm2 IS NULL)
        OR (_grViewcall._amPm2[1] NOT MATCHES "[AP]")
        THEN
            ERROR "Time must be either AM or PM."
            LET _grViewcall._amPm2[1] = "A"
            NEXT FIELD _amPm2
        END IF
    BEFORE FIELD _yrMon2
        IF _grViewcall._yrMon2 IS NULL THEN
            LET _grViewcall._yrMon2 = TODAY
        END IF
    AFTER FIELD _yrMon2
        IF _grViewcall._yrMon2 IS NULL THEN
            LET _grViewcall._yrMon2 = TODAY
            DISPLAY BY NAME _grViewcall._yrMon2
        END IF
        IF _grViewcall._yrMon2 < _grViewcall._yrMon1 THEN
            ERROR "Resolution date should not be before call date."
            LET _grViewcall._yrMon2 = TODAY
            NEXT FIELD _yrMon2
        END IF
    BEFORE FIELD res_flag
        MESSAGE "Press F2 (CTRL-E) to edit resolution description."
        IF _grWorkcall.customer_num IS NULL THEN --* doing an insert
            LET _grViewcall.res_flag = editDescr("R")
            DISPLAY BY NAME _grViewcall.res_flag
        END IF
    AFTER FIELD res_flag
    IF _grCustcalls.res_descr IS NULL
    AND (_grViewcall.res_flag = "Y")
    THEN
        ERROR "No resolution description exists: changing flag to ?N?."
        LET _grViewcall.res_flag = "N"
        DISPLAY BY NAME _grViewcall.res_flag
    END IF
    IF _grCustcalls.res_descr IS NOT NULL
    AND (_grViewcall.res_flag = "N")
    THEN
        ERROR "A resolution description exists: changing flag to ?Y?."
        LET _grViewcall.res_flag = "Y"
        DISPLAY BY NAME _grViewcall.res_flag
    END IF
    MESSAGE ""
    ON KEY (F2, CONTROL-E)
        IF INFIELD(call_flag) OR INFIELD(res_flag) THEN
            IF INFIELD(call_flag) THEN
                LET _fldFlag = "C"
            ELSE --* user pressed F2 (CTRL-E) from res_flag
                LET _fldFlag = "R"
            END IF
            LET _newFlag = editDescr(_fldFlag)
            IF _fldFlag = "C" THEN
                LET _grViewcall.call_flag = _newflag
                DISPLAY BY NAME _grViewcall.call_flag
            ELSE --* _fldFlag = "R", editing Call Resolution
                LET _grViewcall.res_flag = _newflag
                DISPLAY BY NAME _grViewcall.res_flag
            END IF
        END IF
    ON KEY (CONTROL-W)
        IF INFIELD(company) THEN
            CALL SHOWHELP(50)
        END IF
        IF INFIELD(address1) OR INFIELD(address2) THEN
            CALL SHOWHELP(51)
        END IF
        IF INFIELD(city) THEN
            CALL SHOWHELP(52)
        END IF
        IF INFIELD(state) THEN
            CALL SHOWHELP(53)
        END IF
        IF INFIELD(zipcode) THEN
            CALL SHOWHELP(54)
        END IF
        IF INFIELD(fname) OR INFIELD(lname) THEN
            CALL SHOWHELP(55)
        END IF
        IF INFIELD(phone) THEN
            CALL SHOWHELP(56)
        END IF
        IF int_flag THEN
            LET int_flag = FALSE
            RETURN (FALSE)
        END IF
        LET _grCustcalls.customer_num = _grViewcall.customer_num
        LET _grCustcalls.user_id = _grViewcall.user_id
        LET _grCustcalls.call_code = _grViewcall.call_code
        CALL getDatetime(_prRestime.*, _grViewcall._amPm2,
        _grViewcall._yrMon2) RETURNING _grCustcalls.res_dtime
    END INPUT
    RETURN (TRUE)
END FUNCTION -- inputCall --

########################################
FUNCTION browseCalls(_custNum)
########################################
    DEFINE _custNum LIKE customer.customer_num,
    _fndCalls SMALLINT,
    _endList SMALLINT

    LET _fndCalls = FALSE
    LET _endList = FALSE
    
    DECLARE c_calls CURSOR FOR
    SELECT *
    FROM cust_calls
    WHERE customer_num = _custNum
    ORDER BY call_dtime

    FOREACH c_calls INTO _grCustcalls.*
        LET _fndCalls = TRUE
        LET _grViewcall.customer_num = _grCustomer.customer_num
        LET _grViewcall.company = _grCustomer.company
        LET _grViewcall.user_id = _grCustcalls.user_id
        LET _grViewcall.call_code = _grCustcalls.call_code

        CALL getTimeflds(_grCustcalls.call_dtime)
        RETURNING _grViewcall.call_time, _grViewcall._amPm1,
        _grViewcall._yrMon1
        
        IF _grCustcalls.call_descr IS NULL THEN
            LET _grViewcall.call_flag = "N"
        ELSE
            LET _grViewcall.call_flag = "Y"
        END IF
        IF _grCustcalls.res_dtime IS NULL THEN
            LET _grViewcall.res_time = NULL
            LET _grViewcall._amPm2 = "AM"
            LET _grViewcall._yrMon2 = TODAY
        ELSE
            CALL getTimeflds(_grCustcalls.res_dtime)
            RETURNING _grViewcall.res_time, _grViewcall._amPm2,
            _grViewcall._yrMon2
        END IF

        IF _grCustcalls.res_descr IS NULL THEN
            LET _grViewcall.res_flag = "N"
        ELSE
            LET _grViewcall.res_flag = "Y"
        END IF

        DISPLAY BY NAME _grViewcall.*
        IF NOT nxtactCall() THEN
            LET _endList = FALSE
            EXIT FOREACH
        ELSE
            LET _endList = TRUE
        END IF
    END FOREACH

    IF NOT _fndCalls THEN
        CALL msg("No calls exist for this customer.")
    END IF
    IF _endList THEN
        CALL msg("No more customer calls.")
    END IF

    CLEAR call_time, _amPm1, _yrMon1, user_id, call_code,
    call_flag, res_time, _amPm2, _yrMon2, res_flag
END FUNCTION -- browseCalls --

########################################
FUNCTION nxtactCall()
########################################
    DEFINE _nxtAction SMALLINT
    LET _nxtAction = TRUE
    MENU "CUSTOMER CALL MODIFICATION"
        COMMAND "Next" "View next selected customer call." HELP 90
            EXIT MENU
        COMMAND "Update" "Update current customer call on screen."
            HELP 91
            CALL addupdCall("U")
            NEXT OPTION "Next"
        COMMAND KEY ("!")
            CALL bang()
        COMMAND KEY ("E","X") "Exit" "Return to CUSTOMER CALLS Menu"
            HELP 92
            LET _nxtAction = FALSE
            EXIT MENU
    END MENU
    RETURN _nxtAction
END FUNCTION -- nxtactCall --

########################################
FUNCTION getTimeflds(_theDtime)
########################################
    DEFINE _theDtime DATETIME YEAR TO MINUTE,
    _amPm CHAR(2),
    _yrMon DATE,
    _timeFld CHAR(5),
    _numHrs SMALLINT

    IF _theDtime IS NULL THEN
        LET _timeFld = NULL
        LET _amPm = NULL
        LET _yrMon = NULL
    ELSE
        LET _yrMon = _theDtime
        LET _timeFld = "00:00"
        LET _timeFld[1,2] = EXTEND(_theDtime, HOUR TO HOUR)
        LET _timeFld[4,5] = EXTEND(_theDtime, MINUTE TO MINUTE)
        LET _numHrs = _timeFld[1,2]
        IF _numHrs >= 12 THEN
            LET _amPm = "PM"
            LET _numHrs = _numHrs - 12
            IF _numHrs > 9 THEN
            LET _timeFld[1,2] = _numHrs
            ELSE
                LET _timeFld[1] = "0"
                LET _timeFld[2] = _numHrs
            END IF
        ELSE
            LET _amPm = "AM"
            IF _numHrs = 0 THEN
                LET _timeFld[1,2] = "12"
            END IF
        END IF
    END IF
    RETURN _timeFld, _amPm, _yrMon
END FUNCTION -- getTimeflds --

########################################
FUNCTION getDatetime(_prTime, _amPm, _yrMon)
########################################
    DEFINE _prTime RECORD
            _hrs SMALLINT,
            _mins SMALLINT
    END RECORD,
    _amPm CHAR(2),
    _yrMon DATE,
    _theDtime DATETIME YEAR TO MINUTE

    IF _yrMon IS NULL THEN
        LET _theDtime = NULL
    ELSE
        LET _theDtime = _yrMon --* use 4GL convertion to
        --* convert DATE to DATETIME
        IF _amPm[1] = "A" THEN
            IF _prTime._hrs = 12 THEN
                LET _prTime._hrs = 0
            END IF
        ELSE --* _amPm = "P"
            IF _prTime._hrs < 12 THEN
                LET _prTime._hrs = _prTime._hrs + 12 --* convert PM to 24-hour time
            END IF
        END IF
        LET _theDtime = _theDtime + _prTime._hrs UNITS HOUR
        + _prTime._mins UNITS MINUTE --* add in time (hours and minutes)
        --* to DATETIME value
    END IF
    RETURN (_theDtime)
END FUNCTION -- getDatetime --

########################################
FUNCTION initTime()
########################################
    DEFINE _newTime CHAR(5),
    _amPm CHAR(2),
    _hrs SMALLINT

    LET _newTime = CURRENT HOUR TO MINUTE

    IF _newTime > "12:59" THEN -- if 24-hour notation, convert to
        LET _hrs = _newTime[1,2] -- 12-hour and AM/PM flag
        LET _hrs = _hrs - 12
        IF _hrs > 9 THEN -- need to put two digits in
            LET _newTime[1,2] = _hrs
        ELSE -- need to put only 1 digit in
            LET _newTime[1] = 0
            LET _newTime[2] = _hrs
        END IF
        LET _amPm = "PM"
    ELSE
        LET _amPm = "AM"
    END IF
    RETURN _newTime, _amPm
END FUNCTION -- initTime --

########################################
FUNCTION editDescr(_editFlg)
########################################
    DEFINE _editFlg CHAR(1),
    _editStr LIKE cust_calls.call_descr,
    _editRet SMALLINT,
    _hasValue CHAR(1)
    OPEN WINDOW w_edit AT 3,11
    WITH 12 ROWS, 60 COLUMNS
    ATTRIBUTE (BORDER, FORM LINE 4, COMMENT LINE 2)

    OPEN FORM f_edit FROM "f_edit"
    DISPLAY FORM f_edit

    DISPLAY " Press Accept to save, Cancel to exit w/out saving."
    AT 1, 1 ATTRIBUTE (REVERSE, YELLOW)
    IF _editFlg = "C" THEN
        DISPLAY "CALL DESCRIPTION"
        AT 3, 24
        LET _editStr = _grCustcalls.call_descr
    ELSE --* _editFlg = ?R?
        DISPLAY "CALL RESOLUTION"
        AT 3, 24
        LET _editStr = _grCustcalls.res_descr
    END IF

    LET int_flag = FALSE
    INPUT BY NAME _editStr
    WITHOUT DEFAULTS
    LET _hasValue = "Y"

    IF _editStr IS NULL THEN
        LET _hasValue = "N"
    END IF
    IF int_flag THEN
        LET int_flag = FALSE
    ELSE
        IF _editFlg = "C" THEN
            LET _grCustcalls.call_descr = _editStr
        ELSE
            LET _grCustcalls.res_descr = _editStr
        END IF
    END IF

    CLOSE FORM f_edit
    CLOSE WINDOW w_edit
    RETURN _hasValue
END FUNCTION -- editDescr --

########################################
FUNCTION insertCall()
########################################
    WHENEVER ERROR CONTINUE
    INSERT INTO cust_calls
    VALUES (_grCustcalls.*)
    WHENEVER ERROR STOP

    IF (status < 0) THEN
        ERROR status USING "-<<<<<<<<<<<", ": Unable to complete customer call ",
        "insert."
    ELSE
        CALL msg("Customer call has been entered in the database.")
    END IF
    CALL msg("Customer call has been entered in the database.")
END FUNCTION -- insertCall --

########################################
FUNCTION updateCall()
########################################
    WHENEVER ERROR CONTINUE
    UPDATE cust_calls SET cust_calls.* = _grCustcalls.*
    WHERE customer_num = _grCustcalls.customer_num
    AND call_dtime = _grCustcalls.call_dtime
    WHENEVER ERROR STOP

    IF (status < 0) THEN
        ERROR status USING "-<<<<<<<<<<<",
    ": Unable to complete customer call update."
        RETURN
    END IF
    CALL msg("Customer call has been updated.")
END FUNCTION -- updateCall --

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

FUNCTION showMessage(_x, _y, _countMessage)
    DEFINE  _countRows      SMALLINT,
            _x,_y,_i        SMALLINT,
            _prompt         CHAR(1),
            _countMessage   SMALLINT
    LET _countRows = 4
    FOR _i = 1 TO _countMessage
        IF _arrayMessage[_i] IS NOT NULL
        THEN
            LET _countRows = _countRows + 1
        END IF
    END FOR

    OPEN WINDOW _window AT _x,_y WITH _countRows ROWS, 52 COLUMNS ATTRIBUTE (BORDER, PROMPT LINE LAST)
    DISPLAY "APPLICATION MASSAGE" AT 1, 17 ATTRIBUTE (REVERSE,BLUE)
    LET _countRows = 3
    FOR _i = 1 TO _countMessage
        IF _arrayMessage[_i] IS NOT NULL
        THEN
            DISPLAY _arrayMessage[_i] AT _countRows, 2
            LET _countRows = _countRows + 1
        END IF
    END FOR
    PROMPT "Press RETURN to continue..." FOR _prompt
    CLOSE WINDOW _window
    CALL resetMessage(_countMessage)
END FUNCTION

FUNCTION resetMessage(_countMessage)
    DEFINE  _i, _countMessage  SMALLINT
    FOR _i = 1 TO _countMessage
        INITIALIZE _arrayMessage[_i] TO NULL
    END FOR
END FUNCTION

FUNCTION initMsgs()
    DEFINE i SMALLINT

    FOR i = 1 TO 5
        LET _arrayMessage[i] = NULL
    END FOR
END FUNCTION -- initMsgs --

FUNCTION msg(str)
 	DEFINE str CHAR(78)

	MESSAGE str
 	SLEEP 3
 	MESSAGE ""
END FUNCTION -- msg --

FUNCTION clearLines(_numLines, _mRows)
 	DEFINE _numLines SMALLINT,
 			_mRows SMALLINT,
 			i SMALLINT

 	FOR i = 1 TO _numLines
 		DISPLAY " " AT _mRows,1
 		LET _mRows = _mRows + 1
	END FOR
END FUNCTION -- clearLines --

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
        IF _arrayMessage[i] IS NOT NULL
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
        IF _arrayMessage[i] IS NOT NULL
        THEN
            DISPLAY _arrayMessage[i] CLIPPED AT _rowNum, 2
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
                    LET _arrayMessage[1] = "This company name already exists in the "
                    LET _arrayMessage[2] = "          database."
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

        LET _arrayMessage[1] = "Customer has been entered in tho database."
        LET _arrayMessage[2] = "  Number: ", _grCustomer.customer_num USING "<<<<<<<<<<<", " Name: ", _grCustomer.company
        CALL showMessage(9, 15, 5)
    END IF
END FUNCTION

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
 			LET _arrayMessage[1] = "You did not enter any search criteria."
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

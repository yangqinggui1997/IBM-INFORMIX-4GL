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
            FORM state
            WHERE code = _grCustomer.state
                
            IF (_custCnt = 0)
            THEN
                ERROR "Unknown state code. Use F5 (CTRL-F) to see valid codes."
                LET _grCustomer.state = NULL
                NEXT FIELD state
            END IF

            MESSAGE ""
        ON KEY(CONTROL-F, F5)
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
                CALL SHOWHELP(fname)
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
    RETURN (FALSE)
END FUNCTION

FUNCTION statePopup()
    DEFINE _paState ARRAY[60] OF RECORD
            code    LIKE state.code,
            sname   LIKE sate.sname
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

DATABASE test4gl

GLOBALS 
	DEFINE _gaManuf ARRAY[50] OF RECORD
							manu_code LIKE manufact.manu_code,
							manu_name LIKE manufact.manu_name,
							lead_time LIKE manufact.lead_time
				END RECORD,
				_gaMrowid ARRAY[50] OF RECORD
									_mRowid INTEGER,
									_opFlag CHAR(1)
				END RECORD,
				_gaDrows ARRAY[50] OF RECORD
									_mRowid INTEGER,
									manu_code LIKE manufact.manu_code
				END RECORD,
				_gIdx 	SMALLINT
	DEFINE _message ARRAY[5] OF CHAR(48)
END GLOBALS

MAIN	
	OPTIONS
		FORM LINE 4,
		MESSAGE LINE LAST,
		COMMENT LINE 2,
		INSERT KEY CONTROL-E,
		DELETE KEY CONTROL-T
	DEFER INTERRUPT
	
	IF dsplyManuf()
	THEN
		CALL chooseOp()
		CALL msg("Manufacturer maintenance complete.")
	END IF
END MAIN

FUNCTION dsplyManuf()
	DEFINE _idx SMALLINT,
	_currPa SMALLINT,
	_currSa SMALLINT,
	_totalPa SMALLINT,
	_manufCnt SMALLINT,
	_prNullMan RECORD
							manu_code LIKE manufact.manu_code,
							manu_name LIKE manufact.manu_name,
							lead_time LIKE manufact.lead_time
							END RECORD,
	_prWorkMan RECORD
							manu_code LIKE manufact.manu_code,
							manu_name LIKE manufact.manu_name,
							lead_time LIKE manufact.lead_time
							END RECORD

	INITIALIZE _prNullMan.* TO NULL
	OPEN WINDOW _wManufs AT 4, 5 WITH 13 ROWS, 67 COLUMNS ATTRIBUTE (BORDER)
	OPEN FORM _frmManuf FROM "f_manuf"
	DISPLAY FORM _frmManuf
	
	DISPLAY " Press Accept to save manufacturers, cancle to exit w/out saving." AT 1, 1 ATTRIBUTE (REVERSE, YELLOW) 
	DISPLAY " Press CTRL-E to insert a line, CTRL-T to delete a line." AT 13, 1 ATTRIBUTE (REVERSE, YELLOW)
	DISPLAY "MANUFACTURER MAINTENANCE" AT 3, 15
	
	DECLARE _cManufs CURSOR FOR
	SELECT ROWID, manu_code, manu_name, lead_time FROM manufact ORDER BY manu_code
	
	LET _idx = 1
	FOREACH _cManufs INTO _gaMrowid[_idx]._mRowid, _gaManuf[_idx].*
		LET _idx = _idx + 1
	END FOREACH
	
	IF _idx = 1
	THEN
		LET _gaManuf[1].* = _prNullMan.*
	END IF
	
	CALL SET_COUNT(_idx - 1)
	INPUT ARRAY _gaManuf WITHOUT DEFAULTS FROM _saManuf.*
	BEFORE ROW
		LET _currPa = ARR_CURR()
		LET _currSa = SCR_LINE()
		LET _totalPa = ARR_COUNT()
		LET _prWorkMan.* = _gaManuf[_currPa].*
	BEFORE INSERT
		LET _prWorkMan.* = _prNullMan.*
	BEFORE DELETE
		CALL saveRowid(_gaMrowid[_currPa]._mRowid, _gaManuf[_currPa].manu_code)
		CALL reshuffle("D")	
		LET _prWorkMan.manu_code  = _gaManuf[_currPa].manu_code
	AFTER FIELD manu_code
		IF (_gaManuf[_currPa].manu_code IS NULL)
		THEN
			IF NOT validNull(_currPa, _totalPa)
			THEN
				ERROR "You must enter a manufacturer code. Please try again."
				LET _gaManuf[_currPa].manu_code = _prWorkMan.manu_code			
			END IF 
		END IF
		
		IF (_prWorkMan.manu_code IS NULL) AND (_gaManuf[_currPa].manu_code IS NOT NULL)
		THEN
			SELECT COUNT(*)
			INTO _manufCnt
			FROM manufact
			WHERE manu_code = _gaManuf[_currPa].manu_code
			
			IF _manufCnt > 0
			THEN
				ERROR "This manufacturer code already exists. Please another code."
				LET _gaManuf[_currPa].manu_name = NULL
				NEXT FIELD manu_code
			ELSE
				IF _currPa <> _totalPa 
				THEN
					CALL reshuffle("I")
				END IF
				LET  _gaMrowid[_currPa]._opFlag = "I"
			END IF
		ELSE
			IF (_gaManuf[_currPa].manu_code <> _prWorkMan.manu_code)
			THEN
				LET _message[1] = "You cannot modify the manufacturer code."
				LET _message[2] = " "
				LET _message[3] = "To modify this value, delete the incorrect"
				LET _message[4] = " entry and enter a new one with the correct"
				let _message[5] = " manufacturer code."
				CALL messageWindow(7,7)
				LET _gaManuf[_currPa].manu_code = _prWorkMan.manu_code
				NEXT FIELD manu_code
			END IF
		END IF
	BEFORE FIELD manu_code
		LET _prWorkMan.manu_code = _gaManuf[_currPa].manu_name
	AFTER FIELD manu_name
		IF _gaManuf[_currPa].manu_name IS NULL
		THEN
			ERROR "You must enter the manufacturer name. Please try again."
			NEXT FIELD manu_name
		END IF
		IF (_gaManuf[_currPa].manu_name <> _prWorkMan.manu_name)
		THEN
			IF _gaMrowid[_currPa]._opFlag IS NULL
			THEN
				LET _gaMrowid[_currPa]._opFlag = "U"
			END IF
		END IF
	BEFORE FIELD lead_time
		IF _gaManuf[_currPa].lead_time = 0 IS NULL
		THEN
			LET _gaManuf[_currPa].lead_time = 0 UNITS DAY
		END IF
		LET _prWorkMan.lead_time = _gaManuf[_currPa].lead_time
		MESSAGE "Enter the lead_time in the form ' ###' (e.g. ' 001')."
	AFTER FIELD lead_time
		IF _gaManuf[_currPa].lead_time IS NULL
		THEN
			LET _gaManuf[_currPa].lead_time = 0 UNITS DAY
			DISPLAY _gaManuf[_currPa].lead_time TO _saManuf[_currSa].lead_time
		END IF
		IF (_gaManuf[_currPa].lead_time <> _prWorkMan.lead_time) 
		THEN
			IF _gaMrowid[_currPa]._opFlag IS NULL
			THEN
				LET _gaMrowid[_currPa]._opFlag = "U"
			END IF
		END IF
		
		MESSAGE ""
		DISPLAY " Press CTRL-E to insert a line, CTRL-T to delete a line." AT 13, 1 ATTRIBUTE (REVERSE, YELLOW)
	END INPUT
	
	IF INT_FLAG 
	THEN
		LET INT_FLAG = FALSE
		CALL msg("Manufacturer maintenance terminated.")
		RETURN FALSE
	END IF
	
	IF promptWindow("Are you sure you want to save these changes?", 8, 11)
	THEN
		RETURN (TRUE)
	ELSE
		RETURN (FALSE)
	END IF
END FUNCTION

FUNCTION validNull(_arrayIdx, _arraySize)
	DEFINE _arrayIdx SMALLINT,
					_arraySize SMALLINT,
					_nextFld SMALLINT,
					_lastKey INTEGER
					
	LET _lastKey = FGL_LASTKEY()
	LET _nextFld = (_lastKey = FGL_KEYVAL("right")) OR (_lastKey = FGL_KEYVAL("return")) OR (_lastKey = FGL_KEYVAL
	("tab"))
	IF (_arrayIdx >= _arraySize) 
	THEN
		IF _nextFld
		THEN
			RETURN (FALSE)
		END IF
	ELSE
		IF NOT _nextFld
		THEN
			LET _message[1] = "You cannot leave an empty line in the middle "
			LET _message[2] = " of the array. To continue, either: "
			LET _message[3] = " - enter a Manufacturer in the line "
			LET _message[4] = " - delete the empty line "
			CALL messageWindow(7,12)
		END IF
		RETURN (FALSE)
	END IF
	RETURN TRUE
END FUNCTION

FUNCTION reshuffle(_direction)
	DEFINE _direction CHAR(1),
				_pCurr, _pTotal, _i SMALLINT,
				_clearIt SMALLINT
				
	LET _pCurr = ARR_CURR()
	LET _pTotal = ARR_COUNT()
	IF _direction = "I"
	THEN
		FOR _i = _pTotal TO _pCurr STEP -1
			LET _gaMrowid[_i + 1].* = _gaMrowid[_i].*
		END FOR
		LET _clearIt = _pCurr
	END IF
	
	IF _direction = "D"
	THEN
		IF _pCurr < _pTotal 
		THEN
			FOR _i = _pCurr TO _pTotal
				LET _gaMrowid[_i].* = _gaMrowid[_i + 1].*
			END FOR 
 		END IF
 		LET _clearIt = _pTotal
 	END IF
 	LET _gaMrowid[_clearIt]._mRowid = 0
 	LET _gaMrowid[_clearIt]._opFlag = NULL
END FUNCTION

FUNCTION verifyMdel(_arrayIdx)
	DEFINE _arrayIdx SMALLINT,
					_stockCnt SMALLINT
	
	SELECT COUNT(*)
	INTO _stockCnt 
	FROM stock
	WHERE manu_code = (SELECT manu_code FROM manufact WHERE ROWID = _gaDrows[_arrayIdx]._mRowid)
	
	IF _stockCnt > 0
	THEN
		LET _message[1] = "Inventory currently has stock items made"
		LET _message[2] = " by Manufacturer ", _gaDrows[_arrayIdx].manu_code
		LET _message[3] = " Cannot delete manufacturer while stock items"
		LET _message[4] = " exists."
		CALL messageWindow(6,9)
		RETURN (FALSE)
	END IF
	
	RETURN (TRUE)					
END FUNCTION 

FUNCTION chooseOp()
	DEFINE _idx SMALLINT
	
	FOR _idx = 1 TO ARR_COUNT()
		CASE _gaMrowid[_idx]._opFlag
		WHEN "I"
			CALL insertManuf(_idx)
		WHEN "U"
			CALL updateManuf(_idx)
		END CASE
	END FOR
	
	FOR _idx = 1 TO _gIdx
		CALL deleteManuf(_idx)
	END FOR
END FUNCTION 

FUNCTION insertManuf(_arrayIdx)
	DEFINE _arrayIdx SMALLINT
	
	WHENEVER ERROR CONTINUE
	INSERT INTO manufact(manu_code, manu_name, lead_time) VALUES (_gaManuf[_arrayIdx].manu_code, _gaManuf[_arrayIdx].manu_name, _gaManuf[_arrayIdx].lead_time)
	WHENEVER ERROR STOP
	
	IF (STATUS < 0) 
	THEN
		ERROR STATUS USING "-<<<<<<<<<<<", ": Unable to complete manufact insert of ", _gaManuf[_arrayIdx].manu_code
	ELSE
		LET _message[1] = "Manufacturer ", _gaManuf[_arrayIdx].manu_code, " has been inserted."
		CALL messageWindow(6,6)
	END IF
END FUNCTION

FUNCTION updateManuf(_arrayIdx)
	DEFINE _arrayIdx SMALLINT,
	_mRowid INTEGER,
	_mcode LIKE manufact.manu_code
	
	LET _mRowid = _gaMrowid[_arrayIdx]._mRowid
	LET _mcode = _gaManuf[_arrayIdx].manu_code
	IF verifyRowid(_mRowid, _mcode)
	THEN
		WHENEVER ERROR CONTINUE
			UPDATE manufact SET (manu_code, manu_name, lead_time) = (_gaManuf[_arrayIdx].manu_code, _gaManuf[_arrayIdx].manu_name, _gaManuf[_arrayIdx].lead_time)
			WHERE ROWID = _mRowid
		WHENEVER ERROR STOP
		IF (STATUS < 0)
		THEN
			ERROR STATUS USING "-<<<<<<<<<<<", ": Unable to complete manufact update of ", _mcode
		END IF
		LET _message[1] = "Manufacturer ", _mcode, " has been updated."
		CALL messageWindow(6,6)
	END IF
END FUNCTION

FUNCTION deleteManuf(_delIdx)
	DEFINE _delIdx SMALLINT,
	_msgText CHAR(40),
	_mRowid INTEGER
	
	IF verifyMdel(_delIdx) 
	THEN 
		LET _mRowid = _gaDrows[_delIdx]._mRowid
		IF verifyRowid(_mRowid, _gaDrows[_delIdx].manu_code)
		THEN
			WHENEVER ERROR CONTINUE
			DELETE FROM manufact
			WHENEVER ERROR STOP
			IF (STATUS < 0)
			THEN
				ERROR STATUS USING "-<<<<<<<<<<<", ": Unable to complete manufact delete of ", _gaDrows[_delIdx].manu_code
			END IF
			LET _message[1] = "Manufacturer ", _gaDrows[_delIdx].manu_code, " has been deleted."
			CALL messageWindow(6,6)
		END IF 
	END IF
END FUNCTION

FUNCTION verifyRowid(_mRowid, _codeInMem)
	DEFINE _mRowid INTEGER,
					_codeInMem LIKE manufact.manu_code,
					_codeOnDisk LIKE manufact.manu_code
					
	SELECT manu_code
	INTO _codeOnDisk
	FROM manufact
	WHERE ROWID = _mRowid
	
	IF (STATUS = NOTFOUND) OR (_codeOnDisk <> _codeInMem)
	THEN
		ERROR "Manufacturer ", _codeInMem, " has been deleteD by another user."
		RETURN (FALSE)
	END IF
	
	RETURN (TRUE)
END FUNCTION

FUNCTION saveRowid(_mRowid, _mcode)
	DEFINE _mRowid INTEGER,
				_mcode LIKE manufact.manu_code
	
	IF _gIdx IS NULL
	THEN
		LET _gIdx = 0
	END IF
	LET _gIdx = _gIdx + 1
	LET _gaDrows[_gIdx]._mRowid = _mRowid	
	LET _gaDrows[_gIdx].manu_code = _mcode
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

FUNCTION initMsgs()
 	DEFINE i SMALLINT

 	FOR i = 1 TO 5
 		LET _message[i] = NULL
 	END FOR
END FUNCTION -- initMsgs --
DATABASE test4gl
GLOBALS
    DEFINE _gaMenu ARRAY[20] OF RECORD
            x CHAR(1),
            _optionNum CHAR(3),
            _optionName CHAR(35)
        END RECORD,
        _gMenutitle CHAR(25)
    DEFINE _message ARRAY[5] OF CHAR(48)
END GLOBALS

MAIN
OPTIONS
    HELP FILE "hlpmsgs",
    COMMENT LINE FIRST,
    MESSAGE LINE LAST,
    FORM LINE 2

    DEFER INTERRUPT
    CALL __dsplyMenu()
END MAIN

FUNCTION __dsplyMenu()
    DEFINE _dsply SMALLINT,
    _optionNo SMALLINT,
    _totalOptions SMALLINT
    
    OPEN WINDOW _wMenu2 AT 3,3 WITH 16 ROWS, 75 COLUMNS ATTRIBUTE (BORDER)
    OPEN FORM _fMenu FROM "_fMenu2"
    DISPLAY FORM _fMenu
    DISPLAY " Use F3, F4, and arrow keys to move cursor to desired option." AT 15, 1 ATTRIBUTE (REVERSE, YELLOW)
    DISPLAY " Press Accept to choose option, Cancel to exit menu. Press CTRL-W for Help." AT 16, 1 ATTRIBUTE (REVERSE, YELLOW)
    CALL _initMenu() RETURNING _totalOptions
    DISPLAY _gMenutitle TO menu_title
    LET _dsply = TRUE
    
    WHILE _dsply
        LET _optionNo = chooseOption(_totalOptions)
        IF (_optionNo > 0) 
        THEN
             CASE _optionNo
            WHEN 1
                CALL custMaint()
            WHEN 2
                CALL orderMaint()
            WHEN 3
                CALL stockMaint()
            WHEN 4
                CALL manufMaint()
            WHEN 5
                CALL ccallMaint()
            WHEN 6
                CALL stateMaint()
            WHEN 7 --* Exit option
                LET _dsply = FALSE
            END CASE
        ELSE 
            LET _dsply = FALSE
        END IF
    END WHILE
    CLOSE FORM _fMenu
    CLOSE WINDOW _wMenu2
END FUNCTION -- __dsplyMenu --

FUNCTION _initMenu()
    DEFINE _totalOptions SMALLINT

    LET _gMenutitle = "4GL Test MAIN MENU 2"
    LET _gaMenu[1]._optionName = "Customer Maintenance"
    LET _gaMenu[2]._optionName = "Order Maintenance"
    LET _gaMenu[3]._optionName = "Stock Maintenance"
    LET _gaMenu[4]._optionName = "Manufacturer Maintenance"
    LET _gaMenu[5]._optionName = "Customer Calls Maintenance"
    LET _gaMenu[6]._optionName = "State Maintenance"
    LET _gaMenu[7]._optionName = "Exit MAIN MENU"
    LET _totalOptions = 7
    
    CALL initOpnum(_totalOptions)
    RETURN _totalOptions
END FUNCTION -- _initMenu --

FUNCTION initOpnum(_totalOptions)
    DEFINE _totalOptions SMALLINT,
    i SMALLINT

    FOR i = 1 TO _totalOptions
        IF i < 10 
        THEN
            LET _gaMenu[i]._optionNum[2] = i
        ELSE
            LET _gaMenu[i]._optionNum[1,2] = i
        END IF
        LET _gaMenu[i]._optionNum[3] = ")"
    END FOR
END FUNCTION -- initOpnum --

FUNCTION chooseOption(_totalOptions)
    DEFINE _totalOptions SMALLINT,
        _currPa SMALLINT,
        _currRa SMALLINT,
        _totalPa SMALLINT,
        _lastKey SMALLINT
    
    OPTIONS
        DELETE KEY CONTROL-A,
        INSERT KEY CONTROL-A
    CALL SET_COUNT(_totalOptions)
    LET INT_FLAG = FALSE
    INPUT ARRAY _gaMenu WITHOUT DEFAULTS FROM sa_menu.* HELP 121
        BEFORE ROW
            LET _currPa = ARR_CURR()
            LET _totalPa = ARR_COUNT()
            LET _currRa = SCR_LINE()
            DISPLAY _gaMenu[_currPa].* TO sa_menu[_currRa].* ATTRIBUTE (REVERSE)
        AFTER FIELD x
        IF _gaMenu[_currPa].x IS NOT NULL 
        THEN
            LET _gaMenu[_currPa].x = NULL
            DISPLAY BY NAME _gaMenu[_currPa].x
        END IF
        IF _currPa = _totalPa 
        THEN
            LET _lastKey = FGL__lastKey()
            IF ( (_lastKey = FGL_KEYVAL("down")) OR (_lastKey = FGL_KEYVAL("return")) OR (_lastKey = FGL_KEYVAL("tab")) OR (_lastKey = FGL_KEYVAL("right")) )
            THEN
                ERROR "No more menu options in this direction."
                NEXT FIELD x
            END IF
        END IF
        AFTER ROW
            LET _currPa = ARR_CURR()
            LET _currRa = SCR_LINE()
            DISPLAY _gaMenu[_currPa].* TO sa_menu[_currRa].*
            END INPUT
            IF INT_FLAG 
            THEN
                LET INT_FLAG = FALSE
                RETURN (0)
            END IF
    RETURN (_currPa)
END FUNCTION -- chooseOption --

FUNCTION custMaint()
    LET _message[1] = "This function would contain the statements to"
    LET _message[2] = " implement the Customer Maintenance option."
    CALL _messageWindow(6,12)
END FUNCTION -- custMaint --

FUNCTION orderMaint()
    LET _message[1] = "This function would contain the statements to"
    LET _message[2] = " implement the Orders Maintenance option."
    CALL _messageWindow(6,12)
END FUNCTION

FUNCTION stockMaint()
    LET _message[1] = "This function would contain the statements to"
    LET _message[2] = " implement the Stock Maintenance option."
    CALL _messageWindow(6,12)
END FUNCTION

FUNCTION manufMaint()
    LET _message[1] = "This function would contain the statements to"
    LET _message[2] = " implement the Manufacturer Maintenance option."
    CALL _messageWindow(6,12)
END FUNCTION

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

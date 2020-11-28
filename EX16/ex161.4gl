DATABASE test4gl

GLOBALS
	DEFINE _message ARRAY[5] OF CHAR(48)
END GLOBALS

MAIN
    OPTIONS
    HELP FILE "hlpmsgs",
    FORM LINE FIRST,
    COMMENT LINE 2
    DEFER INTERRUPT
    CALL mainMenu()
END MAIN

FUNCTION mainMenu()
    DEFINE _dsply SMALLINT,
    _optionNum SMALLINT
    
    LET _dsply = TRUE
    OPEN WINDOW _wMenu AT 2, 3 WITH 19 ROWS, 70 COLUMNS ATTRIBUTE (BORDER, MESSAGE LINE LAST)
    OPEN FORM _fMenu FROM "_fMenu"
    DISPLAY FORM _fMenu
    
    DISPLAY " Enter a menu option number and press Accept or RETURN." AT 18, 1 ATTRIBUTE (REVERSE, YELLOW)
    DISPLAY " Choose option 7 to exit the menu. Press CTRL-W for Help." AT 19, 1 ATTRIBUTE (REVERSE, YELLOW)

    WHILE _dsply
        LET INT_FLAG = FALSE
        INPUT BY NAME _optionNum HELP 120
        
        IF INT_FLAG 
        THEN
            LET _dsply = FALSE
        ELSE
            CASE _optionNum
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
            WHEN 7
                LET _dsply = FALSE
            OTHERWISE
                ERROR "Invalid menu choice. Please try again."
            END CASE
        END IF
    END WHILE
    CLOSE FORM _fMenu
    CLOSE WINDOW _wMenu
END FUNCTION -- mainMenu --

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

FUNCTION ccallMaint()
    LET _message[1] = "This function would contain the statements to"
    LET _message[2] = " implement the count of calls Maintenance option."
    CALL _messageWindow(6,12)
END FUNCTION

FUNCTION stateMaint()
    LET _message[1] = "This function would contain the statements to"
    LET _message[2] = " implement the State Maintenance option."
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


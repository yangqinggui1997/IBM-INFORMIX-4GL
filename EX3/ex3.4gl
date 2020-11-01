GLOBALS
    DEFINE _message ARRAY[5] OF CHAR(255)
END GLOBALS

MAIN
    DISPLAY "---------------------------------------Press CTRL-W for Help----------" AT 3, 1
    MENU "DEMO MENU"
        COMMAND "First" "This is the first option of the menu." HELP 1
            CALL dsplyOption(1)
        COMMAND "Second" "This is the second option of the menu." HELP 2
            CALL dsplyOption(2)
        COMMAND "Third" "This is the third option of the menu." HELP 3
            CALL dsplyOption(3)
        COMMAND "Fourth" "This is the fourth option of the menu." HELP 4
            CALL dsplyOption(4)
        COMMAND KEY ("!")
            CALL bang()
        COMMAND "Exit" "Exit the program." HELP 100
            EXIT MENU
    END MENU
    CLEAR SCREEN
END MAIN

FUNCTION dsplyOption(_optionNum)
    DEFINE _optionNum SMALLINT,
            _optionName CHAR(50)

    CASE _optionNum
    WHEN 1
        LET _optionName = "First          "
    WHEN 2
        LET _optionName = "Second"
    WHEN 3
        LET _optionName = "Third"
    WHEN 4
        LET _optionName = "Fourth"
    END CASE

    LET _message[1] = "You have selected the ", _optionName CLIPPED, " option from the"
    LET _message[2] = " DEMO menu."
    CALL messageWindow(6, 4)
END FUNCTION -- dsplyOption 

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

FUNCTION _initMsgs()
    DEFINE i SMALLINT

    FOR i = 1 TO 5
        LET _message[i] = NULL
    END FOR
END FUNCTION -- _initMsgs --

GLOBALS
    DEFINE _arrayMessage ARRAY[5] OF CHAR(48)
END GLOBALS

MAIN
    DEFINE  _i          SMALLINT,
            _errCode    INTEGER
    LET _errCode = -3720
    INITIALIZE _arrayMessage TO NULL
    LET _arrayMessage[1] = "The first message."
    LET _arrayMessage[2] = "The second message."
    LET _arrayMessage[3] = "Get error code: ", _errCode USING "-<<<<<<<<<<<<"
    CALL showMessage(5,6,5)
END MAIN

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

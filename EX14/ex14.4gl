DATABASE test4gl
GLOBALS
    DEFINE _message ARRAY[5] OF CHAR(100)
END GLOBALS

MAIN
    LET _message[1] = " Manufacturer Listing Report"
    IF promptWindow("Do you want to display this report?", 5, 10)
    THEN
        CALL manufListing()
    END IF
END MAIN

FUNCTION manufListing()
    DEFINE _paManuf RECORD
        _manuCode LIKE manufact._manuCode,
        _manuName LIKE manufact._manuName,
        _leadTime LIKE manufact._leadTime
    END RECORD

    DECLARE _cManuf CURSOR FOR
    SELECT _manuCode, _manuName, _leadTime
    FROM manufact
    ORDER BY _manuCode
    
    START REPORT manufRpt
    FOREACH _cManuf INTO _paManuf.*
        OUTPUT TO REPORT manufRpt(_paManuf.*)
    END FOREACH
    FINISH REPORT manufRpt
END FUNCTION -- manufListing --

REPORT manufRpt(_paManuf)
    DEFINE _paManuf RECORD
        _manuCode LIKE manufact._manuCode,
        _manuName LIKE manufact._manuName,
        _leadTime LIKE manufact._leadTime
        END RECORD

    OUTPUT
        LEFT MARGIN 0
        RIGHT MARGIN 0
        TOP MARGIN 1
        BOTTOM MARGIN 1
        PAGE LENGTH 23
    FORMAT
        PAGE HEADER
            SKIP 3 LINES
            
            PRINT COLUMN 30, "MANUFACTURER LISTING"
            PRINT COLUMN 31, TODAY USING "ddd. mmm dd, yyyy"
            PRINT COLUMN 31, "Screen Number: ", PAGENO USING "##&"
            
            SKIP 5 LINES 
            
            PRINT COLUMN 2, "Manufacturer",
            COLUMN 17, "Manufacturer",
            COLUMN 34, "Lead Time"
            PRINT COLUMN 6, "Code",
            COLUMN 21, "Name",
            COLUMN 36, "(in days)"
            
            PRINT "----------------------------------------";
            PRINT "----------------------------------------"
            SKIP 1 LINE
            
        ON EVERY ROW
            PRINT COLUMN 6, _paManuf._manuCode,
            COLUMN 16, _paManuf._manuName,
            COLUMN 36, _paManuf._leadTime
        PAGE TRAILER
            SKIP 1 LINE

        PAUSE "Press RETURN to display next screen."
END REPORT -- manufRpt --

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


MAIN
    CALL displayForm(3)
END MAIN

FUNCTION displayForm(_sleepSeconds)
    DEFINE 	_sleepSeconds	SMALLINT,
            _theDate        DATE
    OPEN FORM _frm FROM "ex1"
    DISPLAY FORM _frm
    DISPLAY "HELLO! INFORMIX 4GL" AT 2,15 ATTRIBUTE (REVERSE, GREEN)
    LET _theDate = TODAY
    DISPLAY _theDate TO formonly.appdate
    SLEEP _sleepSeconds
    CLOSE FORM _frm
END FUNCTION

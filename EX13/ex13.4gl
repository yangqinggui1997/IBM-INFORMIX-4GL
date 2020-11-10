MAIN
    DEFINE arg SMALLINT,
    fstat SMALLINT,
    anarg CHAR(80)
    
    IF NUM_ARGS() = 0 
    THEN
        LET anarg = " "
        CALL fdump(anarg) RETURNING fstat
    ELSE
        FOR arg = 1 TO NUM_ARGS()
            LET anarg = ARG_VAL(arg)
            CALL fdump(anarg) RETURNING fstat
            IF fstat <> NOTFOUND 
            THEN
                EXIT FOR
            END IF
        END FOR
    END IF
    
    IF fstat <> NOTFOUND 
    THEN -- quit due to a problem, diagnose
        CASE fstat
        WHEN -1
            DISPLAY "\nUnable to open file ", anarg CLIPPED, ".\n"
        WHEN -2
            DISPLAY "\nToo many files open in fglgets().\n"
        WHEN -3
            DISPLAY "\nCall to malloc() failed. Couldn¡¦t open the file.\n"
        WHEN -4
            DISPLAY "\nToo many parameters to fglgets().\n"
        OTHERWISE
            DISPLAY "\nUnknown return ",fstat," from fglgets().\n"
        END CASE
        PROMPT "Press RETURN to continue." FOR anarg
    END IF
END MAIN

FUNCTION fdump(fname)
    DEFINE fname CHAR(80),
    inline CHAR(255),
    ret SMALLINT
    
    CALL fglgets(fname) RETURNING inline
    LET ret = fglgetret()
    IF ret = 0 
    THEN -- successful read of first line
        IF fname <> " " 
        THEN
            DISPLAY "-------------- dumping file ", fname CLIPPED, "----------------"
        END IF
        WHILE ret = 0
            DISPLAY inline CLIPPED
            CALL fglgets(fname) RETURNING inline
            LET ret = fglgetret()
        END WHILE
        IF ret = NOTFOUND AND fname <> " " 
        THEN
            DISPLAY "\n-------------- end file ",
            fname CLIPPED,
            "----------------\n"
            SLEEP 3
        END IF
    END IF
    RETURN ret
END FUNCTION -- fdump --
GLOBALS
# used by init_msgs(), message_window(), and prompt_window() to allow
# user to display text in a message or prompt window.
 DEFINE ga_dsplymsg ARRAY[5] OF CHAR(48)
END GLOBALS
########################################
MAIN
########################################
 DEFINE i SMALLINT,
 dbstat INTEGER
 LET dbstat = -3720
 INITIALIZE ga_dsplymsg TO NULL
 LET ga_dsplymsg[1] = "The record has not been inserted into the"
 LET ga_dsplymsg[2] = " database due to an error: ",
 dbstat USING "-<<<<<<<<<<<"
 CALL message_window(5,6)
END MAIN

FUNCTION message_window(x,y)
#######################################
 DEFINE numrows SMALLINT,
 x,y SMALLINT,
 rownum,i SMALLINT,
 answer CHAR(1),
 array_sz SMALLINT -- size of the ga_dsplymsg array
 LET array_sz = 5
 LET numrows = 4 -- * numrows value:
 -- * 1 (for the window header)
 -- * 1 (for the window border)
 -- * 1 (for the empty line before
 -- * the first line of message)
 -- * 1 (for the empty line after
 -- * the last line of message)
 FOR i = 1 TO array_sz
 IF ga_dsplymsg[i] IS NOT NULL THEN
 LET numrows = numrows + 1
 END IF
 END FOR
 
OPEN WINDOW w_msg AT x, y
 WITH numrows ROWS, 52 COLUMNS
 ATTRIBUTE (BORDER, PROMPT LINE LAST)
 DISPLAY " APPLICATION MESSAGE" AT 1, 17
 ATTRIBUTE (REVERSE, BLUE)
 LET rownum = 3 -- * start text display at third line
 FOR i = 1 TO array_sz
 IF ga_dsplymsg[i] IS NOT NULL THEN
 DISPLAY ga_dsplymsg[i] CLIPPED AT rownum, 2
 LET rownum = rownum + 1
 END IF
 END FOR
  PROMPT " Press RETURN to continue." FOR answer
 CLOSE WINDOW w_msg
CALL init_msgs()
END FUNCTION -- message_window --
########################################
FUNCTION init_msgs()
########################################
 DEFINE i SMALLINT
FOR i = 1 TO 5
 LET ga_dsplymsg[i] = NULL
 END FOR
END FUNCTION -- init_msgs --

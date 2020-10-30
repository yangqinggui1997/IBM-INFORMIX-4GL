GLOBALS
# used by init_msgs(), message_window(), and prompt_window() to allow
# user to display text in a message or prompt window.
 DEFINE ga_dsplymsg ARRAY[5] OF CHAR(255)
END GLOBALS
MAIN
########################################
 OPTIONS
 HELP FILE "hlpmsgs",
 PROMPT LINE LAST
 DISPLAY
 "---------------------------------------Press CTRL-W for Help----------"
 AT 3, 1
 MENU "DEMO MENU"
 COMMAND "First" "This is the first option of the menu." HELP 1
 CALL dsply_option(1)
 COMMAND "Second" "This is the second option of the menu." HELP 2
 CALL dsply_option(2)
 COMMAND "Third" "This is the third option of the menu." HELP 3
 CALL dsply_option(3)
 COMMAND "Fourth" "This is the fourth option of the menu." HELP 4
 CALL dsply_option(4)
 COMMAND KEY ("!")
 CALL bang()
 COMMAND "Exit" "Exit the program." HELP 100
 EXIT MENU
 END MENU
 CLEAR SCREEN
END MAIN

#######################################
FUNCTION dsply_option(option_num)
#######################################
 DEFINE option_num SMALLINT,
 option_name CHAR(50)
 CASE option_num
 WHEN 1
 LET option_name = "First          "
 WHEN 2
 LET option_name = "Second"
 WHEN 3
 LET option_name = "Third"
 WHEN 4
 LET option_name = "Fourth"
 END CASE
 LET ga_dsplymsg[1] = "You have selected the ", option_name CLIPPED,
 " option from the"
 LET ga_dsplymsg[2] = " DEMO menu."
 CALL message_window(6, 4)
END FUNCTION -- dsply_option 

########################################
FUNCTION bang()
########################################
 DEFINE cmd CHAR(80),
 key_stroke CHAR(1)
 LET key_stroke = "!"
 WHILE key_stroke = "!"
 PROMPT "unix! " FOR cmd
 RUN cmd
 PROMPT "Type RETURN to continue." FOR CHAR key_stroke
 END WHILE
END FUNCTION -- bang --

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

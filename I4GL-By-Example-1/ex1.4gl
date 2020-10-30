MAIN
########################################
CALL dsply_logo(3)
END MAIN
#######################################
FUNCTION dsply_logo(sleep_secs)
#######################################
DEFINE sleep_secs SMALLINT,
 thedate DATE
  OPEN FORM app_logo FROM "ex1"
 DISPLAY FORM app_logo
DISPLAY " INFORMIX-4GL By Example Application" AT 2,15
 ATTRIBUTE (REVERSE, GREEN)
 LET thedate = TODAY
 DISPLAY thedate TO formonly.appdate
  SLEEP sleep_secs
 CLOSE FORM app_logo
END FUNCTION -- dsply_logo --

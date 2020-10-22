DATABASE stores7
GLOBALS
 DEFINE gr_customer RECORD LIKE customer.*,
 gr_workcust RECORD LIKE customer.*
 DEFINE ga_dsplymsg ARRAY[5] OF CHAR(100)
END GLOBALS

########################################
MAIN
########################################
 DEFINE st_cust CHAR(150)
 OPTIONS
 HELP FILE "hlpmsgs",
 FORM LINE 5,
 COMMENT LINE 5,
 MESSAGE LINE 19
 DEFER INTERRUPT
 OPEN FORM f_customer FROM "../I4GL-By-Example-5/f_customer"
 DISPLAY FORM f_customer
 CALL query_cust2() RETURNING st_cust
 IF st_cust IS NOT NULL THEN
 CALL browse_custs(st_cust)
 END IF
 CLOSE FORM f_customer
 CLEAR SCREEN
END MAIN

########################################
FUNCTION query_cust2()
########################################
 DEFINE q_cust CHAR(100),
 selstmt CHAR(150)
 CALL clear_lines(1,4)
 DISPLAY "CUSTOMER QUERY-BY-EXAMPLE 2" AT 4, 24
 CALL clear_lines(2,16)
 DISPLAY " Enter search criteria and press Accept. Press CTRL-W for Help."
 AT 16,1 ATTRIBUTE (REVERSE, YELLOW)
 DISPLAY " Press Cancel to exit w/out searching."
 AT 17,1 ATTRIBUTE (REVERSE, YELLOW)
 LET int_flag = FALSE
 CONSTRUCT BY NAME q_cust ON customer.customer_num, customer.company,
 customer.address1, customer.address2,
 customer.city, customer.state,
 customer.zipcode, customer.fname,
 customer.lname, customer.phone
 HELP 30
 AFTER CONSTRUCT
 IF (NOT int_flag) THEN
 IF (NOT FIELD_TOUCHED(customer.*)) THEN
 LET ga_dsplymsg[1] = "You did not enter any search criteria."
 IF NOT prompt_window("Do you really want to see all rows?", 9, 15)
 THEN
 CONTINUE CONSTRUCT
 END IF
 END IF
 END IF
 END CONSTRUCT
 IF int_flag THEN
 LET int_flag = FALSE
 CALL clear_lines(2,16)
 CALL msg("Customer query terminated.")
 LET selstmt = NULL
 ELSE
 LET selstmt = "SELECT * FROM customer WHERE ", q_cust CLIPPED
 END IF
 CALL clear_lines(1,4)
 CALL clear_lines(2,16)
  RETURN (selstmt)
END FUNCTION -- query_cust2 --

########################################
FUNCTION browse_custs(selstmt)
########################################
 DEFINE selstmt CHAR(150),
 fnd_custs SMALLINT,
 end_list SMALLINT
 PREPARE st_selcust FROM selstmt
 DECLARE c_cust CURSOR FOR st_selcust
 LET fnd_custs = FALSE
 LET end_list = FALSE
 INITIALIZE gr_workcust.* TO NULL
 FOREACH c_cust INTO gr_customer.*
 LET fnd_custs = TRUE
 DISPLAY BY NAME gr_customer.*
 IF NOT next_action() THEN
 LET end_list = FALSE
 EXIT FOREACH
 ELSE
 LET end_list = TRUE
 END IF
 LET gr_workcust.* = gr_customer.*
 END FOREACH
 CALL clear_lines(2,16)
 IF NOT fnd_custs THEN
 CALL msg("No customers match search criteria.")
 END IF
 IF end_list THEN
 CALL msg("No more customer rows.")
 END IF
 CLEAR FORM
END FUNCTION -- browse_custs --

########################################
FUNCTION next_action()
########################################
 DEFINE nxt_action SMALLINT
 CALL clear_lines(1,16)
 LET nxt_action = TRUE
 DISPLAY
"---------------------------------------Press CTRL-W for Help----------"
 AT 3, 1
 MENU "CUSTOMER MODIFICATION"
 COMMAND "Next" "View next selected customer." HELP 20
 EXIT MENU
 COMMAND "Update" "Update current customer on screen." HELP 21
 IF change_cust() THEN
 CALL update_cust()
 CALL clear_lines(1,16)
 END IF
 NEXT OPTION "Next"
 COMMAND "Delete" "Delete current customer on screen." HELP 22
 CALL delete_cust()
 IF gr_workcust.customer_num IS NOT NULL THEN
 LET gr_customer.* = gr_workcust.*
 DISPLAY BY NAME gr_customer.*
 ELSE
 INITIALIZE gr_customer.* TO NULL
 LET nxt_action = FALSE
 EXIT MENU
 END IF
 NEXT OPTION "Next"
 COMMAND "Exit" "Exit the program." HELP 100
 LET nxt_action = FALSE
 EXIT MENU
 END MENU
 RETURN nxt_action
END FUNCTION -- next_action --
########################################
FUNCTION change_cust()
########################################
 CALL clear_lines(2,16)
 DISPLAY " Press Accept to save new customer data. Press CTRL-W for Help."
 AT 16, 1 ATTRIBUTE (REVERSE, YELLOW)
 DISPLAY " Press Cancel to exit w/out saving."
 AT 17, 1 ATTRIBUTE (REVERSE, YELLOW)
 INPUT BY NAME gr_customer.company, gr_customer.address1,
 gr_customer.address2, gr_customer.city,
 gr_customer.state, gr_customer.zipcode,
 gr_customer.fname, gr_customer.lname, gr_customer.phone
 WITHOUT DEFAULTS HELP 40
 AFTER FIELD company
 IF gr_customer.company IS NULL THEN
 ERROR "You must enter a company name. Please try again."
 NEXT FIELD company
 END IF
 END INPUT
 IF int_flag THEN
 LET int_flag = FALSE
 CALL clear_lines(2,16)
 RETURN (FALSE)
 END IF
 RETURN (TRUE)
END FUNCTION -- change_cust --

#######################################
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
FUNCTION update_cust()
########################################
 WHENEVER ERROR CONTINUE
 UPDATE customer SET customer.* = gr_customer.*
 WHERE customer_num = gr_customer.customer_num
WHENEVER ERROR STOP
 IF (status < 0) THEN
 ERROR status USING "-<<<<<<<<<<<",
 ": Unable to complete customer update."
 RETURN
 END IF
 CALL msg("Customer has been updated.")
END FUNCTION -- update_cust --
########################################
FUNCTION delete_cust()
########################################
 IF (prompt_window("Are you sure you want to delete this?", 10, 15)) THEN
 IF verify_delete() THEN
 WHENEVER ERROR CONTINUE
 DELETE FROM customer
 WHERE customer_num = gr_customer.customer_num
WHENEVER ERROR STOP
 IF (status < 0) THEN
 ERROR status USING "-<<<<<<<<<<<",
 ": Unable to complete customer delete."
 ELSE
 CALL msg("Customer has been deleted.")
 CLEAR FORM
 END IF
 ELSE
 LET ga_dsplymsg[1] = "Customer ",
 gr_customer.customer_num USING "<<<<<<<<<<<",
 " has placed orders and cannot be"
 LET ga_dsplymsg[2] = " deleted."
 CALL message_window(7, 8)
 END IF
 END IF
END FUNCTION -- delete_cust --
########################################
FUNCTION verify_delete()
########################################
 DEFINE cust_cnt INTEGER
 LET cust_cnt = 0
 SELECT COUNT(*)
 INTO cust_cnt
 FROM orders
 WHERE customer_num = gr_customer.customer_num
 IF (cust_cnt IS NOT NULL) AND (cust_cnt > 0) THEN
 RETURN (FALSE)
 END IF
 LET cust_cnt = 0
 SELECT COUNT(*)
 INTO cust_cnt
 FROM cust_calls
 WHERE customer_num = gr_customer.customer_num
 IF (cust_cnt > 0) THEN
 RETURN (FALSE)
 END IF
 RETURN (TRUE)
END FUNCTION -- verify_delete --

########################################
FUNCTION clear_lines(numlines, mrow)
########################################
 DEFINE numlines SMALLINT,
 mrow SMALLINT,
 i SMALLINT
 FOR i = 1 TO numlines
 DISPLAY
 " "
 AT mrow,1
 LET mrow = mrow + 1
 END FOR
END FUNCTION -- clear_lines --

########################################
FUNCTION init_msgs()
########################################
 DEFINE i SMALLINT
 FOR i = 1 TO 5
 LET ga_dsplymsg[i] = NULL
 END FOR
END FUNCTION -- init_msgs --

#######################################
 FUNCTION prompt_window(question, x,y)
#######################################
 DEFINE question CHAR(48),
 x,y SMALLINT,
 numrows SMALLINT,
 rownum,i SMALLINT,
 answer CHAR(1),
 yes_ans SMALLINT,
 ny_added SMALLINT,
 invalid_resp SMALLINT,
 ques_lngth SMALLINT,
 unopen SMALLINT,
 array_sz SMALLINT,
 local_stat SMALLINT
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
 LET unopen = TRUE
 WHILE unopen
 WHENEVER ERROR CONTINUE
 OPEN WINDOW w_prompt AT x, y
 WITH numrows ROWS, 52 COLUMNS
 ATTRIBUTE (BORDER, PROMPT LINE LAST)
WHENEVER ERROR STOP
 LET local_stat = status
 IF (local_stat < 0) THEN
 IF (local_stat = -1138) OR (local_stat = -1144) THEN
 MESSAGE "prompt_window() error: changing coordinates to 3,3."
 SLEEP 2
 LET x = 3
 LET y = 3
 ELSE
 MESSAGE "prompt_window() error: ", local_stat USING "-<<<<<<<<<<<"
 SLEEP 2
 EXIT PROGRAM
 END IF
  ELSE
 LET unopen = FALSE
 END IF
 END WHILE
 DISPLAY " APPLICATION PROMPT" AT 1, 17
 ATTRIBUTE (REVERSE, BLUE)
 LET rownum = 3 -- * start text display at third line
 FOR i = 1 TO array_sz
 IF ga_dsplymsg[i] IS NOT NULL THEN
 DISPLAY ga_dsplymsg[i] CLIPPED AT rownum, 2
 LET rownum = rownum + 1
 END IF
 END FOR
 LET yes_ans = FALSE
 LET ques_lngth = LENGTH(question)
 IF ques_lngth <= 41 THEN -- * room enough to add "(n/y)" string
 LET question [ques_lngth + 2, ques_lngth + 7] = "(n/y):"
 END IF
 LET invalid_resp = TRUE
 WHILE invalid_resp
 PROMPT question CLIPPED, " " FOR answer
 IF answer MATCHES "[nNyY]" THEN
 LET invalid_resp = FALSE
 IF answer MATCHES "[yY]" THEN
 LET yes_ans = TRUE
 END IF
 END IF
 END WHILE
 CALL init_msgs()
 CLOSE WINDOW w_prompt
 RETURN (yes_ans)
END FUNCTION -- prompt_window --

########################################
FUNCTION msg(str)
########################################
 DEFINE str CHAR(78)
MESSAGE str
 SLEEP 3
 MESSAGE ""
END FUNCTION -- msg --

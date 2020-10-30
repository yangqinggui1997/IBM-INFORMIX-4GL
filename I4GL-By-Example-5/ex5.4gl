DATABASE test4gl
GLOBALS
DEFINE gr_customer RECORD LIKE customer.*
END GLOBALS
########################################
MAIN
########################################
OPTIONS
 PROMPT LINE 14,
 MESSAGE LINE 15
DEFER INTERRUPT
OPEN FORM f_customer FROM "f_customer"
 DISPLAY FORM f_customer
 DISPLAY "CUSTOMER QUERY BY EXAMPLE" AT 2, 25
 CALL query_cust1()
 CLOSE FORM f_customer
 CLEAR SCREEN
END MAIN

########################################
FUNCTION query_cust1()
########################################
 DEFINE q_cust CHAR(200),
 selstmt CHAR(250),
 found_some SMALLINT,
 invalid_resp SMALLINT
WHILE TRUE
DISPLAY
 " Press Accept to search for customer data, Cancel to exit w/out searching."
 AT 15,1 ATTRIBUTE (REVERSE, YELLOW)
LET int_flag = FALSE
CONSTRUCT BY NAME q_cust ON customer.customer_num,
 customer.company,
 customer.address1,
 customer.address2,
 customer.city,
 customer.state,
 customer.zipcode,
 customer.fname,
 customer.lname,
 customer.phone
IF int_flag THEN
 LET int_flag = FALSE
 EXIT WHILE
 END IF
--* User hasn't pressed Cancel, clear out selection instructions
DISPLAY
 " "
 AT 15, 1
--* Check to see if user has entered search criteria
IF q_cust = " 1=1" THEN
 IF NOT answer("Do you really want to see all customers? (n/y):")
 THEN
 CONTINUE WHILE
 END IF
END IF
--* Create and prepare the SELECT statement
LET selstmt = "SELECT * FROM customer WHERE ", q_cust CLIPPED
PREPARE st_selcust FROM selstmt
DECLARE c_cust CURSOR FOR st_selcust
--* Execute the SELECT statement and open the cursor to access the rows
OPEN c_cust
--* Fetch first row. If fetch successful, rows found
LET found_some = 0
 FETCH c_cust INTO gr_customer.*
 IF (status = 0) THEN
 LET found_some = 1
 END IF
WHILE (found_some = 1)
--* Display first customer
DISPLAY BY NAME gr_customer.*
--* Fetch next customer (fetch ahead)
FETCH NEXT c_cust INTO gr_customer.*
 IF (status = NOTFOUND) THEN
 LET found_some = -1
 EXIT WHILE
 END IF
--* Ask user if going to view next row
IF NOT answer("Display next customer? (n/y):") THEN
 LET found_some = -2
 END IF
 END WHILE
--* Notify user of various "error" conditions
CASE found_some
 WHEN -1
 CALL msg("End of selected customers.")
 WHEN 0
 CALL msg("No customers match search criteria.")
 WHEN -2
 CALL msg("Display terminated at your request.")
 END CASE
CLOSE c_cust
 END WHILE
DISPLAY
 " "
 AT 15,1
 CLEAR FORM
END FUNCTION -- query_cust1 --

########################################
FUNCTION answer(question)
########################################
 DEFINE question CHAR(50),
 invalid_resp SMALLINT,
 _answer CHAR(1),
 ans_yes SMALLINT
LET invalid_resp = TRUE
 WHILE invalid_resp
PROMPT question CLIPPED FOR _answer
IF _answer MATCHES "[NnYy]" THEN
 LET invalid_resp = FALSE
 LET ans_yes = TRUE
 IF _answer MATCHES "[Nn]" THEN
 LET ans_yes = FALSE
 END IF
END IF
IF _answer MATCHES "[EeQq]" THEN
	EXIT PROGRAM
END IF
 END WHILE
 RETURN ans_yes
END FUNCTION -- answer --


########################################
FUNCTION msg(str)
########################################
 DEFINE str CHAR(78)
MESSAGE str
 SLEEP 3
 MESSAGE ""
END FUNCTION -- msg --
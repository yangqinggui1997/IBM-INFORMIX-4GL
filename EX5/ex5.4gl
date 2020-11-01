DATABASE test4gl
GLOBALS
	DEFINE _grCustomer RECORD LIKE customer.*
END GLOBALS

MAIN
	OPTIONS
 		PROMPT LINE 14,
 		MESSAGE LINE 15
	DEFER INTERRUPT
	
	OPEN FORM _frmCustomer FROM "f_customer"
 	DISPLAY FORM _frmCustomer

 	DISPLAY "CUSTOMER QUERY BY EXAMPLE" AT 2, 25
 	CALL queryCust1()
 	CLOSE FORM _frmCustomer
 	CLEAR SCREEN
END MAIN

FUNCTION queryCust1()
 	DEFINE _qCust CHAR(200),
 			_selstmt CHAR(250),
 			_foundSome SMALLINT,
 			_invalidResp SMALLINT

	WHILE TRUE
		DISPLAY " Press Accept to search for customer data, Cancel to exit w/out searching." AT 15,1 ATTRIBUTE (REVERSE, YELLOW)
		LET int_flag = FALSE
		CONSTRUCT BY NAME _qCust ON customer.customer_num,
 									customer.company,
 									customer.address1,
 									customer.address2,
 									customer.city,
 									customer.state,
 									customer.zipcode,
 									customer.fname,
 									customer.lname,
 									customer.phone
		IF int_flag 
		THEN
 			LET int_flag = FALSE
 			EXIT WHILE
 		END IF
--* User hasn't pressed Cancel, clear out selection instructions
		DISPLAY " " AT 15, 1
--* Check to see if user has entered search criteria
		IF _qCust = " 1=1" 
		THEN
 			IF NOT answer("Do you really want to see all customers? (n/y):")
 			THEN
 				CONTINUE WHILE
 			END IF
		END IF
--* Create and prepare the SELECT statement
		LET _selstmt = "SELECT * FROM customer WHERE ", _qCust CLIPPED
		PREPARE _stSelCust FROM _selstmt
		DECLARE _cCust CURSOR FOR _stSelCust
--* Execute the SELECT statement and open the cursor to access the rows
		OPEN _cCust
--* Fetch first row. If fetch successful, rows found
		LET _foundSome = 0
 		FETCH _cCust INTO _grCustomer.*
 		IF (status = 0) THEN
 			LET _foundSome = 1
 		END IF

		WHILE (_foundSome = 1)
--* Display first customer
			DISPLAY BY NAME _grCustomer.*
--* Fetch next customer (fetch ahead)
			FETCH NEXT _cCust INTO _grCustomer.*
 			IF (status = NOTFOUND) 
			THEN
 				LET _foundSome = -1
 				EXIT WHILE
 			END IF
--* Ask user if going to view next row
			IF NOT answer("Display next customer? (n/y):")
			THEN
 				LET _foundSome = -2
 			END IF
 		END WHILE
--* Notify user of various "error" conditions
		CASE _foundSome
 		WHEN -1
 			CALL msg("End of selected customers.")
 		WHEN 0
 			CALL msg("No customers match search criteria.")
 		WHEN -2
 			CALL msg("Display terminated at your request.")
 		END CASE
		CLOSE _cCust
 	END WHILE
	DISPLAY " " AT 15,1
	CLEAR FORM
END FUNCTION -- _frmCustomer --

FUNCTION answer(_question)
 	DEFINE _question CHAR(50),
 			_invalidResp SMALLINT,
 			_answer CHAR(1),
 			_ansYes SMALLINT

	LET _invalidResp = TRUE
 	WHILE _invalidResp
		PROMPT _question CLIPPED FOR _answer
			IF _answer MATCHES "[NnYy]"
			THEN
 				LET _invalidResp = FALSE
 				LET _ansYes = TRUE
 				IF _answer MATCHES "[Nn]"
				THEN
 					LET _ansYes = FALSE
 				END IF
			END IF
			IF _answer MATCHES "[EeQq]"
			THEN
				EXIT PROGRAM
			END IF
 	END WHILE
 	RETURN _ansYes
END FUNCTION -- answer --

FUNCTION msg(str)
 	DEFINE str CHAR(78)
	MESSAGE str
 	SLEEP 3
 	MESSAGE ""
END FUNCTION -- msg --

DATABASE test4gl

DEFINE _customer RECORD LIKE customer.*
DEFINE _queryStr CHAR(32000),
			_constructQuery CHAR(5000),
			_currentCursor INT,
			_allCursor INT,
			_frm CHAR(255),
			_flagOpenForm CHAR(1),
			_flagOpenCursor CHAR(1),
			_err CHAR(2000)
MAIN
	LET _flagOpenForm = "O"
	LET _frm = "../Forms/frmCustomer"
	LET _allCursor = 0
	LET _currentCursor = 0
	LET _constructQuery = ""
	LET _queryStr = ""
	LET _flagOpenCursor = "C"
	INITIALIZE _customer TO NULL
	
	DEFER INTERRUPT
	WHENEVER ANY ERROR CONTINUE
	OPTIONS 
	PROMPT LINE LAST
	MENU "MENU"
		COMMAND "0. END" "Exit program."
			IF _flagOpenForm MATCHES "[I]" OR _flagOpenForm MATCHES "[S]" THEN
				CLEAR FROM 
				CLOSE FORM _frmCustomer
			END IF
			EXIT MENU
			CLEAR SCREEN
			EXIT PROGRAM			
		COMMAND "1. INQUIRE" "Load data of customers."	
			IF _flagOpenForm MATCHES "[O]" 
			THEN
				LET _flagOpenForm = "I"
				OPEN FORM _frmCustomer FROM _frm
				DISPLAY FORM _frmCustomer
			ELSE
					CLEAR FORM
			END IF
			CALL inquire(0)
		COMMAND "2. INSERT DIRECTLY" "Insert data by input data on form."
			IF _flagOpenForm MATCHES "[O]" 
			THEN
				LET _flagOpenForm = "S"
				OPEN FORM _frmCustomer FROM _frm
				DISPLAY FORM _frmCustomer
			ELSE
					CLEAR FORM
			END IF
			CALL insertDirect()
		COMMAND "3. INSERT BY FILE" "Insert data from one file, that contian pipe."
			CALL insertByFile()
		COMMAND "4. UPDATE" "Update data for customer."
			CALL update()
		COMMAND "5. DELETE ONE" "Delete one customer."
			CALL delete()
		COMMAND "6. DELETE ALL" "Delete all data of customer."
			CALL deleteAll()
		COMMAND "7. BACKUP DATA" "Backup data to your storage."
			CALL backUpData()
		COMMAND "8. REPORT" "Create report."
			CALL exportReport()
		COMMAND "N. NEXT ONE RECORD" "Next one record."
			CALL scrollRecord(TRUE)
		COMMAND "P. PREVIOUS ONE RECORD" "Previous one record."
			CALL scrollRecord(FALSE)
	END MENU
END MAIN

FUNCTION inquire(_option)
	DEFINE _option SMALLINT
	INITIALIZE _customer.* TO NULL
	DISPLAY "" AT 23, 1
	
	CASE _option
	WHEN 0
		CONSTRUCT BY NAME _constructQuery ON customer.* ATTRIBUTE(REVERSE)
	WHEN 1
		LET _constructQuery = "1=1"
	END CASE
	
	LET _queryStr = "SELECT * FROM customer WHERE ", _constructQuery CLIPPED
	PREPARE _prepareCursor FROM _queryStr
	DECLARE _cursorCustomer SCROLL CURSOR FOR _prepareCursor
	IF STATUS < 0 
	THEN
		LET _err = ERR_GET(STATUS)
		ERROR "Error stuck: ", _err CLIPPED
		RETURN
	END IF
	LET _currentCursor = 1
END FUNCTION

FUNCTION insertDirect()
	DEFINE _keyPress INT
	INITIALIZE _customer.* TO NULL
	INPUT BY NAME _customer.* 
		AFTER INPUT
			LET _keyPress = FGL_LASTKEY()
			IF _keyPress == 2011 
			THEN
				ERROR "You are abort!"
			ELSE 
				IF (NOT FIELD_TOUCHED(_customer.fname, _customer.lname, _customer.address1, _customer.city, _customer.state, _customer.phone, _customer.company, _customer.address2, _customer.zipcode))
				THEN
					ERROR "You don't insert data!"
				ELSE 
					IF _customer.fname IS NULL OR _customer.lname IS NULL OR _customer.address1 IS NULL OR _customer.city IS NULL OR _customer.state IS NULL OR _customer.phone IS NULL 
					THEN
						ERROR "Fields (*) is required!"
						NEXT FIELD fname
					ELSE
						BEGIN WORK
							INSERT INTO customer VALUES(_customer.*)
							IF STATUS < 0 
							THEN
								ROLLBACK WORK
								LET _err =  ERR_GET(STATUS)
								ERROR "Error stuck: ", _err CLIPPED
								RETURN
							ELSE
								ERROR "Insert data successfully!"
								CALL inquire(1)
							END IF
						COMMIT WORK
					END IF
				END IF
			END IF
	END INPUT
END FUNCTION

FUNCTION insertByFile()
	DEFINE _prompt CHAR(255)
	PROMPT "Please input file name (include extendtion, file content must has pipe): " FOR _prompt
	LET _prompt = _prompt CLIPPED
	IF _prompt IS NULL 
	THEN
		ERROR "You don't input file name!"
		RETURN
	ELSE
		BEGIN WORK
			LOAD FROM _prompt DELIMITER "|" INSERT INTO customer
			IF STATUS != 0
			THEN
				ROLLBACK WORK
				LET _err = ERR_GET(STATUS)
				ERROR "Error stuck: ", _err CLIPPED
				RETURN
			ELSE
				ERROR "Insert data successfully!"
				CALL inquire(1)
			END IF
		COMMIT WORK
	END IF
END FUNCTION

FUNCTION update()
	DEFINE _keyPress CHAR(1)
	IF _customer.customer_num IS NULL AND (_flagOpenForm MATCHES "[S]" OR _flagOpenForm MATCHES "[O]")
	THEN
		ERROR "Don't have data to update, you must inquire data before!"
		RETURN
	END IF
	INPUT BY NAME _customer.* WITHOUT DEFAULTS
		AFTER INPUT
			LET _keyPress = FGL_LASTKEY()
			IF _keyPress == 2011
			THEN
				ERROR "You are abort!"
				RETURN
			ELSE
				IF FIELD_TOUCHED(_customer.fname, _customer.lname, _customer.company, _customer.address1, _customer.address2, _customer.city, _customer.state, _customer.zipcode, _customer.phone)
				THEN
					BEGIN WORK
						UPADATE customer SET customer.* = _customer.* WHERE customer.customer_num = _customer.customer_num
						IF STATUS != 0
						THEN
							ROLLBACK WORK
							LET _err = ERR_GET(STATUS)
							ERROR "Error stuck: ", _err CLIPPED
							RETURN
						ELSE
							ERROR "Update data successfully!"
							CALL inquire(1)
						END IF
					COMMIT WORK
				ELSE
					ERROR "Data unchanged!"
				END IF
			END IF
	END INPUT
END FUNCTION

FUNCTION delete()
	DEFINE _prompt CHAR(1)
	IF _customer.customer_num IS NULL AND (_flagOpenForm MATCHES "[S]" OR _flagOpenForm MATCHES "[O]")
	THEN
		ERROR "Don't have data to delete, you must inquire data before!"
		RETURN
	END IF

	PROMPT "Are you sure want to delete customer has id [", _customer.customer_num CLIPPED, "], N/n - for uncomfirm, other key for confirm: " FOR _prompt
	IF _prompt MATCHES "[Nn]"
	THEN
		ERROR "You don't confirm to delete!"
		RETURN
	ELSE
		BEGIN WORK
			DELETE FROM customer WHERE customer.customer_num = _customer.customer_num
			IF STATUS != 0
			THEN
				ROLLBACK WORK
				LET _err = ERR_GET(STATUS)
				ERROR "Error stuck: ", _err CLIPPED
				RETURN
			ELSE
				ERROR "Delete customer has id [", _customer.customer_num CLIPPED, "] successfully!"
				CALL inquire(1)
			END IF
		COMMIT WORK
	END IF
END FUNCTION

FUNCTION deleteAll()
	DEFINE _prompt CHAR(1)

	PROMPT "Are you sure want to remove all data of customer? " FOR _prompt
	IF _prompt MATCHES "[Nn]"
	THEN
		ERROR "You don't confirm to delete!"
		RETURN
	ELSE
		BEGIN WORK
			DELETE FROM customer
			IF STATUS != 0
			THEN
				ROLLBACK WORK
				LET _err = ERR_GET(STATUS)
				ERROR "Error stuck: ", _err CLIPPED
				RETURN
			ELSE
				ERROR "Delete data successsfully!"
				CALL inquire(1)
			END IF
		COMMIT WORK
	END IF
END FUNCTION

FUNCTION getUser()
	DEFINE _userName LIKE informix.sysusers.username
	SELECT USER INTO _userName FROM informix.systables
	WHERE tabname = "systables"
	RETURN _userName
END FUNCTION

FUNCTION backUpData()
	DEFINE _prompt CHAR(255)
	DEFINE _path CHAR(255)
	DEFINE _userName CHAR(55)

	CALL getUser() RETURNING _userName
	PROMPT "Please input directory to backup data: " FOR _prompt
	IF _prompt IS NULL 
	THEN
		ERROR "You don't input directory to backup data!"
		RETURN
	ELSE
		LET _path = "/users/", _userName CLIPPED, "/DATA/Download/", _prompt CLIPPED
		UNLOAD TO _path DELIMITER "|" SELECT * FROM customer
		IF STATUS < 0
		THEN
			ROLLBACK WORK
			LET _err = ERR_GET(STATUS)
			ERROR "Error stuck: ", _err CLIPPED
			RETURN
		ELSE
			ERROR "Backup data successfully!"
		END IF
	END IF
END FUNCTION

FUNCTION exportReport()
	DEFINE _trouble INT
	DEFINE _path CHAR(255)
	DEFINE _userName CHAR(55)
	DEFINE _errCode INT
	DEFINE _errMsg CHAR(2000)
	INITIALIZE _customer.* TO NULL

	CALL getUser() RETURNING _userName
	LET _path = "/users/", _userName CLIPPED, "/DATA/Reports/report_", CURRENT YEAR TO SECOND CLIPPED, ".csv"
	DECLARE _cursorReport CURSOR FOR SELECT * FROM customer
	LET _trouble = 0
	START REPORT reportCustomer TO _path
	FOREACH _cursorReport INTO _customer.*
		OUTPUT TO REPORT reportCustomer(_customer.*)
		IF STATUS != 0
		THEN
			LET _trouble = _trouble + 1
			LET _errCode = STATUS
			EXIT FOREACH
		END IF
	END FOREACH
	IF _trouble > 0
	THEN
		TERMINATE REPORT reportCustomer
		LET _errMsg = ERR_GET(_errCode)
		ERROR  "Error stuck: ", _errMsg CLIPPED
	ELSE
		FINISH REPORT reportCustomer
		ERROR "Created report successfully in your account directory!"
	END IF
END FUNCTION

REPORT reportCustomer(_customerRecord)
	DEFINE _customerRecord RECORD LIKE customer.*
	INITIALIZE _customerRecord TO NULL
	FORMAT
		PRINT COLUMN 50 "CUSTOMER INFOMATION"
		SKIP 1 LINE
		PAGE HEADER
			PRINT "Id", COLUMN 5, "Name", COLUMN 35, "Company", COLUMN 55, "Address", COLUMN 95, "City", COLUMN 110, "State", COLUMN 112, "Zipcode", COLUMN 117, "Phone"
			SKIP 1 LINE
		ON EVERY ROW
			PRINT _customer.customer_num, COLUMN 5, _customer.fname, " ", _customer.lname, COLUMN 35, _customer.company, COLUMN 55, "1: ", _customer.address1, " 2: ", _customer.address2, COLUMN 95, _customer.city, COLUMN 110, _customer.state, COLUMN 112, _customer.zipcode, COLUMN 117, _customer.phone
		ON LAST ROW
			PRINT COLUMN 55, "TOTAL CUSTOMER: ", COLUMN 95 , COUNT(*) USING "####"
END REPORT

FUNCTION fetchCursor()
	IF _flagOpenCursor MATCHES "[O]" 
	THEN
		CLOSE _cursorCustomer
		OPEN _cursorCustomer
		LET _flagOpenCursor = "O"
	ELSE
		OPEN _cursorCustomer
		LET _flagOpenCursor = "O"
	END IF
	
	LET _allCursor = 0
	WHILE TRUE
		LET _allCursor = _allCursor + 1
		FETCH ABSOLUTE  _allCursor _cursorCustomer INTO _customer.*
		IF STATUS != 0 THEN
			LET _allCursor = _allCursor - 1
			EXIT WHILE
		END IF
	END WHILE
	IF _allCursor == 0 
	THEN
		CLOSE _cursorCustomer
		LET _flagOpenCursor = "[C]"
		ERROR "Don't have any data!"
	ELSE
		IF _currentCursor > _allCursor 
		THEN _
			LET currentCursor = 1
			ERROR "You are in the top of records!"
		ELSE 
			IF _cursorCustomer < 1 
			THEN 
				LET _currentCursor = _allCursor 
				ERROR "You are in the bottom of records!"
			END IF
		END IF
		FETCH ABSOLUTE _currentCursor _cursorCustomer INTO _customer.*
		DISPLAY BY NAME _customer.*
		DISPLAY "" AT 23,1
		DISPLAY "Display page ", _currentCursor CLIPPED, " of ", _allCursor CLIPPED AT 23, 1
		CLOSE _cursorCustomer
		LET _flagOpenCursor = "[C]"
	END IF
END FUNCTION

FUNCTION scrollRecord(_option)
	DEFINE _option CHAR(1)
	
	IF _flagOpenCursor MATCHES "[C]" 
	THEN
		OPEN _cursorCustomer
		LET _flagOpenCursor = "[O]"
	ELSE
		CLOSE _cursorCustomer
		OPEN _cursorCustomer
		LET _flagOpenCursor = "O"
	END IF
	
	IF _option 
	THEN
		LET _currentCursor = _currentCursor + 1
		FETCH NEXT _cursorCustomer INTO _customer.*
	ELSE
		LET _currentCursor = _currentCursor - 1
		FETCH NEXT _cursorCustomer INTO _customer.*
	END IF
	CALL fetchCursor()
END FUNCTION

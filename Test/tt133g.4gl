DATABASE test4gl@test

#GLOBALS 'kmgbl.4gl'
DEFINE _customer RECORD LIKE customer.*
DEFINE _tmpCustomer RECORD
			customer_num LIKE customer.customer_num,
			fname LIKE customer.fname,
			lname LIKE customer.lname,
			company LIKE customer.company,
			address1 LIKE customer.address1,
			address2 LIKE customer.address2,
			city LIKE customer.city,
			state LIKE customer.state,
			zipcode LIKE customer.zipcode,
			phone LIKE customer.phone,
			action CHAR(1)
			END RECORD

DEFINE _queryStr CHAR(500),
			_constructQuery CHAR(800),
			_currentCursor INT,
			_allCursor INT,
			_frm CHAR(255),
			_flagOpenCursor CHAR(1),
			_err CHAR(2000),
			_flagInquireData SMALLINT,
			_flagChangeData SMALLINT
					
FUNCTION mainfun()
	#LET _frm = "../../scr/frmCustomer"
	LET _frm = "frm/frmCustomer"
	LET _allCursor = 0
	LET _currentCursor = 0
	LET _constructQuery = ""
	LET _queryStr = ""
	LET _flagOpenCursor = "C"
	LET _flagInquireData = FALSE
	INITIALIZE _customer TO NULL
	{
	DEFER INTERRUPT}
	
	#SET LOCK MODE TO WAIT 
	OPTIONS 
	PROMPT LINE LAST
	WHENEVER ANY ERROR CONTINUE
	
	CREATE TEMP TABLE tmpCustomer1
	(
		customer_num SERIAL(101),
		fname CHAR(15),
		lname CHAR(15),
		company CHAR(20),
		address1 CHAR(20),
		address2 CHAR(20),
		city CHAR(15),
		state CHAR(2),
		zipcode CHAR(5),
		phone CHAR(18),
		action CHAR(1)
	)
	
	CREATE TEMP TABLE tmpCustomer2
	(
		customer_num SERIAL(101),
		fname CHAR(15),
		lname CHAR(15),
		company CHAR(20),
		address1 CHAR(20),
		address2 CHAR(20),
		city CHAR(15),
		state CHAR(2),
		zipcode CHAR(5),
		phone CHAR(18)
	);

	INSERT INTO tmpCustomer1 SELECT *, "O" FROM test4gl@test:customer
	LET _flagChangeData = FALSE
	
	OPEN FORM _frmCustomer FROM _frm
	DISPLAY FORM _frmCustomer
	
	
	MENU "MENU"
		COMMAND "0. END" "Exit program."
			IF _flagChangeData THEN CALL confirmSaveData(FALSE) END IF
			CLOSE FORM _frmCustomer
			EXIT MENU
			CLEAR SCREEN
			EXIT PROGRAM
			DROP TABLE tmpCustomer1		
		COMMAND "1. INQUIRE" "Load data of customers."
			CALL inquire(0)
		COMMAND "2. INSERT DIRECTLY" "Insert data by input data on form."
			CALL insertDirect()
			IF _allCursor
			THEN 
				DISPLAY "Display page ", _currentCursor CLIPPED, " of ", _allCursor CLIPPED AT 23, 1
			END IF
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
		COMMAND "9. SAVE ALL CHANGE" "Save all change that you impacted on database."
			CALL confirmSaveData(TRUE)
		COMMAND "N. NEXT ONE RECORD" "Next one record."
			CALL scrollRecord(TRUE, TRUE)
		COMMAND "P. PREVIOUS ONE RECORD" "Previous one record."
			CALL scrollRecord(FALSE, TRUE)
	END MENU
END FUNCTION

FUNCTION confirmSaveData(_option)
	DEFINE _prompt CHAR(1), _option SMALLINT
	
	IF _option
	THEN
		LABEL _prCf:
		PROMPT "Do you want to save all change? " FOR _prompt
		IF _prompt MATCHES "[Yy]" 
		THEN
			CALL inquire(2)
			WHILE _currentCursor <= _allCursor
				BEGIN WORK
					CASE 
					WHEN _tmpCustomer.action MATCHES "[I]"
						INSERT INTO test4gl@test:customer VALUES(_customer.*)
					WHEN _tmpCustomer.action MATCHES "[U]"
						UPDATE test4gl@test:customer SET customer.* = _customer.* WHERE test4gl@test:customer.customer_num = _customer.customer_num
					WHEN _tmpCustomer.action MATCHES "[D]"
						DELETE FROM test4gl@test:customer WHERE test4gl@test:customer.customer_num = _customer.customer_num
					END CASE
					IF STATUS  < 0
					THEN
						ROLLBACK WORK
						LET _err= ERR_GET(STATUS)
						ERROR "Error stuck: ", _err CLIPPED
						RETURN
					END IF
				COMMIT WORK
				CALL scrollRecord(TRUE, FALSE)
			END WHILE
		ELSE
			IF _prompt NOT MATCHES "[Nn]" 
			THEN
				GOTO _prCf
			END IF
		END IF
	ELSE
		CALL inquire(2)
		WHILE _currentCursor <= _allCursor
    	BEGIN WORK
        CASE 
        WHEN _tmpCustomer.action MATCHES "[I]"
            INSERT INTO test4gl@test:customer VALUES(_customer.*)
        WHEN _tmpCustomer.action MATCHES "[U]"
            UPDATE test4gl@test:customer SET customer.* = _customer.* WHERE test4gl@test:customer.customer_num = _customer.customer_num
        WHEN _tmpCustomer.action MATCHES "[D]"
            DELETE FROM test4gl@test:customer WHERE test4gl@test:customer.customer_num = _customer.customer_num
        END CASE
        IF STATUS  < 0
				THEN
					ROLLBACK WORK
					LET _err= ERR_GET(STATUS)
					ERROR "Error stuck: ", _err CLIPPED
					RETURN
				END IF
			COMMIT WORK
    CALL scrollRecord(TRUE, FALSE)
	END WHILE
	END IF
END FUNCTION

FUNCTION inquire(_option)
	DEFINE _option SMALLINT
	INITIALIZE _customer.* TO NULL
	DISPLAY "" AT 23, 1
	
	CLEAR FORM
	CASE _option
	WHEN 0
		CONSTRUCT BY NAME _constructQuery ON customer.* ATTRIBUTE(REVERSE)
	WHEN 1
		LET _constructQuery = "1=1"
	END CASE
	LET _queryStr = "SELECT * FROM test4gl@test:tmpCustomer1 WHERE ", _constructQuery CLIPPED
	PREPARE _prepareCursor FROM _queryStr
	DECLARE _cursorCustomer SCROLL CURSOR FOR _prepareCursor
	
	IF STATUS < 0 
	THEN
		LET _err = ERR_GET(STATUS)
		ERROR "Error stuck: ", _err CLIPPED
		RETURN
	END IF
  LET _currentCursor = 1
  IF _option == 0 OR _option == 1
  THEN 
		CALL fetchCursor(TRUE)
	ELSE
		CALL fetchCursor(FALSE)
	END IF
END FUNCTION

FUNCTION insertDirect()
	DEFINE _keyPress INT
	INITIALIZE _customer.* TO NULL
	LET _flagInquireData = FALSE
	
	CLEAR FORM
	INPUT BY NAME _customer.* 
		AFTER INPUT
			LET _keyPress = FGL_LASTKEY()
			IF _keyPress == 2011 
			THEN
				ERROR "You are abort!"
				SLEEP 1
				CALL inquire(1)
			ELSE 
				IF (NOT FIELD_TOUCHED(_customer.fname, _customer.lname, _customer.address1, _customer.city, _customer.state, _customer.phone, _customer.company, _customer.address2, _customer.zipcode))
				THEN
					ERROR "You don't insert data!"
					SLEEP 1
					CALL inquire(1)
				ELSE 
					IF _customer.fname IS NULL OR _customer.lname IS NULL OR _customer.address1 IS NULL OR _customer.city IS NULL OR _customer.state IS NULL OR _customer.phone IS NULL 
					THEN
						ERROR "Fields (*) is required!"
						NEXT FIELD fname
					ELSE
						BEGIN WORK
							LET _customer.customer_num = 0
							INSERT INTO test4gl@test:tmpCustomer1 VALUES(_customer.*, "I")
							
							IF STATUS < 0 
							THEN
								ROLLBACK WORK
								LET _err =  ERR_GET(STATUS)
								ERROR "Error stuck: ", _err CLIPPED
								RETURN
							ELSE
								LET _flagChangeData = TRUE
								ERROR "Insert data into temp table successfully!"
								SLEEP 1
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
	LET _flagInquireData = FALSE
	
	CLEAR FORM
	PROMPT "Please input directory to file: " FOR _prompt
	LET _prompt = _prompt CLIPPED
	IF _prompt IS NULL 
	THEN
		ERROR "You don't input file name!"
		SLEEP 1
		CALL inquire(1)
		RETURN
	ELSE
		BEGIN WORK
			LOAD FROM _prompt DELIMITER "|" INSERT INTO test4gl@test:tmpCustomer2
			INSERT INTO tmpCustomer1 SELECT *, "I" FROM tmpCustomer2
			IF STATUS != 0
			THEN
				ROLLBACK WORK
				LET _err = ERR_GET(STATUS)
				ERROR "Error stuck: ", _err CLIPPED
				RETURN
			ELSE
				LET _flagChangeData = TRUE
				ERROR "Insert data into temp table successfully!"
				SLEEP 1
				CALL inquire(1)
			END IF
		COMMIT WORK
	END IF
END FUNCTION

FUNCTION update()
	DEFINE _keyPress CHAR(1)
	IF _customer.customer_num IS NULL AND NOT _flagInquireData
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
						UPDATE test4gl@test:tmpCustomer1 SET test4gl@test:tmpCustomer1.* = (_customer, "U") WHERE test4gl@test:tmpCustomer1.customer_num = _customer.customer_num
						IF STATUS != 0
						THEN
							ROLLBACK WORK
							LET _err = ERR_GET(STATUS)
							ERROR "Error stuck: ", _err CLIPPED
							RETURN
						ELSE
							LET _flagChangeData = TRUE
							ERROR "Update into temp table successfully!"
							SLEEP 1
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
	IF _customer.customer_num IS NULL AND NOT _flagInquireData
	THEN
		ERROR "Don't have data to delete, you must inquire data before!"
		RETURN
	END IF
	LABEL _prmp:
	PROMPT "Are you sure want to delete customer has id [", _customer.customer_num CLIPPED, "], N/n - for uncomfirm, other key for confirm: " FOR _prompt
	IF _prompt MATCHES "[Nn]"
	THEN
		ERROR "You don't confirm to delete!"
		RETURN
	ELSE
		IF _prompt MATCHES "[Yy]" 
		THEN
			BEGIN WORK
				UPDATE test4gl@test:tmpCustomer1 SET test4gl@test4gl:tmpCustomer1.* = (_customer.*, "D") WHERE test4gl@test:tmpCustomer1.customer_num = _customer.customer_num
				IF STATUS < 0
				THEN
					ROLLBACK WORK
					LET _err = ERR_GET(STATUS)
					ERROR "Error stuck: ", _err CLIPPED
					RETURN
				ELSE
					LET _flagChangeData = TRUE
					ERROR "Delete customer has id [", _customer.customer_num CLIPPED, "] from temp table successfully!"
					SLEEP 1
					CALL inquire(1)
				END IF
			COMMIT WORK
		ELSE
			GOTO _prmp
		END IF
	END IF
END FUNCTION

FUNCTION deleteAll()
	DEFINE _prompt CHAR(1)
	
	LABEL _prmpDelAl:
	PROMPT "Are you sure want to remove all data of customer? " FOR _prompt
	IF _prompt MATCHES "[Nn]"
	THEN
		ERROR "You don't confirm to delete!"
		SLEEP 1
		CALL inquire(1)
		RETURN
	ELSE
		IF _prompt MATCHES "[Yy]"
		THEN
			CALL inquire(2)
			WHILE _currentCursor <= _allCursor
				BEGIN WORK
					UPDATE _tmpCustomer1 SET _tmpCustomer1.* = (_customer.*, "D") WHERE test4gl@test:tmpCustomer1.customer_num = _customer.customer_num
					IF STATUS != 0
					THEN
						ROLLBACK WORK
						LET _err = ERR_GET(STATUS)
						ERROR "Error stuck: ", _err CLIPPED
						RETURN
					END IF
					CALL scrollRecord(TRUE, FALSE)
				END WHILE
				LET _flagChangeData = TRUE
		ELSE
			GOTO _prmpDelAl
		END IF
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
	
	IF _flagChangeData
	THEN
		PROMPT "Changes isn't save yet, do you want to save all change before export data? "
		IF _prompt MATCHES "[yY]"
		THEN 
			CALL confirmSaveData(FALSE)
		END IF
	END IF
	
	CALL getUser() RETURNING _userName
	PROMPT "Please input file name, file storage in your account directory: " FOR _prompt
	IF _prompt IS NULL 
	THEN
		ERROR "You don't input directory to backup data!"
		RETURN
	ELSE
		LET _path = "/users/", _userName CLIPPED, "/DATA/Download/", _prompt CLIPPED, ".csv"
		UNLOAD TO _path DELIMITER "|" SELECT * FROM test4gl@test:customer
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
	DEFINE _prompt CHAR(1)
	INITIALIZE _customer.* TO NULL

	IF _flagChangeData
	THEN
		PROMPT "Changes isn't save yet, do you want to save all change before export data? "
		IF _prompt MATCHES "[yY]"
		THEN 
			CALL confirmSaveData(FALSE)
		END IF
	END IF
	
	CALL getUser() RETURNING _userName
	LET _path = "/users/", _userName CLIPPED, "/DATA/Reports/report_", CURRENT YEAR TO SECOND CLIPPED, ".csv"
	DECLARE _cursorReport CURSOR FOR SELECT * FROM test4gl@test:customer
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
	FORMAT
		PAGE HEADER
			PRINT COLUMN 50, "CUSTOMER INFOMATION"
			SKIP 1 LINE
			PRINT "Id", COLUMN 5, "Name", COLUMN 35, "Company", COLUMN 56, "Address", COLUMN 96, "City", COLUMN 111, "State ", COLUMN 117, "Zipcode ", COLUMN 124, "Phone"
			SKIP 1 LINE
		ON EVERY ROW
			PRINT _customerRecord.customer_num CLIPPED USING "-<<<<<<<<", " ", COLUMN 5, _customerRecord.fname CLIPPED, " ", _customerRecord.lname CLIPPED, " ", COLUMN 35, _customerRecord.company CLIPPED, " ", COLUMN 56, "1: ", _customerRecord.address1 CLIPPED, " 2: ", _customerRecord.address2 CLIPPED, " ", COLUMN 96, _customerRecord.city CLIPPED, " ", COLUMN 111, _customerRecord.state CLIPPED, " ", COLUMN 117, _customerRecord.zipcode CLIPPED, " ", COLUMN 124, _customerRecord.phone
		ON LAST ROW
			PRINT COLUMN 55, "TOTAL CUSTOMER: ", COLUMN 95 , COUNT(*) USING "####"
END REPORT

FUNCTION fetchCursor(_option)
	DEFINE _option SMALLINT
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
		LET _flagOpenCursor = "C"
		IF _option THEN ERROR "Don't have any data!" END IF
	ELSE
		IF _currentCursor > _allCursor OR _currentCursor == 1
		THEN 
			LET _currentCursor = 1
			IF _option THEN ERROR "You are in the top of records!" END IF
		ELSE 
			IF _currentCursor < 1 OR _currentCursor == _allCursor
			THEN 
				LET _currentCursor = _allCursor 
				IF _option THEN ERROR "You are in the bottom of records!" END IF
			END IF
		END IF
		FETCH ABSOLUTE _currentCursor _cursorCustomer INTO _customer.*
		FETCH ABSOLUTE _currentCursor _cursorCustomer INTO _tmpCustomer.*
		IF _option
		THEN 
			IF _tmpCustomer.action NOT MATCHES "[D]"
			THEN
				DISPLAY BY NAME _customer.*
				DISPLAY "" AT 23,1
				DISPLAY "Display page ", _currentCursor CLIPPED, " of ", _allCursor CLIPPED AT 23, 1
			END IF
		END IF
		CLOSE _cursorCustomer
		LET _flagOpenCursor = "C"
	END IF
END FUNCTION

FUNCTION scrollRecord(_option1, _option2)
	DEFINE _option1 SMALLINT, _option2 SMALLINT
	
	IF _flagOpenCursor MATCHES "[C]" 
	THEN
		OPEN _cursorCustomer
		LET _flagOpenCursor = "O"
	ELSE
		CLOSE _cursorCustomer
		OPEN _cursorCustomer
		LET _flagOpenCursor = "O"
	END IF
	
	IF _option1
	THEN
		LET _currentCursor = _currentCursor + 1
		FETCH NEXT _cursorCustomer INTO _customer.*
		FETCH NEXT _cursorCustomer INTO _tmpCustomer.*
	ELSE
		LET _currentCursor = _currentCursor - 1
		FETCH NEXT _cursorCustomer INTO _customer.*
		FETCH NEXT _cursorCustomer INTO _tmpCustomer.*
	END IF
	IF _option2 THEN CALL fetchCursor(TRUE) ELSE CALL fetchCursor(FALSE) END IF
END FUNCTION
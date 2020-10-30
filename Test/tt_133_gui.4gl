DATABASE test4gl@test
DEFINE _trouble INT
DEFINE _test RECORD LIKE test.*
DEFINE _Pfrm         CHAR(20)
DEFINE _cnt INTEGER,
		_allCnt INTEGER,
        _whStr CHAR(500),
        _qryStr CHAR(800),
        _opCode CHAR(1),
        _flagOpenForm CHAR(1)
MAIN
	DEFER INTERRUPT 
	OPTIONS
	PROMPT LINE LAST
	INITIALIZE _test.* TO NULL
	LET _opCode = "C"
	LET _flagOpenForm = "O"
   	LET _Pfrm = "../../scr/test1"
    MENU "MENU"
        COMMAND "0.END" "HELP: EXIT,Return previous menu,Ctrl-P Basic help"
            HELP 0001 
            IF _flagOpenForm MATCHES "[I]" OR _flagOpenForm MATCHES "[S]" THEN
               	CALL csetInt() CALL curFun()
               	CLEAR FORM  	
      			CLOSE FORM _tt133gui
            END IF
            EXIT MENU
        COMMAND "1.INQUIRE" "HELP: Inquire data, Esc to run, Del to abort"
            HELP 0001
            INITIALIZE _test.* TO NULL
            IF _flagOpenForm MATCHES "[O]" THEN 
   				LET _flagOpenForm = "I"
   				OPEN FORM _tt133gui FROM _Pfrm
   				DISPLAY FORM _tt133gui
   			ELSE
   				CLEAR FORM
   			END IF
        	CALL csetInt() CALL inqFun(0)
        COMMAND "2.INSERT A RECORD" "HELP: Insert a record, Esc to run, Del to abort"
            HELP 0001
            INITIALIZE _test.* TO NULL
            IF _flagOpenForm MATCHES "[O]" THEN 
            	LET _flagOpenForm = "S"
               	OPEN FORM _tt133gui FROM _Pfrm
   				DISPLAY FORM _tt133gui
   			ELSE
   				CLEAR FORM
   			END IF
            CALL csetInt() CALL addFun()
        COMMAND "3.INSERT BY FILE" "HELP: Insert data by a file, file is contain pipe seperate between COLUMNS"
            HELP 0001
            CALL adByFile()
        COMMAND "4.UPDATE" "HELP: Update data, Esc to run, Del to abort. You need enquire before!"
            HELP 0001
            IF _test.a IS NOT NULL AND (_flagOpenForm MATCHES "[I]" OR _flagOpenForm MATCHES "[S]") THEN
                CALL csetInt() CALL updFun()
            ELSE
                ERROR "Don't have data to update."
            END IF
        COMMAND "5.DELETE" "HELP: Delete data, Esc to run, Del to abort. You need enquire before!"
            HELP 0001
            IF _test.a IS NOT NULL AND (_flagOpenForm MATCHES "[I]" OR _flagOpenForm MATCHES "[S]") THEN
                CALL csetInt() CALL deFun()
            ELSE
            	ERROR "Don't have data to delete."
            END IF
            COMMAND "6.DELETE ALL DATA" "HELP: Remove all data table"
            HELP 0001
            CALL delAllData()
		COMMAND "7.BACKUP DATA" "HELP: Backup data to local machine"
            HELP 0001
            CALL backupData()
		COMMAND "8.CREATE REPORT" "HELP: Output report"
            HELP 0001
            INITIALIZE _test.* TO NULL
			CALL exportReport()
        COMMAND "N.Page Down" "HELP:   Display next page, Ctrl-P  Basic help"
            HELP 0001
            CALL csetInt() CALL pgFun(TRUE)
        COMMAND "U.Page Up" "HELP:   Display previous page, Ctrl-P Basic help "
            HELP 0001
            CALL csetInt() CALL pgFun(FALSE)
        COMMAND "H.HELP" "HELP: Operation help"
        	ERROR "Unreleased file support!"
      END MENU
END MAIN

FUNCTION csetInt()
  LET INT_FLAG = FALSE
END FUNCTION

FUNCTION inqFun(_ops)
	DEFINE _ops SMALLINT
 	DISPLAY "" AT 23,1
 	WHENEVER ERROR CONTINUE
 	IF _flagOpenForm MATCHES "[O]" AND _ops <> 2 THEN 
 		LET _flagOpenForm = "I"
 		OPEN FORM _tt133gui FROM _Pfrm
 		DISPLAY FORM _tt133gui
 	END IF
 	IF _ops == 1 THEN LET _whStr = "1=1"
 	ELSE
 		CONSTRUCT BY NAME _whStr ON test.* ATTRIBUTE(REVERSE)
  		IF INT_FLAG THEN
      	LET INT_FLAG = FALSE
     		CLEAR FORM
   	   	RETURN
   		END IF
  	END IF
 	LET _qryStr ="SELECT * FROM test WHERE ", _whStr CLIPPED
 	PREPARE _cnt_exe FROM _qryStr
	DECLARE _cnt_cur SCROLL CURSOR FOR _cnt_exe
	IF STATUS < 0 THEN
		ERROR "Something went wrong!, can't inquire data!"
	END IF
 	LET _cnt = 1
  	IF _opCode MATCHES "[C]" THEN
 		LET _opCode = "O"
 		OPEN _cnt_cur
 	ELSE 
		IF  _opCode MATCHES "[O]" THEN
 			CLOSE _cnt_cur
 			LET _opCode = "C"
 		END IF
 	END IF
 	CALL reopen()
END FUNCTION

FUNCTION getUser()
	DEFINE _uid LIKE informix.sysusers.username
	SELECT USER INTO _uid FROM informix.systables
	WHERE tabname = "systables"
	RETURN _uid
END FUNCTION

FUNCTION adByFile()
	DEFINE _prompt CHAR(255)
	#DEFINE _path CHAR(255)
	#DEFINE _userName CHAR(55)
	#CALL getUser() RETURNING _userName
	PROMPT "Please prompt file name, that include extention: " FOR _prompt
	#LET _path = "/users/", _userName CLIPPED, "/DATA/Upload/", _prompt CLIPPED
	BEGIN WORK
	WHENEVER ERROR CONTINUE
		#LOAD FROM _path DELIMITER "|" INSERT INTO test
		LOAD FROM _prompt DELIMITER "|" INSERT INTO test
		IF STATUS < 0 THEN 
			ROLLBACK WORK
			ERROR "Something went wrong, the problem can come from bad directory!"
			RETURN
		END IF
	COMMIT WORK
	CALL inqFun(1)
END FUNCTION

FUNCTION backupData()
	DEFINE _prompt CHAR(255)
	DEFINE _path CHAR(255)
	DEFINE _userName CHAR(55)
	CALL getUser() RETURNING _userName
	PROMPT "Please prompt directory to file, that include file name and extention: " FOR _prompt
	LET _path = "/users/", _userName CLIPPED, "/DATA/Download/", _prompt CLIPPED
	BEGIN WORK
		WHENEVER ERROR CONTINUE
		UNLOAD TO _path DELIMITER "|" SELECT * FROM test
		IF STATUS < 0 THEN 
			ROLLBACK WORK
			ERROR "Something went wrong, the problem can come from bad directory!"
			RETURN
		END IF
	COMMIT WORK
	ERROR "Data is backed up!"
END FUNCTION

FUNCTION addFun()
	DEFINE _key INT
 	INPUT BY NAME _test.*
 		AFTER INPUT 
 			IF (NOT FIELD_TOUCHED(_test.a, _test.b, _test.c, _test.d)) THEN
 				ERROR "You don't insert data!!"
 			ELSE
 				IF _test.a IS NOT NULL THEN
 					LET _key = FGL_LASTKEY()
 					IF _key <> 2011 THEN #user press delete button to abort
 					BEGIN WORK
 						WHENEVER ERROR CONTINUE
						INSERT INTO test VALUES(_test.a, _test.b, _test.c, _test.d)
						IF STATUS < 0 THEN 
							ROLLBACK WORK
							ERROR "Something went wrong!, can't insert data."
							RETURN
						END IF
						ERROR "Insert data successfully!"
					COMMIT WORK
					CALL inqFun(1)
					ELSE
						ERROR "You aborted!"
					END IF
				ELSE
					IF _test.b IS NOT NULL OR _test.c IS NOT NULL OR _test.d IS NOT NULL THEN
						ERROR "You are missing field a, insert data to this field before save!"
						NEXT FIELD a
					END IF
				END IF
			END IF
 		END INPUT
END FUNCTION

FUNCTION updFun()
	DEFINE _key INT
	INPUT BY NAME _test.b, _test.c, _test.d WITHOUT DEFAULTS
	AFTER INPUT
		IF FIELD_TOUCHED(_test.b, _test.c, _test.d) THEN
			LET _key = FGL_LASTKEY()
 			IF _key <> 2011 THEN #user press delete button to abort
				BEGIN WORK
					WHENEVER ERROR CONTINUE
					UPDATE test SET b = _test.b, c = _test.c, d = _test.d WHERE a = _test.a
					IF STATUS < 0 THEN 
						ROLLBACK WORK
						ERROR "Something went wrong!, can't update data."
						RETURN
					END IF
					ERROR "Update data successfully!"
				COMMIT WORK
				CALL inqFun(1)
			ELSE
				ERROR "You aborted!"
			END IF
		ELSE
			ERROR "Data is Unchange!"
		END IF
	END INPUT
END FUNCTION

FUNCTION deFun()
	DEFINE _prompt CHAR(255)
	PROMPT "Are you sure want to delete this record, N - For unconfirm, Anything key for confirm? " FOR _prompt
	IF LENGTH(_prompt) > 255 THEN
		ERROR "You prompt over 255 character! it aborted."
	ELSE
		IF _prompt NOT MATCHCLOSE _cursorCustomer
		LET _flagOpenCursor = "[C]"ES "[Nn]" THEN
			IF _test.a IS NOT NULL THEN
				BEGIN WORK
					WHENEVER ERROR CONTINUE
					DELETE FROM test WHERE a = _test.a
					IF STATUS < 0 THEN 
						ROLLBACK WORK
						ERROR "Something went wrong!, can't delete data."
						RETURN
					END IF
					ERROR "Delete data successfully!"
				COMMIT WORK
				CALL inqFun(1)
			ELSE
				ERROR "Object isn't exists!"
			END IF
		ELSE
			ERROR "You don't confirm to delete!"
		END IF
	END IF
END FUNCTION

FUNCTION delAllData()
	DEFINE _prompt CHAR(1)
	PROMPT "Are you sure want to delete all data, N for unconfirm, any other for confirm? " FOR _prompt
	IF _prompt NOT MATCHES "[Nn]" THEN
		BEGIN WORK
		WHENEVER ERROR CONTINUE
		DELETE FROM test
		IF STATUS < 0 THEN
			ROLLBACK WORK
			ERROR "Something went wrong!, can't delete all data table."
			RETURN
		END IF
		COMMIT WORK
		ERROR "Delete datas successfully!"
		SLEEP 1
		ERROR "System moved to inquire option!"
		SLEEP 1
		CALL inqFun(2)
	ELSE
		ERROR "You don't confirm to delete!"
	END IF
END FUNCTION

FUNCTION curFun()
   	IF _opCode MATCHES "[O]" THEN
       	CLOSE _cnt_cur
       	LET _opCode = "C"
   	END IF
END FUNCTION

FUNCTION pgFun(_move)
   	DEFINE _move CHAR(1)
   	IF _opCode = "C" THEN
   			OPEN _cnt_cur
   			LET _opCode = "O"
   	END IF 
   	IF _move = TRUE THEN
   	   	FETCH NEXT _cnt_cur INTO _test.*
      	LET _cnt = _cnt + 1
   	ELSE
    	FETCH NEXT _cnt_cur INTO _test.*
       	LET _cnt = _cnt - 1
   	END IF
   	CALL reopen()
END FUNCTION

FUNCTION reopen()
	IF _opCode MATCHES "[C]" THEN
   	OPEN _cnt_cur
   	LET _opCode = "O"
  END IF
   	LET _allCnt = 0
   	WHILE TRUE
   	    LET _allCnt = _allCnt + 1
        FETCH ABSOLUTE _allCnt _cnt_cur INTO _test.*
        IF STATUS != 00 THEN
        	LET _allCnt = _allCnt - 1
            EXIT WHILE
        END IF
   	END WHILE
   	CLEAR FORM
   	IF _allCnt = 0 THEN
      	LET _opCode = "C"
      	CLOSE _cnt_cur
      	ERROR "Don't have any data!"
   	ELSE
   	   	IF _cnt == 1 OR _cnt > _allCnt THEN 
       		LET _cnt = 1 
       		ERROR "You are staying on the top of records!"
       	ELSE 
       		IF _cnt < 1 OR _cnt == _allCnt THEN 
       			LET _cnt = _allCnt
       			ERROR "You are staying on the bottom of records!"
       		END IF
       	END IF
    	FETCH ABSOLUTE _cnt _cnt_cur INTO _test.*
		DISPLAY BY NAME _test.*
       	DISPLAY "" AT 23,1
       	DISPLAY "  Current page is page  ", _cnt , ", Total pages: ", _allCnt AT 23,1
   END IF
END FUNCTION

REPORT testReport(_testRecord)
	DEFINE _testRecord RECORD LIKE test.*
	FORMAT
		PAGE HEADER
			PRINT "A", COLUMN 12, "B", COLUMN 24, "C", COLUMN 36, "D"
			SKIP 1 LINE
		ON EVERY ROW
			PRINT _testRecord.a USING "####", COLUMN 12, _testRecord.b USING "####", COLUMN 24, _testRecord.c USING "####", COLUMN 36, _testRecord.d USING "####"
		ON LAST ROW
			SKIP 1 LINE
			PRINT COLUMN 12, "TOTAL NUMBER OF RECORDS:", COLUMN 36, COUNT(*) USING "##"
END REPORT

FUNCTION exportReport()
	DEFINE _path CHAR(255)
	DEFINE _userName CHAR(55)
	WHENEVER ANY ERROR GOTO  :err	
	CALL getUser() RETURNING _userName
	DECLARE _cursorReport CURSOR FOR SELECT * FROM test
	LET _trouble = 0
	LET _path = "/users/", _userName CLIPPED, "/DATA/Reports/report_", CURRENT YEAR TO SECOND CLIPPED, ".csv" CLIPPED
	START REPORT testReport TO _path
	FOREACH _cursorReport INTO _test.*
		OUTPUT TO REPORT testReport(_test.*)
		IF STATUS != 0 THEN
			LET _trouble = _trouble + 1
			EXIT FOREACH
		END IF
	END FOREACH
	LABEL err:
	IF _trouble > 0 THEN
		TERMINATE REPORT testReport
		ERROR "Something went wrong, can't create report!"
	ELSE IF _trouble == 0 THEN
		FINISH REPORT testReport
		ERROR "Report is created in your account directory!"
		END IF
	END IF 
END FUNCTION

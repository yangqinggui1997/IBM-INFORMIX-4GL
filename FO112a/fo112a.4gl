# PRGNAM: fo112a.4gl
# PRGFUN: 異常工時機台基本輸入
# AUTHOR: Gui
# FORMS : fo112a.PER
# LIB   : w213
# DATE  : 2020-11-18

--> DEFINE some global variable, which is declared in kmgbl.4gl file 
GLOBALS 'kmgbl.4gl'
--<
--> DEFINE header pointer point to fields on 
DEFINE PH, PH1 RECORD
       manuf     LIKE w213.manuf, -- manufacturer indentity  
       manufna   CHAR(23),      -- manufacturer name 
       pitems    LIKE w213.pitems,     -- item indentity
       pitemsna  CHAR(23),   -- item name
       dept      LIKE w213.dept,   -- department iddentity
       deptna    CHAR(23)        -- department name
       END RECORD,
      PH2 ARRAY[99] OF RECORD
         errno LIKE w215.errno
      END RECORD,
--<
--> DEFINE array of pointer point to fields on table or list
       P1,P2  ARRAY[99] OF RECORD
       kind     LIKE w213.kind,   -- kind 
       mach_cn  LIKE w213.mach_cn,     -- machine name in chinese 
       mach_en  LIKE w213.mach_en,  -- machine name in english
       machcode LIKE w213.machcode,    -- machine code
       posno    LIKE w213.posno,      -- Number of stations
       hole     LIKE w213.hole,      -- Number of holes
       lossprs  LIKE w213.lossprs,  -- Number of losses per hour
       losshr   LIKE w213.losshr,  -- Lost time
       lossgw   LIKE w213.lossgw -- Lost production weight per hour
       END RECORD,
--<
       Wrowid  ARRAY[99] OF INTEGER   , -- Array of ROWID, which is used in delete or updated record
       scr_ary      INTEGER, --max size of array that can contain records
       wk_flagOpenCur1 SMALLINT, -- Flag is use to know header cursor is open
       wk_flagOpenCur2 SMALLINT -- Flag is use to know cursor of table is open
#-------------------------------------------------------------------------------
FUNCTION mainfun()
   WHENEVER ERROR CALL errmsg
   LET max_ary = 99
   LET scr_ary = 5
   --> Set mode access DATABASE, action after should be wait action before complete
   SET LOCK MODE TO WAIT
   --< 
   --> Open form
   LET Pfrm = Cfrm CLIPPED,"/fo112a"
   OPEN FORM fo112a FROM Pfrm
   DISPLAY FORM fo112a
   --< 
   LET wk_flagOpenCur1 = FALSE
   LET wk_flagOpenCur2 = FALSE
   LET   op_code = "N"

   --> Define menu
   IF frmtyp = '1'
   THEN
      MENU "功能"
         COMMAND "0.結束" "說明:   結束執行, 回到上一畫面, Ctrl-P 基本操作說明"
                  HELP 0001 CALL Cset_int() CALL curfun()
                  EXIT MENU
         COMMAND "1.新增"
               "說明:   新增資料, 按 Esc 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[1] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL clearLine() CALL curfun() CALL addfun()
                  END IF
         COMMAND "2.查詢"
                  "說明:   查詢資料, 按 Esc 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL clearLine() CALL inqfun(TRUE)
                  END IF
         COMMAND "3.修改"
                  "說明:   修改資料, 按 Esc 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[3] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL clearLine()  CALL updfun()
                  END IF
         COMMAND "4.刪除"
                  "說明:   刪除此張資料, 按 Y 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[4] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL clearLine() CALL delfun()
                  END IF
         COMMAND "5.明細查詢" "說明:   查詢目前所顯示之明細資料, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL clearLine() CALL disfun()
                  END IF
         COMMAND "N.下張" "說明:   顯示下一張資料, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL clearLine() CALL pgfun(TRUE)
                  END IF
         COMMAND "U.上張" "說明:   顯示上一張資料, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL clearLine() CALL pgfun(FALSE)
                  END IF
         COMMAND "7.輸入清單"
                  "說明:   修改資料, 按 Esc 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL clearLine() CALL prtfun()
                  END IF
         COMMAND "H.說明" "說明:   程式操作輔助說明"
               CALL showhelp(0114)
      END MENU
   ELSE
      MENU "MENU"
      COMMAND "0.END" "HELP:   EXIT,Return previous menu,Ctrl-P Basic help"
               HELP 0001 CALL Cset_int() CALL curfun()
               EXIT MENU
      COMMAND "1.CREATE" "HELP:   Create data, Esc to run, Del to abort, Ctrl-P Basic help"
               HELP 0001 IF( usr_pg[1] = 'N' )THEN ERROR mess[25] CLIPPED
               ELSE CALL Cset_int() CALL clearLine() CALL curfun() CALL addfun()
               END IF
      COMMAND "2.INQUIRE" "HELP:   Inquire data, Esc to run, Del to abort, Ctrl-P Basic help"
                HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                ELSE CALL Cset_int() CALL clearLine() CALL inqfun(TRUE)
                END IF
      COMMAND "3.UPDATE" "HELP:   UPDATE data, Esc to run, Del to abort, Ctrl-P Basic help"
                HELP 0001 IF( usr_pg[3] = 'N' )THEN ERROR mess[25] CLIPPED
                ELSE CALL Cset_int() CALL clearLine() CALL updfun()
                END IF
      COMMAND "4.DELETE" "HELP:   Delete data, Esc to run, Del to abort, Ctrl-P Basic help"
                HELP 0001 IF( usr_pg[4] = 'N' )THEN ERROR mess[25] CLIPPED
                ELSE CALL Cset_int() CALL clearLine() CALL delfun()
                END IF
      COMMAND "5.DETAIL QUERY" "HELP:   Display detail Data, Ctrl-P Basic help"
                HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                ELSE CALL Cset_int() CALL clearLine() CALL disfun()
                END IF
      COMMAND "N.PAGE DOWN" "HELP:   Display next page, Ctrl-P  Basic help"
               HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
               ELSE CALL Cset_int() CALL clearLine() CALL pgfun(TRUE)
               END IF
      COMMAND "U.PAGE UP" "HELP:   Display previous page, Ctrl-P Basic help"
               HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
               ELSE CALL Cset_int() CALL clearLine() CALL pgfun(FALSE)
               END IF
      COMMAND "7.Print"
              "HELP:   Inquire data, Esc to run, Del to abort, Ctrl-P Basic help"
               HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
               ELSE CALL Cset_int() CALL clearLine() CALL prtfun()
               END IF
      COMMAND "H.HELP" "HELP:   Operation Help"
               CALL showhelp(0114)
      END MENU
   END IF
   --< 
   CLOSE FORM fo112a -- close form and end program
END FUNCTION
#----------------------------------------------------------------------
FUNCTION inqfun(iv_option) -- function for search data
   DEFINE iv_option SMALLINT -- variable is flag for inquire function, TRUE for input user, FALSE for where 1=1
   CLEAR FORM

   INITIALIZE PH.* TO NULL #Reset PH cursor for begining search
   IF iv_option
   THEN  
   --> Build construct for search
      CONSTRUCT BY NAME wh_str ON pitems, dept
         BEFORE CONSTRUCT -- The logic is execute before user input on any field on form
            LET PH.manuf = gv_manuf
            LET PH.manufna  = cal_j02(7,PH.manuf) -- Call function that is defined in another program to get manufacturer name
            DISPLAY BY NAME PH.manuf, PH.manufna -- DISPLAY on screen
         ON KEY(F5, CONTROL-W) -- Execute when user press these button.
               IF INFIELD(pitems) 
               THEN
                  CALL win_j02(620) RETURNING PH.pitems,PH.pitemsna
                  DISPLAY BY NAME PH.pitems, PH.pitemsna
                  NEXT FIELD dept
               END IF
         AFTER FIELD pitems -- execute when curser out of field
            IF PH.pitems IS NOT NULL AND PH.pitems NOT MATCHES "[ ]" 
            THEN
               LET PH.pitemsna = cal_j02(620,PH.pitems)
               DISPLAY BY NAME PH.pitems, PH.pitemsna
            END IF
         AFTER FIELD dept
            IF PH.dept IS NOT NULL AND PH.dept NOT MATCHES "[ ]" 
            THEN
               CALL cal_n15("W",PH.manuf,PH.dept) RETURNING PH.deptna
               DISPLAY BY NAME PH.dept, PH.deptna
            END IF
         AFTER CONSTRUCT -- execute when user complete input by  press ESC OR ACCEPT button
            IF PH.pitems IS NOT NULL AND PH.pitems NOT MATCHES "[ ]" 
            THEN
               LET PH.pitemsna = cal_j02(620,PH.pitems)
               DISPLAY BY NAME PH.pitems, PH.pitemsna
            END IF
            IF PH.dept IS NOT NULL AND PH.dept NOT MATCHES "[ ]" 
            THEN
               CALL cal_n15("W",PH.manuf,PH.dept) RETURNING PH.deptna
               DISPLAY BY NAME PH.dept, PH.deptna
            END IF
      END CONSTRUCT
      --<
      --> If any stuck during input construct, terminate search
      IF INT_FLAG 
      THEN
         LET INT_FLAG = FALSE
         CLEAR FORM
         ERROR mess[6]
         RETURN
      END IF
      --<
   ELSE
      LET wh_str = "1=1"
   END IF
   ------
   --> Build seacrh info 
   LET qry_str = "SELECT UNIQUE a.manuf,'' manufna ,a.pitems,'' pitemsna ,a.dept,'' deptna ",
                  " FROM w213 a WHERE ",wh_str CLIPPED,
                  " AND a.manuf = '",gv_manuf,"'",
                  " ORDER BY 1"
   --<
   --> Prepare and Declare cursor for search
   PREPARE cnt_exe FROM qry_str
   DECLARE cnt_cur SCROLL CURSOR FOR cnt_exe
   --<
   LET qry_str3 = "SELECT kind,mach_cn,mach_en,machcode,posno,hole,lossprs,losshr,lossgw,ROWID ",
                  " FROM w213",
                  " WHERE ", wh_str CLIPPED, " AND manuf = '", gv_manuf, "' AND pitems = ? AND dept = ?", 
                  " ORDER BY 1"
   PREPARE qry_exe FROM qry_str3
   DECLARE std_curs SCROLL CURSOR FOR qry_exe

   CALL reopen()  -- Call this function to load data into table on screen at first point
   LET op_code = "Y"  -- turn flag for search on                 
END FUNCTION
#----------------------------------------------------------------
FUNCTION inq100(iv_phPosition) -- Function for retrieve data
   DEFINE iv_phPosition INTEGER -- Position start retrive data

   CALL readfun1(iv_phPosition) -- Call this function to read and display data to fields on form
   
   --> Initialize three pointer to null for begin fecth data to
   FOR cc = 1 TO max_ary
      INITIALIZE P1[cc].* TO NULL
      INITIALIZE P2[cc].* TO NULL
      INITIALIZE Wrowid[cc] TO NULL
   END FOR
   -->

   CALL openCursorStd() -- open cursor
   --> Fecth data from cursor to pointer
   FOR cc = 1 TO max_ary
      FETCH std_curs INTO P1[cc].*,Wrowid[cc]
      IF STATUS != 0 THEN
         EXIT FOR
      END IF
      IF cc <= scr_ary THEN
         DISPLAY P1[cc].* TO SR[cc].*
      END IF
      LET P2[cc].* = P1[cc].*
      LET PH1.* = PH.*
   END FOR
   --<
   CALL closeCursorStd() -- close cursor after using

   LET cc = cc - 1 -- count of record is fetched
   IF cc > scr_ary THEN
      ERROR mess[14] CLIPPED -- count of record is greater than count of screen array
   ELSE
      IF cc = 0 THEN ERROR mess[10] CLIPPED END IF -- no record is found
   END IF
END FUNCTION
#----------------------------------------------------------------
FUNCTION readfun1(iv_cc) -- Function for read and display data to fields on form
   DEFINE iv_cc INTEGER

   CALL openCursorCnt()
   FETCH ABSOLUTE iv_cc cnt_cur INTO PH.*
   CALL closeCursorCnt()

   LET PH.manufna  = cal_j02(7,PH.manuf)  
   LET PH.pitemsna = cal_j02(620,PH.pitems)  
   CALL cal_n15("W",PH.manuf,PH.dept) RETURNING PH.deptna
   
   DISPLAY BY NAME PH.* -- Display all fields on fields on form
END FUNCTION
#----------------------------------------------------------------
FUNCTION addfun() -- Function for create new records
   DEFINE wk_machcodecnt INTEGER -- variable determine whether duplicate record
   DEFINE wk_duplicate INTEGER -- variable determine numbers of duplicate record
   DEFINE wk_countAddSuccess INTEGER -- variable determine numbers of record is added successfull

   LET wk_duplicate = 0
   LET wk_countAddSuccess = 0

   FOR cc = 1 TO max_ary
      INITIALIZE P1[cc].* TO NULL
      INITIALIZE Wrowid[cc] TO NULL
   END FOR
   CLEAR FORM
   ------
   INITIALIZE PH.* TO NULL
   CALL add100(FALSE, FALSE, PH.*) -- Call this function to user input on fields on form, the first  and the second parameter for update record to asign old data of a header pointer to another pointer, this compare after user change any data on fields, the last parameter is value of pointer for asign 
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      CLEAR FORM
      ERROR mess[5] CLIPPED -- Cancel add new data
      RETURN
   END IF
   ------

   CALL add200(FALSE, FALSE) -- CALL this function to user input on fields of table on screen, the first parameter for update, the last parameter for delete
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      CLEAR FORM
      ERROR mess[5] CLIPPED
      RETURN
   END IF
   ------
   ERROR mess[11] # proccessing...
   --> add datas into table on database
   BEGIN WORK
   FOR cc = 1 TO max_ary
      IF P1[cc].kind IS NULL THEN -- exit add data if record is null
         EXIT FOR
      END IF 
      IF P1[cc].kind NOT MATCHES '[FYNG]' THEN CONTINUE FOR END IF -- continue new loop if kind out of true values
      LET wk_machcodecnt = 0
      SELECT COUNT(*) INTO wk_machcodecnt FROM w213
      WHERE manuf = PH.manuf AND pitems = PH.pitems AND dept = PH.dept AND machcode = P1[cc].machcode
      IF wk_machcodecnt THEN
         LET wk_duplicate = wk_duplicate + 1
      ELSE
         INSERT INTO w213 VALUES(PH.manuf, PH.pitems, PH.dept, P1[cc].machcode, P1[cc].kind, P1[cc].mach_cn, P1[cc].mach_en, P1[cc].posno, P1[cc].hole, P1[cc].lossprs, P1[cc].losshr, P1[cc].lossgw,login_usr, CURRENT YEAR TO SECOND)
         IF SQLCA.SQLERRD[3] = 0 OR STATUS != 0 THEN
            ROLLBACK WORK
            ERROR "w213 ",mess[52] CLIPPED,",",mess[48] CLIPPED
            CLEAR FORM
            RETURN
         ELSE
            LET wk_countAddSuccess = wk_countAddSuccess + 1 -- increase number of record is added successfull
         END IF
      END IF
   END FOR
   COMMIT WORK
   --<
   IF wk_countAddSuccess > 0 THEN
      IF wk_duplicate
      THEN 
         IF frmtyp = "2" THEN
            ERROR mess[58] CLIPPED, wk_countAddSuccess USING "<<<<< & record! To be Duplicated ", wk_duplicate USING "<<<<< & record." SLEEP 1
         ELSE
            ERROR mess[58] CLIPPED, wk_countAddSuccess USING "<<<<< & 記錄! 要復制 ", wk_duplicate USING "<<<<< & 記錄." SLEEP 1
         END IF
      ELSE
         IF frmtyp = "2" THEN
            ERROR mess[58] CLIPPED, wk_countAddSuccess USING "<<<<< & record!" SLEEP 1
         ELSE
            ERROR mess[58] CLIPPED, wk_countAddSuccess USING "<<<<< & 記錄!" SLEEP 1
         END IF
      END IF
      CALL inqfun(FALSE)
   ELSE
      IF wk_duplicate
      THEN 
         IF frmtyp = "2" THEN
            ERROR mess[4] CLIPPED, "! To be Duplicated ", wk_duplicate USING "<<<<< & record."
         ELSE  
            ERROR mess[4] CLIPPED, "! 要復制 ", wk_duplicate USING "<<<<< & 記錄."
         END IF
      ELSE
         ERROR mess[4] CLIPPED, "!"
      END IF
   END IF
END FUNCTION
#-------------------------------------------------------------------
FUNCTION add100(iv_option1, iv_option2, iv_record) -- Function for user input fields on form, the first  and the second parameter for update record to asign old data of a header pointer to another pointer, this compare after user change any data on fields, the last parameter is value of pointer for asign 
   DEFINE iv_option1, iv_option2 SMALLINT
   DEFINE wk_key SMALLINT -- the last key that user pressed
   DEFINE iv_record RECORD
      manuf     LIKE w213.manuf,  
      manufna   CHAR(23),      
      pitems    LIKE w213.pitems,     
      pitemsna  CHAR(23),   
      dept      LIKE w213.dept,  
      deptna    CHAR(23)        
   END RECORD

   OPTIONS INSERT KEY F13, -- set option for user to press button on keyboard 
            DELETE KEY F14
   INPUT BY NAME PH.pitems, PH.dept
      BEFORE INPUT -- execute before user input on any fileds on form
         IF iv_option1
         THEN
            LET PH.* = iv_record.*
            IF iv_option2 THEN
               LET PH1.* = PH.* -- save old value to compare if user change data
            END IF
            DISPLAY BY NAME PH.*
         ELSE
            LET PH.manuf = gv_manuf
            LET PH.manufna  = cal_j02(7,PH.manuf)
            DISPLAY BY NAME PH.*
         END IF
      ON KEY(F5, CONTROL-W) 
            IF INFIELD(pitems) 
            THEN
               CALL win_j02(620) RETURNING PH.pitems,PH.pitemsna
               DISPLAY BY NAME PH.pitems, PH.pitemsna
               NEXT FIELD dept
            END IF
      AFTER INPUT -- execute when user complete input by  press ESC OR ACCEPT button
         LET wk_key = FGL_LASTKEY()
         IF wk_key == FGL_KEYVAL("ACCEPT") OR wk_key == FGL_KEYVAL("ESC")
         THEN
            IF PH.pitems IS NOT NULL AND PH.pitems NOT MATCHES "[ ]" 
            THEN
               LET PH.pitemsna = cal_j02(620,PH.pitems)
               IF PH.pitemsna IS NULL OR PH.pitemsna MATCHES "[ ]"
               THEN
                  ERROR mess[9] CLIPPED
                  DISPLAY BY NAME PH.pitemsna
                  NEXT FIELD pitems
               ELSE
                  DISPLAY BY NAME PH.pitems, PH.pitemsna
               END IF
            ELSE
               ERROR mess[15]
               NEXT FIELD pitems
            END IF
            IF PH.dept IS NOT NULL AND PH.dept NOT MATCHES "[ ]" 
            THEN
               CALL cal_n15("W",PH.manuf,PH.dept) RETURNING PH.deptna
               IF PH.deptna IS NULL OR PH.deptna MATCHES "[ ]"
               THEN
                  ERROR mess[9] CLIPPED
                   DISPLAY BY NAME PH.deptna
                  NEXT FIELD dept
               ELSE
                  DISPLAY BY NAME PH.dept, PH.deptna
               END IF
            ELSE
               ERROR mess[15]
               NEXT FIELD dept
            END IF
         END IF
   END INPUT
END FUNCTION
#-------------------------------------------------------------------------------
FUNCTION add200(iv_option, iv_option1) -- Function for user input on fields on table on screen, the first parameter for update, the last parameter for delete
   DEFINE iv_option, iv_option1 SMALLINT
   DEFINE wk_key SMALLINT -- the last key that user pressed
   DEFINE iv_cc SMALLINT -- variable save count of record was exists on database
   DEFINE wk_goto SMALLINT -- variable determine if program is execute goto command
   DEFINE wk_recordDel INTEGER -- variable determine count of record is null by input of user and these record will be removed
   DEFINE wk_prompt CHAR(1) -- the key that user prompt

   LET wk_goto = FALSE -- initialize for begin
   LET wk_recordDel = 0

   INPUT ARRAY P1 WITHOUT DEFAULTS FROM SR.*
      BEFORE ROW -- the logic execute before user move cursor to new row
         LET aln = ARR_CURR() -- get position of array record
         LET sln = SCR_LINE() -- get position of screen array
         DISPLAY P1[aln].* TO SR[sln].* ATTRIBUTE(REVERSE) -- Display array record into screen array
         IF frmtyp ='1' THEN
            DISPLAY "本行是第 ", aln USING "<<#"," 行" AT 22, 1
         ELSE
            DISPLAY "This row is ", aln USING "<<#"," row" AT 22, 1
         END IF
      BEFORE FIELD kind -- The logic execute before cursor to this field
         IF frmtyp = "2" THEN
            ERROR "Values are only 'F', 'Y', 'N' and 'G'!"
         ELSE
            ERROR "值僅是 'F', 'Y', 'N' 和 'G'!"
         END IF
      ON KEY (CONTROL-Z) -- press button to come back fields on form
         IF NOT iv_option1
         THEN
            LABEL lblCallAdd100: -- input again if duplication happen
            CALL add100(TRUE, FALSE, PH.*)
            IF INT_FLAG THEN
               LET INT_FLAG = FALSE
               CLEAR FORM
               ERROR mess[5] CLIPPED
               RETURN
            END IF
         END IF
      ON KEY (CONTROL-O) -- press this button to delete present row
         IF iv_option1
         THEN
            IF frmtyp = "2" THEN
               PROMPT "Do you really want to remove this record (y/Y for Yes, another for No)? " FOR wk_prompt
            ELSE
               PROMPT "您是否真的要刪除此記錄 (y/Y 為是, 另一個為否)? " FOR wk_prompt
            END IF
            IF wk_prompt MATCHES "[yY]"
            THEN
               BEGIN WORK
                  CALL delRelatedData(aln)
                  DELETE FROM w213 WHERE ROWID = Wrowid[aln]
                  IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
                     ERROR mess[63] CLIPPED
                     ROLLBACK WORK
                  END IF 
                  LET wk_recordDel = wk_recordDel + 1 -- increase number of record is removed
                  ERROR mess[60] CLIPPED
               COMMIT WORK
               INITIALIZE P1[aln].* TO NULL
               DISPLAY P1[aln].* TO SR[sln].* ATTRIBUTE(REVERSE) -- Display row is removed to blank 
               EXIT INPUT
            END IF
         END IF
      ON KEY (CONTROL-M) -- press button to delete all row on present table screen
         IF iv_option1
         THEN
            IF frmtyp = "2" THEN
               PROMPT "Do you really want to remove all record (y/Y for Yes, another for No)? " FOR wk_prompt
            ELSE
               PROMPT "您是否真的要刪除所有記錄 (y / y為是，另一個為no)? " FOR wk_prompt
            END IF
            IF wk_prompt MATCHES "[yY]"
            THEN
               LET cnt1 = 0
               BEGIN WORK
                  FOR cc1 = 1 TO cc
                     CALL delRelatedData(cc1)
                     DELETE FROM w213 WHERE ROWID = Wrowid[cc1]
                     IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
                        ERROR mess[63] CLIPPED
                        ROLLBACK WORK
                        RETURN
                     END IF
                  END FOR
               COMMIT WORK
               ERROR mess[53] CLIPPED, cnt1 USING "<<< & ",mess[41] CLIPPED
               CALL reopen() -- Call this to reload data
               EXIT INPUT 
            END IF
         END IF
      AFTER ROW -- The logic execute after cursor out of row
         IF NOT iv_option1 THEN
            IF (P1[aln].kind IS NOT NULL OR P1[aln].kind NOT MATCHES "[ ]")
               OR (P1[aln].mach_cn IS NOT NULL OR P1[aln].mach_cn NOT MATCHES "[ ]")
               OR (P1[aln].mach_en IS NOT NULL OR P1[aln].mach_en NOT MATCHES "[ ]")
               OR (P1[aln].machcode IS NOT NULL OR P1[aln].machcode NOT MATCHES "[ ]")
               OR (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]" OR P1[aln].posno != 0)
               OR (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]" OR P1[aln].hole != 0)
               OR (P1[aln].lossprs IS NOT NULL OR P1[aln].lossprs NOT MATCHES "[ ]" OR P1[aln].lossprs != 0.0)
               OR (P1[aln].losshr IS NOT NULL OR P1[aln].losshr NOT MATCHES "[ ]" OR P1[aln].losshr != 0.0)
               OR (P1[aln].lossgw IS NOT NULL OR P1[aln].lossgw NOT MATCHES "[ ]" OR P1[aln].lossgw != 0.0)
            THEN  -- check if has any change data from user
               IF P1[aln].kind IS NULL OR P1[aln].kind MATCHES "[ ]" THEN
                  ERROR mess[15]
                  NEXT FIELD kind
               ELSE
                  IF P1[aln].kind NOT MATCHES "[FYNG]" 
                  THEN
                     NEXT FIELD kind
                     IF frmtyp = "2" THEN
                        ERROR "Values are only 'F', 'Y', 'N' and 'G'!"
                     ELSE
                        ERROR "值僅是 'F', 'Y', 'N' 和 'G'!"
                     END IF
                  ELSE
                     IF P1[aln].kind MATCHES "[Y]" 
                     THEN
                        IF p1[aln].posno IS NULL OR P1[aln].posno MATCHES "[ ]" THEN
                           ERROR mess[15]
                           NEXT FIELD posno
                        END IF
                        IF p1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]" THEN
                           ERROR mess[15]
                           NEXT FIELD hole
                        END IF
                     ELSE
                        ERROR ""
                     END IF
                  END IF
               END IF
               IF P1[aln].machcode IS NULL OR P1[aln].machcode MATCHES "[ ]"  THEN
                  ERROR mess[15]
                  NEXT FIELD machcode
               ELSE
                  IF (NOT iv_option) OR (iv_option AND (P2[aln].machcode != P1[aln].machcode OR PH1.pitems != PH.pitems OR PH1.dept != PH.dept))
                  THEN
                     LET iv_cc = 0
                     SELECT COUNT(*) INTO iv_cc FROM w213
                     WHERE manuf = PH.manuf AND pitems = PH.pitems AND dept = PH.dept AND machcode = P1[aln].machcode
                     IF iv_cc > 0 THEN
                        ERROR mess[2]
                        IF ((PH1.pitems != PH.pitems OR PH1.dept != PH.dept) AND iv_option) OR NOT iv_option
                        THEN
                           LET wk_goto = TRUE
                           GOTO lblCallAdd100
                        END IF
                        IF P2[aln].machcode != P1[aln].machcode AND iv_option
                        THEN 
                           NEXT FIELD machcode
                        END IF
                     END IF
                  ELSE
                     IF wk_goto THEN CALL add200(TRUE, FALSE) END IF
                  END IF
               END IF
               IF P1[aln].lossprs IS NULL OR P1[aln].lossprs MATCHES "[ ]"  THEN
                  ERROR mess[15]
                  NEXT FIELD lossprs
               END IF
               IF P1[aln].losshr IS NULL OR P1[aln].losshr MATCHES "[ ]"  THEN
                  ERROR mess[15]
                  NEXT FIELD losshr
               END IF
               IF P1[aln].lossgw IS NULL OR P1[aln].lossgw MATCHES "[ ]" THEN
                  ERROR mess[15]
                  NEXT FIELD lossgw
               END IF
            END IF
         END IF
      AFTER INPUT -- The logic execute after user complete input
         LET wk_key = FGL_LASTKEY()
         IF wk_key == FGL_KEYVAL("ACCEPT") OR wk_key == FGL_KEYVAL("ESC")
         THEN
            IF NOT iv_option1
            THEN
               IF (P1[aln].kind IS NOT NULL OR P1[aln].kind NOT MATCHES "[ ]")
                  OR (P1[aln].mach_cn IS NOT NULL OR P1[aln].mach_cn NOT MATCHES "[ ]")
                  OR (P1[aln].mach_en IS NOT NULL OR P1[aln].mach_en NOT MATCHES "[ ]")
                  OR (P1[aln].machcode IS NOT NULL OR P1[aln].machcode NOT MATCHES "[ ]")
                  OR (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]" OR P1[aln].posno != 0)
                  OR (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]" OR P1[aln].hole != 0)
                  OR (P1[aln].lossprs IS NOT NULL OR P1[aln].lossprs NOT MATCHES "[ ]" OR P1[aln].lossprs != 0.0)
                  OR (P1[aln].losshr IS NOT NULL OR P1[aln].losshr NOT MATCHES "[ ]" OR P1[aln].losshr != 0.0)
                  OR (P1[aln].lossgw IS NOT NULL OR P1[aln].lossgw NOT MATCHES "[ ]" OR P1[aln].lossgw != 0.0)
               THEN
                  IF P1[aln].kind IS NULL OR P1[aln].kind MATCHES "[ ]" THEN
                     ERROR mess[15]
                     NEXT FIELD kind
                  ELSE
                     IF P1[aln].kind NOT MATCHES "[FYNG]" 
                     THEN
                        NEXT FIELD kind
                        IF frmtyp = "2" THEN
                           ERROR "Values are only 'F', 'Y', 'N' and 'G'!"
                        ELSE
                           ERROR "值僅是 'F', 'Y', 'N' 和 'G'!"
                        END IF
                     ELSE  
                        IF P1[aln].kind MATCHES "[Y]" 
                        THEN
                           IF p1[aln].posno IS NULL OR P1[aln].posno MATCHES "[ ]" THEN
                              ERROR mess[15]
                              NEXT FIELD posno
                           END IF
                           IF p1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]" THEN
                              ERROR mess[15]
                              NEXT FIELD hole
                           END IF
                        ELSE
                           ERROR ""
                        END IF
                     END IF
                  END IF
                  IF P1[aln].machcode IS NULL OR P1[aln].machcode MATCHES "[ ]"  THEN
                     ERROR mess[15]
                     NEXT FIELD machcode
                  ELSE
                     IF (NOT iv_option) OR (iv_option AND (P2[aln].machcode != P1[aln].machcode OR PH1.pitems != PH.pitems OR PH1.dept != PH.dept))
                     THEN
                        LET iv_cc = 0
                        SELECT COUNT(*) INTO iv_cc FROM w213
                        WHERE manuf = PH.manuf AND pitems = PH.pitems AND dept = PH.dept AND machcode = P1[aln].machcode
                        IF iv_cc > 0 THEN
                           ERROR mess[2]
                           IF ((PH1.pitems != PH.pitems OR PH1.dept != PH.dept) AND iv_option) OR NOT iv_option
                           THEN
                              LET wk_goto = TRUE
                              GOTO lblCallAdd100
                           END IF
                           IF P2[aln].machcode != P1[aln].machcode AND iv_option
                           THEN 
                              NEXT FIELD machcode
                           END IF
                        END IF
                     ELSE
                        IF wk_goto THEN CALL add200(TRUE, FALSE) END IF
                     END IF
                  END IF
                  IF P1[aln].lossprs IS NULL OR P1[aln].lossprs MATCHES "[ ]"  THEN
                     ERROR mess[15]
                     NEXT FIELD lossprs
                  END IF
                  IF P1[aln].losshr IS NULL OR P1[aln].losshr MATCHES "[ ]"  THEN
                     ERROR mess[15]
                     NEXT FIELD losshr
                  END IF
                  IF P1[aln].lossgw IS NULL OR P1[aln].lossgw MATCHES "[ ]" THEN
                     ERROR mess[15]
                     NEXT FIELD lossgw
                  END IF
               END IF
            ELSE
               IF wk_recordDel THEN
                  ERROR mess[53] CLIPPED, wk_recordDel USING "<<< & ",mess[41] CLIPPED SLEEP 1
                  CALL reopen()
               END IF
            END IF
         ELSE
            IF iv_option1 THEN -- TRUE, prompt for delete. FALSE, prompt for add and update.
               IF frmtyp = "2" THEN
                  PROMPT "Do you really want to exit delete fucntion (y/Y for Yes, another for No)? " FOR wk_prompt
               ELSE
                  PROMPT "您是否真的要退出刪除功能 (y / y表示是，另一個表示否)? " FOR wk_prompt
               END IF
            ELSE
               IF frmtyp = "2" THEN
                  PROMPT "Do you really want to cancel input (y/Y for Yes, another for No)? " FOR wk_prompt
               ELSE
                  PROMPT "您是否真的要取消輸入 (y / y表示是，另一個表示否)? " FOR wk_prompt
               END IF
            END IF
            IF wk_prompt NOT MATCHES "[yY]"
            THEN
               CONTINUE INPUT
            ELSE
               IF iv_option1
               THEN
                  IF wk_recordDel THEN
                     ERROR mess[53] CLIPPED, wk_recordDel USING "<<< & ",mess[41] CLIPPED SLEEP 1
                     CALL reopen()
                  END IF
               END IF
            END IF
         END IF
   END INPUT
END FUNCTION
#-------------------------------------------------------------------------------
FUNCTION updfun() -- Function for update
   DEFINE wk_machcodecnt INTEGER -- variable determine whether duplicate record
   DEFINE wk_duplicate INTEGER -- variable determine numbers of duplicate record
   DEFINE wk_countUpdateSuccess INTEGER -- variable determine numbers of record is added successfull
   DEFINE wk_countDel INTEGER -- variable determine count of record is null by input of user and these record will be removed

   LET wk_duplicate = 0 
   LET wk_countDel = 0
   LET wk_countUpdateSuccess = 0

   IF op_code = 'N' THEN -- user don't inquire data yet, terminate update
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   OPTIONS INSERT KEY F13,
         DELETE KEY F14

   CALL add100(TRUE, TRUE, PH.*)
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      ERROR mess[07] CLIPPED
      RETURN
   END IF

   CALL SET_COUNT(cc) -- set max of record that user can input
   IF frmtyp = "2" THEN
      DISPLAY "If you prompt the row is empty, this row will be removed!" AT 21, 1
   ELSE
      DISPLAY "如果您提示該行為空，則該行將被刪除!" AT 21, 1
   END IF
   CALL add200(TRUE, FALSE)
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      ERROR mess[07] CLIPPED
      RETURN
   END IF

   BEGIN WORK
   FOR cc1 = 1 TO max_ary
      IF P2[cc1].kind IS NULL
      THEN 
         CONTINUE FOR 
      ELSE
       -- remove empty row
         IF (P1[cc1].kind IS NULL OR P1[cc1].kind  MATCHES "[ ]")
            AND (P1[cc1].mach_cn IS NULL OR P1[cc1].mach_cn  MATCHES "[ ]")
            AND (P1[cc1].mach_en IS NULL OR P1[cc1].mach_en  MATCHES "[ ]")
            AND (P1[cc1].machcode IS NULL OR P1[cc1].machcode  MATCHES "[ ]")
            AND (P1[cc1].posno IS NULL OR P1[cc1].posno  MATCHES "[ ]" OR P1[cc1].lossprs != 0)
            AND (P1[cc1].hole IS NULL OR P1[cc1].hole  MATCHES "[ ]" OR P1[cc1].hole != 0)
            AND (P1[cc1].lossprs IS NULL OR P1[cc1].lossprs  MATCHES "[ ]" OR P1[cc1].lossprs != 0.0)
            AND (P1[cc1].losshr IS NULL OR P1[cc1].losshr  MATCHES "[ ]" OR P1[cc1].losshr != 0.0)
            AND (P1[cc1].lossgw IS NULL OR P1[cc1].lossgw  MATCHES "[ ]" OR P1[cc1].lossgw != 0.0)
         THEN
            DELETE FROM w213 WHERE ROWID = Wrowid[cc1]
            LET wk_countDel = wk_countDel + 1 
         END IF
      --  
      END IF
      IF PH1.pitems != PH.pitems OR PH1.dept != PH.dept OR P2[cc1].machcode !=  P1[cc1].machcode OR P2[cc1].kind !=  P1[cc1].kind OR P2[cc1].mach_cn !=  P1[cc1].mach_cn OR P2[cc1].mach_en !=  P1[cc1].mach_en OR P2[cc1].posno !=  P1[cc1].posno OR P2[cc1].hole !=  P1[cc1].hole OR P2[cc1].lossprs !=  P1[cc1].lossprs OR P2[cc1].losshr !=  P1[cc1].losshr OR P2[cc1].lossgw !=  P1[cc1].lossgw
      THEN
         
         IF P1[cc1].kind NOT MATCHES '[FYNG]' THEN CONTINUE FOR END IF
         LET wk_machcodecnt = 0
         IF PH1.pitems != PH.pitems OR PH1.dept != PH.dept OR P2[cc1].machcode !=  P1[cc1].machcode
         THEN
            SELECT COUNT(*) INTO wk_machcodecnt FROM w213
            WHERE manuf = PH.manuf AND pitems = PH.pitems AND dept = PH.dept AND machcode = P1[cc1].machcode
         END IF
          
         IF wk_machcodecnt THEN
            LET wk_duplicate = wk_duplicate + 1
         ELSE
            UPDATE w213 SET (pitems, dept, machcode, kind,mach_cn,mach_en,posno,hole,lossprs,losshr,lossgw,upusr,upday)
                        = (PH.pitems, PH.dept, P1[cc1].machcode, P1[cc1].kind, P1[cc1].mach_cn, P1[cc1].mach_en, P1[cc1].posno, P1[cc1].hole, P1[cc1].lossprs, P1[cc1].losshr, P1[cc1].lossgw,login_usr, CURRENT YEAR TO SECOND)
            WHERE manuf = PH1.manuf AND pitems = PH1.pitems AND dept = PH1.dept AND machcode = P2[cc1].machcode
            IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
               ROLLBACK WORK
               ERROR mess[04] CLIPPED
               RETURN
            ELSE
               IF P2[cc1].machcode !=  P1[cc1].machcode OR P2[cc1].kind !=  P1[cc1].kind OR PH1.pitems != PH.pitems OR PH1.dept != PH.dept
               THEN
                  CALL updateRelatedData(cc1) -- Call this function to update data on relate table
               END IF 
               LET wk_countUpdateSuccess = wk_countUpdateSuccess + 1
            END IF
         END IF
      END IF
   END FOR
   COMMIT WORK
   IF wk_countUpdateSuccess > 0 THEN
      IF wk_duplicate
      THEN 
      IF wk_countDel > 0 THEN
            IF frmtyp = "2" THEN
               ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!", " To be Duplicated ", wk_duplicate USING "<<<<< & record. To be removed ", wk_countDel USING "<<<<< & record." SLEEP 1
            ELSE
               ERROR "修改 ", wk_countUpdateSuccess USING "<<& "," 行成功!", " 要復制 ", wk_duplicate USING "<<<<< & 行. 即將被刪除 ", wk_countDel USING "<<<<< & 行." SLEEP 1
            END IF
         ELSE
            IF frmtyp = "2" THEN
               ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!", " To be Duplicated ", wk_duplicate USING "<<<<< & record." SLEEP 1
            ELSE
               ERROR "修改 ", wk_countUpdateSuccess USING "<<& "," 行成功!", " 要復制 ", wk_duplicate USING "<<<<< & 行." SLEEP 1
            END IF
         END IF
      ELSE
         IF wk_countDel > 0 THEN
            IF frmtyp = "2" THEN
               ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success! To be removed ", wk_countDel USING "<<<<< & record." SLEEP 1
            ELSE
               ERROR "修改 ", wk_countUpdateSuccess USING "<<& "," 行成功! 即將被刪除 ", wk_countDel USING "<<<<< & 行." SLEEP 1
            END IF
         ELSE
            IF frmtyp = "2" THEN
               ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!" SLEEP 1
            ELSE
               ERROR "修改 ", wk_countUpdateSuccess USING "<<& "," 行成功!" SLEEP 1
            END IF
         END IF
      END IF
      CALL reopen() 
   ELSE
      IF wk_duplicate
      THEN 
         IF wk_countDel > 0 THEN
            IF frmtyp = "2" THEN
               ERROR "Datas are unchanged! To be Duplicated ", wk_duplicate USING "<<<<< & record. To be removed ", wk_countDel USING "<<<<< & record." SLEEP 1
            ELSE
               ERROR "數據不變! 要復制 ", wk_duplicate USING "<<<<< & 行. 即將被刪除 ", wk_countDel USING "<<<<< & 行." SLEEP 1
            END IF
         ELSE
            IF frmtyp = "2" THEN
               ERROR "Datas are unchanged! To be Duplicated ", wk_duplicate USING "<<<<< & record." SLEEP 1
            ELSE
               ERROR "數據不變! 要復制 ", wk_duplicate USING "<<<<< & 行." SLEEP 1
            END IF
         END IF
         CALL reopen()
      ELSE
         IF wk_countDel > 0 THEN
            IF frmtyp = "2" THEN
               ERROR "Datas are unchanged!. To be removed ", wk_countDel USING "<<<<< & record." SLEEP 1
            ELSE
               ERROR "數據不變!. 即將被刪除 ", wk_countDel USING "<<<<< & 行." SLEEP 1
            END IF
            CALL reopen()
         ELSE
            IF frmtyp = "2" THEN
               ERROR "Datas are unchanged!" SLEEP 1
            ELSE
               ERROR "數據不變!" SLEEP 1
            END IF
         END IF
      END IF
   END IF
END FUNCTION
#----------------------------------------------------------------------
FUNCTION pgfun(move) -- Function for move to new page
   DEFINE move SMALLINT -- variable determine if user want to move to next page or previous page. TRUE for next and FALSE for previous 
   DEFINE wk_message CHAR(300) -- variable use for store message to display
   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   IF move THEN -- TRUE for next
      LET cnt = cnt + 1
      IF cnt >= allcnt -- the present position of cursor is greater than or equal max of position
      THEN 
         IF cnt > allcnt THEN 
            LET cnt = 1 -- reset into 1 if greater, scroll for next
            LET wk_message = mess[12] -- first page
         ELSE
            LET wk_message = mess[13] -- last page
         END IF
      END IF
      CALL openCursorCnt()
      FETCH ABSOLUTE cnt cnt_cur INTO PH.* -- fetch present cursor to header pointer
      CALL closeCursorCnt()
   ELSE
      LET cnt = cnt - 1
      IF cnt <= 1 -- the present position of cursor is less than or equal max of position
      THEN 
         IF cnt < 1 THEN 
            LET cnt = allcnt -- asign for max position, scroll for previous
            LET wk_message = mess[13]
         ELSE
            LET wk_message = mess[12]
         END IF
      END IF
      CALL openCursorCnt()
      FETCH ABSOLUTE cnt cnt_cur INTO PH.*
      CALL closeCursorCnt()
   END IF
   CLEAR FORM #Reset all field include input array
   ERROR wk_message CLIPPED -- DISPLAY messasge as error,  but this isn't error
   CALL inq100(cnt) -- Call this function to inquire at present position
   IF frmtyp ='1' THEN
      DISPLAY "總頁數 : ",allcnt USING "<<<<#",
              "  顯示第 ",cnt USING "<<<<#"," 頁 " AT 23,1
   ELSE
      DISPLAY "Totals pages : ",allcnt USING "<<<<#",
               "  Display page ",cnt USING "#" AT 23,1
   END IF           	           
END FUNCTION
#-------------------------------------------------------------------------------
FUNCTION delfun() -- Function for delete
   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   CALL SET_COUNT(cc) -- set max of record that user can input
   CALL add200(TRUE, TRUE) 
   -- CALL ans() RETURNING ans1
   -- IF ans1 MATCHES "[^Yy]" THEN
   --    ERROR mess[8]
   --    RETURN
   -- END IF
   -- LET cnt1 = 0
   -- BEGIN WORK
   --    FOR cc1 = 1 TO cc
   --       DELETE FROM w213 WHERE ROWID = Wrowid[cc1]
   --       IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
   --          ERROR mess[63] CLIPPED
   --          ROLLBACK WORK
   --          RETURN
   --       ELSE
   --          LET cnt1 = cnt1 + 1
   --       END IF
   --    END FOR
   -- COMMIT WORK
   -- ERROR mess[53] CLIPPED, cnt1 USING "<<< & ",mess[41] CLIPPED
   -- CALL reopen()
END FUNCTION
#----------------------------------------------------------------------
FUNCTION delRelatedData(iv_index) -- Function for delete data on tables that reference to w213 table
   DEFINE iv_index INTEGER
   DEFINE wk_cc1 INTEGER
   DEFINE wk_machcode LIKE w213.machcode
   LET qry_str = "SELECT a.errno FROM w215 AS a JOIN  w214 AS b ON a.errno = b.errno WHERE b.manuf = ? AND b.pitems = ? AND b.dept = ? AND a.machcode = ? AND a.kind = ?"

   PREPARE cnt_exe1 FROM qry_str
   DECLARE std_curs1 SCROLL CURSOR FOR cnt_exe1

   LET wk_machcode = P1[iv_index].machcode CLIPPED
   OPEN std_curs1 USING PH.manuf, PH.pitems, PH.dept, wk_machcode, P1[iv_index].kind

   FOR wk_cc1 = 1 TO max_ary
      INITIALIZE PH2[wk_cc1].* TO NULL 
   END FOR
   FOR wk_cc1 = 1 TO max_ary
      FETCH std_curs1 INTO PH2[wk_cc1].* 
      IF STATUS != 0 THEN
         EXIT FOR
      END IF
      DELETE FROM w215 WHERE errno = PH2[wk_cc1].errno
      IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
         ERROR mess[63] CLIPPED
         ROLLBACK WORK
      END IF 
      DELETE FROM w214 WHERE errno = PH2[wk_cc1].errno
      IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
         ERROR mess[63] CLIPPED
         ROLLBACK WORK
      END IF 
   END FOR
   CLOSE std_curs1
END FUNCTION
#----------------------------------------------------------------------
FUNCTION updateRelatedData(iv_index) -- Function for update data on tables that reference to w213 table
   DEFINE iv_index INTEGER
   DEFINE wk_cc1 INTEGER
   DEFINE wk_machcode LIKE w213.machcode
   LET qry_str = "SELECT a.errno FROM w215 AS a JOIN  w214 AS b ON a.errno = b.errno WHERE b.manuf = ? AND b.pitems = ? AND b.dept = ? AND a.machcode = ? AND a.kind = ?"

   PREPARE cnt_exe2 FROM qry_str
   DECLARE std_curs2 SCROLL CURSOR FOR cnt_exe2

   LET wk_machcode = P2[iv_index].machcode CLIPPED
   OPEN std_curs2 USING PH.manuf, PH1.pitems, PH1.dept, wk_machcode, P2[iv_index].kind

   FOR wk_cc1 = 1 TO max_ary
      INITIALIZE PH2[wk_cc1].* TO NULL 
   END FOR
   FOR wk_cc1 = 1 TO max_ary
      FETCH std_curs2 INTO PH2[wk_cc1].* 
      IF STATUS != 0 THEN
         EXIT FOR
      END IF
      UPDATE w215 SET (machcode, kind) = (P1[iv_index].machcode, P1[iv_index].kind) WHERE errno = PH2[wk_cc1].errno
      IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
         ERROR mess[63] CLIPPED
         ROLLBACK WORK
      END IF 
      UPDATE w214 SET (pitems, dept) = (PH.pitems, PH.dept) WHERE errno = PH2[wk_cc1].errno
      IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
         ERROR mess[63] CLIPPED
         ROLLBACK WORK
      END IF 
   END FOR
   CLOSE std_curs2
END FUNCTION
#----------------------------------------------------------------------
FUNCTION reopen() -- Function for reload data
   LET cnt = 1
   LET allcnt = 1

   CLEAR FORM

   CALL openCursorCnt()
   WHILE TRUE
      FETCH ABSOLUTE allcnt cnt_cur INTO PH.*
      IF STATUS != 0 THEN
         EXIT WHILE
      END IF
      LET allcnt = allcnt + 1
   END WHILE
   CALL closeCursorCnt()

   LET allcnt = allcnt - 1
   IF allcnt = 0 THEN
      ERROR mess[10] CLIPPED
      CLEAR FORM
      RETURN
   ELSE
      IF frmtyp = '2' THEN
         DISPLAY "Totals pages : ",allcnt USING "<<<<#",
                 "  Display page ",cnt USING "#" AT 23,1
      ELSE
         DISPLAY "總頁數 : ",allcnt USING "<<<<#",
              "  顯示第 ",cnt USING "<<<<#"," 頁 " AT 23,1
      END IF
      ERROR mess[12] CLIPPED SLEEP 1
      CALL inq100(cnt) -- call this function to inquire at present position.
   END IF
END FUNCTION
#----------------------------------------------------------------------
FUNCTION disfun() -- FUNCTION for user to show all row if numbers of record is greater than size of screen array 
   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   DISPLAY "" AT 1, 1
   DISPLAY "" AT 2, 1

   DISPLAY mess[29] CLIPPED,mess[32] CLIPPED AT 1, 1

   LET cc = 1
   CALL openCursorStd()
   WHILE TRUE
      FETCH std_curs INTO P1[cc].*,Wrowid[cc]
      IF STATUS != 0 THEN
         EXIT WHILE
      END IF
      LET cc = cc + 1
      --> If number of records is greater than max size of array of record, confirm if user want to display
      IF cc > max_ary THEN
         ERROR mess[18] CLIPPED,max_ary USING "<<< #"
         LET cc = cc - 1
         CALL SET_COUNT (cc)
         DISPLAY "" AT 1, 1
         DISPLAY "" AT 2, 1
         IF frmtyp ='1' THEN
            DISPLAY "請往下查 ",
                    max_ary USING "<<<#"," 筆" AT 1, 1
            DISPLAY "共 ",cc USING "<<<#"," 筆 " AT 23, 1
            DISPLAY ARRAY P1 TO SR.*
            LET ans2 = "N"
            PROMPT "繼續往下查詢 (y/n)? " FOR CHAR ans2
         ELSE
            DISPLAY "Search next ",
                    max_ary USING "<<<#"," row" AT 1, 1
            DISPLAY "Total ",cc USING "<<<#"," row " AT 23, 1
            DISPLAY ARRAY P1 TO SR.*
            LET ans2 = "N"
            PROMPT "Continue inquiry (y/n)? " FOR CHAR ans2
         END IF      
         IF INT_FLAG THEN
            LET INT_FLAG = FALSE
            CALL closeCursorStd()
            RETURN
         END IF
         IF ans2 MATCHES '[Yy]' THEN
            LET cc = 1
         ELSE
            CLEAR FORM
            CALL closeCursorStd()
            RETURN
         END IF
      END IF
      --<
   END WHILE
   CALL closeCursorStd()

   LET cc = cc - 1
   IF cc = 0 THEN
      ERROR mess[9] CLIPPED
      RETURN
   END IF
   CALL SET_COUNT (cc)
   DISPLAY "" AT 1, 1
   DISPLAY "" AT 2, 1
   DISPLAY mess[29] CLIPPED,mess[32] CLIPPED AT 1, 1
   IF frmtyp ='1' THEN
      DISPLAY "共 ",cc USING "<<<#"," 筆 " AT 23, 1
   ELSE
      DISPLAY "Total ",cc USING "<<<#"," row " AT 23, 1
   END IF   	   
   DISPLAY ARRAY P1 TO SR.*
END FUNCTION
#---------------------------------------------------------------------
FUNCTION curfun() -- Function for reset flag of search data
   IF op_code = "Y" THEN
      LET op_code = "N"
   END IF
END FUNCTION
#---------------------------------------------------------------------
FUNCTION prtfun() -- Function for export report
   DEFINE P RECORD
      manufna   CHAR(23),
      pitemsna  CHAR(23),
      deptna    CHAR(23)        
   END RECORD

   DEFINE  D1  RECORD 
      manuf     LIKE w213.manuf, 
      pitems    LIKE w213.pitems, 
      dept      LIKE w213.dept,    
      machcode  LIKE w213.machcode,     
      kind      LIKE w213.kind,         
      mach_cn   LIKE w213.mach_cn,      
      mach_en   LIKE w213.mach_en,      
      posno     LIKE w213.posno,      
      hole      LIKE w213.hole,      
      lossprs   LIKE w213.lossprs, 
      losshr    LIKE w213.losshr,  
      lossgw    LIKE w213.lossgw
   END RECORD 

   DEFINE qry_str4   CHAR(500)
   
   DISPLAY "" AT 1,1
   DISPLAY "" AT 2,1
   LET offset1 =  80    
   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED  
      RETURN
   END IF
   DISPLAY mess[11] CLIPPED AT 24 , 1 ATTRIBUTE(REVERSE)

   CALL reptol() -- Call this function to show options for user export data
   SET ISOLATION TO DIRTY READ -- set option for read data from database
   
   LET cc = 0
   LET qry_str4 = "SELECT manuf,pitems,dept,machcode, kind,mach_cn,mach_en,posno,hole, lossprs,losshr,lossgw ",
                  " FROM w213",
                  " WHERE manuf = '",gv_manuf,"' AND ", wh_str CLIPPED	
   PREPARE qry_exe4 FROM qry_str4
   DECLARE std_cur4 CURSOR FOR qry_exe4 
                        
   START REPORT fo112av TO rep_naw -- Declare and start report
   FOREACH std_cur4 INTO D1.*
      IF INT_FLAG = TRUE THEN
         LET INT_FLAG = FALSE
         ERROR mess[47] CLIPPED
         EXIT FOREACH
      END IF

      --> get some information need for output report  
      LET P.manufna  = cal_j02(7,D1.manuf)  
      LET P.pitemsna = cal_j02(620,D1.pitems)  
      CALL cal_n15("W",D1.manuf,D1.dept) RETURNING P.deptna    
      --< 

      OUTPUT TO REPORT fo112av(P.*, D1.*) -- Call report and output it  
      LET cc=cc+1
      IF frmtyp = "1" THEN
         DISPLAY "筆數 : ",cc USING "<<<#" AT 22,1
      ELSE
         DISPLAY "Rows : ",cc USING "<<<#" AT 22,1
      END IF        
   END FOREACH
   FINISH REPORT fo112av
   ERROR ""
   IF cc >= 0 THEN
      CALL Cprint(rep_na,"Y")  
   ELSE
      DISPLAY "Rows :      " AT 22,1
      ERROR mess[09] CLIPPED
   END IF
END FUNCTION
#------------------------------------------------------------------------------
REPORT fo112av(P, R) -- define report
   DEFINE Head_B    CHAR(30)
   DEFINE IsEnd     SMALLINT
   DEFINE iv_qty    DECIMAL(9,1)

   DEFINE P RECORD 
      manufna   CHAR(23),     
      pitemsna  CHAR(23),  
      deptna    CHAR(23)        
   END RECORD

   DEFINE R RECORD 
      manuf     LIKE w213.manuf, 
      pitems    LIKE w213.pitems, 
      dept      LIKE w213.dept,         
      machcode LIKE w213.machcode,
      kind     LIKE w213.kind,            
      mach_cn  LIKE w213.mach_cn,      
      mach_en  LIKE w213.mach_en,      
      posno    LIKE w213.posno,      
      hole     LIKE w213.hole,      
      lossprs  LIKE w213.lossprs, 
      losshr   LIKE w213.losshr,  
      lossgw   LIKE w213.lossgw
   END RECORD	

   OUTPUT
      PAGE     LENGTH 10
      TOP      MARGIN 0
      BOTTOM   MARGIN 0
      RIGHT    MARGIN 10
      LEFT     MARGIN 0
      ORDER BY R.pitems,R.dept
   FORMAT        
      FIRST PAGE HEADER    
         LET iv_qty=0
         LET Head_B = cal_compy1('2',gv_manuf)
         PRINT "||", Head_B CLIPPED
         LET IsEnd = FALSE
         
         PRINT "Abnormal working hours machine basic input"
         PRINT "Program: FO112A |||",
               "Print dat: ",TODAY
         PRINT "Print user: ",login_usr CLIPPED,"|||",
               "Print time: ",TIME

         IF frmtyp = 1 THEN
            PRINT   "廠別|manufna|品項|pitemsna|單位|deptna|類型|機台名稱|機台英文|機台編號|台位|孔位|雙/時|時/台|kg/雙"
         ELSE
            PRINT   "manuf|manufna|pitems|pitemsna|dept|deptna|machcode|kind|mach_cn|mach_en|posno|hole|lossprs|losshr|lossgw"
      END IF 	                 
      ON EVERY ROW
         PRINT R.manuf,"|",P.manufna,"|",R.pitems,"|",P.pitemsna,"|",R.dept,"|",P.deptna,"|"        
               ,R.machcode,"|",R.kind,"|",R.mach_cn,"|",R.mach_en,"|",R.posno,"|",R.hole,"|",
               R.lossprs,"|",R.losshr,"|",R.lossgw         
      ON LAST ROW
            PRINT
            PRINT "核決:","||","審核:","||","製表:"             
            PRINT  
            LET IsEnd = TRUE
END REPORT

FUNCTION openCursorCnt() -- function for open header cursor
   IF wk_flagOpenCur1
   THEN
      CLOSE cnt_cur
   END IF
   OPEN cnt_cur
   LET wk_flagOpenCur1 = TRUE
END FUNCTION

FUNCTION closeCursorCnt() -- function for close header cursor
   CLOSE cnt_cur
   LET wk_flagOpenCur1 = FALSE
END FUNCTION

FUNCTION openCursorStd() -- function for open cursor of table
   IF wk_flagOpenCur2
   THEN
      CLOSE std_curs
   END IF
   OPEN std_curs USING PH.pitems, PH.dept
   LET wk_flagOpenCur2 = TRUE
END FUNCTION

FUNCTION closeCursorStd() -- function for close cursor of table
   CLOSE std_curs
   LET wk_flagOpenCur2 = FALSE
END FUNCTION

FUNCTION clearLine() -- function for clear lines use for display message
   DISPLAY "" AT 21, 1
   DISPLAY "" AT 22, 1
   DISPLAY "" AT 23, 1
   DISPLAY "" AT 24, 1
END FUNCTION

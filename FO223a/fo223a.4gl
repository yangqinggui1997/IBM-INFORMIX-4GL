# PRGNAM: fo223a.4gl
# PRGFUN: ??????????
# AUTHOR: Gui
# FORMS : fo223a.PER
# LIB   : w213, w214, w215, j02(779)
# DATE  : 2020-11-21

GLOBALS 'kmgbl.4gl'
DEFINE PH, PH1 RECORD
        manuf     LIKE w214.manuf,  
        manufna   CHAR(23), 
        errno     LIKE w214.errno,
        pitems    LIKE w214.pitems,     
        pitemsna  CHAR(23),
        errdat    LIKE w214.errdat,   
        dept      LIKE w214.dept,  
        deptna    CHAR(23),
        remark    LIKE w214.remark,
        code      LIKE w214.code,
        codsc     LIKE j02.codsc        
        END RECORD,

    P1,P2  ARRAY[99] OF RECORD
         kind LIKE w213.mach_cn,
         machcode LIKE w215.machcode,
         machno LIKE  w215.machno, 
         posno LIKE w215.machno, 
         hole LIKE w215.hole, 
         rmodel LIKE w215.rmodel, 
         tolcls LIKE w215.tolcls, 
         errhr LIKE w215.errhr, 
         slosshole LIKE w215.slosshole,
         slossgw LIKE w215.slossgw, 
         slossprs LIKE w215.slossprs, 
         press LIKE w215.press
       END RECORD,

      Wrowid  ARRAY[99] OF INTEGER   ,
      scr_ary      INTEGER,
      wk_flagOpenCur1 SMALLINT,
      wk_flagOpenCur2 SMALLINT
      DEFINE wk_posno    LIKE w213.posno
      DEFINE wk_hole     LIKE w213.hole
      DEFINE wk_lossprs  LIKE w213.lossprs
      DEFINE wk_losshr   LIKE w213.losshr
      DEFINE wk_lossgw   LIKE w213.lossgw
#-------------------------------------------------------------------------------
FUNCTION mainfun()
   WHENEVER ERROR CALL errmsg
   LET max_ary = 99
   LET scr_ary = 4
   SET LOCK MODE TO WAIT
   LET Pfrm = Cfrm CLIPPED,"/fo223a"
   OPEN FORM fo223a FROM Pfrm
   DISPLAY FORM fo223a
   LET wk_flagOpenCur1 = FALSE
   LET wk_flagOpenCur2 = FALSE
   LET   op_code = "N"

   IF frmtyp = '1'
   THEN
      MENU "??"
         COMMAND "0.??" "??:   ????, ??????, Ctrl-P ??????"
                  HELP 0001 CALL Cset_int() CALL curfun()
                  EXIT MENU
         COMMAND "1.??"
               "??:   ????, ? Esc ??, Del ??, Ctrl-P ??????"
                  HELP 0001 IF( usr_pg[1] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL curfun() CALL addfun()
                  END IF
         COMMAND "2.??"
                  "??:   ????, ? Esc ??, Del ??, Ctrl-P ??????"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL inqfun(TRUE)
                  END IF
         COMMAND "3.??"
                  "??:   ????, ? Esc ??, Del ??, Ctrl-P ??????"
                  HELP 0001 IF( usr_pg[3] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL updfun()
                  END IF
         COMMAND "4.??"
                  "??:   ??????, ? Y ??, Del ??, Ctrl-P ??????"
                  HELP 0001 IF( usr_pg[4] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL delfun()
                  END IF
         COMMAND "5.????" "??:   ????????????, Ctrl-P ??????"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL disfun()
                  END IF
         COMMAND "N.??" "??:   ???????, Ctrl-P ??????"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL pgfun(TRUE)
                  END IF
         COMMAND "U.??" "??:   ???????, Ctrl-P ??????"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL pgfun(FALSE)
                  END IF
         COMMAND "7.????"
                  "??:   ????, ? Esc ??, Del ??, Ctrl-P ??????"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL prtfun()
                  END IF
         COMMAND "H.??" "??:   ????????"
               CALL showhelp(0114)
      END MENU
   ELSE
      MENU "MENU"
      COMMAND "0.END" "HELP:   EXIT,Return previous menu,Ctrl-P Basic help"
               HELP 0001 CALL Cset_int() CALL curfun()
               EXIT MENU
      COMMAND "1.CREATE" "HELP:   Create data, Esc to run, Del to abort, Ctrl-P Basic help"
               HELP 0001 IF( usr_pg[1] = 'N' )THEN ERROR mess[25] CLIPPED
               ELSE CALL Cset_int() CALL curfun() CALL addfun()
               END IF
      COMMAND "2.INQUIRE" "HELP:   Inquire data, Esc to run, Del to abort, Ctrl-P Basic help"
                HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                ELSE CALL Cset_int() CALL inqfun(TRUE)
                END IF
      COMMAND "3.UPDATE" "HELP:   UPDATE data, Esc to run, Del to abort, Ctrl-P Basic help"
                HELP 0001 IF( usr_pg[3] = 'N' )THEN ERROR mess[25] CLIPPED
                ELSE CALL Cset_int() CALL updfun()
                END IF
      COMMAND "4.DELETE" "HELP:   Delete data, Esc to run, Del to abort, Ctrl-P Basic help"
                HELP 0001 IF( usr_pg[4] = 'N' )THEN ERROR mess[25] CLIPPED
                ELSE CALL Cset_int() CALL delfun()
                END IF
      COMMAND "5.DETAIL QUERY" "HELP:   Display detail Data, Ctrl-P Basic help"
                HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                ELSE CALL Cset_int() CALL disfun()
                END IF
      COMMAND "N.PAGE DOWN" "HELP:   Display next page, Ctrl-P  Basic help"
               HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
               ELSE CALL Cset_int() CALL pgfun(TRUE)
               END IF
      COMMAND "U.PAGE UP" "HELP:   Display previous page, Ctrl-P Basic help"
               HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
               ELSE CALL Cset_int() CALL pgfun(FALSE)
               END IF
      COMMAND "7.Print"
              "HELP:   Inquire data, Esc to run, Del to abort, Ctrl-P Basic help"
               HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
               ELSE CALL Cset_int() CALL prtfun()
               END IF
      COMMAND "H.HELP" "HELP:   Operation Help"
               CALL showhelp(0114)
      END MENU
   END IF
   CLOSE FORM fo223a
END FUNCTION
#----------------------------------------------------------------------
FUNCTION inqfun(iv_option)
   DEFINE iv_option SMALLINT

   CLEAR FORM
   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   INITIALIZE PH.* TO NULL #Reset PH cursor for begining search
   IF iv_option
   THEN  
      CONSTRUCT BY NAME wh_str ON PH.pitems, PH.dept, PH.code, PH.errno, PH.errdat, PH.remark
         BEFORE CONSTRUCT
            LET PH.manuf = gv_manuf
            LET PH.manufna  = cal_j02(7,PH.manuf)
            DISPLAY BY NAME PH.manuf, PH.manufna
         ON KEY(F5, CONTROL-W)
               IF INFIELD(pitems) 
               THEN
                  CALL win_j02(620) RETURNING PH.pitems,PH.pitemsna
                  DISPLAY BY NAME PH.pitems, PH.pitemsna
                  NEXT FIELD dept
               END IF
         AFTER FIELD pitems
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
         AFTER FIELD code
            IF PH.code IS NOT NULL AND PH.code NOT MATCHES "[ ]" 
            THEN
               LET PH.codsc = cal_j02e(799, PH.code)
               DISPLAY BY NAME PH.code, PH.codsc
            END IF
         AFTER CONSTRUCT
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
            IF PH.code IS NOT NULL AND PH.code NOT MATCHES "[ ]" 
            THEN
               LET PH.codsc = cal_j02e(799, PH.code)
               DISPLAY BY NAME PH.code, PH.codsc
            END IF
      END CONSTRUCT
      IF INT_FLAG 
      THEN
         LET INT_FLAG = FALSE
         CLEAR FORM
         ERROR mess[6]
         RETURN
      END IF
   ELSE
      LET wh_str = "1=1"
   END IF
   ------  

   LET qry_str = "SELECT UNIQUE a.manuf,'' manufna , a.errno ,a.pitems,'' pitemsna,",
                  " a.errdat, a.dept,'' deptna, a.remark, a.code, b.codsc",
                  " FROM w214 as a JOIN j02 as b ON a.code = b.code WHERE codk = '799' ",
                  " AND a.manuf = '",gv_manuf,"' AND ",wh_str CLIPPED,
                  " ORDER BY 1"
   PREPARE cnt_exe FROM qry_str
   DECLARE cnt_cur SCROLL CURSOR FOR cnt_exe

   LET qry_str3 = "SELECT a.kind, a.machcode, a.machno, a.posno, a.hole, a.rmodel, a.tolcls,",
                  " a.errhr, a.slosshole, a.slossgw, a.slossprs, a.press, a.ROWID",
                  " FROM w215 AS a ",
                  " WHERE errno = ?", 
                  " ORDER BY 1"
   PREPARE qry_exe FROM qry_str3
   DECLARE std_curs SCROLL CURSOR FOR qry_exe

   CALL reopen() 
   LET op_code = "Y"                   
END FUNCTION
#----------------------------------------------------------------
FUNCTION inq100(iv_phPosition)
   DEFINE iv_phPosition INTEGER

   CALL readfun1(iv_phPosition)
   
   FOR cc = 1 TO max_ary
      INITIALIZE P1[cc].* TO NULL
      INITIALIZE P2[cc].* TO NULL
      INITIALIZE Wrowid[cc] TO NULL
   END FOR

   CALL openCursorStd()
   FOR cc = 1 TO max_ary
      FETCH std_curs INTO P1[cc].*,Wrowid[cc]
      IF STATUS != 0 THEN
         EXIT FOR
      END IF
      IF cc <= scr_ary THEN
         DISPLAY P1[cc].* TO SR[cc].*
      END IF
      LET P2[cc].* = P1[cc].*
   END FOR
   CALL closeCursorStd()

   LET cc = cc - 1
   DISPLAY "" AT 24, 1
   IF cc > scr_ary THEN
      ERROR mess[14] CLIPPED
   ELSE
      IF cc = 0 THEN ERROR mess[10] CLIPPED END IF
   END IF
END FUNCTION
#----------------------------------------------------------------
FUNCTION readfun1(iv_cc)
   DEFINE iv_cc INTEGER

   CALL openCursorCnt()
   FETCH ABSOLUTE iv_cc cnt_cur INTO PH.*
   CALL closeCursorCnt()
   LET PH.manufna  = cal_j02(7,PH.manuf)  
   LET PH.pitemsna = cal_j02(620,PH.pitems)
   CALL cal_n15("W",PH.manuf,PH.dept) RETURNING PH.deptna

   DISPLAY BY NAME PH.*
END FUNCTION
#----------------------------------------------------------------
FUNCTION addfun()
   DEFINE wk_machcodecnt INTEGER
   DEFINE wk_duplicate INTEGER
   DEFINE wk_countAddSuccess INTEGER

   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   LET wk_duplicate = 0
   LET wk_countAddSuccess = 0
   INITIALIZE PH.* TO NULL

   FOR cc = 1 TO max_ary
      INITIALIZE P1[cc].* TO NULL
      INITIALIZE Wrowid[cc] TO NULL
   END FOR
   CLEAR FORM
   ------
   CALL add100(FALSE, FALSE, PH.*)
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      CLEAR FORM
      ERROR mess[5] CLIPPED
      RETURN
   END IF
   ------

   CALL add200(FALSE)
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      CLEAR FORM
      ERROR mess[5] CLIPPED
      RETURN
   END IF
   ------
   ERROR mess[11] # proccessing...
   BEGIN WORK
   FOR cc = 1 TO max_ary
      IF P1[cc].kind IS NULL THEN
            EXIT FOR
      END IF
      IF P1[cc].kind NOT MATCHES '[FYNG]' THEN CONTINUE FOR END IF
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
            LET wk_countAddSuccess = wk_countAddSuccess + 1
         END IF
      END IF
   END FOR
   COMMIT WORK
   IF wk_countAddSuccess > 0 THEN
      IF wk_duplicate
      THEN 
         ERROR mess[58] CLIPPED, wk_countAddSuccess USING "<<<<< & record! To be Duplicated ", wk_duplicate USING "<<<<< & record." SLEEP 1
      ELSE
         ERROR mess[58] CLIPPED, wk_countAddSuccess USING "<<<<< & record!" SLEEP 1
      END IF
      CALL inqfun(FALSE)
   ELSE
      IF wk_duplicate
      THEN 
         ERROR mess[4] CLIPPED, "! To be Duplicated ", wk_duplicate USING "<<<<< & record."
      ELSE
         ERROR mess[4] CLIPPED, "!"
      END IF
   END IF
END FUNCTION
#-------------------------------------------------------------------
FUNCTION add100(iv_option1, iv_option2, iv_record)
   DEFINE iv_option1, iv_option2 SMALLINT
   DEFINE wk_key SMALLINT
   DEFINE iv_record RECORD
      manuf     LIKE w214.manuf,  
      manufna   CHAR(23), 
      errno     LIKE w214.errno,
      pitems    LIKE w214.pitems,     
      pitemsna  CHAR(23),
      errdat    LIKE w214.errdat,   
      dept      LIKE w214.dept,  
      deptna    CHAR(23),
      remark    LIKE w214.remark,
      code      LIKE w214.code,
      codsc     LIKE j02.codsc        
   END RECORD

   OPTIONS INSERT KEY F13,
            DELETE KEY F14
   INPUT BY NAME PH.pitems, PH.dept, PH.code, PH.errdat, PH.remark WITHOUT DEFAULTS
      BEFORE INPUT
         IF iv_option1
         THEN
            LET PH.* = iv_record.*
            IF iv_option2 THEN
               LET PH1.* = PH.*
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
            IF INFIELD(code) 
            THEN
               CALL win_j02(799) RETURNING PH.code,PH.codsc
               DISPLAY BY NAME PH.code, PH.codsc
               NEXT FIELD errdat
            END IF
      AFTER INPUT
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
            IF PH.code IS NOT NULL AND PH.code NOT MATCHES "[ ]" 
            THEN
               SELECT UNIQUE code FROM j02 WHERE codk = 799 AND mark='z' AND code = PH.code
               IF STATUS = NOTFOUND THEN
                  ERROR mess[9]
                  NEXT FIELD code
               END IF
               LET PH.codsc = cal_j02e(799, PH.code)
               DISPLAY BY NAME PH.code, PH.codsc
            END IF
            IF PH.errdat IS NULL AND PH.errdat MATCHES "[ ]" 
            THEN
               ERROR mess[15]
               NEXT FIELD errdat
            END IF
            LET PH.errno = get_no('R', PH.dept)
            IF PH.errno IS NULL OR PH.deptna MATCHES "[ ]"
            THEN
               ERROR mess[9] CLIPPED
               NEXT FIELD dept
            END IF
         END IF
   END INPUT
END FUNCTION
#-------------------------------------------------------------------------------
FUNCTION checkDuplicate(iv_index)
   DEFINE iv_index INTEGER
   DEFINE wk_count INTEGER
   LET wk_count = 0

   SELECT COUNT(*) INTO wk_count FROM w215 WHERE errno = PH.errno AND machcode = P1[wk_count].machcode AND kind = P1[wk_count].kind AND machno = P1[wk_count].machno AND posno = P1[wk_count].posno AND hole = P1[wk_count].hole AND rmodel = P1[wk_count].rmodel AND tolcls = P1p[wk_count].tolcls

   IF wk_count
   THEN  
      RETURN (TRUE)
   END IF

   RETURN (FALSE)
END FUNCTION

FUNCTION checkExists(iv_manuf, iv_pitems, iv_dept, iv_machcode)
   DEFINE iv_manuf LIKE w213.manuf
   DEFINE iv_pitems LIKE w213.pitems
   DEFINE iv_dept  LIKE w213.dept
   DEFINE wk_kind LIKE w213.kind
   DEFINE iv_machcode LIKE w213.machcode

   LET wk_count = 0

   SELECT kind INTO wk_kind FROM w213 WHERE manuf = iv_manuf AND pitems = iv_pitems AND dept = iv_dept AND machcode = iv_machcode

   RETURN wk_kind
END FUNCTION

FUNCTION add200(iv_option)
   DEFINE iv_option SMALLINT
   DEFINE wk_key SMALLINT
   DEFINE wk_cc SMALLINT
   DEFINE wk_goto SMALLINT
   DEFINE wk_hour  SMALLINT
   DEFINE wk_cyctime LIKE w55.cyctime
   DEFINE wk_cycqty  DECIMAL(5,0)
   LET wk_goto = FALSE

   INPUT ARRAY P1 WITHOUT DEFAULTS FROM SR.*
      BEFORE ROW
         LET aln = ARR_CURR()
         LET sln = SCR_LINE()
         LET P1[aln].errhr = 0
         LET P1[aln].slosshole = 0
         LET P1[aln].slossgw = 0.0
         LET P1[aln].slossprs = 0.0
         LET P1[aln].press = 'N'
         DISPLAY P1[aln].* TO SR[sln].* ATTRIBUTE(REVERSE)
         IF frmtyp ='1' THEN
            DISPLAY "本行是第 ", aln USING "<<#"," 行" AT 22, 1
         ELSE
            DISPLAY "This row is ", aln USING "<<#"," row" AT 22, 1
         END IF
      BEFORE FIELD kind
         ERROR "Values are only 'F', 'Y', 'N' and 'G'!, Press CONTROL-W to show options."
      BEFORE FIELD machcode
         ERROR "Press CONTROL-W to show options."
      ON KEY (CONTROL-Z)
         LABEL lblCallAdd100:
         CALL add100(TRUE, FALSE, PH.*)
         IF INT_FLAG THEN
            LET INT_FLAG = FALSE
            CLEAR FORM
            ERROR mess[5] CLIPPED
            RETURN
         END IF
      ON KEY(F5, CONTROL-W)
         IF INFIELD(machcode)
         THEN
            CALL win_w213(PH.manuf,PH.pitems,PH.dept) RETURNING P1[aln].kind,P1[aln].machcode
            NEXT FIELD machno
         END IF
      AFTER ROW
         LET wk_key = FGL_LASTKEY()
         IF wk_key == FGL_KEYVAL("ACCEPT") OR wk_key == FGL_KEYVAL("ESC") OR wk_key == FGL_KEYVAL("TAB")
         THEN
         -- check machcode field
            IF P1[aln].machcode IS NULL OR P1[aln].machcode MATCHES "[ ]"  THEN
               ERROR mess[15]
               NEXT FIELD machcode
            ELSE
               CALL checkExists(PH.manuf, PH.pitems, PH.dept, P1[aln].machcode) RETURNING P1[aln].kind
               IF P1[aln].kind
               THEN
                  DISPLAY P1[aln].kind TO SR[aln].kind
               ELSE
                  IF frmtyp = '2' THEN
                     CALL cal_err("Kind and machcode weren't found","please try again")
                  ELSE
                     CALL cal_err("無異常工時計算代碼","請重新輸入")
                  END IF
                  NEXT FIELD machcode
               END IF
            END IF
         -- check posno and hole fields
            IF (P1[aln].posno IS NULL OR P1[aln].posno MATCHES "[ ]") AND (P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]")
            THEN
               SELECT posno, hole INTO wk_posno, wk_hole
         	   FROM w213 
               WHERE manuf = PH.manuf
               AND pitems=PH.pitems 
               AND dept=PH.dept
               AND machcode=P1[aln].machcode
               IF STATUS = 0 THEN
                  LET P1[aln].slosshole = wk_posno * wk_hole
               END IF	          	 
            END IF
            IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]") THEN
               LET P1[aln].slosshole = wk_hole
            END IF
            IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]") THEN
               LET P1[aln].slosshole = 1
            END IF
            DISPLAY P1[aln].slosshole TO SR[sln].slosshole   
         -- check rmodel field
            IF (LENGTH(P1[aln].rmodel) = 0 OR P1[aln].rmodel IS NULL OR P1[aln].rmodel MATCHES "[ ]") AND P1[aln].kind MATCHES '[Y]' 
            THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD rmodel
            END IF
            LET wk_cc = 0
            SELECT COUNT(UNIQUE tolno) INTO wk_cc FROM wj04
            WHERE tolno = P1[aln].rmodel
               AND lmanuf = PH.manuf
            IF wk_cc <= 0 THEN ERROR mess[01] CLIPPED
               NEXT FIELD rmodel
            END IF
         -- check tolcls field
            IF (P1[aln].tolcls IS NULL OR P1[aln].tolcls MATCHES "[ ]" OR LENGTH(P1[aln].tolcls) = 0) AND P1[aln].kind MATCHES '[Y]' THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD tolcls
            END IF
            SELECT ROWID FROM wj03 WHERE tolcls = P1[aln].tolcls
            IF STATUS != 0 THEN
               ERROR mess[20] CLIPPED
               NEXT FIELD tolcls
            END IF
            SELECT ROWID FROM wj04
            WHERE lmanuf = PH.manuf
            AND tolno = P1[aln].rmodel 
            AND tolcls = P1[aln].tolcls

            IF STATUS != 0 THEN
               IF frmtyp = '2' THEN
                  CALL cal_err("wj04 Mold data not found","please try again")
               ELSE
                  CALL cal_err("wj04 無該模具資料","請重新輸入")
               END IF
               NEXT FIELD rmodel
            END IF
         -- check errhr field
            IF (P1[aln].errhr IS NULL OR P1[aln].errhr MATCHES "[ ]" OR LENGTH(P1[aln].errhr) = 0) AND P1[aln].kind MATCHES '[F]'  THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD errhr
            ELSE
               IF P1[aln].kind MATCHES '[F]' AND P1[aln].errhr < 0 THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD errhr
               END IF
            END IF
         -- check slosshole field
            IF (P1[aln].slosshole IS NULL OR P1[aln].slosshole MATCHES "[ ]" OR LENGTH(P1[aln].slosshole) = 0) 
            AND P1[aln].kind MATCHES '[Y]' 
            THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD slosshole
            ELSE
            #計算TCT
               SELECT AVG(cyctime) INTO wk_cyctime
               FROM w55 
               WHERE manuf = PH.manuf
               AND rmodel = P1[aln].rmodel AND tolcls = P1[aln].tolcls

               LET wk_hour = 0
               SELECT codsc INTO wk_hour FROM j02 
               WHERE codk ='615' AND mark[1] = gv_manuf
                  #1孔(hole)損失
               LET wk_cycqty = (wk_hour * 60)/(wk_cyctime/60) #21小時計算 
               IF P1[aln].posno IS NULL OR P1[aln].posno MATCHES "[ ]" OR AND P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]" 
               THEN
                  SELECT  posno, hole
                  INTO wk_posno, wk_hole
                  FROM w213 
                  WHERE manuf = PH.manuf 
                  AND pitems = PH.pitems 
                  AND dept = PH.dept 
                  AND machcode = P1[aln].machcode
                  IF STATUS = 0 THEN
                     LET P1[aln].slossprs = wk_cycqty * wk_posno * wk_hole
                  END IF	          	 
               END IF
               IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]") THEN
                  LET P1[aln].slossprs = wk_cycqty * 2
               END IF
               IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]") THEN)
                  LET P1[aln].slossprs = wk_cycqty
               END IF          	
            END IF
            DISPLAY P1[aln].slosshole TO SR[sln].slosshole 
         -- check slossgw field
            IF (P1[aln].slossgw IS NULL OR P1[aln].slossgw MATCHES "[ ]" OR LENGTH(P1[aln].slossgw) = 0) AND P1[aln].kind MATCHES '[N]'  
            THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD slossgw
            ELSE
               IF P1[aln].kind MATCHES '[N]' AND P1[aln].slossgw < 0.0 
               THEN
                  ERROR mess[15] CLIPPED
                  NEXT FIELD slossgw         	  
               END IF
               SELECT  posno, hole, lossprs, losshr, lossgw
               INTO wk_posno, wk_hole, wk_lossprs, wk_losshr, wk_lossgw
               FROM w213 
               WHERE manuf = PH.manuf  
               AND pitems = PH.pitems 
               AND dept = PH.dept 
               AND machcode = P1[aln].machcode
               IF STATUS = 0 THEN
                  LET P1[aln].slossprs = P1[aln].slossgw/wk_lossgw
               END IF	   
            END IF
            DISPLAY P1[aln].slossgw TO SR[sln].slossgw 
         -- check slossprs field
            IF (P1[aln].slossprs IS NULL OR P1[aln].slossprs MATCHES "[ ]" OR LENGTH(P1[aln].slossprs) = 0) AND P1[aln].kind MATCHES '[YNG]'  THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD slossprs
            ELSE
               IF P1[aln].kind MATCHES '[G]' AND P1[aln].errhr < 0 THEN
               ERROR mess[15] CLIPPED
                  NEXT FIELD errhr
               END IF
               SELECT  posno, hole, lossprs, losshr, lossgw
               INTO wk_posno, wk_hole, wk_lossprs, wk_losshr, wk_lossgw
               FROM w213 
               WHERE manuf = PH.manuf  
               AND pitems = PH.pitems 
               AND dept = PH.dept 
               AND machcode = P1[aln].machcode
               IF STATUS = 0 THEN
                  LET P1[aln].slossprs = P1[aln].errhr * wk_lossprs
               END IF 
            END IF
            DISPLAY P1[aln].slossprs TO SR[sln].slossprs 
         -- check duplicate
            IF (NOT iv_option) OR (iv_option AND (P2[aln].machcode != P1[aln].machcode OR P2[aln].machno != P1[aln].machno OR P2[aln].posno != P1[aln].posno OR P2[aln].hole != P1[aln].hole OR P2[aln].rmodel != P1[aln].rmodel OR P2[aln].tolcls != P1[aln].tolcls OR PH1.pitems != PH.pitems OR PH1.dept != PH.dept))
            THEN
               IF checkDuplicate(aln)
               THEN  
                  ERROR mess[2]
                  IF ((PH1.pitems != PH.pitems OR PH1.dept != PH.dept) AND iv_option) OR NOT iv_option
                  THEN
                     LET wk_goto = TRUE
                     GOTO lblCallAdd100
                  END IF
                  IF (iv_option AND (P2[aln].machcode != P1[aln].machcode OR P2[aln].machno != P1[aln].machno OR P2[aln].posno != P1[aln].posno OR P2[aln].hole != P1[aln].hole OR P2[aln].rmodel != P1[aln].rmodel OR P2[aln].tolcls != P1[aln].tolcls))
                  THEN 
                     NEXT FIELD machcode
                  END IF
               ELSE
                  NEXT FIELD machno
               END IF
            ELSE
               IF wk_goto THEN CALL add200(TRUE) END IF
            END IF
            IF P1[aln].errhr     IS NULL THEN LET P1[aln].errhr     = 0   END IF
            IF P1[aln].slosshole IS NULL THEN LET P1[aln].slosshole = 0   END IF
            IF P1[aln].slossgw   IS NULL THEN LET P1[aln].slossgw   = 0.0 END IF
            IF P1[aln].slossprs  IS NULL THEN LET P1[aln].slossprs  = 0.0 END IF
            IF P1[aln].press     IS NULL THEN LET P1[aln].press     = 'N' END IF
            
            IF P1[aln].kind MATCHES '[Y]' AND P1[aln].slosshole < 0.0 
            THEN
               NEXT FIELD slosshole
            END IF
            #?÷?x????F???????i?`·l??/???j?A?u???p?§±`?u??????
            IF P1[aln].kind MATCHES '[F]' AND P1[aln].errhr < 0 
            THEN
               NEXT FIELD errhr
            END IF 
            #?÷?x????N?O?????q(Kg):???q(Kg)????°??Hg/??*?§±`????=?i?`·l??/???j                     
            IF P1[aln].kind MATCHES '[N]' AND P1[aln].slossgw < 0.0 
            THEN
               NEXT FIELD slossgw
            END IF 
            #?÷?x????G???T?w??/?p???p??????·l???G?§±`????*??/?p??=?i?`·l/???j
            IF P1[aln].kind MATCHES '[G]' AND P1[aln].errhr < 0 
            THEN
               NEXT FIELD errhr
            END IF 
            IF P1[aln].kind MATCHES '[YNG]' AND P1[aln].slossprs < 0.0 
            THEN
               NEXT FIELD slossprs
            END IF
            DISPLAY P1[aln].errhr     TO SR[sln].errhr     ATTRIBUTE(REVERSE)
            DISPLAY P1[aln].slosshole TO SR[sln].slosshole ATTRIBUTE(REVERSE)
            DISPLAY P1[aln].slossprs  TO SR[sln].slossprs  ATTRIBUTE(REVERSE)
            DISPLAY P1[aln].slossgw   TO SR[sln].slossgw   ATTRIBUTE(REVERSE)
         END IF
      AFTER INPUT
         LET wk_key = FGL_LASTKEY()
         IF wk_key == FGL_KEYVAL("ACCEPT") OR wk_key == FGL_KEYVAL("ESC")
         THEN
         -- check machcode field
            IF P1[aln].machcode IS NULL OR P1[aln].machcode MATCHES "[ ]"  THEN
               ERROR mess[15]
               NEXT FIELD machcode
            ELSE
               CALL checkExists(PH.manuf, PH.pitems, PH.dept, P1[aln].machcode) RETURNING P1[aln].kind
               IF P1[aln].kind
               THEN
                  DISPLAY P1[aln].kind TO SR[aln].kind
               ELSE
                  IF frmtyp = '2' THEN
                     CALL cal_err("Kind and machcode weren't found","please try again")
                  ELSE
                     CALL cal_err("無異常工時計算代碼","請重新輸入")
                  END IF
                  NEXT FIELD machcode
               END IF
            END IF
         -- check posno and hole fields
            IF (P1[aln].posno IS NULL OR P1[aln].posno MATCHES "[ ]") AND (P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]")
            THEN
               SELECT posno, hole INTO wk_posno, wk_hole
         	   FROM w213 
               WHERE manuf = PH.manuf
               AND pitems=PH.pitems 
               AND dept=PH.dept
               AND machcode=P1[aln].machcode
               IF STATUS = 0 THEN
                  LET P1[aln].slosshole = wk_posno * wk_hole
               END IF	          	 
            END IF
            IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]") THEN
               LET P1[aln].slosshole = wk_hole
            END IF
            IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]") THEN
               LET P1[aln].slosshole = 1
            END IF
            DISPLAY P1[aln].slosshole TO SR[sln].slosshole   
         -- check rmodel field
            IF (LENGTH(P1[aln].rmodel) = 0 OR P1[aln].rmodel IS NULL OR P1[aln].rmodel MATCHES "[ ]") AND P1[aln].kind MATCHES '[Y]' 
            THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD rmodel
            END IF
            LET wk_cc = 0
            SELECT COUNT(UNIQUE tolno) INTO wk_cc FROM wj04
            WHERE tolno = P1[aln].rmodel
               AND lmanuf = PH.manuf
            IF wk_cc <= 0 THEN ERROR mess[01] CLIPPED
               NEXT FIELD rmodel
            END IF
         -- check tolcls field
            IF (P1[aln].tolcls IS NULL OR P1[aln].tolcls MATCHES "[ ]" OR LENGTH(P1[aln].tolcls) = 0) AND P1[aln].kind MATCHES '[Y]' THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD tolcls
            END IF
            SELECT ROWID FROM wj03 WHERE tolcls = P1[aln].tolcls
            IF STATUS != 0 THEN
               ERROR mess[20] CLIPPED
               NEXT FIELD tolcls
            END IF
            SELECT ROWID FROM wj04
            WHERE lmanuf = PH.manuf
            AND tolno = P1[aln].rmodel 
            AND tolcls = P1[aln].tolcls

            IF STATUS != 0 THEN
               IF frmtyp = '2' THEN
                  CALL cal_err("wj04 Mold data not found","please try again")
               ELSE
                  CALL cal_err("wj04 無該模具資料","請重新輸入")
               END IF
               NEXT FIELD rmodel
            END IF
         -- check errhr field
            IF (P1[aln].errhr IS NULL OR P1[aln].errhr MATCHES "[ ]" OR LENGTH(P1[aln].errhr) = 0) AND P1[aln].kind MATCHES '[F]'  THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD errhr
            ELSE
               IF P1[aln].kind MATCHES '[F]' AND P1[aln].errhr < 0 THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD errhr
               END IF
            END IF
         -- check slosshole field
            IF (P1[aln].slosshole IS NULL OR P1[aln].slosshole MATCHES "[ ]" OR LENGTH(P1[aln].slosshole) = 0) 
            AND P1[aln].kind MATCHES '[Y]' 
            THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD slosshole
            ELSE
            #計算TCT
               SELECT AVG(cyctime) INTO wk_cyctime
               FROM w55 
               WHERE manuf = PH.manuf
               AND rmodel = P1[aln].rmodel AND tolcls = P1[aln].tolcls

               LET wk_hour = 0
               SELECT codsc INTO wk_hour FROM j02 
               WHERE codk ='615' AND mark[1] = gv_manuf
                  #1孔(hole)損失
               LET wk_cycqty = (wk_hour * 60)/(wk_cyctime/60) #21小時計算 
               IF P1[aln].posno IS NULL OR P1[aln].posno MATCHES "[ ]" OR AND P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]" 
               THEN
                  SELECT  posno, hole
                  INTO wk_posno, wk_hole
                  FROM w213 
                  WHERE manuf = PH.manuf 
                  AND pitems = PH.pitems 
                  AND dept = PH.dept 
                  AND machcode = P1[aln].machcode
                  IF STATUS = 0 THEN
                     LET P1[aln].slossprs = wk_cycqty * wk_posno * wk_hole
                  END IF	          	 
               END IF
               IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]") THEN
                  LET P1[aln].slossprs = wk_cycqty * 2
               END IF
               IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]") THEN)
                  LET P1[aln].slossprs = wk_cycqty
               END IF          	
            END IF
            DISPLAY P1[aln].slosshole TO SR[sln].slosshole 
         -- check slossgw field
            IF (P1[aln].slossgw IS NULL OR P1[aln].slossgw MATCHES "[ ]" OR LENGTH(P1[aln].slossgw) = 0) AND P1[aln].kind MATCHES '[N]'  
            THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD slossgw
            ELSE
               IF P1[aln].kind MATCHES '[N]' AND P1[aln].slossgw < 0.0 
               THEN
                  ERROR mess[15] CLIPPED
                  NEXT FIELD slossgw         	  
               END IF
               SELECT  posno, hole, lossprs, losshr, lossgw
               INTO wk_posno, wk_hole, wk_lossprs, wk_losshr, wk_lossgw
               FROM w213 
               WHERE manuf = PH.manuf  
               AND pitems = PH.pitems 
               AND dept = PH.dept 
               AND machcode = P1[aln].machcode
               IF STATUS = 0 THEN
                  LET P1[aln].slossprs = P1[aln].slossgw/wk_lossgw
               END IF	   
            END IF
            DISPLAY P1[aln].slossgw TO SR[sln].slossgw 
         -- check slossprs field
            IF (P1[aln].slossprs IS NULL OR P1[aln].slossprs MATCHES "[ ]" OR LENGTH(P1[aln].slossprs) = 0) AND P1[aln].kind MATCHES '[YNG]'  THEN
               ERROR mess[15] CLIPPED
               NEXT FIELD slossprs
            ELSE
               IF P1[aln].kind MATCHES '[G]' AND P1[aln].errhr < 0 THEN
               ERROR mess[15] CLIPPED
                  NEXT FIELD errhr
               END IF
               SELECT  posno, hole, lossprs, losshr, lossgw
               INTO wk_posno, wk_hole, wk_lossprs, wk_losshr, wk_lossgw
               FROM w213 
               WHERE manuf = PH.manuf  
               AND pitems = PH.pitems 
               AND dept = PH.dept 
               AND machcode = P1[aln].machcode
               IF STATUS = 0 THEN
                  LET P1[aln].slossprs = P1[aln].errhr * wk_lossprs
               END IF 
            END IF
            DISPLAY P1[aln].slossprs TO SR[sln].slossprs 
         -- check duplicate
            IF (NOT iv_option) OR (iv_option AND (P2[aln].machcode != P1[aln].machcode OR P2[aln].machno != P1[aln].machno OR P2[aln].posno != P1[aln].posno OR P2[aln].hole != P1[aln].hole OR P2[aln].rmodel != P1[aln].rmodel OR P2[aln].tolcls != P1[aln].tolcls OR PH1.pitems != PH.pitems OR PH1.dept != PH.dept))
            THEN
               IF checkDuplicate(aln)
               THEN  
                  ERROR mess[2]
                  IF ((PH1.pitems != PH.pitems OR PH1.dept != PH.dept) AND iv_option) OR NOT iv_option
                  THEN
                     LET wk_goto = TRUE
                     GOTO lblCallAdd100
                  END IF
                  IF (iv_option AND (P2[aln].machcode != P1[aln].machcode OR P2[aln].machno != P1[aln].machno OR P2[aln].posno != P1[aln].posno OR P2[aln].hole != P1[aln].hole OR P2[aln].rmodel != P1[aln].rmodel OR P2[aln].tolcls != P1[aln].tolcls))
                  THEN 
                     NEXT FIELD machcode
                  END IF
               ELSE
                  NEXT FIELD machno
               END IF
            ELSE
               IF wk_goto THEN CALL add200(TRUE) END IF
            END IF
            IF P1[aln].errhr     IS NULL THEN LET P1[aln].errhr     = 0   END IF
            IF P1[aln].slosshole IS NULL THEN LET P1[aln].slosshole = 0   END IF
            IF P1[aln].slossgw   IS NULL THEN LET P1[aln].slossgw   = 0.0 END IF
            IF P1[aln].slossprs  IS NULL THEN LET P1[aln].slossprs  = 0.0 END IF
            IF P1[aln].press     IS NULL THEN LET P1[aln].press     = 'N' END IF
            
            IF P1[aln].kind MATCHES '[Y]' AND P1[aln].slosshole < 0.0 
            THEN
               NEXT FIELD slosshole
            END IF
            #?÷?x????F???????i?`·l??/???j?A?u???p?§±`?u??????
            IF P1[aln].kind MATCHES '[F]' AND P1[aln].errhr < 0 
            THEN
               NEXT FIELD errhr
            END IF 
            #?÷?x????N?O?????q(Kg):???q(Kg)????°??Hg/??*?§±`????=?i?`·l??/???j                     
            IF P1[aln].kind MATCHES '[N]' AND P1[aln].slossgw < 0.0 
            THEN
               NEXT FIELD slossgw
            END IF 
            #?÷?x????G???T?w??/?p???p??????·l???G?§±`????*??/?p??=?i?`·l/???j
            IF P1[aln].kind MATCHES '[G]' AND P1[aln].errhr < 0 
            THEN
               NEXT FIELD errhr
            END IF 
            IF P1[aln].kind MATCHES '[YNG]' AND P1[aln].slossprs < 0.0 
            THEN
               NEXT FIELD slossprs
            END IF
            DISPLAY P1[aln].errhr     TO SR[sln].errhr     ATTRIBUTE(REVERSE)
            DISPLAY P1[aln].slosshole TO SR[sln].slosshole ATTRIBUTE(REVERSE)
            DISPLAY P1[aln].slossprs  TO SR[sln].slossprs  ATTRIBUTE(REVERSE)
            DISPLAY P1[aln].slossgw   TO SR[sln].slossgw   ATTRIBUTE(REVERSE)
         END IF
   END INPUT
END FUNCTION

FUNCTION updfun()
--    DEFINE wk_machcodecnt INTEGER
--    DEFINE wk_duplicate INTEGER
--    DEFINE wk_countUpdateSuccess INTEGER

--    DISPLAY "" AT 23, 1
--    DISPLAY "" AT 22, 1

--    LET wk_duplicate = 0
--    LET wk_countUpdateSuccess = 0

--    IF op_code = 'N' THEN
--       ERROR mess[16] CLIPPED
--       RETURN
--    END IF
--    OPTIONS INSERT KEY F13,
--          DELETE KEY F14
--    CALL SET_COUNT(cc)

--    CALL add200(TRUE)
--    IF INT_FLAG THEN
--       LET INT_FLAG = FALSE
--       ERROR mess[07] CLIPPED
--       RETURN
--    END IF

--    BEGIN WORK
--    FOR cc1 = 1 TO max_ary
--       IF P1[cc1].kind IS NULL THEN
--          EXIT FOR
--       END IF
--       IF P2[cc1].kind !=  P1[cc1].kind OR P2[cc1].mach_cn !=  P1[cc1].mach_cn OR P2[cc1].mach_en !=  P1[cc1].mach_en
--          OR P2[cc1].posno !=  P1[cc1].posno OR P2[cc1].hole !=  P1[cc1].hole OR P2[cc1].machcode !=  P1[cc1].machcode
--          OR P2[cc1].lossprs !=  P1[cc1].lossprs OR P2[cc1].losshr !=  P1[cc1].losshr OR P2[cc1].lossgw !=  P1[cc1].lossgw
--       THEN
--          IF P1[cc1].kind NOT MATCHES '[FYNG]' THEN CONTINUE FOR END IF
--          LET wk_machcodecnt = 0
--          SELECT COUNT(*) INTO wk_machcodecnt FROM w213
--          WHERE manuf = PH.manuf AND pitems = PH.pitems AND dept = PH.dept AND machcode = P1[cc1].machcode
--          IF wk_machcodecnt THEN
--             LET wk_duplicate = wk_duplicate + 1
--          ELSE
--             UPDATE w213 SET (machcode, kind,mach_cn,mach_en,posno,hole,lossprs,losshr,lossgw,upusr,upday)
--                         = (P1[cc1].machcode, P1[cc1].kind, P1[cc1].mach_cn, P1[cc1].mach_en, P1[cc1].posno, P1[cc1].hole, P1[cc1].lossprs, P1[cc1].losshr, P1[cc1].lossgw,login_usr, CURRENT YEAR TO SECOND)
--             WHERE ROWID = Wrowid[cc1]
--             IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
--                ROLLBACK WORK
--                ERROR mess[04] CLIPPED
--                RETURN
--             ELSE
--                LET wk_countUpdateSuccess = wk_countUpdateSuccess + 1
--             END IF
--          END IF
--       END IF
--    END FOR
--    COMMIT WORK
--    IF wk_countUpdateSuccess > 0 THEN
--       IF wk_duplicate
--       THEN 
--          ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!", " To be Duplicated ", wk_duplicate USING "<<<<< & record." SLEEP 1
--       ELSE
--          ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!" SLEEP 1
--       END IF
--       CALL inqfun(FALSE)
--    ELSE
--       IF wk_duplicate
--       THEN 
--          ERROR "Datas are unchanged! To be Duplicated ", wk_duplicate USING "<<<<< & record." SLEEP 1
--       ELSE
--          ERROR "Datas are unchanged!" SLEEP 1
--       END IF
--    END IF
--    CALL reopen()
END FUNCTION
#----------------------------------------------------------------------
FUNCTION pgfun(move)
   DEFINE move SMALLINT
--    DEFINE wk_message CHAR(300)

--    DISPLAY "" AT 23, 1
--    DISPLAY "" AT 22, 1

--    IF op_code = "N" THEN
--       ERROR mess[16] CLIPPED
--       RETURN
--    END IF
--    IF move THEN
--       LET cnt = cnt + 1
--       IF cnt >= allcnt 
--       THEN 
--          IF cnt > allcnt THEN 
--             LET cnt = 1 
--             LET wk_message = mess[12]
--          ELSE
--             LET wk_message = mess[13]
--          END IF
--       END IF
--       CALL openCursorCnt()
--       FETCH ABSOLUTE cnt cnt_cur INTO PH.*
--       CALL closeCursorCnt()
--    ELSE
--       LET cnt = cnt - 1
--       IF cnt <= 1
--       THEN 
--          IF cnt < 1 THEN 
--             LET cnt = allcnt 
--             LET wk_message = mess[13]
--          ELSE
--             LET wk_message = mess[12]
--          END IF
--       END IF
--       CALL openCursorCnt()
--       FETCH ABSOLUTE cnt cnt_cur INTO PH.*
--       CALL closeCursorCnt()
--    END IF
--    CLEAR FORM #Reset all field include input array
--    ERROR wk_message CLIPPED
--    CALL inq100(cnt)
--    IF frmtyp ='1' THEN
--       DISPLAY "??? : ",allcnt USING "<<<<#",
--               "  ??? ",cnt USING "<<<<#"," ? " AT 23,1
--    ELSE
--       DISPLAY "Totals pages : ",allcnt USING "<<<<#",
--                "  Display page ",cnt USING "#" AT 23,1
--    END IF           	           
END FUNCTION
#-------------------------------------------------------------------------------
FUNCTION delfun()
--    DISPLAY "" AT 23, 1
--    DISPLAY "" AT 22, 1

--    IF op_code = "N" THEN
--       ERROR mess[16] CLIPPED
--       RETURN
--    END IF
--    CALL ans() RETURNING ans1
--    IF ans1 MATCHES "[^Yy]" THEN
--       ERROR mess[8]
--       RETURN
--    END IF
--    LET cnt1 = 0
--    BEGIN WORK
--       FOR cc1 = 1 TO cc
--          DELETE FROM w213 WHERE ROWID = Wrowid[cc1]
--          IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
--             ERROR mess[63] CLIPPED
--             ROLLBACK WORK
--             RETURN
--          ELSE
--             LET cnt1 = cnt1 + 1
--          END IF
--       END FOR
--    COMMIT WORK
--    ERROR mess[53] CLIPPED, cnt1 USING "<<< & ",mess[41] CLIPPED
--    CALL reopen()
END FUNCTION
#----------------------------------------------------------------------
FUNCTION reopen()
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
         DISPLAY "??? : ",allcnt USING "<<<<#",
              "  ??? ",cnt USING "<<<<#"," ? " AT 23,1
      END IF
      ERROR mess[12] CLIPPED SLEEP 1
      CALL inq100(cnt)
   END IF
END FUNCTION
#----------------------------------------------------------------------
FUNCTION disfun()
--    IF op_code = "N" THEN
--       ERROR mess[16] CLIPPED
--       RETURN
--    END IF
--    DISPLAY "" AT 1, 1
--    DISPLAY "" AT 2, 1
--    DISPLAY "" AT 23, 1
--    DISPLAY "" AT 22, 1

--    DISPLAY mess[29] CLIPPED,mess[32] CLIPPED AT 1, 1

--    LET cc = 1
--    CALL openCursorStd()
--    WHILE TRUE
--       FETCH std_curs INTO P1[cc].*,Wrowid[cc]
--       IF STATUS != 0 THEN
--          EXIT WHILE
--       END IF
--       LET cc = cc + 1
--       IF cc > max_ary THEN
--          ERROR mess[18] CLIPPED,max_ary USING "<<< #"
--          LET cc = cc - 1
--          CALL SET_COUNT (cc)
--          DISPLAY "" AT 1, 1
--          DISPLAY "" AT 2, 1
--          IF frmtyp ='1' THEN
--             DISPLAY "???? ",
--                     max_ary USING "<<<#"," ?" AT 1, 1
--             DISPLAY "? ",cc USING "<<<#"," ? " AT 23, 1
--             DISPLAY ARRAY P1 TO SR.*
--             LET ans2 = "N"
--             PROMPT "?????? (y/n)? " FOR CHAR ans2
--          ELSE
--             DISPLAY "Search next ",
--                     max_ary USING "<<<#"," row" AT 1, 1
--             DISPLAY "Total ",cc USING "<<<#"," row " AT 23, 1
--             DISPLAY ARRAY P1 TO SR.*
--             LET ans2 = "N"
--             PROMPT "Continue inquiry (y/n)? " FOR CHAR ans2
--          END IF      
--          IF INT_FLAG THEN
--             LET INT_FLAG = FALSE
--             CALL closeCursorStd()
--             RETURN
--          END IF
--          IF ans2 MATCHES '[Yy]' THEN
--             LET cc = 1
--          ELSE
--             CLEAR FORM
--             CALL closeCursorStd()
--             RETURN
--          END IF
--       END IF
--    END WHILE
--    CALL closeCursorStd()

--    LET cc = cc - 1
--    IF cc = 0 THEN
--       ERROR mess[9] CLIPPED
--       RETURN
--    END IF
--    CALL SET_COUNT (cc)
--    DISPLAY "" AT 1, 1
--    DISPLAY "" AT 2, 1
--    DISPLAY "" AT 23, 1
--    DISPLAY mess[29] CLIPPED,mess[32] CLIPPED AT 1, 1
--    IF frmtyp ='1' THEN
--       DISPLAY "? ",cc USING "<<<#"," ? " AT 23, 1
--    ELSE
--       DISPLAY "Total ",cc USING "<<<#"," row " AT 23, 1
--    END IF   	   
--    DISPLAY ARRAY P1 TO SR.*
END FUNCTION
#---------------------------------------------------------------------
FUNCTION curfun()
   IF op_code = "Y" THEN
      LET op_code = "N"
   END IF
END FUNCTION
#######################################################
FUNCTION prtfun()
--    DEFINE P RECORD
--       manufna   CHAR(23),
--       pitemsna  CHAR(23),
--       deptna    CHAR(23)        
--    END RECORD

--    DEFINE  D1  RECORD 
--       manuf     LIKE w213.manuf, 
--       pitems    LIKE w213.pitems, 
--       dept      LIKE w213.dept,    
--       machcode  LIKE w213.machcode,     
--       kind      LIKE w213.kind,         
--       mach_cn   LIKE w213.mach_cn,      
--       mach_en   LIKE w213.mach_en,      
--       posno     LIKE w213.posno,      
--       hole      LIKE w213.hole,      
--       lossprs   LIKE w213.lossprs, 
--       losshr    LIKE w213.losshr,  
--       lossgw    LIKE w213.lossgw
--    END RECORD 

--    DEFINE iv_storna CHAR(20)	
--    DEFINE qry_str4   CHAR(500)
--    DEFINE wd_qty     LIKE w202.qty
--    DEFINE wd_seq     LIKE w200.seq
--    DEFINE wk_week    SMALLINT
--    DEFINE  iv_day    DATE
--    DEFINE  ir_day    DATE
   
--    DISPLAY "" AT 1,1
--    DISPLAY "" AT 2,1
--    LET offset1 =  80
--    DISPLAY "" AT 23, 1
--    DISPLAY "" AT 22, 1        
--    IF op_code = "N" THEN
--       ERROR mess[16] CLIPPED  
--       RETURN
--    END IF
--    DISPLAY mess[11] CLIPPED AT 24 , 1 ATTRIBUTE(REVERSE)

--    CALL reptol()
--    SET ISOLATION TO DIRTY READ
   
--    LET cc = 0
--    LET wd_seq = 0  
--    LET qry_str4 = "SELECT manuf,pitems,dept,machcode, kind,mach_cn,mach_en,posno,hole, lossprs,losshr,lossgw ",
--                   " FROM w213",
--                   " WHERE manuf = '",gv_manuf,"' AND ", wh_str CLIPPED	
--    PREPARE qry_exe4 FROM qry_str4
--    DECLARE std_cur4 CURSOR FOR qry_exe4 
                        
--    START REPORT fo223av TO rep_naw
--    FOREACH std_cur4 INTO D1.*
   
--       IF INT_FLAG = TRUE THEN
--          LET INT_FLAG = FALSE
--          ERROR mess[47] CLIPPED
--          EXIT FOREACH
--       END IF
--       LET P.manufna  = cal_j02(7,D1.manuf)  
--       LET P.pitemsna = cal_j02(620,D1.pitems)  
--       CALL cal_n15("W",D1.manuf,D1.dept) RETURNING P.deptna    
--       OUTPUT TO REPORT fo223av(P.*, D1.*)  
--       LET cc=cc+1
--       IF frmtyp = "1" THEN
--          DISPLAY "?? : ",cc USING "<<<#" AT 22,1
--       ELSE
--          DISPLAY "Rows : ",cc USING "<<<#" AT 22,1
--       END IF        
--    END FOREACH
--    FINISH REPORT fo223av
--    ERROR ""
--    IF cc >=0 THEN
--       CALL Cprint(rep_na,"Y")  
--    ELSE
--       DISPLAY "Rows :      " AT 22,1
--       ERROR mess[09] CLIPPED
--    END IF
END FUNCTION
#------------------------------------------------------------------------------
-- REPORT fo223av(P, R)
--    DEFINE Head_B    CHAR(30)
--    DEFINE IsEnd     SMALLINT
--    DEFINE iv_qty    DECIMAL(9,1)

--    DEFINE P RECORD 
--       manufna   CHAR(23),     
--       pitemsna  CHAR(23),  
--       deptna    CHAR(23)        
--    END RECORD

--    DEFINE R RECORD 
--       manuf     LIKE w213.manuf, 
--       pitems    LIKE w213.pitems, 
--       dept      LIKE w213.dept,         
--       machcode LIKE w213.machcode,
--       kind     LIKE w213.kind,            
--       mach_cn  LIKE w213.mach_cn,      
--       mach_en  LIKE w213.mach_en,      
--       posno    LIKE w213.posno,      
--       hole     LIKE w213.hole,      
--       lossprs  LIKE w213.lossprs, 
--       losshr   LIKE w213.losshr,  
--       lossgw   LIKE w213.lossgw
--    END RECORD	

--    OUTPUT
--       PAGE     LENGTH 10
--       TOP      MARGIN 0
--       BOTTOM   MARGIN 0
--       RIGHT    MARGIN 10
--       LEFT     MARGIN 0
--       ORDER BY R.pitems,R.dept
--    FORMAT        
--       FIRST PAGE HEADER    
--          LET iv_qty=0
--          LET Head_B = cal_compy1('2',gv_manuf)
--          PRINT "||", Head_B CLIPPED
--          LET IsEnd = FALSE
         
--          PRINT "Abnormal working hours machine basic input"
--          PRINT "Program: fo223a |||",
--                "Print dat: ",TODAY
--          PRINT "Print user: ",login_usr CLIPPED,"|||",
--                "Print time: ",TIME

--          IF frmtyp = 1 THEN
--             PRINT   "??|manufna|??|pitemsna|??|deptna|??|????|????|????|??|??|?/?|?/?|kg/?"
--          ELSE
--             PRINT   "manuf|manufna|pitems|pitemsna|dept|deptna|machcode|kind|mach_cn|mach_en|posno|hole|lossprs|losshr|lossgw"
--       END IF 	                 
--       ON EVERY ROW
--          PRINT R.manuf,"|",P.manufna,"|",R.pitems,"|",P.pitemsna,"|",R.dept,"|",P.deptna,"|"        
--                ,R.machcode,"|",R.kind,"|",R.mach_cn,"|",R.mach_en,"|",R.posno,"|",R.hole,"|",
--                R.lossprs,"|",R.losshr,"|",R.lossgw         
--       ON LAST ROW
--             PRINT
--             PRINT "??:","||","??:","||","??:"             
--             PRINT  
--             LET IsEnd = TRUE
-- END REPORT

FUNCTION openCursorCnt()
   IF wk_flagOpenCur1
   THEN
      CLOSE cnt_cur
   END IF
   OPEN cnt_cur
   LET wk_flagOpenCur1 = TRUE
END FUNCTION

FUNCTION closeCursorCnt()
   CLOSE cnt_cur
   LET wk_flagOpenCur1 = FALSE
END FUNCTION

FUNCTION openCursorStd()
   IF wk_flagOpenCur2
   THEN
      CLOSE std_curs
   END IF
   OPEN std_curs USING PH.errno
   LET wk_flagOpenCur2 = TRUE
END FUNCTION

FUNCTION closeCursorStd()
   CLOSE std_curs
   LET wk_flagOpenCur2 = FALSE
END FUNCTION


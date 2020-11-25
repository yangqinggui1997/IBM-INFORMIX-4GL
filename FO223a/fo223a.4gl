# PRGNAM: fo223a.4gl
# PRGFUN: 異常工時統計維護
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
      wk_flagOpenCur2 SMALLINT,
      wk_flagNoData SMALLINT

      DEFINE wk_posno    LIKE w213.posno
      DEFINE wk_hole     LIKE w213.hole
      DEFINE wk_lossprs  LIKE w213.lossprs
      DEFINE wk_losshr   LIKE w213.losshr
      DEFINE wk_lossgw   LIKE w213.lossgw

      DEFINE wk_errhr LIKE w215.errhr
      DEFINE wk_slosshole LIKE w215.slosshole    
      DEFINE wk_slossgw LIKE w215.slossgw
      DEFINE wk_slossprs LIKE w215.slossprs
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
   LET wk_flagNoData = FALSE
   LET   op_code = "N"

   IF frmtyp = '1'
   THEN
      MENU "功能"
         COMMAND "0.結束" "說明:   結束執行, 回到上一畫面, Ctrl-P 基本操作說明"
                  HELP 0001 CALL Cset_int() CALL curfun()
                  EXIT MENU
         COMMAND "1.新增"
               "說明:   新增資料, 按 Esc 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[1] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL curfun() CALL addfun()
                  END IF
         COMMAND "2.查詢"
                  "說明:   查詢資料, 按 Esc 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL inqfun(TRUE)
                  END IF
         COMMAND "3.修改"
                  "說明:   修改資料, 按 Esc 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[3] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL updfun()
                  END IF
         COMMAND "4.刪除"
                  "說明:   刪除此張資料, 按 Y 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[4] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL delfun()
                  END IF
         COMMAND "5.明細查詢" "說明:   查詢目前所顯示之明細資料, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL disfun()
                  END IF
         COMMAND "N.下張" "說明:   顯示下一張資料, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL pgfun(TRUE)
                  END IF
         COMMAND "U.上張" "說明:   顯示上一張資料, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL pgfun(FALSE)
                  END IF
         COMMAND "7.輸入清單"
                  "說明:   修改資料, 按 Esc 執行, Del 放棄, Ctrl-P 基本操作說明"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL prtfun()
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
      LET PH1.* = PH.*
   END FOR
   CALL closeCursorStd()

   LET cc = cc - 1
   DISPLAY "" AT 24, 1
   IF cc > scr_ary THEN
      ERROR mess[14] CLIPPED
   ELSE
      IF cc = 0 THEN 
         LET wk_flagNoData = TRUE
         ERROR mess[10] CLIPPED
         CLEAR FORM
         RETURN
      END IF
   END IF
   LET wk_flagNoData = FALSE
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
FUNCTION add100(iv_option1, iv_option2, iv_record)
   DEFINE iv_option1, iv_option2 SMALLINT
   DEFINE wk_key SMALLINT
   DEFINE wk_prompt CHAR(1)

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
            IF PH.pitems IS NOT NULL OR PH.pitems NOT MATCHES "[ ]" 
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
            IF PH.dept IS NOT NULL OR PH.dept NOT MATCHES "[ ]" 
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
            IF PH.code IS NOT NULL OR PH.code NOT MATCHES "[ ]" 
            THEN
               SELECT UNIQUE code FROM j02 WHERE codk = 799 AND mark='z' AND code = PH.code
               IF STATUS = NOTFOUND THEN
                  ERROR mess[9]
                  NEXT FIELD code
               END IF
               LET PH.codsc = cal_j02e(799, PH.code)
               DISPLAY BY NAME PH.code, PH.codsc
            ELSE
               ERROR mess[15]
               NEXT FIELD code
            END IF
            IF PH.errdat IS NULL OR PH.errdat MATCHES "[ ]" 
            THEN
               ERROR mess[15]
               NEXT FIELD errdat
            END IF
            IF iv_option1
            THEN
               IF PH1.dept != PH.dept
               THEN
                  LET PH.errno = get_no('R', PH.dept)
               END IF
            ELSE
               LET PH.errno = get_no('R', PH.dept)
            END IF
            IF PH.errno IS NULL OR PH.errno MATCHES "[ ]"
            THEN
               ERROR mess[9] CLIPPED
               NEXT FIELD dept
            ELSE
               DISPLAY BY NAME PH.errno
            END IF
         ELSE
            PROMPT "Do you really want to cancle input (y/Y for Yes, another for No)? " FOR wk_prompt
            IF wk_prompt NOT MATCHES "[yY]"
            THEN
               CONTINUE INPUT
            END IF
         END IF
   END INPUT 
END FUNCTION
#-------------------------------------------------------------------------------
FUNCTION checkDuplicate(iv_index)
   DEFINE iv_index INTEGER
   DEFINE wk_count INTEGER
   LET wk_count = 0

   SELECT COUNT(*) INTO wk_count FROM w215 WHERE errno = PH.errno AND machcode = P1[iv_index].machcode AND kind = P1[iv_index].kind AND machno = P1[iv_index].machno AND posno = P1[iv_index].posno AND hole = P1[iv_index].hole AND rmodel = P1[iv_index].rmodel AND tolcls = P1[iv_index].tolcls

   IF wk_count
   THEN  
      RETURN (TRUE)
   END IF

   RETURN (FALSE)
END FUNCTION
#-------------------------------------------------------------------
FUNCTION checkExists(iv_manuf, iv_pitems, iv_dept, iv_machcode)
   DEFINE iv_manuf LIKE w213.manuf
   DEFINE iv_pitems LIKE w213.pitems
   DEFINE iv_dept  LIKE w213.dept
   DEFINE wk_kind LIKE w213.kind
   DEFINE iv_machcode LIKE w213.machcode

   SELECT kind INTO wk_kind FROM w213 WHERE manuf = iv_manuf AND pitems = iv_pitems AND dept = iv_dept AND machcode = iv_machcode

   RETURN wk_kind
END FUNCTION
#-------------------------------------------------------------------
FUNCTION add200(iv_option)
   DEFINE iv_option SMALLINT
   DEFINE wk_key SMALLINT
   DEFINE wk_cc SMALLINT
   DEFINE wk_goto SMALLINT
   DEFINE wk_hour  SMALLINT
   DEFINE wk_cyctime LIKE w55.cyctime
   DEFINE wk_cycqty  DECIMAL(5,0)
   DEFINE wk_prompt CHAR(1)

   LET wk_goto = FALSE

   INPUT ARRAY P1 WITHOUT DEFAULTS FROM SR.*
      BEFORE ROW
         LET aln = ARR_CURR()
         LET sln = SCR_LINE()
         DISPLAY P1[aln].* TO SR[sln].* ATTRIBUTE(REVERSE)
         IF frmtyp ='1' THEN
            DISPLAY "本行是第 ", aln USING "<<#"," 行" AT 22, 1
         ELSE
            DISPLAY "This row is ", aln USING "<<#"," row" AT 22, 1
         END IF
      BEFORE FIELD machcode
         ERROR "Press CONTROL-W to show options."
      BEFORE FIELD press
         ERROR "Y.同意扣工時 N.不扣工時"
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
            IF P1[aln].kind
            THEN
               DISPLAY P1[aln].kind TO SR[sln].kind
               DISPLAY P1[aln].machcode TO SR[sln].machcode
            ELSE
               IF frmtyp = '2' THEN
                  CALL cal_err("Kind and machcode weren't found","please try again")
               ELSE
                  CALL cal_err("無異常工時計算代碼","請重新輸入")
               END IF
               NEXT FIELD machcode
            END IF
            NEXT FIELD machno
         END IF
      AFTER ROW
         LET wk_key = FGL_LASTKEY()
         IF wk_key == FGL_KEYVAL("ACCEPT") OR wk_key == FGL_KEYVAL("ESC") OR wk_key == FGL_KEYVAL("TAB")
         THEN
            IF (P1[aln].machcode IS NOT NULL OR P1[aln].machcode NOT MATCHES "[ ]")
               OR (P1[aln].machno IS NOT NULL OR P1[aln].machno NOT MATCHES "[ ]")
               OR (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]")
               OR (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]")
               OR (P1[aln].rmodel IS NOT NULL OR P1[aln].rmodel NOT MATCHES "[ ]")
               OR (P1[aln].tolcls IS NOT NULL OR P1[aln].tolcls NOT MATCHES "[ ]")
               OR (P1[aln].errhr IS NOT NULL OR P1[aln].errhr NOT MATCHES "[ ]")
               OR (P1[aln].slosshole IS NOT NULL OR P1[aln].slosshole NOT MATCHES "[ ]")
               OR (P1[aln].slossgw IS NOT NULL OR P1[aln].slossgw NOT MATCHES "[ ]")
               OR (P1[aln].slossprs IS NOT NULL OR P1[aln].slossprs NOT MATCHES "[ ]")
               OR (P1[aln].press IS NOT NULL OR P1[aln].press NOT MATCHES "[ ]")
            THEN 
            -- check machcode field
               IF (P1[aln].machcode IS NULL OR P1[aln].machcode MATCHES "[ ]")  THEN
                  ERROR mess[15] SLEEP 1
                  NEXT FIELD machcode
               ELSE
                  CALL checkExists(PH.manuf, PH.pitems, PH.dept, P1[aln].machcode) RETURNING P1[aln].kind
                  IF P1[aln].kind
                  THEN
                     DISPLAY P1[aln].kind TO SR[sln].kind
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
               IF (P1[aln].rmodel IS NULL OR P1[aln].rmodel MATCHES "[ ]") AND P1[aln].kind MATCHES '[Y]' 
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
               IF (P1[aln].tolcls IS NULL OR P1[aln].tolcls MATCHES "[ ]") AND P1[aln].kind MATCHES '[Y]' THEN
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
               IF (P1[aln].errhr IS NULL OR P1[aln].errhr MATCHES "[ ]") AND P1[aln].kind MATCHES '[F]'  THEN
                  ERROR mess[15] CLIPPED
                  NEXT FIELD errhr
               ELSE
                  IF P1[aln].kind MATCHES '[F]' AND P1[aln].errhr < 0.0 THEN
                     ERROR mess[15] CLIPPED
                     NEXT FIELD errhr
                  END IF
               END IF
            -- check slosshole field
               IF (P1[aln].slosshole IS NULL OR P1[aln].slosshole MATCHES "[ ]") 
               AND P1[aln].kind MATCHES '[Y]' 
               THEN
                  ERROR mess[15] CLIPPED
                  NEXT FIELD slosshole
               ELSE
               #?p??TCT
                  SELECT AVG(cyctime) INTO wk_cyctime
                  FROM w55 
                  WHERE manuf = PH.manuf
                  AND rmodel = P1[aln].rmodel AND tolcls = P1[aln].tolcls

                  LET wk_hour = 0
                  SELECT codsc INTO wk_hour FROM j02 
                  WHERE codk ='615' AND mark[1] = gv_manuf
                     #1??(hole)?l??
                  LET wk_cycqty = (wk_hour * 60)/(wk_cyctime/60) #21?p??p?? 
                  IF P1[aln].posno IS NULL OR P1[aln].posno MATCHES "[ ]" AND P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]" 
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
                  IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]") THEN
                     LET P1[aln].slossprs = wk_cycqty
                  END IF          	
               END IF
               DISPLAY P1[aln].slosshole TO SR[sln].slosshole 
            -- check slossgw field
               IF (P1[aln].slossgw IS NULL OR P1[aln].slossgw MATCHES "[ ]") AND P1[aln].kind MATCHES '[N]'  
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
               IF (P1[aln].slossprs IS NULL OR P1[aln].slossprs MATCHES "[ ]") AND P1[aln].kind MATCHES '[YNG]'  THEN
                  ERROR mess[15] CLIPPED
                  NEXT FIELD slossprs
               ELSE
                  IF P1[aln].kind MATCHES '[G]' AND P1[aln].errhr < 0.0 THEN
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
            -- check press field
               IF (P1[aln].press IS NOT NULL OR P1[aln].press NOT MATCHES "[ ]") AND P1[aln].press NOT MATCHES "[YN]" THEN
                  NEXT FIELD press
               END IF
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
               IF P1[aln].kind MATCHES '[F]' AND P1[aln].errhr < 0 
               THEN
                  NEXT FIELD errhr
               END IF                   
               IF P1[aln].kind MATCHES '[N]' AND P1[aln].slossgw < 0.0 
               THEN
                  NEXT FIELD slossgw
               END IF 
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
         END IF
      AFTER INPUT
         LET wk_key = FGL_LASTKEY()
         IF wk_key == FGL_KEYVAL("ACCEPT") OR wk_key == FGL_KEYVAL("ESC")
         THEN
            IF (P1[aln].machcode IS NOT NULL OR P1[aln].machcode NOT MATCHES "[ ]")
               OR (P1[aln].machno IS NOT NULL OR P1[aln].machno NOT MATCHES "[ ]")
               OR (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]")
               OR (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]")
               OR (P1[aln].rmodel IS NOT NULL OR P1[aln].rmodel NOT MATCHES "[ ]")
               OR (P1[aln].tolcls IS NOT NULL OR P1[aln].tolcls NOT MATCHES "[ ]")
               OR (P1[aln].errhr IS NOT NULL OR P1[aln].errhr NOT MATCHES "[ ]")
               OR (P1[aln].slosshole IS NOT NULL OR P1[aln].slosshole NOT MATCHES "[ ]")
               OR (P1[aln].slossgw IS NOT NULL OR P1[aln].slossgw NOT MATCHES "[ ]")
               OR (P1[aln].slossprs IS NOT NULL OR P1[aln].slossprs NOT MATCHES "[ ]")
               OR (P1[aln].press IS NOT NULL OR P1[aln].press NOT MATCHES "[ ]")
            THEN
            -- check machcode field
               IF (P1[aln].machcode IS NULL OR P1[aln].machcode MATCHES "[ ]")  THEN
                  ERROR mess[15] SLEEP 1
                  NEXT FIELD machcode
               ELSE
                  CALL checkExists(PH.manuf, PH.pitems, PH.dept, P1[aln].machcode) RETURNING P1[aln].kind
                  IF P1[aln].kind
                  THEN
                     DISPLAY P1[aln].kind TO SR[sln].kind
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
               IF (P1[aln].rmodel IS NULL OR P1[aln].rmodel MATCHES "[ ]") AND P1[aln].kind MATCHES '[Y]' 
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
               IF (P1[aln].tolcls IS NULL OR P1[aln].tolcls MATCHES "[ ]") AND P1[aln].kind MATCHES '[Y]' THEN
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
               IF (P1[aln].errhr IS NULL OR P1[aln].errhr MATCHES "[ ]") AND P1[aln].kind MATCHES '[F]'  THEN
                  ERROR mess[15] CLIPPED
                  NEXT FIELD errhr
               ELSE
                  IF P1[aln].kind MATCHES '[F]' AND P1[aln].errhr < 0.0 THEN
                     ERROR mess[15] CLIPPED
                     NEXT FIELD errhr
                  END IF
               END IF
            -- check slosshole field
               IF (P1[aln].slosshole IS NULL OR P1[aln].slosshole MATCHES "[ ]") 
               AND P1[aln].kind MATCHES '[Y]' 
               THEN
                  ERROR mess[15] CLIPPED
                  NEXT FIELD slosshole
               ELSE
               #?p??TCT
                  SELECT AVG(cyctime) INTO wk_cyctime
                  FROM w55 
                  WHERE manuf = PH.manuf
                  AND rmodel = P1[aln].rmodel AND tolcls = P1[aln].tolcls

                  LET wk_hour = 0
                  SELECT codsc INTO wk_hour FROM j02 
                  WHERE codk ='615' AND mark[1] = gv_manuf
                     #1??(hole)?l??
                  LET wk_cycqty = (wk_hour * 60)/(wk_cyctime/60) #21?p??p?? 
                  IF P1[aln].posno IS NULL OR P1[aln].posno MATCHES "[ ]" AND P1[aln].hole IS NULL OR P1[aln].hole MATCHES "[ ]" 
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
                  IF (P1[aln].posno IS NOT NULL OR P1[aln].posno NOT MATCHES "[ ]") AND (P1[aln].hole IS NOT NULL OR P1[aln].hole NOT MATCHES "[ ]") THEN
                     LET P1[aln].slossprs = wk_cycqty
                  END IF          	
               END IF
               DISPLAY P1[aln].slosshole TO SR[sln].slosshole 
            -- check slossgw field
               IF (P1[aln].slossgw IS NULL OR P1[aln].slossgw MATCHES "[ ]") AND P1[aln].kind MATCHES '[N]'  
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
               IF (P1[aln].slossprs IS NULL OR P1[aln].slossprs MATCHES "[ ]") AND P1[aln].kind MATCHES '[YNG]'  THEN
                  ERROR mess[15] CLIPPED
                  NEXT FIELD slossprs
               ELSE
                  IF P1[aln].kind MATCHES '[G]' AND P1[aln].errhr < 0.0 THEN
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
            -- check press field
               IF (P1[aln].press IS NOT NULL OR P1[aln].press NOT MATCHES "[ ]") AND P1[aln].press NOT MATCHES "[YN]" THEN
                  NEXT FIELD press
               END IF
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
               IF P1[aln].kind MATCHES '[F]' AND P1[aln].errhr < 0 
               THEN
                  NEXT FIELD errhr
               END IF                   
               IF P1[aln].kind MATCHES '[N]' AND P1[aln].slossgw < 0.0 
               THEN
                  NEXT FIELD slossgw
               END IF 
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
         ELSE
            PROMPT "Do you really want to cancle input (y/Y for Yes, another for No)? " FOR wk_prompt
            IF wk_prompt NOT MATCHES "[yY]"
            THEN
               CONTINUE INPUT
            END IF
         END IF
   END INPUT
END FUNCTION
#-------------------------------------------------------------------
FUNCTION addfun()
   DEFINE wk_count, wk_count1 INTEGER
   DEFINE wk_incorrect INTEGER
   DEFINE wk_countAddSuccess INTEGER

   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   LET wk_incorrect = 0
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
   CALL SET_COUNT(max_ary)
   CALL add200(FALSE)
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      CLEAR FORM
      ERROR mess[5] CLIPPED
      RETURN
   END IF
   ------
   ERROR mess[11] # proccessing...
   LET wk_count = 0
   LET wk_count1 = 1
   SELECT COUNT(*) INTO wk_count FROM w214
   WHERE manuf = PH.manuf AND pitems = PH.pitems AND errdat = PH.errdat AND errno = PH.errno
   SELECT COUNT(*) INTO wk_count1 FROM w215
   WHERE errno = PH.errno

   IF wk_count OR wk_count1 THEN
      ERROR mess[2] CLIPPED, mess[52] CLIPPED, "!" 
      RETURN
   ELSE
      BEGIN WORK
         FOR cc = 1 TO max_ary 
            IF P1[cc].machcode IS NULL OR P1[cc].machcode MATCHES "[ ]" THEN CONTINUE FOR END IF
            -- check data incorrect
            SELECT ROWID FROM wj03 WHERE tolcls = P1[cc].tolcls
            IF STATUS != 0 THEN
               LET  wk_incorrect = wk_incorrect + 1
               CONTINUE FOR
            END IF

            SELECT ROWID FROM wj04
            WHERE lmanuf = PH.manuf
            AND tolno = P1[cc].rmodel 
            AND tolcls = P1[cc].tolcls
            IF STATUS != 0 THEN
               LET  wk_incorrect = wk_incorrect + 1
               CONTINUE FOR
            END IF 
         
            IF P1[cc].press NOT MATCHES "[YN]" THEN LET P1[cc].press = "N" END IF
            --
            LET PH.errno = get_no("R", PH.dept)
            INSERT INTO w214 
            VALUES (PH.manuf, PH.errno, PH.errdat, PH.pitems, PH.dept, PH.code, PH.remark,login_usr, CURRENT YEAR TO SECOND)
            IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
               ROLLBACK WORK
               ERROR mess[04] CLIPPED
               RETURN
            END IF
            
            INSERT INTO w215 
            VALUES (PH.errno, P1[cc].kind, P1[cc].machcode, P1[cc].machno, P1[cc].posno, P1[cc].hole, P1[cc].rmodel, P1[cc].tolcls, P1[cc].errhr, P1[cc].slosshole, P1[cc].slossgw, P1[cc].slossprs, P1[cc].press, login_usr, CURRENT YEAR TO SECOND)
            IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
               ROLLBACK WORK
               ERROR mess[04] CLIPPED
               RETURN
            END IF
            LET wk_countAddSuccess = wk_countAddSuccess + 1
         END FOR
      COMMIT WORK
   END IF
   
   IF wk_countAddSuccess > 0 
   THEN
      IF wk_incorrect
      THEN
         ERROR mess[58] CLIPPED, wk_countAddSuccess USING "<<<<< & record! To be incorrected ", wk_incorrect USING "<<<<< & record."  SLEEP 1
      ELSE
         ERROR mess[58] CLIPPED, wk_countAddSuccess USING "<<<<< & record!" SLEEP 1
      END IF
      CALL inqfun(FALSE)
   ELSE
      IF wk_incorrect
      THEN
         ERROR mess[4] CLIPPED, "! To be incorrected ", wk_incorrect USING "<<<<< & record."
      ELSE
         ERROR mess[4] CLIPPED, "!"
      END IF
   END IF
END FUNCTION
#-------------------------------------------------------------------
FUNCTION updfun()
   DEFINE wk_count, wk_count1 INTEGER
   DEFINE wk_incorrect INTEGER
   DEFINE wk_countUpdateSuccess INTEGER
   DEFINE wk_flagContent, wk_flagHead SMALLINT

   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   LET wk_countUpdateSuccess = 0
   LET wk_flagHead = FALSE

   IF op_code = 'N' THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   IF wk_flagNoData THEN
      ERROR mess[10] CLIPPED
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

   CALL SET_COUNT(cc)

   CALL add200(TRUE)
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      ERROR mess[07] CLIPPED
      RETURN
   END IF

   LET wk_count = 0
   LET wk_count1 = 0
   
   BEGIN WORK
   IF PH1.pitems != PH.pitems OR PH1.dept != PH.dept OR PH1.code != PH.code OR PH1.errno != PH.errno OR PH1.errdat != PH.errdat OR PH1.remark != PH.remark
   THEN
      SELECT COUNT(*) INTO wk_count FROM w214
      WHERE manuf = PH.manuf AND pitems = PH.pitems AND errdat = PH.errdat AND errno = PH.errno
      SELECT COUNT(*) INTO wk_count1 FROM w215
      WHERE errno = PH.errno
      IF wk_count OR wk_count1 THEN
         ERROR mess[2] CLIPPED, mess[54] CLIPPED, "!" 
         RETURN
      ELSE
         UPDATE w214 
         SET (errno, errdat, pitems, dept, code, remark, upusr, upday)
         = (PH.errno, PH.errdat, PH.pitems, PH.dept, PH.code, PH.remark,login_usr, CURRENT YEAR TO SECOND)
         WHERE ROWID = Wrowid[cc1]
         IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
            ROLLBACK WORK
            ERROR mess[04] CLIPPED
            RETURN
         END IF
         LET wk_flagHead = TRUE 
      END IF
   END IF
   FOR cc1 = 1 TO max_ary
      LET wk_flagContent = FALSE
      IF P1[cc1].machcode IS NULL OR P1[cc1].machcode MATCHES "[ ]" THEN CONTINUE FOR END IF
      IF P2[cc1].machcode != P1[cc1].machcode OR P2[cc1].posno != P1[cc1].posno OR P2[cc1].machno != P1[cc1].machno OR P2[cc1].hole != P1[cc1].hole OR P2[cc1].rmodel != P1[cc1].rmodel OR P2[cc1].tolcls != P1[cc1].tolcls OR P2[cc1].errhr != P1[cc1].errhr OR P2[cc1].slosshole != P1[cc1].slosshole OR P2[cc1].slossgw != P1[cc1].slossgw OR P2[cc1].slossprs != P1[cc1].slossprs OR P2[cc1].press != P1[cc1].press
         THEN
            -- check data incorrect
            SELECT ROWID FROM wj03 WHERE tolcls = P1[cc1].tolcls
            IF STATUS != 0 THEN
               LET  wk_incorrect = wk_incorrect + 1
               CONTINUE FOR
            END IF

            SELECT ROWID FROM wj04 
            WHERE lmanuf = PH.manuf
            AND tolno = P1[cc1].rmodel 
            AND tolcls = P1[cc1].tolcls
            IF STATUS != 0 THEN
               LET  wk_incorrect = wk_incorrect + 1
               CONTINUE FOR
            END IF 
         
            IF P1[cc1].press NOT MATCHES "[YN]" THEN LET P1[cc1].press = "N" END IF
            --
            UPDATE w215 
            SET (errno, machcode, kind, machno, posno, hole, rmodel, tolcls, errhr, slosshole, slossgw, slossprs, press, upusr, upday)
            = (PH.errno, P1[cc1].machcode, P1[cc1].kind, P1[cc1].machno, P1[cc1].posno, P1[cc1].hole, P1[cc1].rmodel, P1[cc1].tolcls, P1[cc1].errhr, P1[cc1].slosshole, P1[cc1].slossgw, P1[cc1].slossprs, P1[cc1].press, login_usr, CURRENT YEAR TO SECOND)
            WHERE ROWID = Wrowid[cc1]
            IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
               ROLLBACK WORK
               ERROR mess[04] CLIPPED
               RETURN
            END IF
            LET wk_flagContent = TRUE
         END IF
      IF wk_flagContent THEN
         LET wk_countUpdateSuccess = wk_countUpdateSuccess + 1
      END IF
   END FOR
   COMMIT WORK
   IF wk_countUpdateSuccess > 0 THEN
      IF wk_incorrect
      THEN
         ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!", " To be incorrected ", wk_incorrect USING "<<<<< & record."  SLEEP 1
      ELSE
         ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!"  SLEEP 1
      END IF   
      CALL inqfun(FALSE) 
   ELSE
      IF wk_incorrect
      THEN
         IF wk_flagHead
         THEN
            ERROR "Some datas are changed! To be incorrected ", wk_incorrect USING "<<<<< & record."  SLEEP 1
         ELSE
            ERROR "Datas are changed! To be incorrected ", wk_incorrect USING "<<<<< & record."  SLEEP 1
         END IF
      ELSE
         IF wk_flagHead
         THEN
            ERROR "Some datas are changed!" SLEEP 1
         ELSE
            ERROR "Datas are unchanged!" SLEEP 1
         END IF
      END IF
   END IF
END FUNCTION
#----------------------------------------------------------------------
FUNCTION delfun()
   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   IF wk_flagNoData THEN
      ERROR mess[10] CLIPPED
      RETURN
   END IF
   CALL ans() RETURNING ans1
   IF ans1 MATCHES "[^Yy]" THEN
      ERROR mess[8]
      RETURN
   END IF
   LET cnt1 = 0
   BEGIN WORK
      FOR cc1 = 1 TO cc
         DELETE FROM w215 WHERE ROWID = Wrowid[cc1]
         IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
            ERROR mess[63] CLIPPED
            ROLLBACK WORK
            RETURN
         ELSE
            DELETE FROM w214 WHERE manuf = PH.manuf AND pitems = PH.pitems AND errdat = PH.errdat AND errno = PH.errno
            IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
               ERROR mess[63] CLIPPED
               ROLLBACK WORK
               RETURN
            END IF
            LET cnt1 = cnt1 + 1
         END IF
      END FOR
   COMMIT WORK
   ERROR mess[53] CLIPPED, cnt1 USING "<<< & ",mess[41] CLIPPED
   CALL reopen()
END FUNCTION
#----------------------------------------------------------------------
FUNCTION pgfun(move)
   DEFINE move SMALLINT
   DEFINE wk_message CHAR(300)

   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   IF wk_flagNoData THEN
      ERROR mess[10] CLIPPED
      RETURN
   END IF
   IF move THEN
      LET cnt = cnt + 1
      IF cnt >= allcnt 
      THEN 
         IF cnt > allcnt THEN 
            LET cnt = 1 
            LET wk_message = mess[12]
         ELSE
            LET wk_message = mess[13]
         END IF
      END IF
      CALL openCursorCnt()
      FETCH ABSOLUTE cnt cnt_cur INTO PH.*
      CALL closeCursorCnt()
   ELSE
      LET cnt = cnt - 1
      IF cnt <= 1
      THEN 
         IF cnt < 1 THEN 
            LET cnt = allcnt 
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
   ERROR wk_message CLIPPED
   CALL inq100(cnt)
   IF frmtyp ='1' THEN
      DISPLAY "總頁數 : ",allcnt USING "<<<<#",
              "  顯示第 ",cnt USING "<<<<#"," 頁 " AT 23,1
   ELSE
      DISPLAY "Totals pages : ",allcnt USING "<<<<#",
               "  Display page ",cnt USING "#" AT 23,1
   END IF           	           
END FUNCTION
#-------------------------------------------------------------------------------
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
      LET wk_flagNoData = TRUE
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
      CALL inq100(cnt)
   END IF
END FUNCTION
#----------------------------------------------------------------------
FUNCTION disfun()
   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   IF wk_flagNoData THEN
      ERROR mess[10] CLIPPED
      RETURN
   END IF
   DISPLAY "" AT 1, 1
   DISPLAY "" AT 2, 1
   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   DISPLAY mess[29] CLIPPED,mess[32] CLIPPED AT 1, 1

   LET cc = 1
   CALL openCursorStd()
   WHILE TRUE
      FETCH std_curs INTO P1[cc].*,Wrowid[cc]
      IF STATUS != 0 THEN
         EXIT WHILE
      END IF
      LET cc = cc + 1
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
   DISPLAY "" AT 23, 1
   DISPLAY mess[29] CLIPPED,mess[32] CLIPPED AT 1, 1
   IF frmtyp ='1' THEN
      DISPLAY "共 ",cc USING "<<<#"," 筆 " AT 23, 1
   ELSE
      DISPLAY "Total ",cc USING "<<<#"," row " AT 23, 1
   END IF   	   
   DISPLAY ARRAY P1 TO SR.*
END FUNCTION
#---------------------------------------------------------------------
FUNCTION curfun()
   IF op_code = "Y" THEN
      LET op_code = "N"
   END IF
END FUNCTION
#######################################################
FUNCTION prtfun()
   DEFINE P RECORD 
      manufna   CHAR(23),     
      pitemsna  CHAR(23),  
      deptna    CHAR(23),
      codsc     LIKE j02.codsc               
   END RECORD

   DEFINE  D1  RECORD 
      manuf LIKE w214.manuf, 
      pitems LIKE w214.pitems, 
      errno LIKE w214.errno, 
      errdat LIKE w214.errdat,
      code LIKE w214.code, 
      dept LIKE w214.dept,

      machcode LIKE w215.machcode, 
      kind LIKE w213.mach_cn,
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
   END RECORD 

   DEFINE iv_storna CHAR(20)	
   DEFINE qry_str4   CHAR(500)
   DEFINE wd_qty     LIKE w202.qty
   DEFINE wd_seq     LIKE w200.seq
   DEFINE wk_week    SMALLINT
   DEFINE  iv_day    DATE
   DEFINE  ir_day    DATE
   
   LET wk_errhr = 0.0
   LET wk_slosshole = 0
   LET wk_slossgw = 0.0
   LET wk_slossprs = 0.0

   DISPLAY "" AT 1,1
   DISPLAY "" AT 2,1
   LET offset1 =  80
   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1        
   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED  
      RETURN
   END IF
   DISPLAY mess[11] CLIPPED AT 24 , 1 ATTRIBUTE(REVERSE)

   CALL reptol()
   SET ISOLATION TO DIRTY READ
   
   LET cc = 0
   LET wd_seq = 0  
   LET qry_str4 = "SELECT a.manuf, a.pitems, a.errno , a.errdat, a.code, a.dept, b.machcode, ",
                  "b.kind, b.machno, b.posno, b.hole, b.rmodel, b.tolcls, b.errhr, b.slosshole, b.slossgw,b.slossprs, b.press",
                  " FROM w214 AS a JOIN w215 AS b ON a.errno = b.errno",
                  " WHERE manuf = '",gv_manuf,"' AND ", wh_str CLIPPED	
   PREPARE qry_exe4 FROM qry_str4
   DECLARE std_cur4 CURSOR FOR qry_exe4 
                        
   START REPORT fo223av TO rep_naw
   FOREACH std_cur4 INTO D1.*
   
      IF INT_FLAG = TRUE THEN
         LET INT_FLAG = FALSE
         ERROR mess[47] CLIPPED
         EXIT FOREACH
      END IF
      LET P.manufna  = cal_j02(7,D1.manuf)  
      LET P.pitemsna = cal_j02(620,D1.pitems)  
      CALL cal_n15("W",D1.manuf,D1.dept) RETURNING P.deptna
      LET P.codsc = cal_j02e(799, D1.code)    
      OUTPUT TO REPORT fo223av(P.*, D1.*)  
      LET cc=cc+1
      IF frmtyp = "1" THEN
         DISPLAY "筆數 : ",cc USING "<<<#" AT 22,1
      ELSE
         DISPLAY "Rows : ",cc USING "<<<#" AT 22,1
      END IF        
   END FOREACH
   FINISH REPORT fo223av
   ERROR ""
   IF cc >=0 THEN
      CALL Cprint(rep_na,"Y")  
   ELSE
      DISPLAY "Rows :      " AT 22,1
      ERROR mess[09] CLIPPED
   END IF
END FUNCTION
#------------------------------------------------------------------------------
REPORT fo223av(P, R)
   DEFINE Head_B    CHAR(30)
   DEFINE IsEnd     SMALLINT
   DEFINE iv_qty    DECIMAL(9,1)

   DEFINE P RECORD 
      manufna   CHAR(23),     
      pitemsna  CHAR(23),  
      deptna    CHAR(23),
      codsc     LIKE j02.codsc                    
   END RECORD

   DEFINE R RECORD 
      manuf LIKE w214.manuf, 
      pitems LIKE w214.pitems, 
      errno LIKE w214.errno, 
      errdat LIKE w214.errdat,
      code LIKE w214.code, 
      dept LIKE w214.dept,

      machcode LIKE w215.machcode, 
      kind LIKE w213.mach_cn,
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
   END RECORD	

   OUTPUT
      PAGE     LENGTH 10
      TOP      MARGIN 0
      BOTTOM   MARGIN 0
      RIGHT    MARGIN 10
      LEFT     MARGIN 0
      ORDER BY R.errdat,R.pitems,R.dept,R.machcode,R.kind
   FORMAT        
      FIRST PAGE HEADER    
         LET iv_qty=0
         LET Head_B = cal_compy1('2',gv_manuf)
         PRINT "||", Head_B CLIPPED
         LET IsEnd = FALSE
         
         PRINT "Abnormal working hours statistics maintenance"
         PRINT "Program: fo223a |||",
               "Print dat: ",TODAY
         PRINT "Print user: ",login_usr CLIPPED,"|||",
               "Print time: ",TIME
         PRINT "pitems: ",R.pitems CLIPPED,".",P.pitemsna CLIPPED,
               "|||||||department: ",R.dept CLIPPED,".",P.pitemsna CLIPPED
         IF frmtyp = 1 THEN
            PRINT   "kind|machcode|machno|posno|hole|slosshole|slossgw|slossprs|press"
         ELSE
            PRINT   "機台代碼|計算類別|線別|站台|孔位|型體代碼|工具代碼|異常工時|總損孔數量|總損生產重量|總損雙數|計算否Y/N"
      END IF 	                 
      ON EVERY ROW
         PRINT R.kind,"|",R.machcode,"|",R.machno,"|",R.posno,"|",R.hole,
            "|",R.rmodel,"|",R.tolcls,"|",R.errhr,
            "|",R.slosshole,"|",R.slossgw,"|",R.slossprs,"|",R.press,"|"
            LET wk_errhr = wk_errhr + R.errhr
            LET wk_slosshole = wk_slosshole + R.slosshole     
            LET wk_slossgw = wk_slossgw + R.slossgw 
            LET wk_slossprs = wk_slossprs + R.slossprs 
      ON LAST ROW
         IF frmtyp = 1 THEN
            PRINT "合計|||||||",wk_errhr,"|",wk_slosshole,"|",wk_slossgw,"|",wk_slossprs 
         ELSE
            PRINT "Total|||||||",wk_errhr,"|",wk_slosshole,"|",wk_slossgw,"|",wk_slossprs 
         END IF 
         
         PRINT
         PRINT "|核決:","|||","審核:","|||","製表:"             
         PRINT  
         LET IsEnd = TRUE   
END REPORT

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

FUNCTION get_no(iv_flag, iv_dept)
   DEFINE iv_flag CHAR(01)
   DEFINE iv_dept LIKE w213.dept
   DEFINE iv_number  CHAR(10)
   DEFINE iv_num6    CHAR(07)
   DEFINE wk_yy,wk_seq,wk_mm  INT
   LET iv_number= ' '

   LET wk_yy=YEAR(TODAY)-2000
   LET wk_mm=MONTH(TODAY)
   LET iv_num6=gv_manuf,iv_flag,wk_yy USING "&&",wk_mm USING "&&",'*'

   SELECT MAX(errno) INTO iv_number
   FROM w214
   WHERE errno MATCHES iv_num6

   IF iv_number IS NULL THEN LET iv_number=' ' END IF
   IF iv_number>' 0' THEN
      LET wk_yy=YEAR(TODAY)-2000
      LET wk_mm=MONTH(TODAY)
      LET wk_seq=iv_number[7,10]
      LET wk_seq=wk_seq+1
      LET iv_number=gv_manuf,iv_flag,wk_yy USING "&&",wk_mm USING "&&",wk_seq USING "&&&&"
   ELSE
      IF iv_number=' ' THEN
         LET wk_yy=YEAR(today)-2000
         LET wk_mm=MONTH(TODAY)
         LET wk_seq=iv_number[7,10]
         LET wk_seq=1
         LET iv_number=gv_manuf,iv_flag,wk_yy USING "&&",wk_mm USING "&&",wk_seq USING "&&&&"
      END IF
   END IF
   RETURN iv_number
END FUNCTION

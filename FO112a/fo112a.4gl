# PRGNAM: fo112a.4gl
# PRGFUN: ���`�u�ɾ��x�򥻿�J
# AUTHOR: Gui
# FORMS : fo112a.PER
# LIB   : w213
# DATE  : 2020-11-18

GLOBALS 'kmgbl.4gl'
DEFINE PH, PH1 RECORD
       manuf     LIKE w213.manuf,  
       manufna   CHAR(23),      
       pitems    LIKE w213.pitems,     
       pitemsna  CHAR(23),   
       dept      LIKE w213.dept,  
       deptna    CHAR(23)        
       END RECORD,
       P1,P2  ARRAY[99] OF RECORD
       kind     LIKE w213.kind,   
       mach_cn  LIKE w213.mach_cn,      
       mach_en  LIKE w213.mach_en, 
       machcode LIKE w213.machcode,    
       posno    LIKE w213.posno,      
       hole     LIKE w213.hole,      
       lossprs  LIKE w213.lossprs, 
       losshr   LIKE w213.losshr,  
       lossgw   LIKE w213.lossgw
       END RECORD,
       Wrowid  ARRAY[99] OF INTEGER   ,
       scr_ary      INTEGER,
       wk_flagOpenCur1 SMALLINT,
       wk_flagOpenCur2 SMALLINT
#-------------------------------------------------------------------------------
FUNCTION mainfun()
   WHENEVER ERROR CALL errmsg
   LET max_ary = 99
   LET scr_ary = 5
   SET LOCK MODE TO WAIT
   LET Pfrm = Cfrm CLIPPED,"/fo112a"
   OPEN FORM fo112a FROM Pfrm
   DISPLAY FORM fo112a
   LET wk_flagOpenCur1 = FALSE
   LET wk_flagOpenCur2 = FALSE
   LET   op_code = "N"

   IF frmtyp = '1'
   THEN
      MENU "�\��"
         COMMAND "0.����" "����:   ��������, �^��W�@�e��, Ctrl-P �򥻾ާ@����"
                  HELP 0001 CALL Cset_int() CALL curfun()
                  EXIT MENU
         COMMAND "1.�s�W"
               "����:   �s�W���, �� Esc ����, Del ���, Ctrl-P �򥻾ާ@����"
                  HELP 0001 IF( usr_pg[1] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL curfun() CALL addfun()
                  END IF
         COMMAND "2.�d��"
                  "����:   �d�߸��, �� Esc ����, Del ���, Ctrl-P �򥻾ާ@����"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL inqfun(TRUE)
                  END IF
         COMMAND "3.�ק�"
                  "����:   �ק���, �� Esc ����, Del ���, Ctrl-P �򥻾ާ@����"
                  HELP 0001 IF( usr_pg[3] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL updfun()
                  END IF
         COMMAND "4.�R��"
                  "����:   �R�����i���, �� Y ����, Del ���, Ctrl-P �򥻾ާ@����"
                  HELP 0001 IF( usr_pg[4] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL delfun()
                  END IF
         COMMAND "5.���Ӭd��" "����:   �d�ߥثe����ܤ����Ӹ��, Ctrl-P �򥻾ާ@����"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL disfun()
                  END IF
         COMMAND "N.�U�i" "����:   ��ܤU�@�i���, Ctrl-P �򥻾ާ@����"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL pgfun(TRUE)
                  END IF
         COMMAND "U.�W�i" "����:   ��ܤW�@�i���, Ctrl-P �򥻾ާ@����"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL pgfun(FALSE)
                  END IF
         COMMAND "7.��J�M��"
                  "����:   �ק���, �� Esc ����, Del ���, Ctrl-P �򥻾ާ@����"
                  HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                  ELSE CALL Cset_int() CALL prtfun()
                  END IF
         COMMAND "H.����" "����:   �{���ާ@���U����"
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
   CLOSE FORM fo112a
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
      CONSTRUCT BY NAME wh_str ON pitems, dept
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
   LET qry_str = "SELECT UNIQUE a.manuf,'' manufna ,a.pitems,'' pitemsna ,a.dept,'' deptna ",
                  " FROM w213 a WHERE ",wh_str CLIPPED,
                  " AND a.manuf = '",gv_manuf,"'",
                  " ORDER BY 1"
   PREPARE cnt_exe FROM qry_str
   DECLARE cnt_cur SCROLL CURSOR FOR cnt_exe
   LET qry_str3 = "SELECT kind,mach_cn,mach_en,machcode,posno,hole,lossprs,losshr,lossgw,ROWID ",
                  " FROM w213",
                  " WHERE ", wh_str CLIPPED, " AND manuf = '", gv_manuf, "' AND pitems = ? AND dept = ?", 
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
   INITIALIZE PH.* TO NULL
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
      manuf     LIKE w213.manuf,  
      manufna   CHAR(23),      
      pitems    LIKE w213.pitems,     
      pitemsna  CHAR(23),   
      dept      LIKE w213.dept,  
      deptna    CHAR(23)        
   END RECORD

   OPTIONS INSERT KEY F13,
            DELETE KEY F14
   INPUT BY NAME PH.pitems, PH.dept
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
         END IF
   END INPUT

END FUNCTION
#-------------------------------------------------------------------------------
FUNCTION add200(iv_option)
   DEFINE iv_option SMALLINT
   DEFINE wk_key SMALLINT
   DEFINE iv_cc SMALLINT
   DEFINE wk_goto SMALLINT
   LET wk_goto = FALSE

   INPUT ARRAY P1 WITHOUT DEFAULTS FROM SR.*
      BEFORE ROW
         LET aln = ARR_CURR()
         LET sln = SCR_LINE()
         DISPLAY P1[aln].* TO SR[sln].* ATTRIBUTE(REVERSE)
         IF frmtyp ='1' THEN
            DISPLAY "����O�� ", aln USING "<<#"," ��" AT 22, 1
         ELSE
            DISPLAY "This row is ", aln USING "<<#"," row" AT 22, 1
         END IF
      BEFORE FIELD kind
         ERROR "Values are only 'F', 'Y', 'N' and 'G'!"
      ON KEY (CONTROL-Z)
         LABEL lblCallAdd100:
         CALL add100(TRUE, FALSE, PH.*)
         IF INT_FLAG THEN
            DISPLAY "" AT 22, 1
            LET INT_FLAG = FALSE
            CLEAR FORM
            ERROR mess[5] CLIPPED
            RETURN
         END IF

      AFTER ROW
         LET wk_key = FGL_LASTKEY()
         IF wk_key == FGL_KEYVAL("ACCEPT") OR wk_key == FGL_KEYVAL("ESC") OR wk_key == FGL_KEYVAL("TAB")
         THEN
            IF P1[aln].kind IS NULL OR P1[aln].kind MATCHES "[ ]" THEN
               ERROR mess[15]
               NEXT FIELD kind
            ELSE
               IF P1[aln].kind NOT MATCHES "[FYNG]" 
               THEN
                  NEXT FIELD kind
                  ERROR "Values are only 'F', 'Y', 'N' and 'G'!"
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
                  IF wk_goto THEN CALL add200(TRUE) END IF
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
      AFTER INPUT
         LET wk_key = FGL_LASTKEY()
         IF wk_key == FGL_KEYVAL("ACCEPT") OR wk_key == FGL_KEYVAL("ESC")
         THEN
            IF P1[aln].kind IS NULL OR P1[aln].kind MATCHES "[ ]" THEN
               ERROR mess[15]
               NEXT FIELD kind
            ELSE
               IF P1[aln].kind NOT MATCHES "[FYNG]" 
               THEN
                  NEXT FIELD kind
                  ERROR "Values are only 'F', 'Y', 'N' and 'G'!"
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
                  IF wk_goto THEN CALL add200(TRUE) END IF
               END IF
            END IF
            IF P1[aln].lossprs IS NULL OR P1[aln].lossprs MATCHES "[ ]"  THEN
               ERROR mess[15]
               NEXT FIELD lossprs
            ELSE
               ERROR P1[aln].lossprs
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
   END INPUT
END FUNCTION
FUNCTION updfun()
   DEFINE wk_machcodecnt INTEGER
   DEFINE wk_duplicate INTEGER
   DEFINE wk_countUpdateSuccess INTEGER

   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   LET wk_duplicate = 0
   LET wk_countUpdateSuccess = 0

   IF op_code = 'N' THEN
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

   CALL SET_COUNT(cc)

   CALL add200(TRUE)
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      ERROR mess[07] CLIPPED
      RETURN
   END IF

   BEGIN WORK
   FOR cc1 = 1 TO max_ary
      IF P1[cc1].kind IS NULL THEN
         EXIT FOR
      END IF
      IF PH1.pitems != PH.pitems OR PH1.dept != PH.dept OR P2[cc1].machcode !=  P1[cc1].machcode OR P2[cc1].kind !=  P1[cc1].kind OR P2[cc1].mach_cn !=  P1[cc1].mach_cn OR P2[cc1].mach_en !=  P1[cc1].mach_en
         OR P2[cc1].posno !=  P1[cc1].posno OR P2[cc1].hole !=  P1[cc1].hole OR P2[cc1].machcode !=  P1[cc1].machcode
         OR P2[cc1].lossprs !=  P1[cc1].lossprs OR P2[cc1].losshr !=  P1[cc1].losshr OR P2[cc1].lossgw !=  P1[cc1].lossgw
      THEN
         IF P1[cc1].kind NOT MATCHES '[FYNG]' THEN CONTINUE FOR END IF
         LET wk_machcodecnt = 0
         SELECT COUNT(*) INTO wk_machcodecnt FROM w213
         WHERE manuf = PH.manuf AND pitems = PH.pitems AND dept = PH.dept AND machcode = P1[cc1].machcode
         IF wk_machcodecnt THEN
            LET wk_duplicate = wk_duplicate + 1
         ELSE
            UPDATE w213 SET (pitems, dept, machcode, kind,mach_cn,mach_en,posno,hole,lossprs,losshr,lossgw,upusr,upday)
                        = (PH.pitems, PH.dept, P1[cc1].machcode, P1[cc1].kind, P1[cc1].mach_cn, P1[cc1].mach_en, P1[cc1].posno, P1[cc1].hole, P1[cc1].lossprs, P1[cc1].losshr, P1[cc1].lossgw,login_usr, CURRENT YEAR TO SECOND)
            WHERE ROWID = Wrowid[cc1]
            IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
               ROLLBACK WORK
               ERROR mess[04] CLIPPED
               RETURN
            ELSE
               LET wk_countUpdateSuccess = wk_countUpdateSuccess + 1
            END IF
         END IF
      END IF
   END FOR
   COMMIT WORK
   IF wk_countUpdateSuccess > 0 THEN
      IF wk_duplicate
      THEN 
         ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!", " To be Duplicated ", wk_duplicate USING "<<<<< & record." SLEEP 1
      ELSE
         ERROR "Modify ", wk_countUpdateSuccess USING "<<& "," row success!" SLEEP 1
      END IF
      CALL inqfun(FALSE) 
   ELSE
      IF wk_duplicate
      THEN 
         ERROR "Datas are unchanged! To be Duplicated ", wk_duplicate USING "<<<<< & record." SLEEP 1
      ELSE
         ERROR "Datas are unchanged!" SLEEP 1
      END IF
   END IF
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
      DISPLAY "�`���� : ",allcnt USING "<<<<#",
              "  ��ܲ� ",cnt USING "<<<<#"," �� " AT 23,1
   ELSE
      DISPLAY "Totals pages : ",allcnt USING "<<<<#",
               "  Display page ",cnt USING "#" AT 23,1
   END IF           	           
END FUNCTION
#-------------------------------------------------------------------------------
FUNCTION delfun()
   DISPLAY "" AT 23, 1
   DISPLAY "" AT 22, 1

   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
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
         DELETE FROM w213 WHERE ROWID = Wrowid[cc1]
         IF SQLCA.SQLERRD[3] = 0 AND STATUS != 0 THEN
            ERROR mess[63] CLIPPED
            ROLLBACK WORK
            RETURN
         ELSE
            LET cnt1 = cnt1 + 1
         END IF
      END FOR
   COMMIT WORK
   ERROR mess[53] CLIPPED, cnt1 USING "<<< & ",mess[41] CLIPPED
   CALL reopen()
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
         DISPLAY "�`���� : ",allcnt USING "<<<<#",
              "  ��ܲ� ",cnt USING "<<<<#"," �� " AT 23,1
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
            DISPLAY "�Щ��U�d ",
                    max_ary USING "<<<#"," ��" AT 1, 1
            DISPLAY "�@ ",cc USING "<<<#"," �� " AT 23, 1
            DISPLAY ARRAY P1 TO SR.*
            LET ans2 = "N"
            PROMPT "�~�򩹤U�d�� (y/n)? " FOR CHAR ans2
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
      DISPLAY "�@ ",cc USING "<<<#"," �� " AT 23, 1
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

   DEFINE iv_storna CHAR(20)	
   DEFINE qry_str4   CHAR(500)
   DEFINE wd_qty     LIKE w202.qty
   DEFINE wd_seq     LIKE w200.seq
   DEFINE wk_week    SMALLINT
   DEFINE  iv_day    DATE
   DEFINE  ir_day    DATE
   
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
   LET qry_str4 = "SELECT manuf,pitems,dept,machcode, kind,mach_cn,mach_en,posno,hole, lossprs,losshr,lossgw ",
                  " FROM w213",
                  " WHERE manuf = '",gv_manuf,"' AND ", wh_str CLIPPED	
   PREPARE qry_exe4 FROM qry_str4
   DECLARE std_cur4 CURSOR FOR qry_exe4 
                        
   START REPORT fo112av TO rep_naw
   FOREACH std_cur4 INTO D1.*
   
      IF INT_FLAG = TRUE THEN
         LET INT_FLAG = FALSE
         ERROR mess[47] CLIPPED
         EXIT FOREACH
      END IF
      LET P.manufna  = cal_j02(7,D1.manuf)  
      LET P.pitemsna = cal_j02(620,D1.pitems)  
      CALL cal_n15("W",D1.manuf,D1.dept) RETURNING P.deptna    
      OUTPUT TO REPORT fo112av(P.*, D1.*)  
      LET cc=cc+1
      IF frmtyp = "1" THEN
         DISPLAY "���� : ",cc USING "<<<#" AT 22,1
      ELSE
         DISPLAY "Rows : ",cc USING "<<<#" AT 22,1
      END IF        
   END FOREACH
   FINISH REPORT fo112av
   ERROR ""
   IF cc >=0 THEN
      CALL Cprint(rep_na,"Y")  
   ELSE
      DISPLAY "Rows :      " AT 22,1
      ERROR mess[09] CLIPPED
   END IF
END FUNCTION
#------------------------------------------------------------------------------
REPORT fo112av(P, R)
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
            PRINT   "�t�O|manufna|�~��|pitemsna|���|deptna|����|���x�W��|���x�^��|���x�s��|�x��|�զ�|��/��|��/�x|kg/��"
         ELSE
            PRINT   "manuf|manufna|pitems|pitemsna|dept|deptna|machcode|kind|mach_cn|mach_en|posno|hole|lossprs|losshr|lossgw"
      END IF 	                 
      ON EVERY ROW
         PRINT R.manuf,"|",P.manufna,"|",R.pitems,"|",P.pitemsna,"|",R.dept,"|",P.deptna,"|"        
               ,R.machcode,"|",R.kind,"|",R.mach_cn,"|",R.mach_en,"|",R.posno,"|",R.hole,"|",
               R.lossprs,"|",R.losshr,"|",R.lossgw         
      ON LAST ROW
            PRINT
            PRINT "�֨M:","||","�f��:","||","�s��:"             
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
   OPEN std_curs USING PH.pitems, PH.dept
   LET wk_flagOpenCur2 = TRUE
END FUNCTION

FUNCTION closeCursorStd()
   CLOSE std_curs
   LET wk_flagOpenCur2 = FALSE
END FUNCTION
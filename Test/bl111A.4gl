#  PRGNAM: bl111A.4gl
#  PRGFUN: �Ҩ�ܧO(�x��a�I)�ɺ��@
#  LIB   : w209
#  AUTHOR: QING GUI YANG
#  DATE : 2020/11/10
#---------------------------
GLOBALS 'kmgbl.4gl'
DEFINE  P1,P2  RECORD
        manuf    LIKE   w209.manuf,
        codsc    CHAR(6)         , 
        #dept     LIKE   w209.dept,
        dept     LIKE   n15.teamno,
        deptsc   LIKE   n15.teamcna, #�����W��   #j02.codsc, 
        state    LIKE   w209.state,
        plno     LIKE   w209.plno,
        place    LIKE   w209.place,
        place_e  LIKE   w209.place_e,        
        upusr    LIKE   w209.upusr,
        upday    LIKE   w209.upday
       END RECORD       
       
#2014-07-07 add by Jin
DEFINE C1 RECORD
         dep_for        LIKE a15.dep_for    ,      #�����k�ݥN�X
         dep_forna      LIKE j02.codsc      ,      #�t�O�W��
			   deptsc         LIKE n15.teamcna,
         dep_for_cfm    LIKE a15.dep_for_cfm,      #�����k�ݽT�{�_
         cfm_upusr      LIKE a15.dep_for_cfm_upusr,#�]�ȽT�{��
         cfm_upday      LIKE a15.dep_for_cfm_upday #�]�ȽT�{��
       END RECORD
DEFINE A RECORD
      oplno     LIKE a15.plno,
      oplace    LIKE a09.oplace,
      nplno     LIKE a15.plno,
      nplace    LIKE a09.nplace,
      mark      LIKE a09.mark
END RECORD
DEFINE wk_teamno  LIKE n15.teamno      #�����N��
DEFINE wk_teamcna LIKE n15.teamcna     #���峡���W��
DEFINE wk_teamena LIKE n15.teamena     #�^�峡���W��
DEFINE wk_depno   LIKE d03.depno       #�Ʒ~���N�X


FUNCTION mainfun()
    WHENEVER ERROR CALL errmsg
    SET LOCK MODE TO WAIT
    LET Pfrm = Cfrm CLIPPED,"/bl111"
    OPEN FORM bl111 FROM Pfrm
    DISPLAY FORM  bl111
# update by Jack 2011-03-16  �s�W�^�夶���\���"
    IF frmtyp ='1' THEN
        MENU "�\��"
            #2014-07-18 add by Jin
            BEFORE MENU
               #IF usr_pg[7] = "N" THEN HIDE OPTION "6.�]�ȽT�{","7.�����T�{" END IF

            COMMAND "0.����"
                    "����:   ��������, �^��W�@�e��, Ctrl-P �򥻾ާ@����"
                     HELP 0001 CALL Cset_int() CALL curfun()
                     EXIT MENU
            COMMAND "1.�s�W"
                    "����:   �s�W���, �� Esc ����, Del ���, Ctrl-P �򥻾ާ@����"
                     HELP 0001 IF( usr_pg[1] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL curfun() CALL addfun('1')
                     END IF
            COMMAND "2.�d��"
                     "����:   �d�߸��, �� Esc ����, Del ���, Ctrl-P �򥻾ާ@����"
                     HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL inqfun()
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
            COMMAND "5.�C�L"
                    "����: �C�L�겣�M��,Esc ����,Del ���, Ctrl-P �򥻾ާ@����"
                     CALL prtfun()
            COMMAND "N.�U�i" "����:   ��ܤU�@�i���, Ctrl-P �򥻾ާ@����"
                     HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL pgfun(1)
                     END IF
            COMMAND "U.�W�i" "����:   ��ܤW�@�i���, Ctrl-P �򥻾ާ@����"
                     HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL pgfun(-1)
                     END IF
            COMMAND "H.����" "����:   �{���ާ@���U����"
                     CALL showhelp(0101)
        END MENU
    ELSE
        MENU "MENU"
            #2014-07-18 add by Jin
            BEFORE MENU
               IF usr_pg[7] = "N" THEN HIDE OPTION "6.Finance_CFM","7.CFM CANCEL" END IF

            COMMAND "0.END"
                    "HELP:   Exit, Return previous menu, Ctrl-P basic help"
                     HELP 0001 CALL Cset_int() CALL curfun()
                     EXIT MENU
            COMMAND "1.CREATE"
                    "HELP:   Create data, ESC to run, DEL to abort, Ctrl-P basic help"
                     HELP 0001 IF( usr_pg[1] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL curfun() CALL addfun('1')
                     END IF
            COMMAND "2.INQUERY"
                    "HELP:   Inquery data, ESC to run, DEL to abort, Ctrl-P basic help"
                     HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL inqfun()
                     END IF
            COMMAND "3.UPDATED"
                    "HELP:   UPDATE data, ESC to run, DEL to abort, Ctrl-P basic help"
                     HELP 0001 IF( usr_pg[3] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL updfun()
                     END IF
            #COMMAND "4.DELETE"
            #        "HELP:   Delete data, Y to run, Del to abort, Ctrl-P basic help"
            #         HELP 0001 IF( usr_pg[4] = 'N' )THEN ERROR mess[25] CLIPPED
            #         ELSE CALL Cset_int() CALL delfun()
            #         END IF
            COMMAND "5.PRINT"
                    "Help:   Print list,Esc to run,Del to abort, Ctrl-P Basic Help"
                     CALL prtfun()
            COMMAND "N.PAGE DOWN"
                    "HELP:   Display next page, Ctrl-P basic help"
                     HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL pgfun(1)
                     END IF
            COMMAND "U.PAGE UP"
                    "HELP:   Display previous page, Ctrl-P basic help"
                     HELP 0001 IF( usr_pg[2] = 'N' )THEN ERROR mess[25] CLIPPED
                     ELSE CALL Cset_int() CALL pgfun(-1)
                     END IF
            COMMAND "H.HELP" "HELP:   basic help"
                     CALL showhelp(0101)
        END MENU
    END IF
END FUNCTION
#--------------------------------------------------
FUNCTION inqfun()
   LET   op_code = "N"
   CLEAR FORM
   DISPLAY "" AT 23, 1
   #2014-07-08 Jin:�d�����W�[�����k�ݩM�T�{�_���
   #CONSTRUCT BY NAME wh_str ON a15.plno ATTRIBUTE(REVERSE)
#  CONSTRUCT BY NAME wh_str ON a15.manuf,a15.plno ATTRIBUTE(REVERSE)
   #2015/8/14 yhchen:�W�[���m���i�d��
   CONSTRUCT wh_str ON dept,state,plno 
                  FROM dept,state,plno 
   AFTER CONSTRUCT
      IF INT_FLAG THEN
         LET INT_FLAG = FALSE
         CLEAR FORM
         ERROR mess[06] CLIPPED
         RETURN
      END IF
   END CONSTRUCT

  LET qry_str = "Select manuf,' ' codsc,dept,' ' deptsc,state,plno,place,place_e,upusr,upday ",
                "  from w209 ",
                " Where manuf ='",gv_manuf,"'",
                # "   and a15.manuf=j02.code and j02.codk=7 " ,
                " and ",wh_str CLIPPED," ORDER BY 1,4"
                       
   PREPARE cnt_exe FROM qry_str
   DECLARE cnt_cur SCROLL CURSOR FOR cnt_exe
   DISPLAY mess[11] CLIPPED AT 24, 1 ATTRIBUTE(REVERSE)
   LET op_code = "Y"
   LET cnt     = 1
   OPEN cnt_cur
   CALL reopen(2)
   CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc 
       {SELECT teamcna INTO P1.deptsc FROM n15
       WHERE  manuf  = P1.manuf
         AND  teamno = P1.dept
    	DISPLAY BY NAME P1.deptsc  #�W�[ BY �󻷿P 2020.05.16}
   IF op_code = "N" THEN
   	   CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc 
        RETURN
   END IF

   IF frmtyp = '1' THEN
      DISPLAY "�`���� : ",allcnt USING "<<<<#",
              "  ��ܲ� :",cnt USING "<<<<#"," �� " AT 23,1
   ELSE
      DISPLAY "Total rows : ",allcnt USING "<<<<#",
              "  Current row :",cnt USING "<<<<#" AT 23,1
   END IF

   #FETCH ABSOLUTE cnt cnt_cur INTO P1.*, row_id
   #CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc
   #CALL reopen(2)  #2020.05.19 �󻷿P fix �����W�٤����
       {SELECT teamcna INTO P1.deptsc FROM n15
       WHERE  manuf  = P1.manuf
         AND  teamno = P1.dept}
   	DISPLAY BY NAME P1.deptsc  #�W�[ BY �󻷿P 2020.05.16  
       #DISPLAY '�����N�X',P1.dept,'�����W��',P1.deptsc AT 20,1
   LET op_code = "Y"
   #CALL reopen(2)  #2020.05.19 �󻷿P fix �����W�٤����
END FUNCTION
#--------------------------------------------------
FUNCTION addfun(act)
   DEFINE act CHAR(1)
   DISPLAY "" AT 23,1
   CLEAR FORM
   WHILE TRUE
      IF act='1' THEN
        CLEAR FORM
        LET op_code = 'N'
        INITIALIZE P1.* TO NULL
      ELSE
        IF op_code ='N' THEN
           ERROR mess[16] CLIPPED
           RETURN
        END IF
      END IF
      LET P1.upusr =login_usr
      LET P1.upday =stoday    #CURRENT YEAR TO SECOND
      DISPLAY P1.upusr,P1.upday
      CALL add100(1)
      IF INT_FLAG THEN
         LET INT_FLAG = FALSE
         RETURN
      END IF

      INSERT INTO w209 (manuf,state,dept,plno,place,place_e, upusr, upday)
                VALUES (P1.manuf,P1.state,P1.dept,P1.plno,P1.place,P1.place_e,login_usr, CURRENT YEAR TO SECOND)
                       
                       
      IF ( SQLCA.SQLERRD[3] = 1 AND STATUS = 0 ) THEN
         ERROR mess[03] CLIPPED
      ELSE
         ERROR mess[04] CLIPPED
         CONTINUE WHILE
      END IF
   END WHILE
    CLEAR  FORM
      ERROR mess[40] CLIPPED, cnt1 USING "<<<#",mess[41] CLIPPED    
END FUNCTION
#--------------------------------------------------
FUNCTION add100(act)
   DEFINE act CHAR(1)
   #2015/8/12 yhchen:�W�[���m�x��(FW1580001W)
   INPUT BY NAME P1.dept,P1.state,P1.plno,P1.place,P1.place_e WITHOUT DEFAULTS 	
     #2009-2-13 by mindy:�W�[�����}���d�ߥ\��
      ON KEY (CONTROL-W)
         #IF INFIELD(dept) THEN
         #   CALL win_j02(6) RETURNING P1.dept,P1.deptsc
         #   DISPLAY BY NAME P1.dept,P1.deptsc
         #END IF
         IF INFIELD(dept) THEN
            CALL win_n15c("W",P1.manuf) RETURNING P1.dept,P1.deptsc
            DISPLAY BY NAME P1.dept,P1.deptsc
            NEXT FIELD dept
         END IF         
      	
   BEFORE INPUT
      # update by Jack 2011-03-22
      # SELECT codsc INTO P1.codsc FROM j02 WHERE codk = 7 AND code=P1.manuf
      LET P1.state='Y'
      #LET wk_depno  = cal_j02(6,wk_depno)
         	SELECT manuf,teamno,depno INTO P1.manuf,P1.dept,wk_depno FROM d03
          WHERE logid = login_usr
          #CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc      
 
       #�W�[�^��W��    add by chun 07/08/2010
       IF frmtyp = 1 THEN
           SELECT teamcna INTO P1.deptsc  FROM n15
           WHERE  compy  = 'W'
           AND    manuf  = P1.manuf
           AND    teamno = P1.dept
       ELSE
           SELECT teamena INTO P1.deptsc  FROM n15
           WHERE  compy  = 'W'
           AND    manuf  = P1.manuf
           AND    teamno = P1.dept
      END IF
 
      LET P1.upusr=login_usr
      LET P1.upday = CURRENT YEAR TO SECOND
           
      # update by Jack 2011-03-22
      IF frmtyp="1" THEN
          LET P1.codsc = cal_j02(7,P1.manuf)        
      ELSE
          LET P1.codsc = cal_j02_1e(7,P1.dept)        
      END IF
      DISPLAY BY NAME P1.manuf,P1.codsc,P1.dept,P1.deptsc,P1.state,P1.upusr,P1.upday

   AFTER FIELD plno
    #�[�J�t�O�P�_
    SELECT ROWID FROM w209 WHERE plno = P1.plno AND manuf = P1.manuf AND dept = P1.dept
      IF P1.plno IS NULL OR P1.plno =' ' THEN
        ERROR mess[15] CLIPPED
        NEXT FIELD plno
      END IF
      IF STATUS = 0 THEN
         ERROR mess[02] CLIPPED
         NEXT FIELD plno
      END IF
      IF LENGTH(P1.plno)<=3 THEN
         IF frmtyp = '2' THEN
            CALL cal_err("Mold place need 4 char","pls try again")
         ELSE
            CALL cal_err("�Ҩ�ܧO�N�X�ݭn4�X","�Э��s��J")
         END IF
         NEXT FIELD plno   	
      END IF	
   AFTER FIELD place
    IF P1.place IS NULL OR P1.place = ' ' THEN
      ERROR mess[15] CLIPPED
      NEXT FIELD place
    END IF
   AFTER FIELD place_e
    IF P1.place_e IS NULL OR P1.place_e = ' ' THEN
      ERROR mess[15] CLIPPED
      NEXT FIELD place_e
    END IF    
   
   AFTER FIELD dept  	
         IF P1.dept IS NULL OR P1.dept = ' ' THEN
         	   SELECT teamno INTO P1.dept FROM d03
              WHERE logid = login_usr
               CALL cal_n15(gv_depno,gv_manuf,P1.dept) RETURNING P1.deptsc
            IF frmtyp = "2" THEN
               SELECT teamno,teamena INTO P1.dept,P1.deptsc
                 FROM n15  WHERE teamno = P1.dept
                             AND  depno = gv_depno
                             AND  manuf = gv_manuf
                             AND  use   = 'Y'
            ELSE
                SELECT teamno,teamcna INTO P1.dept,P1.deptsc
                  FROM n15  WHERE teamno = P1.dept
                             AND  depno = gv_depno
                             AND  manuf = gv_manuf
                             AND  use   = 'Y'
            END IF
            IF STATUS = NOTFOUND THEN ####OR LENGTH(PH.odepna) = 0 THEN
                #CALL cal_err("�d�L�������N��","�Э��s��J")
                ERROR mess[20] CLIPPED
                NEXT FIELD orgdep
            END IF
            DISPLAY BY NAME P1.dept,P1.deptsc
        END IF  
    #IF P1.dept IS NULL OR P1.dept=' ' THEN
    #   IF frmtyp = "2" THEN
    #       LET P1.deptsc = cal_j02_1e(6,P1.dept)
    #   ELSE
    #       LET P1.deptsc = cal_j02(6,P1.dept)
    #   END IF   
    #END IF   
    DISPLAY BY NAME P1.dept,P1.deptsc
    NEXT FIELD NEXT    
    
    #IF P1.dept IS NULL OR P1.dept = ' ' THEN
    #  ERROR mess[15] CLIPPED
    #  NEXT FIELD dept
    #END IF
   SELECT ROWID FROM w209 
   WHERE plno = P1.plno AND manuf = P1.manuf #AND dept = P1.dept
       IF STATUS=NOTFOUND THEN 
               IF frmtyp = '2' THEN
                  CALL cal_err("Mold place cannot repeat","pls try again")
               ELSE
                  CALL cal_err("�Ҩ�ܧO�N�X���i�H����","�Э��s��J")
               END IF
               RETURN    #�h�X�s�W�{��
   END IF   
   AFTER INPUT
         IF INT_FLAG THEN
            EXIT INPUT
         END IF
   END INPUT
   
END FUNCTION
#--------------------------------------------------
FUNCTION updfun()
   DEFINE wk_chk  INTEGER
   DISPLAY  "" AT 23, 1
   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF
   OPEN cnt_cur

   #2014-07-07 Jin:�Y�w�i������k�ݽT�{�A�h���i�i��ק�ΧR��
   #IF P1.state = 'Y' THEN
   #   IF frmtyp = '1' THEN
   #      ERROR "�w�i������k�ݽT�{�A�Y�ݶi�沧�ʽгq���]�Ȩ����T�{"
   #   ELSE
   #      ERROR "Have been confirmed depreciation. Please contact Finance cancel confirmed. "
   #   END IF
   #   RETURN
   #END IF


   DISPLAY BY NAME P1.*

   INPUT BY NAME P1.state WITHOUT DEFAULTS ATTRIBUTE(REVERSE)

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN
   END IF
   BEGIN WORK
   SELECT manuf,dept,state,plno,place,place_e,upusr,upday FROM w209
    WHERE ROWID =row_id
   #�p�G�Ҩ�w�s���s�񤣥i�H�R�� 
   #SELECT COUNT(*) INTO wk_chk FROM wj05
   # WHERE plno =P1.plno
   #   AND lmanuf = P1.manuf
   #   AND stat IN ('A','C')
   IF wk_chk IS NULL THEN LET wk_chk = 0 END IF
   IF wk_chk =0 THEN
      IF STATUS != 00  THEN
         CLOSE cnt_cur
         LET op_code = "N"
         DISPLAY "" AT 23, 1
         ERROR mess[59] CLIPPED
         RETURN
      END IF
   END IF
      
           UPDATE w209 SET
                (state,place,upusr,upusr_e,upday)
              = (P1.state,P1.place,P1.place_e,login_usr,stoday)
                WHERE plno  = P1.plno
                  AND manuf = P1.manuf
                  AND dept  = P1.dept

   IF SQLCA.SQLERRD[3] = 0  THEN
      ERROR mess[04] CLIPPED
      ROLLBACK WORK
      RETURN
   ELSE
      COMMIT WORK
      ERROR mess[03] CLIPPED
   END IF
END FUNCTION
#--------------------------------------------------
FUNCTION delfun()
   DEFINE wk_chk INTEGER

   DISPLAY "" AT 23,1
   IF op_code = "N" THEN
      ERROR mess[16] CLIPPED
      RETURN
   END IF

   SELECT manuf,dept,state,plno,place,place_e,upusr,upday FROM w209
    WHERE ROWID =row_id
   #�p�G�Ҩ�w�s���s�񤣥i�H�R�� 
   #SELECT COUNT(*) INTO wk_chk FROM wj05
   # WHERE plno =P1.plno
   #   AND lmanuf = P1.manuf
   #   AND stat IN ('A','C')
   IF wk_chk IS NULL THEN LET wk_chk = 0 END IF
   IF wk_chk =0 THEN
      IF STATUS != 00  THEN
         CLOSE cnt_cur
         LET op_code = "N"
         DISPLAY "" AT 23, 1
         ERROR mess[21] CLIPPED
         RETURN
      END IF


      DISPLAY BY NAME P1.*
      #2014-07-07 add by Jin
 
      #2014-07-07 Jin:�Y�w�i������k�ݽT�{�A�h���i�i��ק�ΧR��
      IF wk_chk >0 THEN
         IF frmtyp = '1' THEN
            ERROR "�a�I�w�i�s�񤣥i�R���A�Y�ݶi�沧�ʽгq���]�Ȩ����T�{"
         ELSE
            ERROR "Have been confirmed depreciation. Please contact Finance cancel confirmed. "
         END IF
         RETURN
      END IF
      CALL ans() RETURNING ans1
      IF ans1 = "y" OR ans1 = "Y" THEN
         DELETE FROM w209 WHERE plno=P1.plno AND manuf=P1.manuf AND dept=P1.dept
          IF SQLCA.SQLERRD[3] = 1 AND STATUS = 0 THEN
             ERROR mess[03] CLIPPED
              CLOSE cnt_cur
              OPEN  cnt_cur
             CALL  reopen(4)
          ELSE
             ERROR mess[04] CLIPPED
             RETURN
          END IF

      ELSE
         ERROR mess[08] CLIPPED
         RETURN
      END IF
   ELSE
      IF frmtyp = '1' THEN
         ERROR "���N�X�٦���L�겣�ϥΤ�"
      ELSE
         ERROR "Other asset uses this CODE"
      END IF
   END IF

END FUNCTION
#--------------------------------------------------
FUNCTION reopen(act)
   DEFINE act CHAR(1)
   LET  allcnt = 0
   WHILE TRUE
      LET allcnt = allcnt + 1
      FETCH ABSOLUTE allcnt cnt_cur INTO P1.*, row_id
      LET P2.* = P1.*  # ??  ����ݭn�o�@��  P2 �b���{�����S����L�a�観�Ψ�
      IF STATUS != 00 THEN
         EXIT WHILE
      END IF
   END WHILE
   LET allcnt = allcnt - 1
   IF  allcnt < 0 THEN LET allcnt = 0 END IF
	
   IF  allcnt = 0 THEN
       CLEAR FORM
       LET   op_code = "N"
       IF   act = "2" THEN ERROR mess[9]  CLIPPED END IF
       IF  ( act = "3" OR act = "4" ) THEN
         IF frmtyp = "1" THEN           
           CALL cal_err("�R����Ʀ��\","���~��ާ@")
         ELSE
           CALL cal_err("DELETE DATA SUCCSED","PLEASE CONTINUE")
         END IF
           RETURN
       END IF
   ELSE
       IF  act = "2" THEN
             LET  op_code = "Y"
             LET  cnt = 1  END IF
       IF  ( act = "3" OR act = "4" ) THEN
             IF   cnt > allcnt THEN LET cnt = allcnt END IF
       END IF
       #2014-07-07 modify by Jin
       FETCH ABSOLUTE cnt cnt_cur INTO P1.*, row_id
       CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc 
       #DISPLAY 'P1.deptsc',P1.deptsc AT 19,1
       #ERROR 'P1.dept',P1.dept
       #DISPLAY BY NAME P1.deptsc      
       DISPLAY BY NAME P1.*


   END IF
END FUNCTION
#--------------------------------------------------
FUNCTION curfun()
   IF op_code = "Y" THEN
#      CLOSE cnt_cur
      LET op_code = "N"
   END IF
END FUNCTION
#----------------------------------------------------
FUNCTION pgfun(move)
   DEFINE move CHAR(1)
   IF op_code="N" THEN
      ERROR mess[16]  CLIPPED
      RETURN
   END IF
   IF move = 1 THEN
      IF cnt = allcnt THEN
         ERROR mess[13] CLIPPED
      ELSE
         FETCH NEXT cnt_cur INTO P1.*, row_id
         LET cnt = cnt + 1
         IF cnt = allcnt THEN
            ERROR mess[13] CLIPPED
         END IF
      END IF
   ELSE
      IF cnt = 1 THEN
         ERROR mess[12] CLIPPED
      ELSE
         FETCH PREVIOUS cnt_cur INTO P1.*, row_id
         LET cnt = cnt - 1
         IF cnt = 1 THEN
            ERROR mess[12] CLIPPED
         END IF
      END IF
   END IF

   # update by Jack 2011-03-22
   # DISPLAY BY NAME P1.*
   IF frmtyp = '1' THEN
      LET P1.codsc = CAL_j02(7,P1.manuf)
      CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc

      DISPLAY BY NAME P1.*

      DISPLAY "�`���� : ",allcnt USING "<<<<#",
              "  ��ܲ� :",cnt USING "<<<<#"," �� " AT 23,1
   ELSE
      LET P1.codsc=cal_j02_1e(7,P1.manuf)
      CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc   
      DISPLAY BY NAME P1.*  
      DISPLAY "Total rows : ",allcnt USING "<<<<#",
              "  Current row :",cnt USING "<<<<#" AT 23,1
   END IF
END FUNCTION

#----------------------------------------------------------------
FUNCTION prtfun()
   DEFINE wk_cnt   INTEGER
   DEFINE wk_row   INTEGER
   DEFINE wk_purno LIKE u36.purno
   DEFINE wk_rptna CHAR(50)
   -----------------------
   IF op_code = "N" THEN
      IF frmtyp="1" THEN
          CALL cal_err("�S����ƥi�ѱ��� ...","�Х��d�� ...")
      ELSE
          CALL cal_err("No RECORD","Please inquire first")
      END IF
      RETURN
   END IF
   ------
   DISPLAY "" AT 2,1
   LET Prt_na = pgno
   CALL reptol()
   ----
   LET wk_cnt = 1
   START REPORT bl111 To rep_naw
   OPEN cnt_cur
   WHILE TRUE
      FETCH ABSOLUTE wk_cnt cnt_cur INTO P1.*, row_id
      IF STATUS =  NOTFOUND THEN
         EXIT WHILE
      END IF
      IF frmtyp = "1" THEN
          LET P1.codsc = cal_j02(7,P1.manuf)
          CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc   
      ELSE
         LET P1.codsc = cal_j02_1e(7,P1.manuf)
         CALL cal_n15("W",P1.manuf,P1.dept) RETURNING P1.deptsc   
      END IF
      ------
      OUTPUT TO REPORT bl111(P1.*)
      IF frmtyp = "1" THEN
          DISPLAY "�����`����� : ",wk_cnt USING "#####"," ��" AT 24,1
      ELSE
          DISPLAY "Data collect complete :" ,wk_cnt USING "#####"," row" AT 24,1
      END IF
      LET wk_cnt = wk_cnt + 1
   END WHILE
   -----------
   FINISH REPORT bl111
   DISPLAY "" AT 24,1
   -------
   IF wk_cnt = 0 THEN
      IF frmtyp="1" THEN
          CALL cal_err("�d�L�����󤧸��","�Эק�d�߱���")
      ELSE
          CALL cal_err("RECORD NOT FOUND","please change query condition")
       END IF
   ELSE
      CALL Cprint(rep_naw,'Y')
   END IF
END FUNCTION
#---------------------------------------------------------------------
REPORT bl111(R1)
   DEFINE w_prno    CHAR(10)
   DEFINE wk_mtaxno CHAR(10)
   DEFINE tm_tmp    CHAR(30)
   DEFINE wk_unused CHAR(6)   #2015/8/12 yhchen
   DEFINE Head_B     CHAR(30)   
   DEFINE IsEnd      SMALLINT   
   DEFINE R1   RECORD
        manuf    LIKE   w209.manuf,
        codsc    CHAR(6)         , 
        dept     LIKE   w209.dept,
        deptsc   LIKE   j02.codsc, 
        state    LIKE   w209.state,
        plno     LIKE   w209.plno,
        place    LIKE   w209.place,
        place_e  LIKE   w209.place_e,
        upusr    LIKE   w209.upusr,
        upday    LIKE   w209.upday
       END RECORD
OUTPUT
   PAGE     LENGTH 10
   TOP      MARGIN 0
   BOTTOM   MARGIN 0
   RIGHT    MARGIN 140
   LEFT     MARGIN 0

  FORMAT
  FIRST PAGE HEADER
     LET Head_B = cal_compy1('2',gv_manuf)
     PRINT "|||", Head_B CLIPPED
     #LET IsEnd = FALSE  
     #LET tm_tmp = cal_compyna(R1.manuf)
     PRINT "|||", "�Ҩ�޲z�����M�ܧO�`��"

     LET tm_tmp = "bl111" 
     PRINT tm_tmp CLIPPED
     PRINT "Print Date:",TODAY CLIPPED,"|||","Print Time:",TIME CLIPPED
     IF frmtyp="1" THEN
          PRINT   "�t�O",'|',"�W��","�O�޳���",'|',"�����W��",'|',"���A",'|',"�ܧO",'|',"�ܧO�W��"
     ELSE
          PRINT   "FTY",'|',"Name",'|',"dept",'|',"deptsc",'|',"State",'|',"Warehouse",'|',"Warehouse Name"
     END IF
  ON EVERY ROW

     
     #PRINT R1.manuf ,'|',R1.codsc,'|',R1.dept,'|',R1.deptsc,'|',R1.state,'|',R1.plno,'|',R1.place
     IF frmtyp="1" THEN
          PRINT R1.manuf ,'|',R1.codsc,'|',R1.deptsc,'|',R1.state,'|',R1.plno,'|',R1.place
     ELSE
          PRINT R1.manuf ,'|',R1.codsc,'|',R1.deptsc,'|',R1.state,'|',R1.plno,'|',R1.place_e
     END IF          
   ON LAST ROW
      PRINT
      PRINT "�֨M:","||","�f��:","||","�s��:"
END REPORT
#---------------------------------------------------------------------
#  awin_j02(vcodk):�W�[�t�O�z�� copy from win_j02() add by Jin 140728
#---------------------------------------------------------------------
FUNCTION awin_j02(vcodk)
   DEFINE P_j02  ARRAY[200] OF RECORD
          code      LIKE j02.code,
          codsc     LIKE j02.codsc
          END RECORD ,
          vcodk     LIKE j02.codk,
          win_str   CHAR(300),
          wmax_ary  INTEGER,
          jj,wk_cout        INTEGER
   DEFINE wk_str    CHAR(500)
   DEFINE ans2      CHAR(01)
   DEFINE iv_compy,iv_manuf CHAR(01)

   LET Pfrm = Cfrm CLIPPED,"/win_j02"
   OPEN WINDOW win_j02 AT 7,36  WITH FORM Pfrm
   ATTRIBUTE ( BORDER, FORM LINE 1)

   WHILE TRUE

      CONSTRUCT BY NAME wk_str ON code,codsc
                              ATTRIBUTE(REVERSE)
      IF( int_flag )THEN
          LET int_flag = FALSE
          CLOSE WINDOW win_j02
          RETURN "", ""
      END IF


      IF frmtyp = "2" THEN
         LET wk_cout = 0
         SELECT COUNT(*) INTO wk_cout FROM j02 WHERE codk = 294 AND codsc = pgno
         #IF STATUS = NOTFOUND THEN
         IF wk_cout IS NULL THEN LET wk_cout = 0 END IF
         IF wk_cout = 0 THEN
            LET win_str=" SELECT code,codsc_en FROM j02_1 WHERE codk=? AND ",
                     wk_str CLIPPED ," ORDER BY code "
         ELSE
            LET win_str=" SELECT code,codmk FROM j02 WHERE codk=? AND ",
                     wk_str CLIPPED ," AND mark = '",P1.manuf,"' ORDER BY code "
         END IF
      ELSE
         LET win_str=" SELECT code,codsc FROM j02 WHERE codk=? AND ",
                     wk_str CLIPPED ,"AND mark = '",P1.manuf,"' ORDER BY code "
      END IF


      PREPARE win_exe FROM win_str
      DECLARE std_curs CURSOR FOR win_exe
      OPEN std_curs USING vcodk
      LET wmax_ary = 200
      LET jj = 1
      WHILE TRUE
            FETCH std_curs INTO P_j02[jj].*
            IF( STATUS = NOTFOUND )THEN
                EXIT WHILE
            END IF
            IF( int_flag )THEN
                EXIT WHILE
            END IF
            IF( jj <= 10 )THEN
                DISPLAY P_j02[jj].* TO SR[jj].*
            END IF
            LET jj = jj + 1
            IF( jj > wmax_ary )THEN
                IF frmtyp = "2" THEN
                   ERROR "More than ", wmax_ary USING "<<<#"," Rows"
                ELSE
                   ERROR "�W�L ", wmax_ary USING "<<<#"," ��"
                END IF
                LET jj = jj - 1
                CALL SET_COUNT(jj)
                DISPLAY "" AT 14, 1
                IF frmtyp = "2" THEN
                   DISPLAY "Press�� Down,�� Up, Ctrl-N:PageDown" AT 15,1
                   DISPLAY "  Esc: Select, Del: Cancel, Ctrl-U:PageUp" AT 16,1
                   DISPLAY "Total ",jj USING "<<<#"," Rows " AT 14, 1
                ELSE
                   DISPLAY "�� �� �U��, �� �W��, Ctrl-N �U��" AT 15,1
                   DISPLAY "  Esc �ﶵ, Del���, Ctrl-U �W��" AT 16,1
                   DISPLAY "�@ ",jj USING "<<<#"," �� " AT 14, 1
                END IF
                DISPLAY ARRAY P_j02 TO SR.*
                IF( int_flag )THEN
                    LET int_flag = FALSE
                    CLOSE std_curs
                    CLOSE WINDOW win_j02
                    RETURN "", ""
                END IF
                LET ans2 = "n"
                PROMPT "���U�d��Continue (y/n)? " FOR CHAR ans2
                IF( ans2 MATCHES "[Yy]" )THEN
                    LET jj = 1
                ELSE
                    CLOSE std_curs
                    CLOSE WINDOW win_j02
                    LET jj = ARR_CURR()
                    RETURN P_j02[jj].code, P_j02[jj].codsc
                END IF
            END IF
         END WHILE
         LET jj = jj - 1
         IF( int_flag )THEN
             LET int_flag = FALSE
            #ERROR "�ϥΪ̤��_�d��"
             ERROR mess[46] CLIPPED
             CLEAR FORM
             CLOSE std_curs
             CONTINUE WHILE
         END IF
         IF( jj = 0 )THEN
            #ERROR "�d�L����� ...."
             ERROR mess[9] CLIPPED
             CONTINUE WHILE
         ELSE
             EXIT WHILE
         END IF
   END WHILE
   CALL SET_COUNT(jj)
   IF frmtyp = "2" THEN
      DISPLAY "Press�� Down,�� Up, Ctrl-N:PageDown" AT 15,1
      DISPLAY "  Esc: Select, Del: Cancel, Ctrl-U:PageUp" AT 16,1
      DISPLAY "Total ",jj USING "<<<#"," Rows " AT 14, 1
   ELSE
      DISPLAY "�� �� �U��, �� �W��, Ctrl-N �U��" AT 15,1
      DISPLAY "  Esc �ﶵ, Del���, Ctrl-U �W��" AT 16,1
      DISPLAY "�@ ",jj USING "<<<#"," �� " AT 14, 1
   END IF
   DISPLAY ARRAY P_j02 TO SR.*
   LET jj = ARR_CURR()
   CLOSE std_curs
   CLOSE WINDOW win_j02
   IF( int_flag )THEN
       LET int_flag = FALSE
       RETURN "", ""
   END IF
   RETURN P_j02[jj].code, P_j02[jj].codsc
END FUNCTION

/* RAKF ADD USER BREXX SCRIPT */
/* GET ARGUMENTS */
PARSE ARG ARGS
/* -------- DEFAULT -------- */
DFLTGRP = 'USER'
OPER=0
SPECIAL=0
NAME=''
PASSWORD='PASSWORD'
USERID=''
/* --------  DONE  -------- */
IF LENGTH(ARGS) = 0 THEN DO
  SAY "RAKF01I INSUFFICIENT ARGUMENTS"
  SAY ""
  SAY "ADDUSER USERID"
  SAY " [PASSWORD(PASSWORD)] DEFAULT: PASSWORD"
  SAY " [DFLTGRP(USER)]      DEFAULT: USER"
  SAY " [OPERATIONS|OPER]    DEFAULT: NO OPERATIONS"
  SAY " [SPECIAL]            DEFAULT: NO SPECIAL"
  SAY " [NAME()]             DEFAULT: BLANK"
  SAY "USERID IS REQUIRED"
  EXIT
END
PARSE UPPER VAR ARGS USERID ARGS
IF POS("(",USERID) > 0 THEN DO
    SAY "RAKF01I FIRST ARGUMENT MUST BE USERID"
    EXIT
END
CALL CHECK_LENGTH USERID 'USERID' 7
/* -------- PARSE ARGUMENTS -------- */
DO WHILE (LENGTH(ARGS) > 0)
   PARSE VAR ARGS T .
      IF POS("(",T) = 0 THEN
        PARSE VAR ARGS CURRENT ARGS
      ELSE DO
        PARSE VAR ARGS O "(" S ")" ARGS
        CURRENT = O||"("||S||")"
      END
/* PARSE VAR ARGS CURRENT ARGS */
   IF POS("(",CURRENT) = 0 THEN DO
     SELECT
       WHEN UPPER(CURRENT) = 'OPER' THEN
         OPER = 1
       WHEN UPPER(CURRENT) = 'OPERATIONS' THEN
         OPER = 1
       WHEN UPPER(CURRENT) = 'SPECIAL' THEN
         SPECIAL = 1
       OTHERWISE DO
         SAY 'RAKF01I ARGUMENT' CURRENT 'NOT RECOGNIZED'
         EXIT
       END
     END
   END  
   ELSE DO
     PARSE VAR CURRENT OPTION "(" SELECTION ")"
     SELECT
       WHEN (UPPER(OPTION) = 'PASSWORD') THEN DO
         PASSWORD = SELECTION
         CALL CHECK_LENGTH PASSWORD 'PASSWORD' 8
       END
       WHEN (UPPER(OPTION) = 'NAME') THEN
         NAME = SELECTION
       WHEN (UPPER(OPTION) = 'COMMENT') THEN
         NAME = SELECTION
       WHEN (UPPER(OPTION) = 'DFLTGRP') THEN DO
         DFLTGRP = SELECTION
         CALL CHECK_LENGTH DFLTGRP 'DFLTGRP' 8
       END
       OTHERWISE DO
         SAY 'RAKF01I ARGUMENT' CURRENT 'NOT RECOGNIZED'
         EXIT
       END
     END
   END
END

/* ----- OPEN RAKF USER FILE ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
CALL CHECK_RC RC
ADDRESS TSO "EXECIO * DISKR RAKF (STEM SORTIN. OPEN FINIS"
CALL CHECK_RC RC
ADDRESS TSO "FREE FI(RAKF)"
DO I=1 TO SORTIN.0
  PARSE VAR SORTIN.I CURRENT_USER .
  IF CURRENT_USER = UPPER(USERID) THEN DO
    SAY 'RAKF03I RAKF USER' USERID 'ALREADY EXISTS'
    EXIT
  END
END
/* --------  DONE  -------- */
/* -------- GENERATE USER LINE -------- */
RAKF = LEFT(USERID,8)||" "||LEFT(DFLTGRP,8)
IF SPECIAL THEN DO
  RAKF_ADMIN = LEFT(USERID,8)||" RAKFADM "
  IF C2D(LEFT(DFLTGRP,1)) < C2D("R") THEN DO
    RAKF_ADMIN = RAKF_ADMIN||" "||LEFT(PASSWORD,8)||" "
    RAKF = RAKF||"*"||LEFT(PASSWORD,8)||" "
  END
  ELSE DO
    RAKF_ADMIN = RAKF_ADMIN||"*"||LEFT(PASSWORD,8)||" "
    RAKF = RAKF||" "||LEFT(PASSWORD,8)||" "
  END
END
ELSE
  RAKF = RAKF||" "||LEFT(PASSWORD,8)||" "
IF OPER THEN DO
  RAKF = RAKF||"Y"
  IF SPECIAL THEN
    RAKF_ADMIN = RAKF_ADMIN||"Y"
END
ELSE DO
  RAKF = RAKF||"N"
  IF SPECIAL THEN
    RAKF_ADMIN = RAKF_ADMIN||"N"
END

IF LENGTH(NAME) > 0 THEN DO
  RAKF = RAKF||"  "||LEFT(NAME,19)
  IF SPECIAL THEN
    RAKF_ADMIN = RAKF_ADMIN||"  "||LEFT(NAME,19)
END
/* ----- ADDING USER */
SORTIN.0 = SORTIN.0 + 1
X = SORTIN.0
SORTIN.X = RAKF
IF SPECIAL THEN DO
  SORTIN.0 = X + 1
  X = X + 1
  SORTIN.X = RAKF_ADMIN
END
CALL RXSORT
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
CALL CHECK_RC RC
ADDRESS TSO "EXECIO * DISKW RAKF (STEM SORTIN. OPEN FINIS"
CALL CHECK_RC RC
ADDRESS TSO "FREE FI(RAKF)"
/* DONE */
/* ----- UPDATE RAKF ----- */
CALL CONSOLE("S RAKFUSER")
/* ----- DONE        ----- */
EXIT

CHECK_LENGTH:
  PARSE ARG X Y Z
  IF LENGTH(X) > Z THEN DO
    SAY 'RAKF02I' Y 'MUST BE' Z 'CHARACTERS OR SHORTER'
    EXIT
  END
RETURN

CHECK_RC:
  PARSE ARG RCODE
  IF RCODE > 0 THEN DO
    SAY 'RAKF04I UNABLE TO OPEN RAKF USER DATABASE'
    EXIT
  END
RETURN

/* RAKF ALTER USER BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args
/* -------- Default -------- */
OPER=0
NOOPER=0
SPECIAL=0
NAME=''
NEWPASS=''
USERID=''
NOSPECIAL=0
notalreadyspecial = 1
/* --------  DONE  -------- */
if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "ALTUSER USERID"
  say " [PASSWORD(PASSWORD)]"
  say " [OPERATIONS|OPER]"
  say " [NOOPERATIONS|NOOPER]"
  say " [SPECIAL]"
  say " [NOSPECIAL]"
  say " [NAME()|COMMENT()]"
  say ""
  say "USERID IS REQUIRED"
  exit
end
parse upper var args userid args
if pos("(",userid) > 0 then do
    say "RAKF01I First argument must be userid"
    exit
end

if length(args) <= 0 THEN EXIT
call check_length userid 'USERID' 7

/* -------- Parse Arguments -------- */
do while (length(args) > 0)
   parse var args t .
   if pos("(",t) = 0 then
     parse var args current args
   else do
     parse var args o "(" s ")" args
     current = o||"("||s||")"
   end
/* parse var args current args */
   if pos("(",current) = 0 then do
     select
       when upper(current) = 'OPER' then
         OPER = 1
       when upper(current) = 'OPERATIONS' then
         OPER = 1
       when upper(current) = 'SPECIAL' then
         SPECIAL = 1
       when upper(current) = 'NOOPER' then
         NOOPER = 1
       when upper(current) = 'NOOPERATIONS' then
         NOOPER = 1
       when upper(current) = 'NOSPECIAL' then
         NOSPECIAL = 1
       otherwise do
         say 'RAKF01I Argument' current 'not recognized'
         exit
       end
     end
   else do
     parse var current option "(" selection ")"
     select
       when (upper(option) = 'PASSWORD') then do
         NEWPASS = selection
         call check_length NEWPASS 'PASSWORD' 8
       end
       when (upper(option) = 'NAME') then
         NAME = selection
       when (upper(option) = 'COMMENT') then
         NAME = selection
       otherwise do
         say 'RAKF01I Argument' current 'not recognized'
         exit
       end
     end
   end
end

IF NOSPECIAL THEN SPECIAL = 0
IF NOOPER THEN OPER=0
/* ----- Open RAKF User file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM userdb. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"

do i=1 to userdb.0
  parse var userdb.i current_user .
  if current_user = upper(USERID) then do
     leave
  end
end

if i > userdb.0 then do
  say "RAKF02I Userid" USERID "does not exist"
  exit
end

newuserdb.0 = 0
j = 0
olduser.0 = 0
k = 0
do i=1 to userdb.0
  parse var userdb.i current_user .
  if current_user \= upper(USERID) then do
    j = j + 1
    newuserdb.j = userdb.i
  end
  else do
    k = k + 1
    olduser.k = userdb.i
  end
end
newuserdb.0 = j
olduser.0 = k
/* --------  DONE  -------- */
/* -------- Make needed changes ----- */
changeuser.0 = 0
c = 0
do i=1 to olduser.0
  GROUP = strip(substr(olduser.i,10,8))
  PASSWORD = strip(substr(olduser.i,19,8))
  COMMENT = strip(substr(olduser.i,31,20))
  OPS = strip(substr(olduser.i,28,1))

  IF GROUP = 'RAKFADM' & NOSPECIAL THEN ITERATE
  IF GROUP = 'RAKFADM' THEN notalreadyspecial = 0
  IF LENGTH(NEWPASS) > 0 THEN PASSWORD = NEWPASS
  IF LENGTH(NAME) > 0 THEN COMMENT = NAME
  IF OPER THEN OPS = 'Y'
  IF NOOPER THEN OPS = 'N'

  rakf = LEFT(USERID,8)||" "||LEFT(GROUP,8)||"*"||LEFT(PASSWORD,8)||,
         " "||OPS||"  "||LEFT(COMMENT,20)
  c = c + 1
  changeuser.c = rakf
end

changeuser.0 = c

if SPECIAL & notalreadyspecial then do
  c = c + 1
  rakf = LEFT(USERID,8)||" RAKFADM *"||LEFT(PASSWORD,8)||,
         " "||OPS||"  "||LEFT(COMMENT,20)
  changeuser.c = rakf
  changeuser.0 = c
end

sortin.0=0
j=0
do i=1 to newuserdb.0
 j = j + 1
 sortin.j = newuserdb.i
end
do i=1 to changeuser.0
 j = j + 1
 sortin.j = changeuser.i
end
sortin.0=j

call rxsort
/* ----- DONE ----- */
/* ----- Update the RAKF database ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKW RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
/* ----- DONE ----- */
/* ----- Update RAKF ----- */
call console("s rakfuser")
/* ----- DONE        ----- */
exit

check_length:
  parse arg x y z
  if length(x) > z then do
    say 'RAKF02I' y 'must be' z 'characters or shorter'
    exit
  end
return

check_rc:
  parse arg rcode
  if rcode > 0 then do
    say 'RAKF04I Unable to open RAKF user database'
    exit
  end
return
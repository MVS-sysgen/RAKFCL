/* RAKF ADD USER BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args
/* -------- Default -------- */
DFLTGRP = 'USER'
OPER=0
SPECIAL=0
NAME=''
PASSWORD='PASSWORD'
USERID=''
/* --------  DONE  -------- */
if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "ADDUSER USERID"
  say " [PASSWORD(PASSWORD)] Default: PASSWORD"
  say " [DFLTGRP(USER)]      Default: USER"
  say " [OPERATIONS|OPER]    Default: NO OPERATIONS"
  say " [SPECIAL]            Default: NO SPECIAL"
  say " [NAME()]             Default: Blank"
  say "USERID IS REQUIRED"
  exit
end
parse upper var args userid args
if pos("(",userid) > 0 then do
    say "RAKF01I First argument must be userid"
    exit
end
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
       otherwise do
         say 'RAKF01I Argument' current 'not recognized'
         exit
       end
     end
   else do
     parse var current option "(" selection ")"
     select
       when (upper(option) = 'PASSWORD') then do
         password = selection
         call check_length PASSWORD 'PASSWORD' 8
       end
       when (upper(option) = 'NAME') then
         NAME = selection
       when (upper(option) = 'COMMENT') then
         NAME = selection
       when (upper(option) = 'DFLTGRP') then do
         DFLTGRP = selection
         call check_length DFLTGRP 'DFLTGRP' 8
       end
       otherwise do
         say 'RAKF01I Argument' current 'not recognized'
         exit
       end
     end
   end
end

/* ----- Open RAKF User file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
do i=1 to sortin.0
  parse var sortin.i current_user .
  if current_user = upper(USERID) then do
    say 'RAKF03I RAKF user' USERID 'already exists'
    exit
  end
end
/* --------  DONE  -------- */
/* -------- Generate user line -------- */
rakf = LEFT(USERID,8)||" "||LEFT(DFLTGRP,8)
if special then do
  rakf_admin = LEFT(USERID,8)||" RAKFADM "
  if c2d(left(DFLTGRP,1)) < c2d("R") then do
    rakf_admin = rakf_admin||" "||LEFT(PASSWORD,8)||" "
    rakf = rakf||"*"||LEFT(PASSWORD,8)||" "
  end
  else do
    rakf_admin = rakf_admin||"*"||LEFT(PASSWORD,8)||" "
    rakf = rakf||" "||LEFT(PASSWORD,8)||" "
  end
end
else
  rakf = rakf||" "||LEFT(PASSWORD,8)||" "
if oper then do
  rakf = rakf||"Y"
  if special then
    rakf_admin = rakf_admin||"Y"
end
else do
  rakf = rakf||"N"
  if special then
    rakf_admin = rakf_admin||"N"
end

if length(name) > 0 then do
  rakf = rakf||"  "||LEFT(name,19)
  if special then
    rakf_admin = rakf_admin||"  "||LEFT(name,19)
end
/* ----- Adding user */
sortin.0 = sortin.0 + 1
x = sortin.0
sortin.x = rakf
if special then do
  sortin.0 = x + 1
  x = x + 1
  sortin.x = rakf_admin
end
call rxsort
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKW RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
/* Done */
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

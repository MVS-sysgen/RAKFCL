/* RAKF ADD GROUP BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args
/* -------- Default -------- */
GROUPOWNER = userid()

/* --------  DONE  -------- */
if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "ADDGROUP GROUPNAME"
  say " [OWNER(USERID)] Default: " || userid()
  say "GROUPNAME IS REQUIRED"
  exit
end
parse upper var args groupname args
if pos("(",userid) > 0 then do
    say "RAKF01E First argument must be group name"
    exit
end
call check_length groupname 'group' 8
/* -------- Parse Arguments -------- */
do while (length(args) > 0)
   parse var args t .
      if pos("(",t) = 0 then do
         say 'RAKF01E Argument' t 'not recognized'
         exit
      end
      else do
        parse var args o "(" s ")" args
        current = o||"("||s||")"
      end
/* parse var args current args */
     parse var current option "(" selection ")"
     select
       when (upper(option) = 'OWNER') then do
         GROUPOWNER = selection
         call check_length GROUPOWNER 'groupowner' 7
       end
       otherwise do
         say 'RAKF01E Argument' current 'not recognized'
         exit
       end
     end
   
end

/* ----- Open RAKF User file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
notfound = 1
do i=1 to sortin.0
  PARSE VAR sortin.i 1 ruser 10 GROUP 18 DFLT 19 PASSWORD_ADMIN_COMMENT

  if strip(ruser) = upper(GROUPOWNER) then do
    notfound = 0
    owner_pass = PASSWORD_ADMIN_COMMENT
  end
  if strip(ruser) = upper(GROUPOWNER) & strip(group) = groupname then do
    say "RAKF02E Group" groupname "already exists."
    say "        Use RX CONNECT '"||GROUPOWNER||" GROUP("||groupname||")'"
    exit
  end
  if strip(group) = groupname then do
    say "RAKF02E Group" groupname "already exists"
    exit
  end
end

if notfound then do
    say "RAKF02E Owner" GROUPOWNER "not found in user database."
    say "        User must already exist before assigning group to it."
    say "        Use RX ADDUSER " GROUPOWNER "to add the user."
    exit
end

rakf = LEFT(GROUPOWNER,8)||" "||LEFT(groupname,8)||" "||owner_pass

/* --------  DONE  -------- */

/* ----- Adding Group */
sortin.0 = sortin.0 + 1
x = sortin.0
sortin.x = rakf

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

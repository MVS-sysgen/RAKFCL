/* RAKF CONNECT USER TO GROUP BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args
/* --------  DONE  -------- */
if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "CONNECT USERNAME GROUP(GROUPNAME)"
  say "USERNAME AND GROUP IS REQUIRED"
  exit
end
parse upper var args USERNAME args
if pos("(",userid) > 0 then do
    say "RAKF01E First argument must be user name"
    exit
end
call check_length USERNAME 'username' 7
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
     parse var current option "(" selection ")"
     select
       when (upper(option) = 'GROUP') then do
         GROUPNAME = selection
         call check_length GROUPNAME 'GROUP' 8
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

notfound_user = 1
notfound_group = 1
do i=1 to sortin.0
  PARSE VAR sortin.i 1 ruser 10 GROUP 18 DFLT 19 PASSWORD_ADMIN_COMMENT

  if strip(group) = GROUPNAME then do
    notfound_group = 0
  end

  if strip(ruser) = upper(USERNAME) then do
    notfound_user = 0
    owner_pass = PASSWORD_ADMIN_COMMENT
  end
  if strip(ruser) = upper(USERNAME) & strip(group) = GROUPNAME then do
    say "RAKF02E Group" groupname "already exists for" USERNAME
    exit
  end
end

if notfound_user then do
    say "RAKF02E User" USERNAME "not found in user database."
    say "        User must already exist before assigning group to it."
    say "        Use RX ADDUSER " USERNAME "to add the user."
    exit
end

if notfound_group then do
    say "RAKF02E Group" GROUPNAME "not found in user database."
    say "        Group must already exist before connecting a user to it."
    say "        Use RX ADDGROUP '"||GROUPNAME||"'to add the group."
    exit
end

rakf = LEFT(USERNAME,8)||" "||LEFT(GROUPNAME,8)||" "||owner_pass

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

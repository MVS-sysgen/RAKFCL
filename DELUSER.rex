/* Open the RAKF db */
parse arg userid .

if length(userid) = 0 then do
  say 'RAKF01I Missing userid'
  exit
end

ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM userdb. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
newuserdb.0 = 0
c = 0
found = 0
DO i=1 to userdb.0
 parse var userdb.i user .
 if upper(user) = upper(userid) then do
    found = 1
    iterate
 end
 c = c + 1
 newuserdb.c = userdb.i
end
newuserdb.0 = c

if found = 0 then do
    say "RAKF01I Userid" upper(userid) "not found"
    exit
end

ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKW RAKF (STEM newuserdb. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
exit

/* ----- Update RAKF ----- */
call console("s rakfuser")
/* ----- DONE        ----- */

check_rc:
  parse arg rcode
  if rcode > 0 then do
    say 'RAKF04I Unsable to open RAKF user database'
    exit
  end
return
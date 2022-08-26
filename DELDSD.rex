/* RAKF DELDSD: DELETE DATASET PROFILE BREXX SCRIPT */
/* THIS IS ALSO THE ALIAS FOR ALTDSD */
/* GET ARGUMENTS */
parse arg profile .

if length(profile) = 0 then do
  say 'RAKF01I Missing dataset profile to remove'
  exit
end

ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(PROFILES)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM classes. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"


newprofile.0 = 0
c = 0
found = 0
DO i=1 to classes.0
 parse var classes.i FACILITY prof .
 if upper(prof) = upper(profile) then do
    found = 1
    iterate
 end
 c = c + 1
 newprofile.c = classes.i
end
newprofile.0 = c

if found = 0 then do
    say "RAKF01I Dataset Profile" upper(profile) "not found"
    exit
end

ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(PROFILES)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKW RAKF (STEM newprofile. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
exit

/* ----- Update RAKF ----- */
call console("s rakfprof")
/* ----- DONE        ----- */

check_rc:
  parse arg rcode
  if rcode > 0 then do
    say 'RAKF04I Unable to open RAKF profile database'
    exit
  end
return
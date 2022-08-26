/* RAKF RDELETE: DELETE A RAKF PROFILE BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args


if length(args) = 0 then do
    say "RAKF01I Insufficient arguments"
    call usage
end

parse upper var args class profile args

if length(profile) = 0 then do
    say "RAKF01I Insufficient arguments"
    call usage
end

if length(args) > 0 then do
    say "RAKF05E Invalid argument:" args
    exit
end

/* ----- Open RAKF profile file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(PROFILES)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"

newprofile.0 = 0
c = 0
notfound = 1
do i = 1 to sortin.0
  parse var sortin.i 1 rclass 9 rprofile 53 rgroup 61 raccess
  if (strip(rclass) = class) & (strip(rprofile) = profile) then do
    notfound = 0
    ITERATE
  end
  c = c + 1
  newprofile.c = sortin.i
end

if notfound then do
  say 'RAKF04E Class' class 'and profile' profile 'not found'
  exit
end

newprofile.0 = c

do i = 1 to c
  sortin.i = newprofile.i
end

sortin.0 = newprofile.0

call rxsort

/* Add changes to PROFILES */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(PROFILES)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKW RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
/* Done */
/* ----- Update RAKF ----- */
call console("s rakfprof")
/* ----- DONE  ----- */
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
    say 'RAKF04I Unable to open RAKF profile database'
    exit
  end
return

usage:
  say ""
  say "RDELETE CLASS PROFILE-NAME"
  say "CLASS AND PROFILE IS REQUIRED"
  say "EXAMPLE: RX RDELETE 'FACILITY SVC244'"
  exit
return
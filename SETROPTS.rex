/* RAKF SETROPTS BREXX SCRIPT */
/* Replicates some SETROPTS functionality */
/* GET ARGUMENTS */
parse arg args
/* -------- Default -------- */
DEFAULT = 'LIST'
CLASSES = ''
/* --------  DONE  -------- */
if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "SETROPTS LIST"
  exit
end

if args \= "LIST" then do
    say 'RAKF01I Argument' args 'not recognized'
    exit
end

/* ----- Open RAKF PROFILE file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(PROFILES)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM profiles. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
do i=1 to profiles.0
    class = strip(left(profiles.i,8))
    if pos(class, classes) = 0 then do
        classes = classes || " " || class
    end
end

say "ACTIVE CLASSES = " || classes

exit

check_rc:
  parse arg rcode
  if rcode > 0 then do
    say 'RAKF04I Unable to open RAKF user database'
    exit
  end
return
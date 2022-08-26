/* RAKF RDELETE: DELETE A RAKF PROFILE BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args

all = 0

if length(args) > 0 then do
    say "RAKF05E Invalid argument:" args
    call usage
end


/* ----- Open RAKF profile file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.PROCLIB(RAKF)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM RAKFJCL. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"   

say 'RAKF DATABASE STATUS:'
say "DATABASE VOLUME DATASET(MEMBER)"
say "-------- ------ ---------------"
do i = 1 to RAKFJCL.0
    parse var RAKFJCL.i "//" JCL DD "DSN=" DSN "(" MEM ")" .
    if JCL = RAKFPROF then do 
        x = LISTDSI("'"||DSN||"'")
        SAY "PROFILES" SYSVOLUME DSN||"("||MEM||")"
    end
    if JCL = RAKFUSER then do
        say "USERS   " SYSVOLUME DSN||"("||MEM||")"
    end
end
say "RVARY COMMAND HAS FINISHED PROCESSING."
/* ----- DONE  ----- */
exit

check_rc:
  parse arg rcode
  if rcode > 0 then do
    say 'RAKF04I Unable to open RAKF profile database'
    exit
  end
return

usage:
  say ""
  say "RVARY Takes no arguments"
  say "EXAMPLE: RX RVARY"
  exit
return
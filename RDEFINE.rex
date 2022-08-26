/* RAKF RDEFINE: ADD CLASS AND PROFILE BREXX SCRIPT */
/* THIS IS ALSO THE ALIAS FOR RALTER */
/* GET ARGUMENTS */
parse arg args
/* -------- Default -------- */
DFLTUACC = 'NONE'
UACC = ''
ACCESS = "NONE READ UPDATE ALTER"
/* --------  DONE  -------- */

if length(args) = 0 then do
    say "RAKF01I Insufficient arguments"
    call usage
end


parse upper var args class args
if pos("UACC",rules) > 0 then do
    say "RAKF01E First argument must be a class"
    call usage
    exit
end

parse upper var args profile args
if pos("UACC",rules) > 0 then do
    say "RAKF01E Second argument must be a profile name"
    call usage
    exit
end

if length(profile) = 0 then do
    say "RAKF01I Insufficient arguments"
    call usage
end

/* -------- Parse Arguments -------- */
if length(args) > 0 then do
    parse var args arguacc args
    if pos("UACC",arguacc) > 0 then do
        parse var arguacc . "(" UACC ")" .
        if UACC = '' then do
            say "RAKF03E Invalid UACC syntax:" arguacc
            exit
        end
        if wordpos(UACC,ACCESS) = 0 then do
            say "RAKF03E Invalid UACC access type. Must be one of"
            say "        NONE READ UPDATE ALTER"
            say "        Type provided:" UACC
            exit
        end
    end
    else do
     say "RAFK05E Invalid argument" arguacc
     exit
    end
end

if length(args) > 0 then do
    say "RAKF05E Invalid argument:" args
    exit
end

if UACC = '' then UACC = DFLTUACC

/* ----- Open RAKF profile file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(PROFILES)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"

/* ----- Does the rule already exist? ----- */
unchanged = 1
do i=1 to sortin.0
  parse var sortin.i 1 rclass 9 rprofile 53 rgroup 61 rUACC
  if (strip(rclass) = class) &,
     (length(strip(rgroup)) = 0) &,
     (strip(rprofile) = profile) then do
    if (strip(rUACC) = UACC) then do
        say 'RAKF04E RAKF' class 'profile' profile "already exists"
        exit 
    end
    else do
/* Are we just changing the UACC? Yes we allow that, unlike other corps */
        sortin.i = LEFT(class,8) || LEFT(profile,52)||LEFT(UACC,6)
        unchanged = 0
    end
  end
end
/* -------- Generate profile line -------- */


/* ----- Adding profiles */
if unchanged then do 
    c = sortin.0 + 1
    sortin.c = LEFT(class,8) || LEFT(profile,52)||LEFT(UACC,6)  
    sortin.0 = c
end

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
  say "RDEFINE CLASS PROFILE-NAME"
  say " [UACC(READ)] Default: NONE"
  say "CLASS AND PROFILE IS REQUIRED"
  say "EXAMPLE: RX RDEFINE 'FACILITY SVC244'"
  say "EXAMPLE: RX RDEFINE 'FACILITY NONQAUTH UACC(READ)'"
  exit
return
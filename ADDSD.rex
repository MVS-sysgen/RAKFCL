/* RAKF ADDSD: ADD DATASET PROFILE BREXX SCRIPT */
/* THIS IS ALSO THE ALIAS FOR ALTDSD */
/* GET ARGUMENTS */
parse arg args
/* -------- Default -------- */
DFLTUACC = 'NONE'
UACC = ''
DFLTCLASS = 'DATASET'
/* --------  DONE  -------- */
if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "ADDSD PROFILE-NAME"
  say " [UACC(READ)] Default: NONE"
  say "DATASET PROFILE IS REQUIRED"
  say "EXAMPLE: RX ADDSD 'SYSGEN.ISPF.* UACC(READ)'"
  say "EXAMPLE: RX ADDSD '(SYS3.**,SYS4.MACLIB) UACC(NONE)'"
  exit
end
parse upper var args rules args
if pos("UACC",rules) > 0 then do
    say "RAKF01E First argument must be dataset profile(s) e.g. 'SYS2.*'"
    exit
end

/* -------- Parse profiles -------- */
if pos("(", rules) > 0 then do
    if pos(")", rules) = 0 then do
        say "RAKF02E No spaces allows in profiles:" rules
        exit
    end
    parse var rules "(" rule ")"
    count = 0
    do while (length(rule) > 0)
        parse var rule r "," rule
        count = count + 1
        profiles.count = r
    end
    profiles.0 = count
end
else do
    profiles.0 = 1
    profiles.1 = rules 
end

do i=1 to profiles.0
    call check_length profiles.i DATASET 44
end


/* -------- Parse Arguments -------- */
if length(args) > 0 then do
    parse upper var args arguacc args
    if pos("UACC",arguacc) > 0 then do
        parse var arguacc . "(" UACC ")" .
        if UACC = '' then do
            say "RAKF03E Invalid UACC syntax:" arguacc
            exit
        end
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
do i=1 to sortin.0
  parse var sortin.i class resource PUACC NOTUACC
  if class = 'DATASET' & length(NOTUACC) = 0 then do
    do j = 1 to profiles.0
        if profiles.j = resource & UACC = PUACC then do
            /* this means the rule exists with the same UACC */
            say 'RAKF04I RAKF Dataset profile' profiles.j "already exists"
            exit 
        end
    end
  end
end
/* -------- Generate profile line -------- */
/* Are we just changing the UACC? Yes we allow that, unlike other corps */
count = 0
do i=1 to sortin.0
    parse var sortin.i class resource PUACC NOTUACC
    if class = 'DATASET' & length(NOTUACC) = 0 then do
        do j = 1 to profiles.0
            if profiles.j = resource then do
                PROF = LEFT(DFLTCLASS,8) || LEFT(profiles.j,52)||LEFT(UACC,6)
                sortin.i = PROF
            end
            else do
                notfound = 1
                do x = 1 to newprof.0
                    if newprof.x = profiles.j then do
                        notfound = 0
                    end
                end
                if notfound then do
                    count = count + 1
                    newprof.count = profiles.j
                end
            end
        end
        newprof.0 = count
    end
end


/* ----- Adding profiles */
start = sortin.0
do i = 1 to newprof.0
    start = start + 1
    PROF = LEFT(DFLTCLASS,8) || LEFT(newprof.i,52)||LEFT(UACC,6)
    sortin.start = PROF
end

sortin.0 = sortin.0 + newprof.0

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

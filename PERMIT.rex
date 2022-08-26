/* RAKF PERMIT BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args
/* -------- Default -------- */
DFLTUACC = 'NONE'
UACC = ''
CLASS = 'DATASET'
DFLTACCESS = 'READ'
IDS.0 = 0
DELETE = 0
ACCESS = 0
ACCESSR = "NONE READ UPDATE ALTER"
/* --------  DONE  -------- */
if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "PERMIT PROFILE-NAME"
  say " ID(USERNAME) Supports multiple users/groups"
  say " [CLASS(FACILITY)] Default: DATASET"
  say " [ACCESS(UPDATE)] Default: READ"
  say "DATASET PROFILE IS REQUIRED"
  say "EXAMPLE: RX PERMIT 'SYSGEN.ISPF.* ID(PHIL,ADMIN) ACCESS(ALTER)'"
  say "EXAMPLE: RX PERMIT 'ISPF.* ID(PHIL)'"
  say "EXAMPLE: RX PERMIT 'DIAG8CMD CLASS(FACILITY)"||,
      " ID(ADMIN,STCGROUP) ACCESS(READ)'"
  exit
end

parse upper var args profile args
if pos("(",userid) > 0 then do
    say "RAKF01I First argument must be profile-name"
    exit
end

/* -------- Parse Arguments -------- */
do while (length(args) > 0)
   parse var args t .
      if pos("(",t) = 0 then
        parse var args current args
      else do
        parse var args o "(" s ")" args
        current = o||"("||s||")"
      end
   if pos("(",current) = 0 then do    
    select
      when current = 'DELETE' then do
          DELETE = 1
      end
      otherwise do 
        say "RAKF01E Argument not understood:" current
        exit 
      end
    end
   end
   else do
     parse var current option "(" selection ")"
     select
       when (upper(option) = 'CLASS') then CLASS = selection
       when (upper(option) = 'ID') then do
         do while length(selection) > 0
           parse var selection id "," selection
           ids.0 = ids.0 + 1
           c = ids.0
           ids.c = id
         end
       end
       when (upper(option) = 'ACCESS') then do
        ACCESS = selection
        if wordpos(ACCESS, ACCESSR) = 0 then do
            say "RAKF03E Access right" ACCESS "not recognized"
            say "        Must be one of: NONE, READ, UPDATE, ALTER"
            exit
        end
       end
       otherwise do
         say 'RAKF01I Argument' current 'not recognized'
         exit
       end
     end
   end
end

if ACCESS \= 0 & DELETE then do
    say "RAKF02E Arguments ACCESS and DELETE cannot be specified"
    say "        on same command"
    exit
end

if ids.0 = 0 then do
  say 'RAFK02E ID() argument is required'
  exit
end

/* ----- Done parsing options ----- */

if ACCESS = 0 then ACCESS = DFLTACCESS
if DELETE then ACCESS = 'DELETE'


/* ----- Open RAKF profile file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(PROFILES)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"


/* ----- Check to make sure the class and other stuff is good */
notfound_class = 1
notfound_resource = 1
changed = ''
do i = 1 to sortin.0
  parse var sortin.i 1 rclass 9 rresource 53 rgroup 61 raccess
  /* if the class doesnt exist we need to exit */
  if strip(rclass) = class then do
    notfound_class = 0
    if strip(rresource) = profile then do
      notfound_resource = 0
      do c = 1 to ids.0
        if strip(rgroup) = ids.c then do
        /* If the exact rule already exists error out */
          if strip(raccess) = access then do
            say "RAKF04E Access right already exists"
            say "          Class:" class
            say "        Profile:" profile
            say "             ID:" ids.c
            say "         Access:" access
            exit
          end
          else do
            /* We change the rule */
            rule = LEFT(class,8) || LEFT(profile,44)||LEFT(ids.c,8)||access
            sortin.i = rule
            changed = changed || " " ids.c
          end
        end
      end
    end
  end
end

if notfound_class then do
  say 'RAKF03E Class' CLASS 'does not exist use RDEFINE to add a new class'
  exit
end

if notfound_resource then do
  say 'RAKF03E Resource' profile 'does not exist in the' class 'class'
  say '        use RDEFINE to add it'
  exit
end

/* ----- Deleting or Adding profiles */

if DELETE then do
  newprofile.0 = 0
  c = 0
  do i = 1 to sortin.0
    parse var sortin.i 1 rclass 9 rresource 53 rgroup 61 raccess
    if (strip(rclass) = class) & (strip(rresource) = profile) then do
      id = 0
      do j = 1 to ids.0
        if strip(rgroup) = ids.j then id = 1
      end
      if id then ITERATE
    end
    c = c + 1
    newprofile.c = sortin.i
  end
  newprofile.0 = c
  do i = 1 to c
    sortin.i = newprofile.i
  end
  sortin.0 = newprofile.0

end
else do
  start = sortin.0
  do i = 1 to ids.0
    /* If this a new rule, not a rule change then make the new rule */
    if wordpos(ids.i,changed) = 0 then do
      start = start + 1
      PROF = LEFT(class,8) || LEFT(profile,44)||LEFT(ids.i,8)||access
      sortin.start = PROF
    end
  end
  sortin.0 = start
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

/* RAKF REMOVE USER FROM GROUP BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args
/* --------  DONE  -------- */
if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "REMOVE USERNAME GROUP(GROUPNAME)"
  say "USERNAME AND GROUP IS REQUIRED"
  exit
end
parse upper var args USERNAME args
if pos("(",userid) > 0 then do
    say "RAKF01E First argument must be user name"
    exit
end
call check_length USERNAME 'username' 7

if length(args) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "REMOVE USERNAME GROUP(GROUPNAME)"
  say "USERNAME AND GROUP IS REQUIRED"
  exit
end

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
newprofile.0 = 0
c = 0
do i=1 to sortin.0
  PARSE VAR sortin.i 1 ruser 10 GROUP 18 .

  if strip(ruser) = upper(USERNAME) then do
    notfound_user = 0
  end
  if strip(ruser) = upper(USERNAME) & strip(group) = GROUPNAME then do
    notfound_group = 0
    ITERATE
  end
  c = c + 1
  newprofile.c = sortin.i
end

if notfound_user then do
    say "RAKF02E User" USERNAME "not found in user database."
    exit
end

if notfound_group then do
    say "RAKF02E User" USERNAME "not connected to" GROUPNAME
    exit
end

newprofile.0 = c

do i = 1 to c
  sortin.i = newprofile.i
end

sortin.0 = newprofile.0

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

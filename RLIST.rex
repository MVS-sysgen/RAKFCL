/* RAKF RLIST: LIST RAKF RESOURCES BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg args

all = 0

if length(args) = 0 then do
    all = 1
end

parse upper var args class profile args

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
notfound_class = 1
notfound_profile = 1
do i = 1 to sortin.0
  parse var sortin.i 1 rclass 9 rprofile 53 rgroup 61 raccess
  if length(strip(rgroup)) = 0 then do
    if all then do 
      call print_profile rclass rprofile raccess
      notfound_class = 0
      notfound_profile = 0
    end
    if (strip(rclass) = class) then do 
      notfound_class = 0
      if length(profile) = 0  then do
        notfound_profile = 0
        call print_profile rclass rprofile raccess
      end
      if strip(rprofile) = profile then do
        call print_profile class profile raccess
        notfound_profile = 0
      end
    end
  end
end

if notfound_class then do
  say 'RAKF04E Class' class 'not found'
  exit
end

if notfound_profile then do
  say 'RAKF04E profile' profile 'in class' class 'not found'
  exit
end


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

print_profile:
    parse arg prt_class prt_profile puacc
    say "CLASS=  " prt_class
    say "PROFILE=" prt_profile
    say "UACC=   " puacc
    groups.0 = 0
    count = 0
    do c = 1 to sortin.0
        parse var sortin.c 1 pclass 9 pprofile 53 pgroup 61 paccess
        if strip(pclass) = strip(prt_class) &,
           strip(pprofile) = strip(prt_profile) &,
           length(strip(pgroup)) > 0 then do
            count = count + 1
            groups.count = left(pgroup,8) paccess
        end
    end
    groups.0 = count
    if groups.0 > 0 then do
      say "" LEFT("GROUP(S)=",9) "ACCESS"
      do x = 1 to groups.0
        say " " groups.x
      end
    end
    say ""
return

usage:
  say ""
  say "RLIST CLASS PROFILE-NAME"
  say "EXAMPLE: RX RLIST 'FACILITY'"
  say "EXAMPLE: RX RLIST 'FACILITY SVC244'"
  exit
return
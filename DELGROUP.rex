/* DELETE A RAKF GROUP */
/* Open the RAKF db */
parse arg group .

if length(group) = 0 then do
  say "RAKF01I Insufficient arguments"
  say ""
  say "DELGROUP GROUPNAME"
  say "GROUPNAME IS REQUIRED"
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
 PARSE VAR userdb.i 1 rUSER 10 rGROUP 18 .
 if strip(rGROUP) = upper(group) then do
    /* Make sure this isn't the only group */
    user_count = 0
    do j = 1 to userdb.0
      parse var userdb.j user .
      if strip(rUSER) = strip(user) then do
        user_count = user_count + 1
      end 
    end

    if user_count = 1 then do
        say "RAKF02E Cannot remove group "group" from user" rUSER
        say "        This user only exists in this one group."
        say "        Either DELUSER or CONNECT to another group"
        say "        before deleting this group"
        exit
    end
    found = 1
    iterate
 end
 c = c + 1
 newuserdb.c = userdb.i
end
newuserdb.0 = c

if found = 0 then do
    say "RAKF01I Group" upper(group) "not found"
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
    say 'RAKF04I Unable to open RAKF user database'
    exit
  end
return
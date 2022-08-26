/* RAKF LIST GROUP(S) BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg groupname .
/* Open the RAKF db */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM userdb. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
groups.0 = 0
gc = 0

call get_groups

if length(groupname) = 0 then do
    do i = 1 to groups.0   
        say "INFORMATION FOR GROUP" groups.i
        call print_users groups.i
    end
end
else do
    group_exists = 0
    do i = 1 to groups.0 
        if groups.i = groupname then group_exists = 1
    end
    if group_exists then do
      say "INFORMATION FOR GROUP" groupname
      call print_users groupname
    end
    else do
        say "RAKF02E Group" groupname "does not exist"
        exit
    end
end
EXIT

get_groups:
  do i = 1 to userdb.0
    PARSE VAR userdb.i 1 . 10 gGROUP 18 .
    /* is this group already in our stem? */
    notfound = 1
    do j = 1 to groups.0 
        if strip(groups.j) = strip(gGROUP) then do
            notfound = 0
        end
    end
    if notfound then do
        groups.0 = groups.0 + 1
        c = groups.0
        groups.c = strip(gGROUP)
    end
  end
return

print_users:
    parse arg group
    say " USER(S)="
    do x = 1 to userdb.0
        PARSE VAR userdb.x 1 user 10 pGROUP 18 .
        if strip(pGROUP) = strip(group) then do
            say " " user
        end
    end
    say ""
return

check_rc:
  parse arg rcode
  if rcode > 0 then do
    say 'RAKF04I Unable to open RAKF user database'
    exit
  end
return

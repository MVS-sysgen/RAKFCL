/* RAKF LIST USER BREXX SCRIPT */
/* GET ARGUMENTS */
parse arg userid .
/* Default to current user */
if length(userid) = 0 then userid = userid()

/* Open the RAKF db */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(USERS)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM userdb. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"

/* If this is a single user */
if userid \= "*" then do
 oper=0
 rakfadm = 0
 line1 = ""
 line1 = line1 || "USER="||LEFT(upper(userid),8)|| " "
 grp = "GROUPS="
 cmnts = "COMMENTS="
 DO i=1 to userdb.0
  USER = strip(substr(userdb.i,1,8))
  GROUP = strip(substr(userdb.i,10,8))
  COMMENT = strip(substr(userdb.i,31,20))
  OPS = strip(substr(userdb.i,28,1))
  if upper(user) = upper(userid) then do
    if group = 'RAKFADM' then rakfadm = 1
    grp = grp|| GROUP||" "
    if OPS="Y" then oper=1
    cmnts=COMMENT
  end
 end
  attr = "ATTRIBUTES="
  if OPER THEN attr = attr||"OPERATIONS "
  if rakfadm then attr = attr||"SPECIAL"
  say line1
  say grp
  say attr
  say "COMMENTS="||cmnts
  say ""
end
else do
  current_user = ""
  grp = ''
  attr= ''
  cmnts=''
  OPER=0
  rakfadm=0
  do i=1 to userdb.0
    USER = strip(substr(userdb.i,1,8))
    GROUP = strip(substr(userdb.i,10,8))
    COMMENT = strip(substr(userdb.i,31,20))
    OPS = strip(substr(userdb.i,28,1))
    if length(current_user) = 0 then current_user = USER
    if current_user \= user then do
     say 'USER='||current_user
     say "GROUPS="||grp
     if OPER THEN attr = attr||"OPERATIONS "
     if rakfadm then attr = attr||"SPECIAL"
     say "ATTRIBUTES="||attr
     say "COMMENTS="||cmnts
     current_user = user
     grp = ''
     attr= ''
     cmnts=''
     OPER=0
     rakfadm=0
     say ''
    end
    grp=grp||GROUP||" "
    cmnts=COMMENT
    if group = 'RAKFADM' then rakfadm = 1
    if OPS="Y" then oper=1
  end
  /* catch the bottom user */
  say 'USER= '||user
  say "GROUPS= "||grp
  if OPER THEN attr = attr||"OPERATIONS "
  if rakfadm then attr = attr||"SPECIAL"
  say "ATTRIBUTES= "||attr
  say "COMMENTS= "||cmnts
  say ''
end
EXIT

check_rc:
  parse arg rcode
  if rcode > 0 then do
    say 'RAKF04I Unable to open RAKF user database'
    exit
  end
return

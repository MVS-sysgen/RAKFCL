/* RAKF LISTDSD: LIST DATASET PROFILE BREXX SCRIPT */
/* THIS IS ALSO THE ALIAS FOR ALTDSD */
/* GET ARGUMENTS */
parse arg args
/* -------- Default -------- */
DFLTUACC = 'NONE'
UACC = ''
FACILITY = 'DATASET'
/* --------  DONE  -------- */
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
       when (upper(option) = 'DATASET') then do
         DATASET = selection
       end
       otherwise do
         say 'RAKF01E Argument' current 'not recognized'
         exit
       end
     end
end


/* ----- Open RAKF profile file ----- */
ADDRESS TSO "ALLOC FI(RAKF) DA('SYS1.SECURE.CNTL(PROFILES)') SHR REUSE"
call check_rc rc
ADDRESS TSO "EXECIO * DISKR RAKF (STEM sortin. OPEN FINIS"
call check_rc rc
ADDRESS TSO "FREE FI(RAKF)"
call rxsort

/* ----- Show the rules ----- */
do i=1 to sortin.0
  parse var sortin.i 1 class 9 resource 53 group 61 access
  if strip(class) = 'DATASET' & length(strip(group)) = 0 then do
    call print_access
  end
end

exit

print_access:
  say "INFORMATION FOR DATASET" strip(resource)
  groups_count = 0
  do j=1 to sortin.0
      parse var sortin.j 1 gclass 9 gresource 53 ggroup 61 gaccess
      if (strip(gclass) = 'DATASET') & (gresource = resource) &,
      (length(strip(ggroup)) > 0) then do
          say "  GROUP:" left(ggroup,8) "ACCESS: " gaccess
      end
  end
  say "  UNIVERSAL ACCESS:" access
  say ""
return

check_rc:
  parse arg rcode
  if rcode > 0 then do
    say 'RAKF04I Unable to open RAKF profile database'
    exit
  end
return
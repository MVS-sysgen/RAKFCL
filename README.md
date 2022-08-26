# RAKF Command Library

**All these tools require BREXX higher than V2R4M0**

## ADDGROUP

Add a new group to RAKF

**Syntax**:

`RX ADDGROUP 'GROUPNAME" [OWNER(USERID)]`

Any argument in `[]` is optional. Arguments with parentheses `()` expect the value to be in the parentheses. The groupname must be the first argument, the rest can be in any order.

**Defaults**:

| ARGUMENT        | DEFAULT            |
|-----------------|--------------------|
| OWNER           | USERID of the user that submitted the command |

**Examples**:

1) To add the group 'SYSTEM' and assign the owner to IBMUSER: `RX ADDGROUP 'SYSTEM OWNER(IBMUSER)`
2) To add the group 'TESTIN' and assign the owner to your currently logged in user: `RX ADDGROUP 'TESTING'`

## ADDSD

Add a new dataset profile to RAKF

**Syntax**:

`RX ADDSD 'PROFILE-NAME [UACC(READ)]'`

Any argument in `[]` is optional. Arguments with parentheses `()` expect the value to be in the parentheses. The dataset profile must be the first argument, the rest can be in any order.

Mutliple profile names can be given, just surround the profile-name with `()` and seperate them with a comma `,`


**Defaults**:

| ARGUMENT        | DEFAULT            |
|-----------------|--------------------|
| UACC            | NONE               |

**Examples**:


1) Add the dataset profile `SYSGEN.ISPF.*` with a UACC of READ: `RX ADDSD 'SYSGEN.ISPF.* UACC(READ)'`
2) Add two dataset profiles, `SYS3.**` and `SYS4.MACLIB` with a UACC of NONE: `RX ADDSD '(SYS3.**,SYS4.MACLIB)'`

## ADDUSER

Add a new user to RAKF

**Syntax**:

`RX ADDUSER 'USERID [PASSWORD(PASSWORD)] [DFLTGRP(USER)] [OPERATIONS|OPER] [SPECIAL] [NAME()|COMMENT()]'`

Any argument in `[]` is optional. Arguments with parentheses `()` expect the value to be in the parentheses. The user id must be the first argument, the rest can be in any order.

**Defaults**:

| ARGUMENT        | DEFAULT            |
|-----------------|--------------------|
| PASSWORD        | PASSWORD           |
| DFLTGRP         | USER               |
| OPERATIONS/OPER | NOOPERATION/NOOPER |
| SPECIAL         | NOSPECIAL          |
| NAME/COMMENT    | `NONE`             |

**Examples**:

1) To add a user with the userid `MARKS` with a password of `E4#J3KIL`:

```
RX ADDUSER 'MARKS PASSWORD(E4#J3KIL)'
```

Defaults - `DFLTGRP(USER) NOSPECIAL NOOPER`

To add the user DA5ID as a RAKF admin user with privileged access and add their name in the comment field:

```
RX ADDUSER 'DA5ID OPER SPECIAL NAME(DAVID COPPERFIELD)'
```

Defaults - `DFLTGRP(USER) PASSWORD(PASSWORD) `


To add a service account for FTPD in the group FTPD with a password of "CHANGEME":

```
RX ADDUSER 'FTPD DFLTGRP(FTPD) PASSWORD(CHANGEME) COMMENT(FTP SERVICE ACCOUNT)'
```

Defaults - `NOSPECIAL NOOPER`

## ALTUSER

Alter an existing RAKF user

**Syntax**:

`RX ALTUSER 'USERID [PASSWORD(PASSWORD)] [OPERATIONS|OPER|NOPERATIONS|NOOPER] [SPECIAL|NOSPECIAL] [NAME()|COMMENT()]'`

Any argument in `[]` is optional but at least one should be used. Arguments with parentheses `()` expect the value to be in the parentheses. The user id must be the first argument, the rest can be in any order.

**Defaults**:

None

**Examples**:

1) To alter a user with the userid `MARKS` and change their password to `HYD3`:

```
RX ALTUSER 'MARKS PASSWORD(HYD3)'
```


To ALTER the user DA5ID and remove their RAKF admin status and privileged access:

```
RX ADDUSER 'DA5ID NOOPER NOSPECIAL'
```

To add alter the service account for FTPD giving it a stronger password and changing the comment:

```
RX ADDUSER 'FTPD PASSWORD(SECRET21) COMMENT(051521 Changed PW)'
```

## CONNECT

Connect a user to a group

**Syntax**:

`RX CONNECT USERNAME GROUP(GROUPNAME)`

**Defaults**:

None

**Examples**:

1) Connect the user `PHIL` to the group `RAKFADM`: `RX CONNECT 'PHIL GROUP(RAKFADM)'`

## DELDSD

Delete a dataset profile

**Syntax**:

`RX DELDSD PROFILE-NAME`

**Defaults**:

None

**Examples**:

1) Delete the RAKF dataset profile `SYS4.MACLIB`: `RX DELDSD 'SYS4.MACLIB'`

## DELGROUP

Delete a RAKF group

**Syntax**:

`RX DELGROUP GROUPNAME`

**Defaults**:

None

**Examples**:

1) Delete the RAKF group `SYSTEM`: `RX DELGROUP 'SYSTEM'`

## DELUSER

Delete RAKF user

**Syntax**:

`RX DELUSER 'USERID'`

**Defaults**:

None

**Examples**:

1) Delete the user `DA5ID`: `RX DELUSER 'DA5ID'`

## LISTDSD

List RAKF dataset profiles

**Syntax**:

`RX LISTDSD`

**Defaults**:

None

**Examples**:

1) List all RAKF dataset profiles: `LISTDSD`

## LISTGRP

List RAKF group(s) and users connected to groups

**Syntax**:

`RX LISTGRP [GROUPNAME]`

**Defaults**:

If no groupname is provided all groups will be listed

**Examples**:

1) List all RAKF group members: `LISTGRP`
2) List members of the group USERS: `LISTGRP USERS`

## LISTUSER

List RAKF user information

**Syntax**:

`RX LISTUSER '[USERID|*]`

**Defaults**:

Current user id

**Examples**:

List current user attributes:

`RX LISTUSER`

Output:

```
USER=DA5ID    GROUPS=ADMIN RAKFADM
ATTRIBUTES=OPERATIONS SPECIAL
COMMENTS=
```

List a different user attributes:

`RX LISTUSER 'HMVS01'`

Output:

```
USER=HMVS01   GROUPS=ADMIN RAKFADM
ATTRIBUTES=OPERATIONS SPECIAL
COMMENTS=
```

List all users:

`RX LISTUSER '*'`

Output:

```
USER=HMVS01
GROUPS=ADMIN RAKFADM
ATTRIBUTES=OPERATIONS SPECIAL
COMMENTS=

USER=HMVS02
GROUPS=USER
ATTRIBUTES=
COMMENTS=

USER=IBMUSER
GROUPS=ADMIN RAKFADM
ATTRIBUTES=OPERATIONS SPECIAL
COMMENTS=
```

## PERMIT

Gives groups access to resources (classes and profiles)

**Syntax**:

`RX PERMIT PROFILE-NAME ID(GROUP[,GROUP2,...,n]) [CLASS(DATASET)] [ACCESS(READ)]`

**Defaults**:

| ARGUMENT        | DEFAULT            |
|-----------------|--------------------|
| CLASS           | DATASET            |
| ACCESS          | READ               |

**Examples**:

1) Permit the groups `ADMIN` and `USERS` to have read access to the BRXAUTH profile in the FACILITY class: `RX PERMIT 'BRXAUTH ID(ADMIN,USERS) CLASS(FACILITY) ACCESS(READ)`
2) Give the group `USERS` alter access to the dataset `SYS4.MACLIB`: `RX PERMIT 'SYS4.MACLIB ID(USERS) ACCESS(ALTER)'`

## RDEFINE

Define a new CLASS and a resource within that class

**Syntax**:

`RX RDEFINE 'CLASS PROFILE-NAME [UACC(NONE)]'`

**Defaults**:


| ARGUMENT        | DEFAULT            |
|-----------------|--------------------|
| UACC            | NONE               |

**Examples**:

1) Define the resource `SVC244` in the FACILITY class, UACC of NONE: `RX RDEFINE 'FACILITY SVC244'`
2) Define the resource `NONQAUTH` in the FACILITY class with a UACC of READ: `RX RDEFINE 'FACILITY NONQAUTH UACC(READ)'`

## RDELETE

Delete a resource from RAKF

**Syntax**:

`RX RDELETE 'CLASS PROFILE-NAME'`

**Defaults**:

None

**Examples**:

1) Delete the resource `SVC244` in the FACILITY class: `RX RDELETE 'FACILITY SVC244'`

## REMOVE

Remove a user from a RAKF group

**Syntax**:

`RX REMOVE 'USERNAME GROUP(GROUPNAME)'`

**Defaults**:

None

**Examples**:

1) Remove the user `PHIL` from the group `USERS`: `RX REMOVE PHIL GROUP(USERS)`

## RLIST

List RAKF resources

**Syntax**:

`RX RLIST [CLASS PROFILE-NAME]`

**Defaults**:

If no class and no profile name is given all resources will be printed.

**Examples**:

1) List all RAKF profiles: `RX RLIST`
2) List the details for the profiles `SVC244` in the FACILITY class: `RX RLIST 'FACILITY SVC244'`


## RVARY

Lists the current status of the RAKF "database"

**Syntax**:

`RX RVARY`

**Defaults**:

None

**Examples**:

1) List the current status and location of the RAKF databases: `RX RVARY`

## SETROPTS

Lists the current status of the RAKF "database"

**Syntax**:

`RX SETROPTS LIST`

**Defaults**:

None

**Examples**:

1) List the current active classes: `RX SETROPTS 'LIST'`

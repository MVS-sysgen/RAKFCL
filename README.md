# RAKF Command Library

**All these tools require BREXX higher than V2R4M0**

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

## DELUSER

Delete RAKF user

**Syntax**:

`RX DELUSER 'USERID'`

**Defaults**:

None

**Examples**:

Delete the user `DA5ID`:

`RX DELUSER 'DA5ID'`

# RAKF Command Library

**All these tools require BREXX higher than R2R4M0**

## ADDUSER

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
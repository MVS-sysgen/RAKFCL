#!/bin/bash

# This creates an inline JCL file to install RAKFCL to SYS2.EXEC

username="IBMUSER"
password="SYS1"

cat << END
//RAKFCL   JOB (TSO),
//             'Install RAKFCL',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),
//             USER=$username,PASSWORD=$password
//*
//* THIS JCL AUTOMATICALLY GENERATED BY make_release.sh
//*
//* Member \$RAKFCL in SYS2.EXEC explains how to use these commands
//*
//* To install to MVS/CE:
//*     In TSO: RX MVP INSTALL RAKFCL
//*     In bash: cat release.jcl|ncat -w1 -v localhost 3505
//*
//RFEPLIB   EXEC PGM=PDSLOAD
//STEPLIB  DD  DSN=SYSC.LINKLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DSN=SYS2.EXEC,DISP=SHR
//SYSUT1   DD  DATA,DLM=@@
END

for i in *.rex; do
    m=${i%.*}
    member=${m##*/}
    echo "./ ADD NAME=$member"
    # We need to convert all the rexx scripts to uppercase
    # otherwise they abend on EXECIO
    # SoF 11-16-23
    cat "$i"| tr "a-z" "A-Z"
    echo ''
done

echo './ ADD NAME=$RAKFCL'
cat README.md


echo "@@"

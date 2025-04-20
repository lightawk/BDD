# dbnewid [-oracle]

Pour modifier le DBID et - ou le nom de la base de donnees (DBNAME).

Pour modifier le DBNAME sans cet utilitaire il faut recreer le fichier de controle.

> Modifier le DBID et le DBNAME.

```
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
${ORACLE_HOME}/bin/nid TARGET=SYS/PWD@DB_1 DBNAME=DB_2 [ LOGFILE=logfile.log APPEND=YES|NO ]
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER SYSTEM SET DB_NAME=DB_2 SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
orapwd file=/u01/oracle/19c/db_1/dbs/initDB_2.ora password=password entries=10
ORACLE_SID=?; export ORACLE_SID
lsnrctl reload
STARTUP MOUNT;
ALTER DATABASE OPEN RESETLOGS;
```

## Modifier uniquement le DBNAME

> Utiliser la clause "SETNAME=YES". Donc pas necessaire d'ouvrir en RESETLOGS.

```
${ORACLE_HOME}/bin/nid TARGET=/ DBNAME=DB SETNAME=YES [ LOGFILE=logfile.log APPEND=YES|NO ]
```

## Modifier uniquement le DBID

> Ne pas specifier de DBNAME.

```
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
${ORACLE_HOME}/bin/nid TARGET=SYS/PWD@DB [ LOGFILE=logfile.log APPEND=YES|NO ]
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE OPEN RESETLOGS;
```

## Options

```
- TARGET  : Chaine de connexion a la base
- DBNAME  : Nouveau nom de la base
- SETNAME : Pour ne changer que le nom de la base sans l'identifiant
- LOGFILE : Nom du fichier log
- APPEND  : Ecrit a la suite de la log
```
# renommage d'une base de donnees [-oracle]

> Renommage d'une base de donnees DB_SOURCE vers DB_CIBLE.

## Arborescence

> Creation des repertoires.

```
for i in 1 2 3 4 5 6 7 8 9; do
mkdir -p /fs_cible/u0$i/oradata/DB_CIBLE
mkdir -p /fs_cible/u0$i/oradata/DB_CIBLE_PDB
done
```

> Creation des repertoires /flash & /archive.

```
mkdir /fs_cible/u07/oradata/DB_CIBLE/flash
mkdir /fs_cible/u07/oradata/DB_CIBLE/archive
mkdir /fs_cible/u07/oradata/DB_CIBLE_PDB/flash
mkdir /fs_cible/u07/oradata/DB_CIBLE_PDB/archive
```

> Creation des repertoires /adm/admin.

```
mkdir -p /fs_cible/adm/admin/DB_CIBLE/bdump
mkdir -p /fs_cible/adm/admin/DB_CIBLE/cdump
mkdir -p /fs_cible/adm/admin/DB_CIBLE/create
mkdir -p /fs_cible/adm/admin/DB_CIBLE/udump
```

## Generation des commandes de move physique

```
export ORACLE_SID=DB_SOURCE
unset ORACLE_PDB_SID

sqlplus -S -L "/ AS SYSDBA" <<'EOF' > /app/log/fichier_mv_controlfiles.sh 2>&1
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
SELECT 'mv ' || NAME || ' ' || REPLACE (REPLACE (NAME, '/fs_source', '/fs_cible'), 'DB_SOURCE', 'DB_CIBLE') FROM v$controlfile WHERE CON_ID <= 2;
EXIT
EOF

chmod 755 /app/log/fichier_mv_controlfiles.sh
```

```
sqlplus -S -L "/ AS SYSDBA" <<'EOF' > /app/log/fichier_mv_files.sh 2>&1
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
SELECT 'mv ' || MEMBER || ' ' || REPLACE (REPLACE (MEMBER, '/fs_source', '/fs_cible'), 'DB_SOURCE', 'DB_CIBLE') FROM v$logfile WHERE CON_ID <= 2;
SELECT 'mv ' || NAME || ' ' || REPLACE (REPLACE (NAME, '/fs_source', '/fs_cible'), 'DB_SOURCE', 'DB_CIBLE') FROM v$datafile WHERE CON_ID <= 2;
SELECT 'mv ' || NAME || ' ' || REPLACE (REPLACE (NAME, '/fs_source', '/fs_cible'), 'DB_SOURCE_PDB', 'DB_CIBLE_PDB') FROM v$datafile WHERE CON_ID = 3;
EXIT
EOF

chmod 755 /app/log/fichier_mv_files.sh
```

## Generation des commandes de move base

```
sqlplus -S -L "/ AS SYSDBA" <<'EOF' > /app/log/fichier_rename_files.sql 2>&1
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
SELECT 'ALTER DATABASE RENAME FILE '
       || CHR (39)
       || MEMBER
       || CHR (39)
       || ' TO '
       || CHR (39)
       || REPLACE (REPLACE (MEMBER, '/fs_source', '/fs_cible'), 'DB_SOURCE', 'DB_CIBLE')
       || CHR (39)
       || ';'
  FROM v$logfile
WHERE CON_ID <= 2;
SELECT 'ALTER DATABASE RENAME FILE '
       || CHR (39)
       || NAME
       || CHR (39)
       || ' TO '
       || CHR (39)
       || REPLACE (REPLACE (NAME, '/fs_source', '/fs_cible'), 'DB_SOURCE', 'DB_CIBLE')
       || CHR (39)
       || ';'
  FROM v$datafile
WHERE CON_ID <= 2;
SELECT 'ALTER DATABASE RENAME FILE '
       || CHR (39)
       || NAME
       || CHR (39)
       || ' TO '
       || CHR (39)
       || REPLACE (REPLACE (NAME, '/fs_source', '/fs_cible'), 'DB_SOURCE_PDB', 'DB_CIBLE_PDB')
       || CHR (39)
       || ';'
  FROM v$datafile
WHERE CON_ID = 3;
EXIT
EOF
```

## Gestion du tablespace temporaire

```
sqlplus / as sysdba
CREATE TEMPORARY TABLESPACE TEMP_RENAME TEMPFILE '/fs_cible/u09/oradata/DB_CIBLE/temp_DB_CIBLE_01.dbf' SIZE 20M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP_RENAME;
EXIT;
```

```
export ORACLE_PDB_SID=DB_SOURCE_PDB
sqlplus / as sysdba
CREATE TEMPORARY TABLESPACE TEMP_RENAME TEMPFILE '/fs_cible/u09/oradata/DB_CIBLE_PDB/temp_DB_CIBLE_PDB_01.dbf' SIZE 20M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP_RENAME;
EXIT;
```

## Arret & deplacement des fichiers

```
unset ORACLE_PDB_SID
sqlplus / as sysdba
SHUTDOWN IMMEDIATE;
EXIT;
```

```
nohup /app/log/fichier_mv_files.sh &
ps -ef | grep fichier_mv_files.sh
```

## Demarrage & renommage des fichiers

```
sqlplus / as sysdba
STARTUP MOUNT;
@/app/log/fichier_rename_files.sql
EXIT;
```

## Renommage de la base dans les fichiers via nid

```
${ORACLE_HOME}/bin/nid TARGET=/ DBNAME=DB_CIBLE LOGFILE=/app/log/nid_$(date +'%d%m%y')_$(date +'%H%M%S').log APPEND=YES 2>&1
```

```
/app/log/fichier_mv_controlfiles.sh
```

```
export ORACLE_SID=DB_CIBLE
sqlplus / as sysdba
STARTUP MOUNT;
ALTER DATABASE OPEN RESETLOGS;
EXIT;
```

## Renommage de la pluggable

```
export ORACLE_PDB_SID=DB_CIBLE_PDB
sqlplus / as sysdba
ALTER PLUGGABLE DATABASE DB_SOURCE_PDB OPEN RESTRICTED FORCE;
ALTER PLUGGABLE DATABASE DB_SOURCE_PDB RENAME GLOBAL_NAME TO DB_CIBLE_PDB;
ALTER PLUGGABLE DATABASE DB_CIBLE_PDB OPEN FORCE;
ALTER PLUGGABLE DATABASE DB_CIBLE_PDB SAVE STATE;
EXIT;
```

## Bascule sur le tablespace temporaire

```
unset ORACLE_PDB_SID
sqlplus / as sysdba
DROP TABLESPACE TEMP INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
ALTER TABLESPACE TEMP_RENAME RENAME TO TEMP;
EXIT;
```

```
export ORACLE_PDB_SID=DB_CIBLE_PDB
sqlplus / as sysdba
DROP TABLESPACE TEMP INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
ALTER TABLESPACE TEMP_RENAME RENAME TO TEMP;
EXIT;
```

## Purge anciennes archives

```
find /fs_source/u07/oradata/DB_SOURCE/archive/ -type f -name *.arc -exec rm -f {} \;
```
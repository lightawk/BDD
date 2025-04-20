# pluggable [-oracle]

## Creer une base de donnees pluggable

> Creer la base pluggable dans le <u>conteneur</u>.

```
unset ORACLE_PDB_SID
sqlplus / as sysdba
CREATE PLUGGABLE DATABASE DB ADMIN USER pdb_adm IDENTIFIED BY pdb_adm
FILE_NAME_CONVERT=('/filesystem/u01/oradata/DBC/system_SEED_01.dbf', '/filesystem/u01/oradata/DB/system_DB_01.dbf',
                   '/filesystem/u02/oradata/DBC/sysaux_SEED_01.dbf', '/filesystem/u02/oradata/DB/sysaux_DB_01.dbf',
                   '/filesystem/u09/oradata/DBC/temp_SEED_01.dbf', '/filesystem/u09/oradata/DB/temp_DB_01.dbf',
                   '/filesystem/u01/oradata/DBC/system_SEED_01_i1_undo.dbf', '/filesystem/u08/oradata/DB/undotbs_DB_01.dbf'
);
```

> Parametrer la base pluggable dans le <u>conteneur</u>.

```
ALTER SESSION SET CONTAINER=DB;
ALTER PLUGGABLE DATABASE OPEN;
ALTER SESSION SET CONTAINER=CDB$ROOT;
ALTER SYSTEM DISABLE RESTRICTED SESSION;
ALTER PLUGGABLE DATABASE DB SAVE STATE;
```

> Purger l'utilisateur admin et renommer l'undo dans la <u>pluggable</u>.

```
export ORACLE_PDB_SID=?
sqlplus / as sysdba
DROP USER pdb_adm CASCADE;
ALTER TABLESPACE UNDO_1 RENAME TO UNDOTBS;
ALTER SYSTEM SET UNDO_TABLESPACE=UNDOTBS;
```
# tablespace [-oracle]

> Creation d'un tablespace.

```
CREATE TABLESPACE TBL DATAFILE '/filesystem/u0?/oradata/DB/tbs_db_01.dbf' SIZE 10M AUTOEXTEND ON NEXT 4M MAXSIZE UNLIMITED;
```

> Suppression d'un tablespace.

```
DROP TABLESPACE TBL INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
```

> Ajout d'un datafile.

```
ALTER TABLESPACE TBL ADD DATAFILE '/filesystem/u0?/oradata/DB/tbl_db_01.dbf' SIZE 20M AUTOEXTEND ON NEXT 128K MAXSIZE UNLIMITED;
```

> Ajout d'un tempfile.

```
ALTER TABLESPACE TEMP ADD TEMPFILE '/filesystem/u0?/oradata/DB/temp_db_01.dbf' SIZE 20M AUTOEXTEND ON NEXT 128K MAXSIZE UNLIMITED;
```

> Mettre un tablespace en lecture seule.

```
ALTER TABLESPACE TBL READ ONLY;
```

> Mettre un tablespace en lecture / écriture

```
ALTER TABLESPACE TBL READ WRITE;
```

> Déplacer un tablespace.

Mettre le tablespace offline, copier le datafile dans le nouveau répertoire, renommer le datafile, mettre le tablespace online, supprimer physiquement l'ancien fichier de données.

```
ALTER TABLESPACE TBL OFFLINE;
cp /filesystem/u01/oradata/DB/tbs_db_01.dbf /filesystem/u02/oradata/DB/tbs_db_02.dbf
ALTER DATABASE RENAME FILE '/filesystem/u01/oradata/DB/tbs_db_01.dbf' TO '/filesystem/u02/oradata/DB/tbs_db_02.dbf';
ALTER TABLESPACE TBL ONLINE;
rm /filesystem/u01/oradata/DB/tbs_db_01.dbf
```

## Renommer datafile

> Deplacer le(s) fichier(s) physiquement sur disque.

```
mv /filesystem_src/u01/oradata/DB_SOURCE/system_SEED_01.dbf /filesystem_cible/u01/oradata/DB_CIBLE/system_SEED_01.dbf
```

> Deplacer le(s) fichier(s) au niveau base.

```
ALTER DATABASE RENAME FILE '/filesystem_src/u01/oradata/DB_SOURCE/system_SEED_01.dbf' TO '/filesystem_cible/u01/oradata/DB_CIBLE/system_SEED_01.dbf';
ALTER DATABASE MOVE DATAFILE '/filesystem_src/u01/oradata/DB_SOURCE/system_SEED_01.dbf' TO '/filesystem_cible/u01/oradata/DB_CIBLE/system_SEED_01.dbf';
```

- Renommage du system_SEED.

```
SHUTDOWN IMMEDIATE;
mv /filesystem_src/u01/oradata/DB_SOURCE/system_SEED_01.dbf /filesystem_cible/u01/oradata/DB_CIBLE/system_SEED_01.dbf
STARTUP MOUNT;
ALTER DATABASE RENAME FILE '/filesystem_src/u01/oradata/DB_SOURCE/system_SEED_01.dbf' TO '/filesystem_cible/u01/oradata/DB_CIBLE/system_SEED_01.dbf';
ALTER DATABASE OPEN;
```

- Renommage du sysaux_SEED.

```
SHUTDOWN IMMEDIATE;
mv /filesystem_src/u02/oradata/DB_SOURCE/sysaux_SEED_01.dbf /filesystem_cible/u02/oradata/DB_CIBLE/sysaux_SEED_01.dbf
STARTUP MOUNT;
ALTER DATABASE RENAME FILE '/filesystem_src/u02/oradata/DB_SOURCE/sysaux_SEED_01.dbf' TO '/filesystem_cible/u02/oradata/DB_CIBLE/sysaux_SEED_01.dbf';
ALTER DATABASE OPEN;
```

> Verifications.

```
SELECT name FROM v$datafile WHERE name LIKE '%SEED%';
SELECT name FROM v$tempfile WHERE name LIKE '%SEED%';
```

> Si impossible de renommer (exemple du TEMPFILE).

```
ALTER DATABASE TEMPFILE '/filesystem_src/u09/oradata/DB_SOURCE/temp_SEED_01.dbf' DROP INCLUDING DATAFILE;
ALTER TABLESPACE TEMP ADD TEMPFILE '/filesystem_cible/u09/oradata/DB_CIBLE/temp_SEED_01.dbf' SIZE 500M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
```
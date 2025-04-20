# tablespace temporaire [-oracle]

Le tablespace temporaire, communement appele TEMP, est utilise pour gerer les requetes longues qui ne peuvent etre executees dans la mémoire PGA.

Vue pour diagnostiquer la cause sur l'usage du tablespace temporaire : v$tempseg_usage.

> Shrink va permettre de defragmenter.

```
ALTER TABLESPACE TEMP SHRINK SPACE KEEP 256M;
ALTER TABLESPACE TEMP SHRINK TEMPFILE '/chemin/datafile.dbf' KEEP 256M;
```

> Resize permet de recuperer l'espace disque.

```
ALTER DATABASE TEMPFILE '/chemin/datafile.dbf' RESIZE 256M;
```

> Recreer le tablespace.

```
CREATE TEMPORARY TABLESPACE TEMP2 TEMPFILE '/filesystem/u0?/oradata/DB/temp_2_db_01.dbf' SIZE 16M REUSE AUTOEXTEND ON NEXT 16M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP2;
DROP TABLESPACE TEMP INCLUDING CONTENTS AND DATAFILES;
CREATE TEMPORARY TABLESPACE TEMP TEMPFILE '/filesystem/u0?/oradata/DB/temp_db_01.dbf' SIZE 16M REUSE AUTOEXTEND ON NEXT 16M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP;
DROP TABLESPACE TEMP2 INCLUDING CONTENTS AND DATAFILES;
```
# packages [-oracle]

> Recompiler un package.

```
ALTER PACKAGE N_PACKAGE COMPILE;
ALTER PACKAGE N_PACKAGE COMPILE BODY;
```

> Recompiler un objet (synonym, procedure, function, trigger, view).

```
ALTER SYNONYM N_SYNONYM COMPILE;
ALTER PROCEDURE N_PROCEDURE COMPILE;
ALTER FUNCTION N_FUNCTION COMPILE;
ALTER TRIGGER N_TRIGGER COMPILE;
ALTER VIEW N_VUE COMPILE;
```

> Voir les erreurs.

```
SHOW ERRORS;
```

## Extraire un package

> Avec la vue dba_source.

```
spool fichier
set lines 999 pages 0 feed off
SELECT text FROM dba_source WHERE name='N_PACKAGE' ORDER BY type, line;
spool off
```

> Avec le package DBMS_METADATA.

```
set long 10000000
SELECT DBMS_METADATA.GET_DDL ('PACKAGE','N_PACKAGE','SCHEMA') FROM DUAL;

set markup csv on delimiter ";" quote off
set head off feed off long 100000000
spool test_1.sql
SELECT text FROM dba_source WHERE name='N_PACKAGE' ORDER BY type, line;
spool off
spool test_2.sql
SELECT DBMS_METADATA.GET_DDL ('PACKAGE','N_PACKAGE','SCHEMA') FROM DUAL;
spool off
```

> Avec un export / import.

```
expdp ${HX_ORA_ADM} schemas=SCHEMA INCLUDE=PACKAGE:\"=\'N_PACKAGE\'\" directory=DUMP_DIR dumpfile=N_PACKAGE.dmp logfile=expdp_N_PACKAGE.log
impdp remap_schema=..
```
# tkprof [-oracle]

Outil utilise pour analyser une requete SQL.

> Activer la trace SQL.

```
sqlplus / as sysdba
ALTER SESSION SET SQL_TRACE=TRUE;
SELECT * FROM SCHEMA.TABLE;
EXIT;
```

> Lancer le tkprof sur le fichier de trace.

```
cd /u02/oracle/diag/rdbms/db/DB/trace
tkprof DB_ora_45351324.trc
output=test.tkp
view test.tkp
```
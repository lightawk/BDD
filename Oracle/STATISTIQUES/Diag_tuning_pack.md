# diagnostic & tuning pack [-oracle]

## Voir si diagnostic+tuning pack sont actives

> Dans la base de donnees.

```
export ORACLE_SID=?
sqlplus / as sysdba
SELECT value FROM v$parameter WHERE NAME='control_management_pack_access';
```

> Dans le fichier de parametres.

```
cd $ORACLE_HOME/dbs
vi init?.ora
*.control_management_pack_access='DIAGNOSTIC+TUNING'
```
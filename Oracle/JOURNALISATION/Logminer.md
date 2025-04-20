# logminer [-oracle]

LOGMINER est un utilitaire Oracle permettant de lire dans des fichiers journaux.

Constitue de deux packages : DBMS_LOGMNR et DBMS_ LOGMNR_D.

> S'installe avec le script catproc.sql qui lance les scripts suivants.

```
$ORACLE_HOME/rdbms/admin/dbmslmd.sql
$ORACLE_HOME/rdbms/admin/dbmslm.sql
$ORACLE_HOME/rdbms/admin/prvtlm.plb
```

> On execute le DBMS_LOGMNR avec le chemin des fichiers redolog a analyser.

```
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(logfilename => '/prod0?/u0?/oradata/DB/redoa_DB_01.log', options => DBMS_LOGMNR.NEW);
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(logfilename => '/prod0?/u0?/oradata/DB/redoa_DB_02.log', options => DBMS_LOGMNR.ADDFILE);
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(logfilename => '/prod0?/u0?/oradata/DB/redoa_DB_03.log', options => DBMS_LOGMNR.ADDFILE);
```

> Voir les dates et heures des switch logfile et les SCN.

```
SELECT filename, low_time, high_time, low_scn, next_scn FROM v$logmnr_logs;
```

> On interroge la vue V_\$LOGMNR_CONTENTS ou la table V\$LOGMNR_CONTENTS.

```
Colonne SQL_REDO => Transaction faite.
Colonne SQL_UNDO => Transaction a faire pour defaire.
```

> Demarrer LOGMINER.

```
EXECUTE DBMS_LOGMNR.START_LOGMNR(options => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG + DBMS_LOGMNR.NO_ROWID_IN_STMT + DBMS_LOGMNR.NO_SQL_DELIMITER);
```

> Demarrer LOGMINER en lui precisant une date et une heure (la vue V_$LOGMNR_CONTENTS sera alimentee).

```
EXECUTE DBMS_LOGMNR.START_LOGMNR(STARTTIME => to_date('16/01/2010 20:45:00','DD/MM/YYYY HH24:MI:SS'));
SELECT USERNAME                                       AS USR,
       SEG_OWNER                                      AS OWNER,
       SCN,
       TIMESTAMP,
       (XIDUSN || '.' || XIDSLT || '.' || XIDSQN)     AS XID,
       SQL_REDO,
       SQL_UNDO
  FROM V$LOGMNR_CONTENTS
 WHERE USERNAME IN ('USER')                    -- remplacer USER par vos USERS
                            AND SEG_OWNER IN ('USER');
```

> Fermeture de LOGMINER (la vue V_$LOGMNR_CONTENTS sera purgee).

```
EXECUTE DBMS_LOGMNR.END_LOGMNR();
```
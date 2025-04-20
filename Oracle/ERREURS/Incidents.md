# incidents [-oracle]

## Consommation CPU provoquee par une / plusieurs requetes

> Recuperer le SQL_ID & le SQL_TEXT de la requete consommatrice via OEM par exemple.

> Rechercher avec les vues AWR si le PLAN_HASH_VALUE a change d'une date a une autre pour cette requete (filtrer par TIMESTAMP DESC).

```
  SELECT sql_id, plan_hash_value, timestamp
    FROM dba_hist_sql_plan
   WHERE sql_id = '?'
ORDER BY timestamp DESC;

3kf1drtsm4880    2060093338    12/02/2024 08:25:29
3kf1drtsm4880    2491982176    04/09/2023 10:14:32
```

> Recuperer son plan d'execution.

```
sqlplus SCHEMA/PWD@DB
EXPLAIN PLAN FOR requete;
SELECT plan_table_output FROM table(DBMS_XPLAN.DISPLAY());
```

> Vider le cache au niveau base.

```
sqlplus / as sysdba
ALTER SYSTEM FLUSH SHARED_POOL;
ALTER SYSTEM FLUSH BUFFER_CACHE;
```

> Recalculer les statistiques sur certaines tables utilisees dans la requete.

```
sqlplus / as sysdba
BEGIN
    SYS.DBMS_STATS.GATHER_TABLE_STATS (
        OwnName            => 'SCHEMA',
        TabName            => 'TABLE',
        Estimate_Percent   => SYS.DBMS_STATS.AUTO_SAMPLE_SIZE,
        Method_Opt         => 'FOR ALL COLUMNS SIZE AUTO',
        Degree             => NULL,
        Cascade            => DBMS_STATS.AUTO_CASCADE,
        No_Invalidate      => DBMS_STATS.AUTO_INVALIDATE,
        Force              => FALSE
    );
END;
/
```
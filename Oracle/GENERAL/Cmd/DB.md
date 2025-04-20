# db [-oracle]

## Listener

```
lsnrctl start LISTENER_${ORACLE_SID}
lsnrctl stop LISTENER_${ORACLE_SID}
lsnrctl status LISTENER_${ORACLE_SID}
```

## Agent

```
${AGENT_HOME}/bin/emctl start agent
${AGENT_HOME}/bin/emctl stop agent
```

## Base de donnees

> Suppression base ou dataguard.

```
SHUTDOWN ABORT;
STARTUP FORCE EXCLUSIVE RESTRICT MOUNT;
DROP DATABASE;
```

> Mode archivelog.

```
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE (NO)ARCHIVELOG;
ALTER DATABASE OPEN;
SELECT log_mode FROM v$database;
```

> Transport archivelogs (log transport).

```
ALTER SYSTEM SET log_archive_dest_state_2=ENABLE scope=both;
ALTER SYSTEM SET log_archive_dest_state_2=DEFER scope=both;
SELECT VALUE FROM v$spparameter WHERE NAME='log_archive_dest_state_2';
```

> Activation / désactivation MRP.

```
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
```

> Verification MRP.

```
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SELECT name, db_name, database_role, open_mode, flashback_on FROM v$database;
SELECT process, client_process, sequence#, status FROM v$managed_standby;
```

> Force logging.

```
ALTER DATABASE FORCE LOGGING;
ALTER DATABASE NO FORCE LOGGING;
SELECT force_logging FROM v$database;
```

> Recompilation des objets.

```
sqlplus / as sysdba
@?/rdbms/admin/utlrp
exit;
```

## Flashback

> Flashback base primaire.

```
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE FLASHBACK ON;
ALTER DATABASE OPEN;
```

> Flashback base standby.

```
STARTUP MOUNT FORCE;
ALTER DATABASE FLASHBACK ON;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
ALTER DATABASE FLASHBACK OFF;

SET LINES 350
SET FEED OFF
COL current_scn FORMAT 9999999999999999
COL resetlogs_change# FORMAT 9999999999999999
COL resetlogs_change# FORMAT A40
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SELECT instance_name FROM v$instance;
SELECT name, flashback_on, resetlogs_change#, resetlogs_time, open_mode, database_role, current_scn FROM v$database;
SELECT current_scn, resetlogs_change#, resetlogs_time FROM v$database;
```

> Flashback point de garantie.

```
STARTUP MOUNT;
FLASHBACK DATABASE TO RESTORE POINT ?;
ALTER DATABASE OPEN RESETLOGS;
SET PAGES 100
SET LINE 200
COLUMN message FORMAT A50
SELECT sid, message FROM v$session_longops WHERE sofar <> totalwork;
```

> Flashback SCN.

```
SELECT scn, name FROM v$restore_point;
STARTUP MOUNT FORCE;
FLASHBACK STANDBY DATABASE TO SCN ?;
```
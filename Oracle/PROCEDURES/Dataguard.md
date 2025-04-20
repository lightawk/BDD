# dataguard [-oracle]

Transport des archivelogs, MRP actifs, faire un switch sur un fichier redolog et voir la consommation sur la dataguard.

## Base en mode archivelog

```
SELECT log_mode FROM v$database;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
```

## Base en mode forcelogging

```
SELECT FORCE_LOGGING FROM v$database;
ALTER DATABASE FORCE LOGGING;
```

## Verifier certains parametres du fichier d'initialisation

> Sur la base primaire.

```
*.standby_file_management='AUTO'
> Les ajouts et suppressions de fichiers du système d'exploitation sur la base de données principale sont répliqués sur la base de données de secours (important)
*.db_name='PRIMARY'
*.db_unique_name='PRIMARY'
*.log_archive_config='DG_CONFIG=(PRIMARY,DATAGUARD)'
*.log_archive_dest_2='service=DATAGUARD lgwr async valid_for=(online_logfiles,primary_role) db_unique_name=DATAGUARD'
*.log_archive_dest_state_2='ENABLE'
```

> Sur la base standby.

```
*.standby_file_management='AUTO'
*.db_name='PRIMARY'
*.db_unique_name='DATAGUARD'
*.log_archive_config='DG_CONFIG=(PRIMARY,DATAGUARD)'
*.log_archive_dest_2='service=PRIMARY valid_for=(online_logfiles,primary_role) db_unique_name=PRIMARY'
*.log_archive_dest_state_2='DEFER'
```

## Verifier configuration listener.ora et du tnsnames.ora

> Sur la base primaire.

```
SID_LIST_LISTENER_PRIMARY =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = PRIMARY)
      (ORACLE_HOME = /u01/oracle/19c/db_1)
      (SID_NAME = PRIMARY)
    )
    (SID_DESC =
      (SID_NAME = PLSExtProc)
      (ORACLE_HOME = /u01/oracle/19c/db_1)
      (PROGRAM = extproc)
      (ENVS = "EXTPROC_DLLS=ONLY:/app/helios/lib/rext.so")
    )
    (SID_DESC =
      (GLOBAL_DBNAME = PRIMARY_PDB)
      (ORACLE_HOME = /u01/oracle/19c/db_1)
      (SID_NAME = PRIMARY)
    )
  )

LISTENER_DATAGUARD =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = serveur_dg)(PORT = 00000))
    )
  )
```

> Sur la base standby.

```
SID_LIST_LISTENER_DATAGUARD =
  (SID_LIST =
    (SID_DESC =
      (ORACLE_HOME = /u01/oracle/19c/db_1)
      (SID_NAME = DATAGUARD)
    )
  )

LISTENER_PRIMARY =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = serveur)(PORT = 00000))
    )
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC))
    )
  )
```

> Joindre les bases via le reseau.

```
tnsping PRIMARY - depuis le serveur qui heberge la dataguard
tnsping DATAGUARD - depuis le serveur qui heberge la base primaire
```

## Création des répertoires sur la dataguard

```
set -A tab PRIMARY_PDB PRIMARY PRIMARY_PDBSEED
for db in ${tab[@]}; do
  for i in 1 2 3 4 5 6 7 8 9; do
    rm -fr /filesystem/u0$i/oradata/${db}
    mkdir -p /filesystem/u0$i/oradata/${db}
  done
done
mkdir /filesystem/u07/oradata/PRIMARY/flash
mkdir /filesystem/u07/oradata/PRIMARY/archive
```

> NB : Les repertoires /flash et /archive sont au niveau du conteneur.

## Créer un fichier mot de passe sur la base primaire & le copier sur la base dataguard

> Sur le serveur qui heberge la base primaire.

```
orapwd file=/u01/oracle/19c/db_1/dbs/orapw${ORACLE_SID} password=pwd
```

> Sur le serveur qui heberge la base dataguard.

```
scp -p oracle@serveur-a:${ORACLE_HOME}/dbs/orapwPRIMARY ${ORACLE_HOME}/dbs/orapw${ORACLE_SID}
```

## Démarrage de la dataguard en nomount

```
STARTUP NOMOUNT PFILE='/filesystem/adm/admin/PRIMARY/pfile/init${ORACLE_SID}.ora';
CREATE SPFILE='/filesystem/adm/admin/PRIMARY/pfile/spfile${ORACLE_SID}.ora' FROM PFILE='/filesystem/adm/admin/PRIMARY/pfile/init${ORACLE_SID}.ora';
SHUTDOWN IMMEDIATE;
STARTUP NOMOUNT;
```

## Copie via rman active duplicate sur la dataguard

```
rman log /app/log/rman_duplicate_${ORACLE_SID}.log
CONNECT TARGET SYS/pwd@PRIMARY
CONNECT AUXILIARY SYS/pwd@DATAGUARD
RUN
{
ALLOCATE CHANNEL PRIM0 TYPE DISK;
ALLOCATE CHANNEL PRIM1 TYPE DISK;
ALLOCATE CHANNEL PRIM2 TYPE DISK;
ALLOCATE CHANNEL PRIM3 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL STBY0 TYPE DISK;
DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE DORECOVER NOFILENAMECHECK;
RELEASE CHANNEL STBY0;
RELEASE CHANNEL PRIM0;
RELEASE CHANNEL PRIM1;
RELEASE CHANNEL PRIM2;
RELEASE CHANNEL PRIM3;
}
```

## Tester le log transport sur la primaire et le MRP sur la dataguard

> Sur le serveur qui heberge la base primaire.

```
SELECT value FROM v$spparameter WHERE name='log_archive_dest_state_2';
ALTER SYSTEM SET log_archive_dest_state_2=ENABLE SCOPE=both;
```

> Sur le serveur qui heberge la base dataguard.

```
STARTUP MOUNT FORCE;
ALTER DATABASE FLASHBACK ON;
```

```
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SELECT name, db_name, database_role, open_mode, flashback_on FROM v$database;
SELECT process, client_process, sequence#, status FROM v$managed_standby;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
```

## Verification du gap

> Sur le serveur qui heberge la base dataguard.

```
cd /u02/oracle/diag/rdbms/dataguard/DATAGUARD/trace
tail -f alert_DATAGUARD.log
```

> Sur le serveur qui heberge la base primaire.

```
export ORACLE_SID=PRIMARY
sqlplus / as sysdba
ALTER SYSTEM SWITCH LOGFILE;
/
EXIT;
```

> Verification du gap sur la base primaire
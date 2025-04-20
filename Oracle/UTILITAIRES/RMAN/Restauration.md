# restauration [-oracle]

Ce type de restauration Point In Time Recovery (PITR) est indique dans le cas d'une procedure manuelle.

Supprimer la base puis de mettre à jour le catalogue RMAN.

## Restauration Point In Time Recovery (PITR) [-TAPE]

### Phase préparatoire

> Suppression de l'ancienne base.

```
sqlplus / as sysdba
SHUTDOWN ABORT;
STARTUP MOUNT EXCLUSIVE RESTRICT;
DROP DATABASE;
EXIT;
```

> Supprimer puis recreer les repertoires de la base.

```
for i in 1 2 3 4 5 6 7 8 9; do
rm -fr /filesystem/u0$i/oradata/DB
done
for i in 1 2 3 4 5 6 7 8 9; do
mkdir -p /filesystem/u0$i/oradata/DB
done
mkdir /filesystem/u07/oradata/DB/flash
mkdir /filesystem/u07/oradata/DB/archive
ls -lrt /filesystem/u0*/oradata/DB/*
```

> Commenter ou de-commenter dans /etc/oratab.

```
vi /etc/oratab
#DB_PDB:/u01/oracle/19c/db_1:N
DB:/u01/oracle/19c/db_1:N
*:/u01/oracle/19c/db_1:N
*:/u01/oracle/agent/agent_13.5.0.0.0:N
```

> Inventaire centralise des installations pour faire pointer le bon oraInventory dans /etc/oraInst.loc.

```
vi /etc/oraInst.loc
ln -s /u01/oracle/oraInventoryX /u01/oracle/oraInventory
```

> Verifier les liens symboliques dans ${ORACLE_HOME}/dbs.

```
initDB.ora -> /filesystem/adm/admin/DB/pfile/initDB.ora
spfileDB.ora -> /filesystem/adm/admin/DB/pfile/spfileDB.ora
```

> Recreer le spfile.

```
export ORACLE_SID=DB
export ORACLE_PDB_SID= ou unset ORACLE_PDB_SID
sqlplus / as sysdba
create spfile='/filesystem/adm/admin/DB/pfile/spfileDB.ora' from pfile;
exit;
```

> Recreer le lien symbolique dans ${ORACLE_HOME}/dbs.

```
ln -sf /filesystem/adm/admin/DB/pfile/spfileDB.ora ${ORACLE_HOME}/dbs/spfileDB.ora
```

### Restauration

> Crosscheck.

```
STARTUP FORCE NOMOUNT;
startup failed: ORA-01078: failure in processing system parameters LRM-00109: could not open parameter file '${ORACLE_HOME}/dbs/initDB.ora'
```

> Liste des sauvegardes disponibles physiquement.

```
LIST BACKUP SUMMARY RECOVERABLE;
LIST BACKUP OF DATABASE SUMMARY RECOVERABLE;
```

> Restaurer le spfile en premier.

```
LIST BACKUP OF SPFILE SUMMARY RECOVERABLE;
RUN
{
ALLOCATE CHANNEL channel0
TYPE 'SBT_TAPE'
SEND 'NB_ORA_CLIENT=srv_orig, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
RESTORE SPFILE FROM TAG 'SPDB_AAAAMMJJ_0_RMDBF?';
}
SHUTDOWN IMMEDIATE;
STARTUP FORCE NOMOUNT;
LIST INCARNATION OF DATABASE;
RESET DATABASE TO INCARNATION ?;
```

> Restaurer les controlfiles.

```
LIST BACKUP OF CONTROLFILE SUMMARY RECOVERABLE;
RUN
{
ALLOCATE CHANNEL channel0
TYPE 'SBT_TAPE'
SEND 'NB_ORA_CLIENT=srv_orig, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
RESTORE CONTROLFILE FROM TAG 'CTLDB_AAAAMMJJ_0_RMDBF?';
}
```

> Recuperer l'incarnation et la date de fin de sauvegarde du controlfile a partir du TAG du fichier de controle.

```
sqlplus RMAN_SCHEMA/RMAN_SCHEMA@CATRMAN
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
WITH
    fin
    AS
        (SELECT completion_time     temps
           FROM rc_backup_piece
          WHERE tag LIKE 'CTL?%'),
    incarnations
    AS
        (SELECT dbinc_key,
                resetlogs_time    debut,
                NVL (LEAD (resetlogs_time) OVER (ORDER BY resetlogs_time),
                     SYSDATE)     fin
           FROM rc_database_incarnation)
SELECT dbinc_key, fin.temps
  FROM fin, incarnations
 WHERE fin.temps BETWEEN incarnations.debut AND incarnations.fin;
```

> Recuperer l'incarnation, la date de fin de sauvegarde du controlfile et son tag a partir d'une DATE.

```
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
WITH
    fin
    AS
        (SELECT tag tag, completion_time temps
           FROM rc_backup_piece
          WHERE completion_time =
                (SELECT MAX (completion_time)
                   FROM rc_backup_piece
                  WHERE     completion_time <=
                            TO_DATE ('?', 'DD/MM/YYYY HH24:MI:SS')
                        AND tag LIKE 'CTL%')),
    incarnations
    AS
        (SELECT dbinc_key,
                resetlogs_time    debut,
                NVL (LEAD (resetlogs_time) OVER (ORDER BY resetlogs_time),
                     SYSDATE)     fin
           FROM rc_database_incarnation)
SELECT dbinc_key, fin.temps, fin.tag
  FROM fin, incarnations
 WHERE fin.temps BETWEEN incarnations.debut AND incarnations.fin;
```

> Restauration de la base sur cassette.

```
LIST BACKUP OF DATABASE SUMMARY RECOVERABLE;
STARTUP MOUNT;
RUN
{
ALLOCATE CHANNEL CHANNEL0
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL1
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL2
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL3
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL4
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL5
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL6
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL7
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
SET UNTIL TIME "TO_DATE('10/08/2018 23:08:39', 'DD/MM/YYYY HH24:MI:SS')";
[SET UNTIL SCN [...]];
[SET UNTIL SEQUENCE [...] THREAD 1];
RESTORE DATABASE [FROM TAG 'SID_YYYYMMJJ_SCHED_POLICY'];
RECOVER DATABASE [DELETE ARCHIVELOG MAXSIZE 128G];
RELEASE CHANNEL CHANNEL0;
RELEASE CHANNEL CHANNEL1;
RELEASE CHANNEL CHANNEL2;
RELEASE CHANNEL CHANNEL3;
RELEASE CHANNEL CHANNEL4;
RELEASE CHANNEL CHANNEL5;
RELEASE CHANNEL CHANNEL6;
RELEASE CHANNEL CHANNEL7;
}
```

Au niveau du "SET UNTIL TIME" penser a prendre la meme date que la restauration du controlfile et une heure un peu plus tardive de 30 minutes par exemple.

> Ouvrir la base en mode open resetlogs.

```
ALTER DATABASE OPEN RESETLOGS;
```

### Restauration sans catalogue [-TAPE]

> Positionnement des variables.

```
export ORACLE_SID=DB
unset ORACLE_PDB_SID

export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS'
```

> Demarrer la base en NOMOUNT.

```
rman target /
STARTUP NOMOUNT;
```

> Restaurer les controlfiles.

```
RUN
{
ALLOCATE CHANNEL CHANNEL0
TYPE 'SBT_TAPE'
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
RESTORE CONTROLFILE FROM 'CTLDB_AAAAMMJJ_0_RMDBF?';
}
```

> Restaurer la base.

```
RUN
{
ALLOCATE CHANNEL CHANNEL0
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL1
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL2
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL3
TYPE 'SBT_TAPE'
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=${ORACLE_SID}, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
RESTORE DATABASE;
RECOVER DATABASE;
}
```

> Ouverture de la base en OPEN RESETLOGS.

```
ALTER DATABASE OPEN RESETLOGS;
```

## Restauration sur disque [-DISK]
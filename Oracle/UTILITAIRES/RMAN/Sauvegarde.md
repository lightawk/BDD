# sauvegarde [-oracle]

## Sauvegarde [-TAPE]

> Double connexion à la base et au catalogue.

```
rman target / catalog RMAN_SCHEMA/RMAN_SCHEMA@CATRMAN
RUN
{
ALLOCATE CHANNEL CHANNEL0
TYPE 'SBT_TAPE'
FORMAT 'Db_DB_AAAAMMJJ_0_RMDBF?_t%t_s%s_p%p'
MAXOPENFILES 1 MAXPIECESIZE 196G
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=DB, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL1
TYPE 'SBT_TAPE'
FORMAT 'Db_DB_AAAAMMJJ_0_RMDBF?_t%t_s%s_p%p'
MAXOPENFILES 1 MAXPIECESIZE 196G
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=DB, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL2
TYPE 'SBT_TAPE'
FORMAT 'Db_DB_AAAAMMJJ_0_RMDBF?_t%t_s%s_p%p'
MAXOPENFILES 1 MAXPIECESIZE 196G
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=DB, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
ALLOCATE CHANNEL CHANNEL3
TYPE 'SBT_TAPE'
FORMAT 'Db_DB_AAAAMMJJ_0_RMDBF?_t%t_s%s_p%p'
MAXOPENFILES 1 MAXPIECESIZE 196G
PARMS 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.a64(shr.o)';
SEND 'NB_ORA_CLIENT=srv_cible, NB_ORA_SID=DB, NB_ORA_POLICY=RMDBF?, NB_ORA_SCHED=heb';
SQL 'ALTER SYSTEM SWITCH LOGFILE';
BACKUP INCREMENTAL LEVEL 0 DATABASE TAG 'DbDB_AAAAMMJJ_0_RMDBF?' [ PLUS ARCHIVELOG ]
BACKUP ARCHIVELOG ALL
BACKUP FULL DATABASE TAG 'DbDB_AAAAMMJJ_0_RMDBF?' [ PLUS ARCHIVELOG ]
[ FORMAT 'arch_DB_AAAAMMJJ_0_RMDBF?_%d_t%t_s%s_p%p_c%c' NOT BACKED UP 1 TIMES TAG 'ArcDB_AAAAMMJJ_0_RMDBF?' [ DELETE INPUT ] ];
BACKUP SPFILE FORMAT 'spf_DB_AAAAMMJJ_0_RMDBF?_%d_t%t_s%s_p%p_c' TAG 'SpDB_AAAAMMJJ_0_RMDBF?';
BACKUP CURRENT CONTROLFILE FORMAT 'Ctl_DB_AAAAMMJJ_0_RMDBF?' TAG 'CtlDB_AAAAMMJJ_0_RMDBF?';
RELEASE CHANNEL CHANNEL0;
RELEASE CHANNEL CHANNEL1;
RELEASE CHANNEL CHANNEL2;
RELEASE CHANNEL CHANNEL3;
}
```

> Faire eventuellement un export du catalogue pour être certain de pouvoir conserver la sauvegarde.

```
expdp EXPIMP/impexp DIRECTORY=RMAN_SCHEMA DUMPFILE=export_DDMMYYYY.dmp LOGFILE=logfile_DDMMYYYY.log SCHEMAS=RMAN_SCHEMA
```

## Parametres

```
TYPE         => TAPE.
PARMS        => Librairie.
SEND         => Envoyer des variables - parametres a Netbackup.
SCHEDULER    => heb | jou | full.
POLICY       => RMDBFX=fin de plan de prod ; RMDBDX=debut de plan de production.
MAXOPENFILES => 196G.
```

## Sauvegarde [-DISK]

> A la différence d'une sauvegarde de type TAPE stockee cote netbackup, on fait ici une sauvegarde compressee de type DISK ou il est necessaire d'indiquer les chemins pour le stockage des backupieces sur differents filesystems.

> Pre-requis a chaud.

```
- Base en MODE ARCHIVELOG et demarree sur le spfile.
- Crosscheck effectue.
- Répertoire de destination suffisant en volumetrie.
- Faire eventuellement un ALTER SYSTEM SWITCH LOGFILE pour vider le dernier redolog puis creer une archivelog pour ainsi etre propre pour faire la sauvegarde.
```

> Pre-requis a froid.

```
Idem & base en MODE NOARCHIVELOG et demarree en MOUNT.
```

> Sauvegarde sur disque.

```
export ORACLE_SID=?
```

> Si on souhaite realiser une sauvegarde sans catalogue le mieux est de sauvegarder le controlfile au prealable car toutes les informations sur la sauvegarde sont contenues dans le fichier de controle.

```
rman target /
BACKUP AS COPY CURRENT CONTROLFILE FORMAT '${ORACLE_HOME}/dbs/sav_controlfile.ctl';
RESTORE CONTROLFILE FROM '${ORACLE_HOME}/dbs/sav_controlfile.ctl';
```

> Se connecter a rman mais uniquement sur la base et pas au catalogue puis lancer la sauvegarde.

```
rman target /
CROSSCHECK ARCHIVELOG ALL;
CHANGE ARCHIVELOG ALL VALIDATE;
RUN
{
CONFIGURE DEVICE TYPE DISK PARALLELISM 4 BACKUP TYPE TO BACKUPSET;
ALLOCATE CHANNEL CANAL01 TYPE DISK FORMAT '/filesbkp/Db_${ORACLE_SID}_t%t_s%s_p%p' MAXPIECESIZE 4G;
ALLOCATE CHANNEL CANAL02 TYPE DISK FORMAT '/filesbkp/Db_${ORACLE_SID}_t%t_s%s_p%p' MAXPIECESIZE 4G;
ALLOCATE CHANNEL CANAL03 TYPE DISK FORMAT '/filesbkp/Db_${ORACLE_SID}_t%t_s%s_p%p' MAXPIECESIZE 4G;
ALLOCATE CHANNEL CANAL04 TYPE DISK FORMAT '/filesbkp/Db_${ORACLE_SID}_t%t_s%s_p%p' MAXPIECESIZE 4G;
SQL 'ALTER SYSTEM SWITCH LOGFILE';
BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG;
BACKUP CURRENT CONTROLFILE FORMAT '/filesbkp/Db_${ORACLE_SID}_ctl';
BACKUP SPFILE FORMAT '/filesbkp/Db_${ORACLE_SID}_spf';
RELEASE CHANNEL CANAL01;
RELEASE CHANNEL CANAL02;
RELEASE CHANNEL CANAL03;
RELEASE CHANNEL CANAL04;
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET;
}
```

## Commandes generiques

> Sauvegarde full de base avec archivelogs.

```
BACKUP FULL DATABASE TAG Db_ PLUS ARCHIVELOG;
```

> Sauvegarde incrementale level 0 avec archivelogs.

```
BACKUP INCREMENTAL LEVEL 0 DATABASE TAG Db_ plus ARCHIVELOG;
```

> Sauvegarde incrementale level 1.

```
BACKUP INCREMENTAL LEVEL 1..; => si BCT active
BACKUP ARCHIVELOG ALL;
```

> Suppression des archivelogs apres qu'elles aient ete sauvegardees.

```
..DELETE INPUT;
```
# archivelog (redologs archives) [-oracle]

Une <u>archivelog</u> est un <u>redolog archivé</u> ou fichier ".arc" qui est cree a chaque <u>switch logfile</u>.

Le repertoire des archivelogs se trouve dans <u>/filesystem/u07/oradata/DB/archive</u>.

> Obtenir des informations sur l'archivage.

```
ARCHIVE LOG LIST;

mode Database log                                mode Archive
Archivage automatique                            Active
Destination de l'archive                         /filesystem/u0?/oradata/DB/archive
Sequence de journal en ligne la plus ancienne    ...
Sequence de journal suivante a archiver          ...
Sequence de journal courante                     ...
```

> Selectionner le nom de la base et son mode d'archivage.

```
SELECT name, log_mode FROM v$database;

NAME      LOG_MODE
--------- ------------
DB        ARCHIVELOG
```

> Selectionner l'état de l'archiver.

```
SELECT archiver FROM v$instance;

ARCHIVE
-------
STARTED
```

> Parametres de l'archivage dans le PFILE.

```
*.log_archive_start=true
*.log_archive_dest='LOCATION=/filesystem/u07/oradata/DB/archive'
*.log_archive_format='arch_%t_%s_%r.arc'
%t - thread number
%s - log sequence number
%r - resetlogs ID that ensures unique names are constructed for the archived log files across multiple incarnations of the database
```

## Vues dynamiques pour l'archivage

> `V$DATABASE` : Affiche des informations sur la base de donnees a partir du <u>fichier de controle</u>.

```
Nom                                       NULL ?   Type
----------------------------------------- -------- ----------------------------
DBID                                               NUMBER
NAME                                               VARCHAR2(9)
CREATED                                            DATE
RESETLOGS_CHANGE#                                  NUMBER
RESETLOGS_TIME                                     DATE
PRIOR_RESETLOGS_CHANGE#                            NUMBER
PRIOR_RESETLOGS_TIME                               DATE
LOG_MODE                                           VARCHAR2(12)
CHECKPOINT_CHANGE#                                 NUMBER
ARCHIVE_CHANGE#                                    NUMBER
CONTROLFILE_TYPE                                   VARCHAR2(7)
CONTROLFILE_CREATED                                DATE
CONTROLFILE_SEQUENCE#                              NUMBER
CONTROLFILE_CHANGE#                                NUMBER
CONTROLFILE_TIME                                   DATE
OPEN_RESETLOGS                                     VARCHAR2(11)
VERSION_TIME                                       DATE
OPEN_MODE                                          VARCHAR2(20)
PROTECTION_MODE                                    VARCHAR2(20)
PROTECTION_LEVEL                                   VARCHAR2(20)
REMOTE_ARCHIVE                                     VARCHAR2(8)
ACTIVATION#                                        NUMBER
SWITCHOVER#                                        NUMBER
DATABASE_ROLE                                      VARCHAR2(16)
ARCHIVELOG_CHANGE#                                 NUMBER
ARCHIVELOG_COMPRESSION                             VARCHAR2(8)
SWITCHOVER_STATUS                                  VARCHAR2(20)
DATAGUARD_BROKER                                   VARCHAR2(8)
GUARD_STATUS                                       VARCHAR2(7)
SUPPLEMENTAL_LOG_DATA_MIN                          VARCHAR2(8)
SUPPLEMENTAL_LOG_DATA_PK                           VARCHAR2(3)
SUPPLEMENTAL_LOG_DATA_UI                           VARCHAR2(3)
FORCE_LOGGING                                      VARCHAR2(39)
PLATFORM_ID                                        NUMBER
PLATFORM_NAME                                      VARCHAR2(101)
RECOVERY_TARGET_INCARNATION#                       NUMBER
LAST_OPEN_INCARNATION#                             NUMBER
CURRENT_SCN                                        NUMBER
FLASHBACK_ON                                       VARCHAR2(18)
SUPPLEMENTAL_LOG_DATA_FK                           VARCHAR2(3)
SUPPLEMENTAL_LOG_DATA_ALL                          VARCHAR2(3)
DB_UNIQUE_NAME                                     VARCHAR2(30)
STANDBY_BECAME_PRIMARY_SCN                         NUMBER
FS_FAILOVER_MODE                                   VARCHAR2(19)
FS_FAILOVER_STATUS                                 VARCHAR2(22)
FS_FAILOVER_CURRENT_TARGET                         VARCHAR2(30)
FS_FAILOVER_THRESHOLD                              NUMBER
FS_FAILOVER_OBSERVER_PRESENT                       VARCHAR2(7)
FS_FAILOVER_OBSERVER_HOST                          VARCHAR2(256)
CONTROLFILE_CONVERTED                              VARCHAR2(3)
PRIMARY_DB_UNIQUE_NAME                             VARCHAR2(30)
SUPPLEMENTAL_LOG_DATA_PL                           VARCHAR2(3)
MIN_REQUIRED_CAPTURE_CHANGE#                       NUMBER
CDB                                                VARCHAR2(3)
CON_ID                                             NUMBER
PENDING_ROLE_CHANGE_TASKS                          VARCHAR2(256)
CON_DBID                                           NUMBER
FORCE_FULL_DB_CACHING                              VARCHAR2(3)
SUPPLEMENTAL_LOG_DATA_SR                           VARCHAR2(3)
```

> `V$ARCHIVED_LOG` : Affiche les <u>informations de journal archivées</u> a partir du <u>fichier de controle</u> y compris les <u>noms des journaux d'archivage</u>.

```
Nom                                       NULL ?   Type
----------------------------------------- -------- ----------------------------
RECID                                              NUMBER
STAMP                                              NUMBER
NAME                                               VARCHAR2(257)
DEST_ID                                            NUMBER
THREAD#                                            NUMBER
SEQUENCE#                                          NUMBER
RESETLOGS_CHANGE#                                  NUMBER
RESETLOGS_TIME                                     DATE
RESETLOGS_ID                                       NUMBER
FIRST_CHANGE#                                      NUMBER
FIRST_TIME                                         DATE
NEXT_CHANGE#                                       NUMBER
NEXT_TIME                                          DATE
BLOCKS                                             NUMBER
BLOCK_SIZE                                         NUMBER
CREATOR                                            VARCHAR2(7)
REGISTRAR                                          VARCHAR2(7)
STANDBY_DEST                                       VARCHAR2(3)
ARCHIVED                                           VARCHAR2(3)
APPLIED                                            VARCHAR2(9)
DELETED                                            VARCHAR2(3)
STATUS                                             VARCHAR2(1)
COMPLETION_TIME                                    DATE
DICTIONARY_BEGIN                                   VARCHAR2(3)
DICTIONARY_END                                     VARCHAR2(3)
END_OF_REDO                                        VARCHAR2(3)
BACKUP_COUNT                                       NUMBER
ARCHIVAL_THREAD#                                   NUMBER
ACTIVATION#                                        NUMBER
IS_RECOVERY_DEST_FILE                              VARCHAR2(3)
COMPRESSED                                         VARCHAR2(3)
FAL                                                VARCHAR2(3)
END_OF_REDO_TYPE                                   VARCHAR2(10)
BACKED_BY_VSS                                      VARCHAR2(3)
CON_ID                                             NUMBER
```

La colonne de nom est "null" si le journal a ete efface.

Si le journal est archive deux fois il y aura deux enregistrements de journal archives avec les memes THREAD#, SEQUENCE# et FIRST_CHANGE# mais avec un nom different.

> `V$ARCHIVE_DEST` : Affiche pour l'instance actuelle toutes les destinations dans la configuration dataguard y compris la valeur, le mode et l'etat actuels de chaque destination.

```
Nom                                       NULL ?   Type
----------------------------------------- -------- ----------------------------
DEST_ID                                            NUMBER
DEST_NAME                                          VARCHAR2(256)
STATUS                                             VARCHAR2(9)
BINDING                                            VARCHAR2(9)
NAME_SPACE                                         VARCHAR2(7)
TARGET                                             VARCHAR2(16)
ARCHIVER                                           VARCHAR2(10)
SCHEDULE                                           VARCHAR2(8)
DESTINATION                                        VARCHAR2(256)
LOG_SEQUENCE                                       NUMBER
REOPEN_SECS                                        NUMBER
DELAY_MINS                                         NUMBER
MAX_CONNECTIONS                                    NUMBER
NET_TIMEOUT                                        NUMBER
PROCESS                                            VARCHAR2(10)
REGISTER                                           VARCHAR2(3)
FAIL_DATE                                          DATE
FAIL_SEQUENCE                                      NUMBER
FAIL_BLOCK                                         NUMBER
FAILURE_COUNT                                      NUMBER
MAX_FAILURE                                        NUMBER
ERROR                                              VARCHAR2(256)
ALTERNATE                                          VARCHAR2(256)
DEPENDENCY                                         VARCHAR2(256)
REMOTE_TEMPLATE                                    VARCHAR2(256)
QUOTA_SIZE                                         NUMBER
QUOTA_USED                                         NUMBER
MOUNTID                                            NUMBER
TRANSMIT_MODE                                      VARCHAR2(12)
ASYNC_BLOCKS                                       NUMBER
AFFIRM                                             VARCHAR2(3)
TYPE                                               VARCHAR2(7)
VALID_NOW                                          VARCHAR2(16)
VALID_TYPE                                         VARCHAR2(15)
VALID_ROLE                                         VARCHAR2(12)
DB_UNIQUE_NAME                                     VARCHAR2(30)
VERIFY                                             VARCHAR2(3)
COMPRESSION                                        VARCHAR2(7)
APPLIED_SCN                                        NUMBER
CON_ID                                             NUMBER
ENCRYPTION                                         VARCHAR2(7)
```

> `V$ARCHIVE_PROCESSES` : Affiche l'etat des <u>differents processus "ARCH"</u> pour l'instance.

```
Nom                                       NULL ?   Type
----------------------------------------- -------- ----------------------------
PROCESS                                            NUMBER
STATUS                                             VARCHAR2(10)
LOG_SEQUENCE                                       NUMBER
STATE                                              VARCHAR2(4)
ROLES                                              VARCHAR2(30)
CON_ID                                             NUMBER
```

> `V$BACKUP_REDOLOG` : Affiche des <u>informations sur les journaux archivés</u> dans les jeux de sauvegarde a partir du <u>fichier de controle</u>.

```
Nom                                       NULL ?   Type
----------------------------------------- -------- ----------------------------
RECID                                              NUMBER
STAMP                                              NUMBER
SET_STAMP                                          NUMBER
SET_COUNT                                          NUMBER
THREAD#                                            NUMBER
SEQUENCE#                                          NUMBER
RESETLOGS_CHANGE#                                  NUMBER
RESETLOGS_TIME                                     DATE
FIRST_CHANGE#                                      NUMBER
FIRST_TIME                                         DATE
NEXT_CHANGE#                                       NUMBER
NEXT_TIME                                          DATE
BLOCKS                                             NUMBER
BLOCK_SIZE                                         NUMBER
TERMINAL                                           VARCHAR2(3)
CON_ID                                             NUMBER
```

A noter que les journaux de retablissement en ligne ne peuvent pas etre sauvegardes directement, ils doivent d'abord etre archives sur disque puis sauvegardes.

Un jeu de sauvegarde de journal d'archivage peut contenir un ou plusieurs journaux archives.

> Liste des archivelogs non appliquees sur la dataguard.

```
SELECT sequence#, applied
  FROM v$archived_log
 WHERE dest_id='2' AND applied='NO';
```

> Voir la liste des archives appliquees sur la dataguard via l'alert.log.

```
grep "Media Recovery Log" alert_DG.log
```
# netbackup [-oracle]

> Allocation (ouverture) d'un canal de maintenance vers NBU.

```
ALLOCATE CHANNEL FOR MAINTENANCE DEVICE TYPE SBT;
```

> Envoi du client de production qui a servi a la sauvegarde d'origine.

```
SEND 'NB_ORA_CLIENT=serv-prod';
```

> Envoi du client qui a servi a la sauvegarde d'origine avec des options supplémentaires facultatives.

```
SEND 'NB_ORA_CLIENT=serv-prod, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=serv-qual, NB_ORA_POLICY=RMDBFX, NB_ORA_SCHED=heb';
```

> Contrôle de disponibilité aupres de NBU.

```
CROSSCHECK BACKUP COMPLETED AFTER 'SYSDATE-XX';
CROSSCHECK ARCHIVELOG ALL;
```

> Liste les sauvegardes disponibles (db, spfile & controlfile).

```
LIST BACKUP SUMMARY RECOVERABLE;
LIST BACKUP OF DATABASE SUMMARY RECOVERABLE;
LIST BACKUP OF SPFILE SUMMARY RECOVERABLE;
LIST BACKUP OF CONTROLFILE SUMMARY RECOVERABLE;
```

> Supprime toutes les archivelogs datant de moins d'une demi-heure.

```
DELETE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE - (1/48)';
```
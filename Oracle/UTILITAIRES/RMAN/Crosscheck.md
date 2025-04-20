# crosscheck [-oracle]

Un crosscheck dans l'utilitaire RMAN permet de mettre a jour les entrees dans le catalogue.

> Crosscheck.

```
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS'
rman TARGET / CATALOG RMAN_SCHEMA/RMAN_SCHEMA@CATRMAN
```

> Ouvre un tunnel de communication entre RMAN et NBU.

```
ALLOCATE CHANNEL FOR MAINTENANCE DEVICE TYPE SBT;
```

> Envoi du client de production qui a servi a la sauvegarde d'origine.

```
SEND 'NB_ORA_CLIENT=srv_orig';
```

> Envoi du client qui a servi a la sauvegarde d'origine avec des options supplementaires facultatives.

```
SEND 'NB_ORA_CLIENT=srv_orig, NB_ORA_SID=${ORACLE_SID}, NB_ORA_DISK_MEDIA_SERVER=srv_cible, NB_ORA_POLICY=RMDBFX, NB_ORA_SCHED=heb';
```

> Controle de disponibilite aupres de NBU.

```
CROSSCHECK BACKUP;
```

> Controle de disponibilite des archivelogs aupres de NBU.

```
CROSSCHECK ARCHIVELOG FROM TIME "TO_DATE('2018-08-10', 'YYYY-MM-DD')-08";
```

> Controle de disponibilite aupres de NBU avec un nombre de jours.

```
CROSSCHECK BACKUP COMPLETED AFTER "TO_DATE('2018-08-10', 'YYYY-MM-DD')-08" / 'SYSDATE-XX';
```

> Controle de disponibilite des archivelogs aupres de NBU.

```
CROSSCHECK ARCHIVELOG ALL;
```

> Supprime les sauvegardes expirees.

```
DELETE EXPIRED BACKUP;
```

> Lister les sauvegardes.

```
LIST BACKUP SUMMARY RECOVERABLE;
LIST BACKUP OF SPFILE SUMMARY RECOVERABLE;
LIST BACKUP OF CONTROLFILE SUMMARY RECOVERABLE;
LIST BACKUP OF DATABASE SUMMARY RECOVERABLE;
```

> Affiche la liste des sauvegardes des archivelogs pouvant etre restaurees.

```
LIST BACKUP OF ARCHIVELOG ALL;
```

> Supprime les entrees des archivelogs non disponibles.

```
DELETE EXPIRED ARCHIVELOG ALL;
```

> Legende.

```
SUMMARY     => Version simplifiee.
RECOVERABLE => Restaurable.
```
# redologs [-oracle]

> Status existants.

```
UNUSED   => Jamais ecrit.
CURRENT  => En ligne et en cours d'ecriture.
ACTIVE   => En ligne et en cours d'archivage.
INACTIVE => En ligne, archive et non utilise.
```

## Consultation

> Liste des groupes.

```
SELECT groups, current_group#, sequence# FROM v$thread;
```

> Liste des groupes et membres.

```
SELECT group#, sequence#, bytes, members, status FROM v$log;
```

## Gestion

> Fichiers.

```
SELECT * FROM v$logfile;
```

> Forcer le switch.

```
ALTER SYSTEM SWITCH LOGFILE;
```

> Ajouter un groupe de fichier.

```
ALTER DATABASE ADD LOGFILE GROUP 1 '/filesystem/u05/oradata/DB/redoa_01.log' SIZE 10M;
```

> Supprimer un groupe de fichier.

```
ALTER DATABASE DROP LOGFILE GROUP 1;
```

> Supprimer un membre d'un fichier online.

```
ALTER DATABASE DROP LOGFILE MEMBER '/filesystem/u05/oradata/DB/redoa_01.log';
```

## Deplacer un fichier redolog online

> Creer un fichier de redo temporaire et se positionner dessus.

```
SELECT group#, status FROM v$log;
ALTER DATABASE ADD LOGFILE GROUP 3 '/filesystem/u05/oradata/DB/redoa_01.log' SIZE 10M;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
```

> Supprimer les redologs et les recreer dans le nouveau repertoire.

```
SELECT group#, status FROM v$log;
ALTER DATABASE DROP LOGFILE MEMBER '/filesystem/u01/oradata/DB/redoa_01.log';
ALTER DATABASE ADD LOGFILE GROUP 1 '/filesystem/u05/oradata/DB/redoa_01.log' SIZE 10M;
ALTER DATABASE DROP LOGFILE MEMBER '/filesystem/u01/oradata/DB/redoa_02.log';
ALTER DATABASE ADD LOGFILE GROUP 1 '/filesystem/u05/oradata/DB/redoa_02.log' SIZE 10M;
ALTER DATABASE DROP LOGFILE MEMBER '/filesystem/u01/oradata/DB/redoa_03.log';
ALTER DATABASE ADD LOGFILE GROUP 2 '/filesystem/u05/oradata/DB/redoa_03.log' SIZE 10M;
ALTER DATABASE DROP LOGFILE MEMBER '/filesystem/u01/oradata/DB/redoa_04.log';
ALTER DATABASE ADD LOGFILE GROUP 2 '/filesystem/u05/oradata/DB/redoa_04.log' SIZE 10M;
SELECT group#, status FROM v$log;
```

> Activer tous les groupes et supprimer le redo temporaire.

```
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
SELECT group#, status FROM v$log;
ALTER DATABASE DROP LOGFILE GROUP 3;
SELECT group#, status FROM v$log;
```

## Reparer un fichier redolog

> Clearer le premier groupe de journaux puis le faire pour chaque groupe.

```
ALTER DATABASE CLEAR UNARCHIVED LOGFILE GROUP 1;
```

> Ouvrir la base en open resetlogs pour recreer les redologs.

```
ALTER DATABASE OPEN RESETLOGS;
```

> Recreer le controlfile avec les options resetlogs.

```
ALTER DATABASE BACKUP CONTROLFILE TO TRACE AS '/DUMP/controlfile.sql' RESETLOGS;
```

> Modifier le script de recreation du fichier de controle /repertoire/controlfile.sql et s'assurer que tous les repertoires des redologs existent et que Oracle a bien les droits dessus en ecriture.

> Creer le controlfile en NOMOUNT.

```
STARTUP FORCE NOMOUNT
@/DUMP/controlfile.sql
```

> Simuler un RECOVER.

```
RECOVER DATABASE USING BACKUP CONTROLFILE UNTIL CANCEL;
- selectionner <CANCEL> lors du prompt
```

> Ouvrir en OPEN RESETLOGS.

```
ALTER DATABASE OPEN RESETLOGS;
```
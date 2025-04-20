# checkpoint [-oracle]

Un checkpoint se produit <u>apres un switch redolog</u> et a des intervalles definis dans certains <u>parametres de la base</u> par exemple <u>*.archive_lag_target=?</u> qui force un switch log après un temps défini.

Il déclenche le <u>process DBWR</u> [ DatabaseWriter ] qui écrit le contenu des <u>blocs du buffer cache</u> de la SGA dans les <u>fichiers de données</u>.

Il met à jour <u>l'entête des fichiers de données</u> & <u>le(s) fichier(s) de contrôle</u>.

> Cas dans lesquels un checkpoint se produit.

- Se produit lors d'un <u>SWITCH LOGFILE</u> (mais pas systématiquement apparemment).
- En positionnant le paramètre <u>fast_start_mttr_target</u>.
- <u>Forcé</u> par le DBA.
- Si un <u>fichier de donnée est OFFLINE</u>.
- En cas de <u>SHUTDOWN</u>.
- Par la commande <u>ALTER SYSTEM CHECKPOINT</u>.
- Par la commande <u>ALTER DATABASE BEGIN BACKUP</u>.

> Basculement d’un fichier de journalisation a un autre.

```
Mon Jul 04 10:08:05 2011
Thread 1 advanced to log sequence 50
Current log# 2 seq# 50 mem# 0: /filesystem/oradata/DB/redoa_02.log
Current log# 2 seq# 50 mem# 1: /filesystem/oradata/DB/redob_02.log
```

> Attente lors d’un basculement - point de reprise non termine.

```
Thu Jul 07 10:42:25 2011
Thread 1 cannot allocate new log, sequence 56
Checkpoint not complete
```

> Attente lors d’un basculement - archivage non termine.

```
Thu Jul 07 10:42:25 2011
Thread 1 cannot allocate new log, sequence 57
All online logs needed archiving
```
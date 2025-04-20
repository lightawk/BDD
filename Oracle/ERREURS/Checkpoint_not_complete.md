# checkpoint not complete [-oracle]

La base Oracle genere trop rapidement des redologs et l'erreur "checkpoint not complete" apparait souvent.

La rotation des redologs est trop rapide pour le process DBWriter ; l'allocation du nouveau redolog attend la fin de l'ecriture des donnees du redolog a allouer dans la base.

Il faut augmenter la taille des redologs ou augmenter le nombre de redologs.

> Positionner le paramètre LOG_CHECKPOINTS_TO_ALERT=TRUE afin d'observer le demarrage et l'arret du checkpoint dans altert.log.

> Positionner le paramètre "archive_lag_target" a 0 pour éviter les messages du type "checkpoint not complete".

```
ALTER SYSTEM SET ARCHIVE_LAG_TARGET=0 SCOPE=BOTH;
```

## Augmenter la taille ou le nombre de groupes de redologs

> Il faut supprimer les groupes inactifs, les recreer, basculer dessus, puis refaire la suppression & recreation sur les autres.

```
ALTER DATABASE DROP LOGFILE GROUP ?;
rm /prod0?/u0?/oradata/${ORACLE_SID}/redoa_${ORACLE_SID}_01.log
rm /prod0?/u0?/oradata/${ORACLE_SID}/redob_${ORACLE_SID}_01.log
ALTER DATABASE ADD LOGFILE GROUP ? (
  '/prod0?/u0?/oradata/${ORACLE_SID}/redoa_${ORACLE_SID}_01.log', 
  '/prod0?/u0?/oradata/${ORACLE_SID}/redob_${ORACLE_SID}_01.log'
) SIZE 512M;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM CHECKPOINT;
```
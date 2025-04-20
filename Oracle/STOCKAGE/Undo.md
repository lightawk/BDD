# tablespace undo [-oracle]

Le tablespace undo est reserve exclusivement a l'annulation des commandes DML comme update, insert, etc.

Lorsqu'on execute l'ordre delete Oracle commence par copier les lignes a supprimer dans le tablespace undo et ensuite indique que les blocs contenant les donnees dans le tablespace d'origine sont libres.

Un rollback permet de revenir en arriere alors que le commit supprimera les lignes du tablespace undo, c'est pourquoi un "delete" est si long : deux ecritures pour une suppression.

Le tablespace undo est unique a une instance car en RAC il y a autant d'undo que d'instance de base de donnees et est guide par les parametres suivants du fichier d'initialisation de la base.

Si l'option AUTOEXTEND a ete appliquee sur un tablespace undo celui-ci peut atteindre une taille tres importante.

> Status.

```
ACTIVE    => Extent undo actif utilise par une transaction.
EXPIRED   => Extent undo expire depasse la valeur du parametre undo retention.
UNEXPIRED => Extent undo non encore expire requis pour honorer le parametre undo_retention.
```

> Consultation.

```
v$undostat        => Contient les statistiques d’utilisation du tablespace undo > utile pour le reglage.
v$rollstat        => Informations sur les undo segments du tablespace.
v$transaction     => Informations sur les images avant ; les transactions actives dans le systeme.
dba_undo_extents  => Information sur l’utilisation du tablespace en terme de stockage.
dba_hist_undostat => Informations sur les snapshots qui alimentent la vue v$undostat.
dba_rollback_segs => Etats varies des segments undo.
```

> Modifier le tablespace undo par defaut.

```
ALTER SYSTEM SET undo_tablespace=UNDOTBS2 scope=both;
```

## Saturation et renommage

> Demarrer la base.

```
sqlplus / as sysdba
STARTUP;
```

> Creer un undotbs transitoire.

```
CREATE UNDO TABLESPACE UNDOTBS2 DATAFILE
'/filesystem/u08/oradata/${ORACLE_SID}/undotbs2_${ORACLE_SID}_01.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED,
'/filesystem/u09/oradata/${ORACLE_SID}/undotbs2_${ORACLE_SID}_02.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED,
'/filesystem/u08/oradata/${ORACLE_SID}/undotbs2_${ORACLE_SID}_03.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED,
'/filesystem/u09/oradata/${ORACLE_SID}/undotbs2_${ORACLE_SID}_04.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED;
```

> Changer l'affectation du tablespace undo.

```
ALTER SYSTEM SET undo_tablespace=UNDOTBS2 scope=both;
```

> Verifier qu'aucune autre transaction ne pointe sur l'ancien tablespace.

```
SELECT TO_CHAR (s.SID) || ',' || TO_CHAR (s.serial#)       sid_serial,
       NVL (s.username, 'None')                            orauser,
       s.program,
       r.NAME                                              undoseg,
       t.used_ublk * TO_NUMBER (x.VALUE) / 1024 || 'K'     "Undo",
       t1.tablespace_name
  FROM SYS.v_$rollname     r,
       SYS.v_$session      s,
       SYS.v_$transaction  t,
       SYS.v_$parameter    x,
       dba_rollback_segs   t1
 WHERE     s.taddr = t.addr
       AND r.usn = t.xidusn(+)
       AND x.NAME = 'db_block_size'
       AND t1.segment_id = r.usn
       AND t1.tablespace_name = 'UNDOTBS';
```

> Supprimer l'ancien tablespace.

```
DROP TABLESPACE UNDOTBS INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
```

> Si blocage verifier les rollbacks segments online et les mettre offline.

```
SELECT segment_name,
       owner,
       tablespace_name,
       status
  FROM dba_rollback_segs
 WHERE tablespace_name = 'UNDOTBS' AND status = 'ONLINE';

ALTER ROLLBACK SEGMENT "_SYSSMU3$" OFFLINE;
```

> Creer un tablespace undo conforme au nommage.

```
CREATE UNDO TABLESPACE UNDOTBS DATAFILE
'/filesystem/u08/oradata/${ORACLE_SID}/undotbs_${ORACLE_SID}_01.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED,
'/filesystem/u09/oradata/${ORACLE_SID}/undotbs_${ORACLE_SID}_02.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED,
'/filesystem/u08/oradata/${ORACLE_SID}/undotbs_${ORACLE_SID}_03.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED,
'/filesystem/u09/oradata/${ORACLE_SID}/undotbs_${ORACLE_SID}_04.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED;
```

> Refaire pointer la base sur le nouvel undotbs.

```
ALTER SYSTEM SET undo_tablespace=UNDOTBS SCOPE=BOTH;
```

> Supprimer le undotbs transitoire.

```
DROP TABLESPACE UNDOTBS2 INCLUDING CONTENTS AND DATAFILES;
```
# sql [-sessions]

## v\$session & v\$process

> Affiche les principales informations sur les sessions courantes actives (hors utilisateur SYS).

> <u>v$process</u> est utilise pour afficher le numero de processus au niveau de l'OS.

```
SELECT sid,
       s.serial#,
       spid     "pid",
       s.username,
       status,
       osuser,
       machine,
       s.program,
       TYPE,
       sql_id,
       logon_time,
       event,
       state
  FROM v$session s
  JOIN v$process p ON paddr = addr
 WHERE s.username <> 'SYS'
 AND status = 'ACTIVE';
```

> Total des sessions actives et inactives par machine - username.

```
  SELECT s.machine,
         s.username,
         COUNT (DECODE (s.status, 'ACTIVE', 1))       AS active_con,
         COUNT (DECODE (s.status, 'INACTIVE', 1))     AS inactive_con,
         COUNT (*)                                    AS total_con
    FROM v$session s
   WHERE TYPE <> 'BACKGROUND'
GROUP BY username, machine
ORDER BY total_con DESC;
```

> Genere les commandes de kill session RMAN au niveau base & OS (commande kill). Tuer toutes les sessions appartenant a RMAN (utile pour stopper une sauvegarde ou une restauration en cours).

```
SELECT 'ALTER SYSTEM KILL SESSION'
       || ' '''
       || sid
       || ', '
       || serial#
       || ''''
       || ' IMMEDIATE;'
  FROM v$session
 WHERE program LIKE 'rman%';
```

```
SELECT 'kill -9 ' || spid
  FROM v$session s JOIN v$process ON paddr = addr
 WHERE s.program LIKE 'rman%';
```

> Total des sessions actives et inactives par machine - username.

```
  SELECT s.machine,
         s.username,
         COUNT (DECODE (s.status, 'ACTIVE', 1))       AS active_con,
         COUNT (DECODE (s.status, 'INACTIVE', 1))     AS inactive_con,
         COUNT (*)                                    AS total_con
    FROM v$session s
   WHERE TYPE <> 'BACKGROUND'
GROUP BY username, machine
ORDER BY total_con DESC;
```

## v$locked_object

> Affiche les sessions qui ont pose un verrou.

```
SELECT sid,
       serial#,
       oracle_username,
       os_user_name,
       object_name,
       DECODE (locked_mode,
               0, 'Verrou demande mais pas encore obtenu',
               1, 'Null',
               2, 'Row Share Lock',
               3, 'Row Exclusive Table Lock',
               4, 'Share Table Lock',
               5, 'Share Row Exclusive Table Lock',
               6, 'Exclusive Table Lock')    "LOCK_MODE"
  FROM v$locked_object
       JOIN dba_objects USING (object_id)
       JOIN v$session ON session_id = sid;
```

## v$resource_limit

> Affiche le nombre de sessions & processes en cours d'utilisation, le nombre max. atteint depuis le dernier demarrage et leur valeur limite.

```
SELECT resource_name,
       current_utilization,
       max_utilization,
       limit_value
  FROM v$resource_limit
 WHERE resource_name IN ('sessions', 'processes');
```
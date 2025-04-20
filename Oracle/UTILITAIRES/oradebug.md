# oradebug [-oracle]

Pour tracer une session sous Oracle on utilise la commande "oradebug".

> Chercher le SPID de la session.

```
SELECT spid
  FROM v$process p, v$session s
 WHERE p.addr = s.paddr AND sid = '?';
```

> Lancer la trace.

```
oradebug SETOSPID 2961508;
oradebug event 10046 trace name context forever, level 8;
```

> Verification du repertoire ou le fichier de trace sera cree.

```
SHOW PARAMETER user_dump;
```

> Arreter la trace.

```
oradebug event 10046 trace name context off;
```

> Prendre un "systemstate dump".

```
oradebug unlimit;
oradebug dump systemstate 266;
```
# sql [-tablespaces]

## dba_temp_files

> Selectionne les datafiles du tablespace TEMP.

```
  SELECT tablespace_name, file_name
    FROM dba_temp_files
   WHERE tablespace_name = 'TEMP'
ORDER BY 2;
```

## dba_data_files | dba_free_space

> Selectionne les datafiles du tablespace UNDO.

```
  SELECT tablespace_name, file_name
    FROM dba_data_files
   WHERE tablespace_name = 'UNDOTBS'
ORDER BY 2;
```

> Liste les tablespaces > a ?% d'occupation.

```
SELECT d.tablespace_name
       nom_tablespace,
   ROUND (a.bytes / 1024 / 1024, 1)
       Taille_Allouee_MB,
   ROUND ((a.bytes / 1024 / 1024) - NVL (b.kbytes_free / 1024, 0), 1)
       Espace_utilisee_MB,
   ROUND (NVL (b.kbytes_free / 1024, 0), 1)
       Espace_libre_MB,
   ROUND (
         (((a.bytes / 1024) - NVL (b.kbytes_free, 0)) / (a.bytes / 1024))
       * 100,
       1)
       PCT_Espace_utilisee,
   ROUND (DECODE (a.maxbytes, 0, a.bytes, a.maxbytes) / 1024 / 1024, 1)
       Taille_MAX_MB,
   ROUND (
       (  (  (a.bytes / 1024 / 1024)
           / (DECODE (a.maxbytes,
                      0, a.bytes / 1024 / 1024,
                      a.maxbytes / 1024 / 1024)))
        * 100),
       1)
       PCT_Taille_Alloue_MAX,
   ROUND (
       (  (  ((a.bytes / 1024 / 1024) - NVL (b.kbytes_free / 1024, 0))
           / (DECODE (a.maxbytes,
                      0, a.bytes / 1024 / 1024,
                      a.maxbytes / 1024 / 1024)))
        * 100),
       1)
       PCT_Espace_utilisee_MAX
FROM (  SELECT tablespace_name, SUM (bytes) bytes, SUM (maxbytes) maxbytes
        FROM dba_data_files
    GROUP BY tablespace_name) a,
   (  SELECT tablespace_name, SUM (bytes) / 1024 Kbytes_free
        FROM dba_free_space
    GROUP BY tablespace_name) b,
   dba_tablespaces  d
WHERE     d.tablespace_name = a.tablespace_name(+)
   AND d.tablespace_name = b.tablespace_name(+)
   AND d.contents NOT LIKE 'TEMPORARY'
   AND ROUND (
           (  (  ((a.bytes / 1024 / 1024) - NVL (b.kbytes_free / 1024, 0))
               / (DECODE (a.maxbytes,
                          0, a.bytes / 1024 / 1024,
                          a.maxbytes / 1024 / 1024)))
            * 100),
           1) >
       90;
```

## v\$sort_usage | v\$parameter | v\$session

> Identifier une forte consommation de l'utilisation du tablespace temporaire - colonnes "extents" et "space".

```
SELECT se.osuser,
     se.username,
     se.sid,
     su.extents,
     su.blocks * TO_NUMBER (RTRIM (p.VALUE))     AS Space,
     tablespace
FROM v$sort_usage su, v$parameter p, v$session se
WHERE p.name = 'db_block_size' AND su.session_addr = se.saddr
ORDER BY se.username, se.sid;
```

## v\$session | v\$transaction | v\$rollstat

> Identifier les sessions bloquantes.

```
SELECT s.sid,
       s.serial#,
       t.start_time,
       t.xidusn,
       s.username
  FROM v$session s, v$transaction t, v$rollstat r
 WHERE     s.saddr = t.ses_addr
       AND t.xidusn = r.usn
       AND (   (r.curext = t.start_uext - 1)
            OR ((r.curext = r.extents - 1) AND t.start_uext = 0));
```

## v\$rollname | v\$session | v\$transaction | v\$parameter

> Verifier qu'aucune transaction ne pointe sur le tablespace undo.

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
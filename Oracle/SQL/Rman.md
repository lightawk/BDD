# sql [-rman]

## v$session_longops

> Suivre une restauration.

```
SET LINES 200 PAGES 99
COL username FORMAT A15
COL opname FORMAT A50
COL target FORMAT A30
COL %DONE FORMAT A5
COL remaining_time FORMAT A20
  SELECT b.username,
         a.sid,
         a.serial#,
         b.opname,
         b.target,
            ROUND (
                  b.sofar
                * 100
                / (CASE WHEN b.totalwork > 0 THEN b.totalwork ELSE b.sofar END),
                0)
         || '%'
             AS "%DONE",
         TO_CHAR (TO_DATE (b.time_remaining, 'sssss'), 'hh24:mi:ss')
             remaining_time,
         TO_CHAR (b.start_time, 'YYYY/MM/DD HH24:MI:SS')
             start_time,
         TO_CHAR (SYSDATE + b.time_remaining / 86400, 'YYYY/MM/DD HH24:MI:SS')
             estimated_end_time,
         b.sql_id
    FROM v$session_longops b, v$session a
   WHERE a.sid = b.sid AND sofar != totalwork
ORDER BY 6, 7;
```

Le nombre de lignes correspond au nombre de channels alloues.

```
/*
 * @def suivre une restauration
 *   le nombre de lignes correspond au nombre de channels alloues
 */
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
SELECT sid,
       serial#,
       TO_CHAR (TO_DATE (elapsed_seconds, 'sssss'), 'hh24:mi:ss')
           duree,
       start_time,
       sofar,
       totalwork,
       ROUND (sofar / totalwork * 100, 2)
           "%_COMPLETE",
       ROUND (time_remaining / 60, 2)
           "RESTANT_EN_Min"
  FROM v$session_longops
 WHERE     opname LIKE 'RMAN%'
       AND opname NOT LIKE '%aggregate%'
       AND totalwork != 0
       AND sofar <> totalwork;
```

## rc_backup_piece | rc_database_incarnation

> Recupere l'incarnation, la date de fin de sauvegarde du controlfile a partir du tag du fichier de controle.

@cn    sqlplus RMAN_SLXX/RMAN_SLXX@CATRMAN.
@param tag - CTLHPRD?_AAAAMMJJ_0|1_RMDBD|F?.

```
ALTER SESSION SET nls_date_format='DD/MM/YYYY HH24:MI:SS';
WITH fin AS (
SELECT completion_time     temps
  FROM rc_backup_piece
 WHERE tag LIKE 'CTL?%'
),
incarnations AS (
SELECT dbinc_key,
       resetlogs_time                                                         debut,
       NVL (LEAD (resetlogs_time) OVER (ORDER BY resetlogs_time), SYSDATE)    fin
  FROM rc_database_incarnation
)
SELECT dbinc_key, fin.temps
  FROM fin, incarnations
 WHERE fin.temps BETWEEN incarnations.debut AND incarnations.fin;
```

> Recupere l'incarnation, la date de fin de sauvegarde du controlfile et son tag a partir d'une date.

@cn    sqlplus RMAN_SLXX/RMAN_SLXX@CATRMAN
@param tag - JJ/MM/AAAA HH:MM:SS

```
ALTER SESSION SET nls_date_format='DD/MM/YYYY HH24:MI:SS';
WITH fin AS (
SELECT tag tag, completion_time temps
  FROM rc_backup_piece
 WHERE completion_time =
       (SELECT MAX (completion_time)
          FROM rc_backup_piece
         WHERE     completion_time <=
                   TO_DATE ('?', 'DD/MM/YYYY HH24:MI:SS')
               AND tag LIKE 'CTL%')
),
incarnations AS (
SELECT dbinc_key,
       resetlogs_time                                                         debut,
       NVL (LEAD (resetlogs_time) OVER (ORDER BY resetlogs_time), SYSDATE)    fin
  FROM rc_database_incarnation
)
SELECT dbinc_key, fin.temps, fin.tag
  FROM fin, incarnations
 WHERE fin.temps BETWEEN incarnations.debut AND incarnations.fin;
```

> Sauvegardes avec une partie des backupieces manquants ou expirés.

```
SET LINES 220 PAGES 999 FEED OFF
WITH
    liste
    AS
        (  SELECT REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)') tag, COUNT (*) nb
             FROM RC_BACKUP_PIECE
         GROUP BY REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)')),
    dispo
    AS
        (  SELECT REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)') tag, COUNT (*) nb
             FROM RC_BACKUP_PIECE
            WHERE status = 'A'
         GROUP BY REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)')),
    expire
    AS
        (  SELECT REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)') tag, COUNT (*) nb
             FROM RC_BACKUP_PIECE
            WHERE status != 'A'
         GROUP BY REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)'))
SELECT tag,
       l.nb     total,
       d.nb     dispo,
       e.nb     expire
  FROM liste  l
       JOIN dispo d USING (tag)
       JOIN expire e USING (tag);
```

> Sauvegardes restaurables.

```
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
WITH
    liste
    AS
        (  SELECT REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)')                         tag,
                  MAX (completion_time)                                            completion_time,
                  CASE WHEN REGEXP_SUBSTR (tag, '_[01]_') = '_0_' THEN 'OK' END    dispo
             FROM RC_BACKUP_PIECE
         GROUP BY REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)'),
                  CASE
                      WHEN REGEXP_SUBSTR (tag, '_[01]_') = '_0_' THEN 'OK'
                  END),
    expire
    AS
        (SELECT DISTINCT REGEXP_REPLACE (tag, '^(DB|CTL|SP|ARC)')     tag
           FROM RC_BACKUP_PIECE
          WHERE status != 'A'),
    dispo
    AS
        (  SELECT l.tag,
                  completion_time,
                  CASE WHEN e.tag IS NOT NULL THEN 'NON' ELSE l.dispo END    disponible
             FROM liste l LEFT JOIN expire e ON e.tag = l.tag
         ORDER BY completion_time),
    final
    AS
        (SELECT tag,
                COALESCE (disponible, 'OK')    disponible,
                CASE
                    WHEN disponible IS NULL
                    THEN
                        LAG (disponible IGNORE NULLS)
                            OVER (ORDER BY completion_time)
                    ELSE
                        disponible
                END                            restaurable
           FROM dispo)
  SELECT DISTINCT final.tag            --, final.disponible, final.restaurable
    FROM RC_BACKUP_PIECE bp
         JOIN final ON REGEXP_REPLACE (bp.tag, '^(DB|CTL|SP|ARC)') = final.tag
   WHERE bp.status = 'A' AND final.restaurable = 'OK'
ORDER BY 1;
```
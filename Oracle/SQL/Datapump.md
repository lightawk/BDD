# sql [-datapump]

> Suivi export / import.

```
SET LINES WINDOW
SET NUMFORMAT 99G990D99
COL objet FORMAT a50
COL completed_rows FORMAT 99G999G999G990
  SELECT TO_CHAR (i.start_time, 'YYYY/MM/DD HH24:MI:SS')
             start_time,
         TO_CHAR (i.last_update, 'YYYY/MM/DD HH24:MI:SS')
             last_update,
         COALESCE (i.object_long_name, i.object_name, i.name)
             objet,
         i.size_estimate / 1024 / 1024 / 1024
             estimate_gb,
         i.total_bytes / 1024 / 1024 / 1024
             total_gb,
         i.completed_bytes / 1024 / 1024 / 1024
             completed_gb,
         i.completed_rows
             completed_rows,
         sql_id,
         physical_read_bytes / 1024 / 1024 / 1024
             physical_read_gb,
         physical_write_bytes / 1024 / 1024 / 1024
             physical_write_gb
    FROM SYS.sys_export_table_01 i
         LEFT JOIN v$process p ON p.pname = i.process_name
         LEFT JOIN v$session s ON s.PADDR = p.addr
         LEFT JOIN v$sql q USING (sql_id)
   WHERE i.state = 'EXECUTING'
ORDER BY start_time;
```

## Arret un job (export ou import)

> Pour recuperer les informations du datapump job concerne.

```
SELECT job_name, state FROM dba_datapump_jobs;
```

> Stopper un job.

```
EXEC DBMS_DATAPUMP.STOP_JOB (DBMS_DATAPUMP.ATTACH('N_DATAPUMP_JOB','SYSTEM'), 1, 0);
```

## Estimation export

> Selectionne la taille approximative des schemas en Go (pour estimer la taille d'un export schema).

```
SELECT owner, (ROUND (SUM (bytes) / 1024 / 1024 / 1024)) AS Taille_Go
  FROM dba_segments
 WHERE owner IN ('SCHEMA')
GROUP BY owner;
```

> Selectionne la taille en Mo d'un objet de type TABLE ou PARTITION (pour estimer l'export).                                                                                 

```
SELECT segment_type, (ROUND (SUM (bytes) / 1024 / 1024)) AS Taille_Mo
  FROM dba_segments
 WHERE     segment_type IN ('TABLE', 'TABLE PARTITION')
       AND segment_name LIKE 'TOTO%'
GROUP BY segment_type;
```
# expdp [-oracle]

Eporter des donnes via l'utilitaire datapump expdp.

Le fichier DUMPFILE=export.dmp correspond au dump qui sera exporte.

Le répertoire de stockage du dump dans lequel doit se trouver le fichier est bien associe a un alias.

> Creation de la directory.

```
SELECT * FROM dba_directories;
CREATE OR REPLACE DIRECTORY EXPDP_DIR AS '/DUMP/DB';
GRANT READ, WRITE ON DIRECTORY EXPDP_DIR TO SCHEMA;
```

> Export datapump.

```
expdp [ USER/****** ] [ \"/ as sysdba\" ] DIRECTORY=EXPDP_DIR DUMPFILE=export.dmp LOGFILE=logfile.log [ FULL=Y | SCHEMAS=schema1, schema2.. | TABLES=table1, table2.. ]
```

> Estimation d'un export full via un log de taille de dump.

```
expdp USER/****** DIRECTORY=EXPDP_DIR LOGFILE=logfile.log FULL=Y ESTIMATE_ONLY=Y
```

> Options generiques.

```
FULL=Y | TABLES=table | SCHEMAS=schema
```

> Nombre de fichiers que va generer le dump et qui va de pair avec la clause "%U" DUMPFILE=export_%U.dmp.

```
PARALLEL=?
```

Mettre idealement un chiffre correspondant au nombre de CPU du serveur.

> Preciser la taille du fichier dump avec l'option FILESIZE.

```
FILESIZE=..
```

> Decouper le dump en plusieurs fichiers avec la clause DUMPFILE=..%U.dmp.

```
DUMPFILE=export_%U.dmp
```
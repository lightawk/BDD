# impdp [-oracle]

Importer des donnes via l'utilitaire datapump impdp.

Le fichier DUMPFILE=export.dmp doit correspondre a un dump precedemment exporte.

> Creation directory.

```
SELECT * FROM dba_directories;
CREATE OR REPLACE DIRECTORY EXPDP_DIR AS '/DUMP/DB';
GRANT READ, WRITE ON DIRECTORY EXPDP_DIR TO SCHEMA;
```

> Import datapump.

```
impdp USER/******@DB DIRECTORY=EXPDP_DIR DUMPFILE=export.dmp LOGFILE=logfile.log [ FULL=Y ]
```

> Importer un schema du catalogue rman en transformant les OIDS.

```
impdp USER/******
      DIRECTORY=RMAN_DIR
      DUMPFILE=expdp_RMAN_05-02-2018_183854.dmp
      LOGFILE=impdp_RMAN.log
      SCHEMAS=RMAN
      TRANSFORM=OID:N
```

> Transformer l'OID.

```
TRANSFORM=OID:N
```

> Si la table existe importer les donnees a la suite de celles existantes.

```
TABLE_EXISTS_ACTION=APPEND
```

> Renommer un objet au niveau des metadonnees.

```
REMAP_SCHEMA=schema_1:schema_2
REMAP_TABLE=table_1:table_2
REMAP_TABLESPACE=tablespace_1:tablespace_2
```
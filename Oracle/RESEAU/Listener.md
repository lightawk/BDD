# listener [-oracle]

Un listener est un evenement qui permet a la base d'etre a l'ecoute d'une demande de connexion provenant de l'extérieur. Contient toutes les informations de connexion. "lsnrctl" ira lire dans ce fichier côté serveur.

La ligne (KEY = EXTPROC) doit être unique pour chaque listener i.e ajouter par la suite un numero pour qu'il soit unique EXTPROC1, EXTPROC2, etc.

> Editer le fichier des listener pour y ajouter une entree.

```
cd ${TNS_ADMIN} /u01/oracle/19c/db_1/network/admin
vi listener.ora
```

> Configurer une librairie externe via un listener.

```
(SID_DESC =
  (SID_NAME = PLSExtProc)
  (ORACLE_HOME = /u01/oracle/19c/db_1)
  (PROGRAM = extproc)
  (ENVS = "EXTPROC_DLLS=ONLY:/app/../lib/rext.so")
)
```

La librairie est definie dans le fichier suivant : /u01/oracle/19c/db_1/hs/admin/extproc.ora.

SELECT * FROM dba_libraries WHERE owner='?';

> Listener standalone.

```
SUBSCRIBE_FOR_NODE_DOWN_EVENT_LISTENER_DB=OFF

LISTENER_DB =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = serveur)(PORT = 00000))
    )
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC) (KEY = EXTPROC))
    )
  )

SID_LIST_LISTENER_DB =
  (SID_LIST =
    (SID_DESC =
      (ORACLE_HOME = /u01/oracle/19c/db_1)
      (SID_NAME = DB)
    )
   (SID_DESC =
     (SID_NAME = PLSExtProc)
     (ORACLE_HOME = /u01/oracle/19c/db_1)
     (PROGRAM = extproc)
     (ENVS = "EXTPROC_DLLS=ONLY:/app/helios/lib/rext.so")
   )
  )
```

> Listener multitenant.

```
SUBSCRIBE_FOR_NODE_DOWN_EVENT_LISTENER_DB=OFF
USE_SID_AS_SERVICE_LISTENER_DB=ON

LISTENER_DB =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = serveur)(PORT = 00000))
    )
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC))
    )
  )

SID_LIST_LISTENER_DB =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = DB)
      (ORACLE_HOME = /u01/oracle/19c/db_1)
      (SID_NAME = DB)
    )
    (SID_DESC =
      (SID_NAME = PLSExtProc)
      (ORACLE_HOME = /u01/oracle/19c/db_1)
      (PROGRAM = extproc)
      (ENVS = "EXTPROC_DLLS=ONLY:/app/helios/lib/rext.so")
    )
    (SID_DESC =
      (GLOBAL_DBNAME = DB_PDB)
      (ORACLE_HOME = /u01/oracle/19c/db_1)
      (SID_NAME = DB)
    )
  )
```
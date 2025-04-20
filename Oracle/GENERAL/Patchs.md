# patchs noyau et base [-oracle]

## Exporter ORACLE_SID

export ORACLE_SID=?

## Exporter les variables d'environnement

```
env | grep ORA
export ORACLE_HOME=/u01/oracle/19c/db_1
export ORA_NLS10=/u01/oracle/19c/db_1/nls/data
export PATH=/app/exploit/hx_tools/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/java5/jre/bin:/usr/java5/bin:/u01/oracle/12c/db_1/bin:.:/u01/oracle/agent/agent_13.2.0.0.0/bin
export TNS_ADMIN=/u01/oracle/19c/db_1/network/admin
```

## Arret des bases et des listeners

Avant chaque application d'un patch qui touche le noyau de la base il faut impérativement arrêter les bases et les listeners sur la machine concernée. Le patch applique des modifications sur le noyau i.e les fichiers binaires de la base.

```
SHUTDOWN IMMEDIATE;
lsnrctl stop LISTENER_${ORACLE_SID}
```

## Installation de Opatch (outil qui va permettre de patcher le moteur)

> Copie du .zip de OPatch dans le répertoire /tmp (par exemple).

```
cp /app/archive_env/DBA_PROD/patch_ora12c_AVRIL_2018/*.zip /tmp
```

> Déplacement de l'ancienne version de OPatch dans un autre répertoire pour le sauvegarder.

```
mv ${ORACLE_HOME}/OPatch /DUMP/OPatch_save
```

> Décompression de OPatch dans ORACLE_HOME.

```
unzip p6880880_122010_AIX64-5L_12_2_0_1_13.zip -d ${ORACLE_HOME}
```

## Application du patch

> Décompression de l'archive dans /tmp/repertoirePatch.

```
unzip /mnt/oracle/patchs/p16400122_112040_AIX64-5L.zip -d /tmp/p16400122_112040_AIX64-5L
```

> Se placer dans le repertoire du patch à appliquer avant d'appliquer la suite des commandes.

```
cd /tmp/p16400122_112040_AIX64-5L/16400122
${ORACLE_HOME}/oui/bin/attachHome.sh
${ORACLE_HOME}/db_1/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./
```

> Application du patch.

```
${ORACLE_HOME}/db_1/OPatch/opatch apply
```

> Rechercher le patch 16400122 dans lsinventory.

```
${ORACLE_HOME}/db_1/OPatch/opatch lsinventory | grep 16400122
```

## Redémarrage des bases et des listeners

```
STARTUP;
lsnrctl start LISTENER_${ORACLE_SID}
```

## Application du datapatch

Le datapatch consiste en l'application du patch moteur dans la base de données.

> Applique le patch dans la base.

```
${ORACLE_HOME}/OPatch/datapatch -verbose
```

> Recompiler l'ensemble des objets.

```
@?/rdbms/admin/utlrp
```

> Informations à propos des mises à jour et de mises à jour critiques de correctifs.

```
SELECT * FROM dba_registry_history;
```

> Vérifier si le patch 28527183 est installé en base.

```
SELECT patch_id, status, action, description, action_time FROM dba_registry_sqlpatch WHERE patch_id='28527183';
```

## Rollback patch / datapatch

> Rollback du patch 16400122 au niveau du noyau.

```
${ORACLE_HOME}/OPatch/opatch rollback -id 16400122
```

> Rollback du patch 27674384 au niveau de la base.

```
${ORACLE_HOME}/OPatch/datapatch -rollback 27674384
```
# oracle entreprise manager (oem) [-oracle]

Le Grid ou Cloud Control est l'autre nom de "Oracle Entreprise Manager" (OEM) qui est un utilitaire permettant de visualiser les données des bases via un navigateur web à l'aide d'une interface graphique.

Aller dans "Configurer -> Notifications -> Ma programmation de notification" pour recevoir les alertes du Cloud dans la messagerie.

## Oracle Entreprise Manager (OEM) - Cloud Control

Ensemble d'outils web pour monitorer les apps et materiel de chez Oracle.

### Plugins

```
- "Configurer -> Extensibilite -> Modules d'extension"
- Derouler menu "base de donnees" (plugin base de donnees)
```

### Gold Image

```
- "Gerer toutes les images -> Creer"
- "Action -> Creer"
- Definir la version en cours (pour activer la Gold Image)
- Deployer une gold image en tant qu'agent
```

## Oracle Management Server (OMS)

Middleware (intergiciel) est une passerelle entre les differentes applications ; réseau d'échange d'informations entre différentes applications informatiques.

### Commandes de demarrage et d'arrêt pour OMS

```
${OMS_HOME} => /u01/oracle/oms/middleware/oms
${OMS_HOME}/bin/emctl start|stop oms -all
```

> Demarrage OMS.

```
sqlplus / as sysdba
STARTUP;
EXIT;
lsnrctl start LISTENER_...
${OMS_HOME}/bin/emctl start oms
${AGENT_HOME}/bin/emctl start agent
```

> Arret OMS.

```
${AGENT_HOME}/bin/emctl stop agent
${OMS_HOME}/bin/emctl stop oms
lsnrctl stop LISTENER_...
sqlplus / as sysdba
SHUTDOWN IMMEDIATE;
EXIT;
```

### Release Update [ RU ]

> A effectuer sur le serveur ou est installe OMS.

> Repertoire qui contient les patchs telecharges (".zip").

```
/mnt/oem135/OMS_RU17
```

> Creer le repertoire ou seront stockes les patchs.

```
mkdir -p /tmp/RU17
```

> Decompresser le patch.

```
unzip -qo /mnt/oem135/OMS_RU17/p35460709_135000_Generic.zip
```

> Verifier le deploiement.

```
export ORACLE_HOME=${OMS_HOME}
${OMS_HOME}/OMSPatcher/omspatcher apply -analyze -property_file /u01/oracle/oms/wlskeys/OMSPatcher.properties
Enter DB user name : SYS
Enter 'sys' password :${ORACLE_SID}_78_EMREP
```

> Proceder au deploiement.

```
${OMS_HOME}/OMSPatcher/omspatcher apply -property_file /u01/oracle/oms/wlskeys/OMSPatcher.properties
```

### Securite

> A effectuer sur le serveur ou est installe OMS.

> Mettre a jour la version de OPatch.

```
java -jar <PATCH_HOME>/6880880/opatch_generic.jar -silent oracle_home=<ORACLE_HOME_LOCATION> -invPtrLoc <INVENTORY_LOCATION>
cd /tmp/RU17/6880880
$OMS_HOME/oracle_common/jdk/bin/java -jar opatch_generic.jar -silent oracle_home=$OMS_HOME [ -invPtrLoc $OMS_HOME/oraInst.loc ]
$OMS_HOME/OPatch/opatch version
```

> Appliquer les patchs.

```
export ORACLE_HOME=${OMS_HOME}
cd /tmp/RU17
$OMS_HOME/OPatch/opatch apply 1221419 (patch coherence)
$OMS_HOME/OPatch/opatch apply 35893811 (patch WebLogic)
```

```
$OMS_HOME/OPatch/opatch napply -id 1221419,35893811
```

> Lister tous les patches (plus simple que lsinventory).

```
$OMS_HOME/OPatch/opatch lspatches
35893811;WLS PATCH SET UPDATE 12.2.1.4.231010
1221419;Coherence Cumulative Patch 12.2.1.4.19
```

## Oracle Management Agent (OMA)

Correspond a l'agent Oracle qui permet de surveiller les bases de donnees.

### Commandes de demarrage et d'arrêt pour OMA

```
${AGENT_HOME} => /u01/oracle/oms/middleware/agent/agent_13.5.0.0.0
${AGENT_HOME}/bin/emctl start|stop agent
```

### Release Update [ RU ]

> Sur l'interface graphique OEM Web.

```
- Menu "Entreprise -> Provisionnement & application de patches -> Patches enregistres"
- Telecharger -> Fichier zip de patch
- Cliquer sur le numero du patch - creer un plan (AGT135_RU17) - Ajouter
- Type de cible -> Selectionner "Agent"
```

> Demarrage - arret BIP uniquement.

```
${OMS_HOME}/bin/emctl start|stop oms -bip_only
```
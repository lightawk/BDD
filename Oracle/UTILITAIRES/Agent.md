# agent [-oracle]

Aller sur le Cloud Control 13 dans la liste des agents disponibles "Configurer -> Gérer Cloud Control -> Agents".

Cliquer sur l'agent que l'on souhaite désinstaller et le désinstaller ainsi que les composants qu'il surveille "Agent -> Configuration de cible -> Désinstallation de l'agent".

Puis se connecter au serveur concerné.

## Sur le serveur hebergeant la base du Cloud Control (EMREP)

> Se connecter a Entreprise Manager en ligne de commandes (> ssh mhmudb3).

```
oracle@mhmudb3:/home/oracle> $OMS_HOME/bin/emcli login -username=sysman
```

> Faire la synchronisation.

```
oracle@mhmudb3:/home/oracle> $OMS_HOME/bin/emcli sync
oracle@mhmudb3:/home/oracle> $OMS_HOME/bin/emcli get_supported_platforms
mkdir -p /oem/AGENTIMAGE
oracle@mhmudb3:/home/oracle> $OMS_HOME/bin/emcli get_agentimage -destination=/oem/AGENTIMAGE -platform="IBM AIX on POWER Systems (64-bit)" -version=13.5.0.0.0
```

> Copier le dossier d'installation.

```
oracle@mhmudb3:/oem/AGENTIMAGE> ls 13.5.0.0.0_AgentCore_212.zip
oracle@mhmudb3:/oem/AGENTIMAGE> cp 13.5.0.0.0_AgentCore_212.zip /app/archive_env/DBA_PROD/AGENT
```

## Sur le serveur a surveiller

> Arreter l'agent.

```
${AGENT_HOME}/bin/emctl stop agent
```

> Supprimer les anciens repertoires.

```
rm -fr /u01/oracle/agent/agent_13.2.0.0.0
rm -fr /u01/oracle/agent/agent_inst
rm -fr /u01/oracle/agent/
```

> Creer le repertoire de l'agent.

```
mkdir -p /u01/oracle/agent/
```

> Decompresser l'archive.

```
unzip /app/archive_env/DBA_PROD/AGENT/13.5.0.0.0_AgentCore_212.zip -d /tmp/agtImg
```

> Ajouter les éléments suivants dans le fichier de reponse.

```
vi /tmp/agtImg/agent.rsp
OMS_HOST=mhmudb3
EM_UPLOAD_PORT=1159
AGENT_BASE_DIR=/u01/oracle/agent
AGENT_PORT=3872
EM_INSTALL_TYPE="AGENT"
ORACLE_HOME=${AGENT_HOME}
ORACLE_HOSTNAME=vhxud00
```

> Lancer l'installation.

```
/tmp/agtImg/agentDeploy.sh AGENT_BASE_DIR=/u01/oracle/agent RESPONSE_FILE=/tmp/agtImg/agent.rsp PROPERTIES_FILE=/tmp/agtImg/agentimage.properties INVENTORY_LOCATION=/u01/oracle/oraInventory -ignorePrereqs
```

> Démarrer l'agent.

```
${AGENT_HOME}/bin/emctl start agent
```

> Sécuriser l'agent https.

```
${AGENT_HOME}/bin/emctl secure agent
```

> Vérifier l'état de l'agent.

```
${AGENT_HOME}/bin/emctl clearstate agent
```

> Charger l'agent vers EMREP.

```
${AGENT_HOME}/bin/emctl upload agent
```

> Voir son statut.

```
${AGENT_HOME}/bin/emctl status agent
```

> Pour voir l'agent dans mhmudb3 OEM.

```
${AGENT_HOME}/bin/emctl config agent addInternaltargets
```
# PostgreSQL

## Installation

```
apt-get install postgresql
```

## Commandes

```
service postgresql status
service postgresql stop
service postgresql start
service postgresql reload
```

## Configuration

> Instance « main » par défaut.

```
/etc/postgresql/<version>/main
```

> Principaux fichiers de configuration.

```
postgresql.conf
pg_hba.conf
```

## Données

```
/var/lib/postgresql/<version>/main.
```

## Binaires

```
/usr/lib/postgresql/<version>/bin.
```

#### pg_ctl

> Lancement de PostgreSQL.

```
+- Gestion de l'instance / cluster.
+- start/stop/kill.
+- init: creation autre espace de datas.
+- Promote: promotion du standby.
```

#### psql

> Avoir accès à un client pour se connecter (pgAdmin).

```
+- Client de connexion a un cluster.
+- Précision utilisateur et/ou DB.
+- Passage de SQL en CLI ou script SQL.
```

#### pg_createcluster

> Création d’un cluster / instance ; répertoire /etc /var/lib ; Debian.

```
+- Création d'un cluster (une instance PG).
+- Création des répertoires /etc /var/lib.
```

#### pg_dropcluster

```
+- Suppression d'un cluster.
+- Cluster arrêté.
```

#### pg_lscluster

```
+- Lister les cluster.
```

#### pg_ctlcluster

```
+- Equivalent du pg_ctl.
+- Contrôle du cluster (stop/start).
```

#### pg_dump

```
+- Sauvegarde d’une instance (format plain-text ou binaire).
```

#### pg_dump_all

```
+- Sauvegarde intégrale au format binaire.
```

#### pg_restore

```
+- Restauration à partir d'une sauvegarde (pg_dumpall).
```

### Wrappers

```
createdb
dropdb
createuser
dropuser
```

### Maintenance

#### reindexdb

```
+- Réindexation des index.
```

#### vacuumdb

```
+- Ménage.
```

#### vacuumlo

```
+- Suppression des large objects.
```

### Système

#### pg_controldata

```
+- Vérifie l'état du serveur et les informations critiques.
```

#### pg_resetwal

```
+- En cas de crash avec « Write Ahead Logging » (WAL).
+- Datas inconsistentes.
```

#### pg_receive_wal

```
+- Récupération des WAL d’une autre BDD.
```

#### pg_basebackup

```
+- Récupération des données par une connexion à une autre base.
```

> Binaire principal qui va lancer d’autres « forks » / process.

```
+- ps aux | grep  postgres
/usr/lib/postgresql/<version>/bin/postgres -D /var/lib/postgresql/<version>/main -c config_file=/etc/postgresql/<version>/main/postgresql.conf
```

> Localisation des données avec l’option « -D » dans /var/lib/postgresql/<version>/main.

> Fichier de configuration avec l’option « -c » dans config_file=/etc/postgresql/<version>/main/postgresql.conf.

### Démarrage

### Affectation de la mémoire partagée

```
+- shared_buffers (défaut 128 Mb).
+- Parametre dans postgresql.conf.
```

### Lecture des fichiers de controle

```
+- "pg_control" dans $PGDATA(/var/lib/postgresql/<version>/main)/global/pg_control.
```

### WAL (Write Ahead Logging)

```
+- Vérification Checkpoint.
+- Fichiers spécifiques qui enregistrent toutes les transactions (relance).
```

### Arrêt

```
1. OS: Signal d'arrêt (si type SIGINT).
2. Nouvelles connexions coupées.
3. Stoppe les autres connexions.
4. Rollback des transactions en cours (si type SIGTERM).
5. Ecriture d'un checkpoint.
6. Ecriture de la mémoire sur le disque.
7. Mise a jour des fichiers de contrôle.
```

### Process

#### Processus père

```
+- /usr/lib/postgresql/<version>/bin/postgres
```

#### Processus fils

```
+- checkpointer (=poser des jalons mémoire/disque ; écrire la mémoire sur disque).
+- background writer (=écriture des dirty pages sur disque).
+- walwriter (=écriture des WAL buffer sur disque).
+- autovacuum launcher (=nettoyer les tables ; tâche de maintenance).
+- stats collector (=calcule les statistiques ; stockées dans "pg_stats_temp").
+- logical replication launcher (=réplication logique pour les standby qui se connectent).
+- postgres postgres (idle) (=processus de connexion qui sont affectes pour chaque connexion ; nom DB et USER ; "IDLE" si en attente). Parametre "work memory" alloue pour chaque connexion.
```

### Memoire

```
+- shared memory: shared buffer (=128M), wal buffer & c-log-buffer.
+- wal buffers.
+- work memory (=tri, classements, filtres, jointures).
+- maintenance work memory (=vacuum, défragmentation, réindexation).
```

### Repertoires

#### Fichiers de donnees

> /var/lib/postgresql/<version>/main (=fichiers liés aux données).

```
+- base (=localisation des bases "template0" & "template1").
+- global (=controlfiles).
+- pg_wal (=fichiers d'archivage).
+- pg_stat (=elaboration des plans de requetes ; EXPLAIN_PLAN).
+- pg_act (=stocker le statut des transactions non-sérializables ou "sans ordre" commitées).
+- pg_serial (=idem pour les transactions sérializables).
+- pg_tblspc (=pointeur vers les tablespaces).
+- pg_repslot (=infos sur la réplication / slot).
```

#### Fichiers de configuration

> /etc/postgresql/<version>/main (fichiers liés à la conf').

```
+- postgresql.conf (=config).
+- pg_hba.conf (=autorisations d'accès).
```

### Autorisation d'accès

> Fichier pg_hba.conf.

### PSQL

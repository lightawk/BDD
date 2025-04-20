# AWR [-oracle]

AWR (ou Automatic Workload Repository) est un référentiel (ou dépôt) qui stocke un historique des informations utiles pour l’optimisation.

A intervalle régulier, des snapshots de la base (statistiques, charge, …) sont stockés dans l’AWR via le processus MMON.

C’est en quelque sorte un référentiel qui stocke un historique des informations utiles pour l’optimisation.

## General

Package DBMS_WORKLOAD_REPOSITORY avec un ensemble de procedures disponibles (create_snapshot, drop_snapshot_range, etc).

> Liste non-exhaustive des vues AWR.

```
- DBA_HIST_DATABASE_INSTANCE
- DBA_HIST_ACTIVE_SESS_HISTORY
- DBA_HIST_SNAPSHOT
- DBA_HIST_ASH_SNAPSHOT
- DBA_HIST_WR_CONTROL
```

## Parametrage pour les cliches AWR (frequence, retention, etc.)

Vue DBA_HIST_WR_CONTROL.

> Retention positionne a 30 jours et 30 minutes sur le conteneur.

```
EXECUTE dbms_workload_repository.modify_snapshot_settings(
    retention => 43200,
    interval => 30
);
```

## Generer un rapport AWR

```
export ORACLE_SID=?
sqlplus /as sysdba
@$ORACLE_HOME/rdbms/admin/awrrpti.sql
Type Specified: html
Entrez une valeur pour dbid : ? (=> SELECT dbid FROM v$database;)
Entrez une valeur pour inst_num : ?
Selectionner une plage begin_snap & end_snap dans les valeurs disponibles
```

> Type ou format du rapport (html).

```
Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
AWR reports can be generated in the following formats.  Please enter the
name of the format at the prompt. Default value is 'html'.

   'html'          HTML format (default)
   'text'          Text format
   'active-html'   Includes Performance Hub active report

Entrez une valeur pour report_type : html
```

> Localisation des donnees AWR (CDB ou PDB).

```
Specify the location of AWR Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AWR_ROOT - Use AWR data from root (default)
AWR_PDB - Use AWR data from PDB
Entrez une valeur pour awr_location : AWR_ROOT
```

> Specifier l'identifiant de la base de donnees et le numero d'instance.

```
Instances in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  DB Id      Inst Num   DB Name      Instance     Host
------------ ---------- ---------    ----------   ------
* 568523471      1      XXXXXC       XXXXXC       serveur

Entrez une valeur pour dbid : 568523471
Using 568523471 for database Id
Entrez une valeur pour inst_num : 1
```

> Liste des snaps disponibles depuis les x-jours a afficher.

```
Specify the number of days of snapshots to choose from
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Entering the number of days (n) will result in the most recent
(n) days of snapshots being listed.  Pressing <return> without
specifying a number lists all completed snapshots.


Entrez une valeur pour num_days : 3
```

> Plage de snap_id a selectionner (<u>exemple:</u> du 21/05 19h au 21/05 23h).

```
15296  21 Mai   2024 19:0   1
15297  21 Mai   2024 19:3   1
15298  21 Mai   2024 20:0   1
15299  21 Mai   2024 20:3   1
15300  21 Mai   2024 21:0   1
15301  21 Mai   2024 21:3   1
15302  21 Mai   2024 22:0   1
15303  21 Mai   2024 22:3   1
15304  21 Mai   2024 23:0   1

Specify the Begin and End Snapshot Ids
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Entrez une valeur pour begin_snap : 15296
Begin Snapshot Id specified: 15296

Entrez une valeur pour end_snap : 15304
```

> Nom du rapport.

```
Specify the Report Name
~~~~~~~~~~~~~~~~~~~~~~~
The default report file name is awrrpt_1_15296_15304.html.  To use this name,
press <return> to continue, otherwise enter an alternative.

Entrez une valeur pour report_name :report-name
```
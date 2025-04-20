# plan d'execution [-oracle]

> Active le mode trace.

```
SET AUTOTRACE ON;
```

## Méthode 1

> Construire et afficher le plan pour la requête avec le package DBMS_XPLAN.

```
EXPLAIN PLAN FOR SELECT * FROM dual;
SELECT plan_table_output FROM table(DBMS_XPLAN.DISPLAY());
```

## Méthode 2

> Trouver la requete et son sql_id via la vue stats\$sqltext (via statspack).

```
SELECT * FROM stats$sqltext WHERE sql_text LIKE '%?';
```

> Trouver la requete et recuperer le plan_hash_value via la v$sql.

```
SELECT * FROM v$sql WHERE sql_id='?';
```

> Récupérer le plan_hash_value de l'ancienne requete via stats\$sql_plan_usage (via statspack).

```
SELECT * FROM stats$sql_plan_usage WHERE sql_id='?';
```

> Affiche le plan d'execution de la requete en fonction du plan_hash_value.

```
SELECT * FROM table(DBMS_XPLAN.DISPLAY('PERFSTAT.stats$sql_plan', NULL, NULL, 'PLAN_HASH_VALUE=&planhashvalue'));
```
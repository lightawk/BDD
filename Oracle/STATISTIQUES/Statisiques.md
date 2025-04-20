# statistiques [-oracle]

Package DBMS_STATS.

## Base

> Pour toute la base.

```
EXEC DBMS_STATS.GATHER_DATABASE_STATS;
```

> Pour toute la base avec un échantillon de 15%.

```
EXEC DBMS_STATS.GATHER_DATABASE_STATS(estimate_percent => 15);
```

> Sur les objets fixes, le dictionnaire de données et les statistiques système.

```
EXECUTE DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
EXECUTE DBMS_STATS.GATHER_DICTIONARY_STATS;
EXECUTE DBMS_STATS.GATHER_SYSTEM_STATS;
```

## Schema

> Pour un schéma.

```
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SCHEMA');
```

> Pour un schéma avec un échantillon de 15%.

```
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SCHEMA', estimate_percent => 15);
```

## Table

> Calcul des statistiques sur la table MA_TABLE.

```
ANALYZE TABLE MA_TABLE COMPUTE STATISTICS;
```

> Pour une table.

```
EXEC DBMS_STATS.GATHER_TABLE_STATS('MA_TABLE', 'TABLE');
```

> Pour une table avec un échantillon de 15%.

```
EXEC DBMS_STATS.GATHER_TABLE_STATS('MA_TABLE', 'TABLE', estimate_percent => 15);
```

> Pour une table avec des options supplementaires.

```
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS (
        ownname            => 'SCHEMA',
        tabname            => 'TABLE',
        cascade            => TRUE,
        estimate_percent   => DBMS_STATS.AUTO_SAMPLE_SIZE,
        method_opt         => 'FOR ALL INDEXED COLUMNS SIZE AUTO',
        granularity        => 'ALL',
        degree             => PARALLEL);
END;
/
```

## Index

> Pour un index.

```
EXEC DBMS_STATS.GATHER_INDEX_STATS('SCHEMA', 'PK');
```

> Pour un index avec un échantillon de 15%.

```
EXEC DBMS_STATS.GATHER_INDEX_STATS('SCHEMA', 'PK', estimate_percent => 15);
```

## Table de staging

> Suppression de la table de staging.

```
EXECUTE DBMS_STATS.DROP_STAT_TABLE(ownname => 'SCHEMA', stattab => 'TABLE_STAGING');
```

> Création de la table de staging.

```
DBMS_STATS.CREATE_STAT_TABLE(ownname => 'SCHEMA', stattab => 'TABLE_STAGING');
```

> Exporte les statistiques sur les tables fixes.

```
EXECUTE DBMS_STATS.EXPORT_FIXED_OBJECTS_STATS(stattab => 'TABLE_STAGING', statown => 'SCHEMA');
```

> Exporte les statistiques sur le dictionnaire de donnees.

```
EXECUTE DBMS_STATS.EXPORT_DICTIONARY_STATS(stattab => 'TABLE_STAGING', statown => 'SCHEMA');
```

> Exporte les statistiques du schema dans la table de staging.

```
EXEC DBMS_STATS.EXPORT_SCHEMA_STATS(ownname => 'SCHEMA', stattab => 'TABLE_STAGING');
```

> Importe les statistiques du schema depuis la table de staging.

```
EXEC DBMS_STATS.IMPORT_SCHEMA_STATS(ownname => 'SCHEMA' , stattab => 'TABLE_STAGING');
```
# sqlpatch [-oracle]

Permet d'injecter un hint dans du SQL dans toucher à la requête.

Package DBMS_SQLDIAG qui fournit une interface avec la fonctionnalité de diagnostic SQL (vue dba_sql_patches).

> Creation d'un patch.

```
EXEC DBMS_SQLDIAG.CREATE_SQL_PATCH (
    sql_text    => 'requete',
    hint_text   => 'FULL(CHAMP)',
    name        => 'patch',
    description => 'descriptif',
    category    => NULL,
    validate    => TRUE
);
```

> Supprimer un patch.

```
EXEC DBMS_SQLDIAG.DROP_SQL_PATCH(name => 'PATCH');
```

> Verifier la creation du patch.

```
SELECT name, status FROM dba_sql_patches;
```

> Regroupe les correctifs SQL dans la table de transfert creee par un appel a la procédure CREATE_STGTAB_SQLPATCH.

```
EXEC DBMS_SQLDIAG.PACK_STGTAB_SQLPATCH;
```

> Decompresse de la table de transfert (remplie par un appel a la procédure PACK_STGTAB_SQLPATCH) en utilisant les donnees de correctif stockees dans la table de transfert.

```
EXEC DBMS_SQLDIAG.UNPACK_STGTAB_SQLPATCH (
    patch_name           => 'patch',
    REPLACE              => '',
    staging_table_name   => 'nom_table_staging',
    staging_schema_owner => 'proprietaire'
);
```
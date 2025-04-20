# rman [-oracle]

> Connexion a rman ou au catalogue.

```
rman
rman target /
rman catalog RMAN_SCHEMA/RMAN_SCHEMA@CATRMAN
```

> Connexion a rman et au catalogue.

```
rman target / catalog RMAN_SCHEMA/RMAN_SCHEMA@CATRMAN
```

> Voir la liste des incarnation de la base dans le catalogue.

```
LIST INCARNATION OF DATABASE DB;
```

> Enregistrement et desinscription de la base dans le catalogue.

```
REGISTER DATABASE;
UNREGISTER DATABASE DB;.
```

> Positionnement du DBID et desinscription de la base dans le catalogue.

```
RUN
{
SET DBID ?;
UNREGISTER DATABASE DB NOPROMPT;
}
```
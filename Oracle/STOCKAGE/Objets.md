# objets [-oracle]

## Utilisateur

> Creer un utilisateur, modifier son mot de passe, le supprimer.

```
CREATE USER UTILISATEUR IDENTIFIED BY PWD DEFAULT TABLESPACE tbs TEMPORARY TABLESPACE TEMP;
ALTER USER UTILISATEUR IDENTIFIED BY PWD;
DROP USER UTILISATEUR CASCADE;
```

> Donner a l'utilisateur le droit de creer une table.

```
GRANT CREATE TABLE TO UTILISATEUR;
```

> Donner a l'utilisateur le droit de se connecter.

```
GRANT CONNECT TO utilisateur;
```

## Tables

> Creation de table.

```
CREATE TABLE SCHEMA.TAB (
    PARTENAIRE        VARCHAR2 (10) NOT NULL,
    DATE_             DATE,
    CONTACT           VARCHAR2 (2000),
    MAIL_CONTACT      VARCHAR2 (2000),
    TEL_CONTACT       VARCHAR2 (2000),
    MODE_TRANSFERT    VARCHAR2 (15),
    COMMENTAIRE       VARCHAR2 (2000),
    CONSTRAINT PK_PARTENAIRE PRIMARY KEY (PARTENAIRE),
    CONSTRAINT FK_ FOREIGN KEY (CHAMP_ID) REFERENCES  TABLE (CHAMP_ID);
)
TABLESPACE TBS;
```

> Ajout d'une colonne de type DATE.

```
ALTER TABLE TAB
    ADD COLONNE DATE
            DEFAULT TO_DATE ('01/01/2023 00:00:00', 'DD/MM/YYYY HH24:MM:SS')
            NOT NULL;
```

> Suppression d'une table.

```
DROP TABLE SCHEMA.TAB CASCADE CONSTRAINTS PURGE;
```

La clause PURGE supprime definitivement la table de la corbeille Oracle.

> Ajout et suppression de contraintes.

```
ALTER TABLE SCHEMA.TAB
    ADD CONSTRAINT PK PRIMARY KEY (CHAMP);

ALTER TABLE SCHEMA.TAB
    DROP PRIMARY KEY CONSTRAINT PK.CHAMP;

SELECT constraint_name, constraint_type
  FROM dba_constraints
 WHERE table_name = '?';
```

> Desactiver une contrainte de cle primaire.

```
ALTER TABLE SCHEMA.TAB DISABLE PRIMARY KEY CONSTRAINT SCHEMA.TAB;
```

## Tables partitionnees

> Par range.

```
CREATE TABLE SALES (
    year       NUMBER (4),
    product    VARCHAR2 (10),
    amt        NUMBER (10, 2)
) 
PARTITION BY RANGE (year)
PARTITION P1 VALUES LESS THAN (1992) TABLESPACE TBS_1,
PARTITION P2 VALUES LESS THAN (1993) TABLESPACE TBS_2,
PARTITION P3 VALUES LESS THAN (1994) TABLESPACE TBS_3,
PARTITION P4 VALUES LESS THAN (1995) TABLESPACE TBS_4,
PARTITION P5 VALUES LESS THAN (MAXVALUE) TABLESPACE TBS_5;
```

On partitionne la table sur la colonne "year" avec une partition pour chaque valeur de "year" et un tablespace rattache.

> Par hash.

```
CREATE TABLE PRODUCTS (
    partno         NUMBER,
    description    VARCHAR2(60)
)
PARTITION BY HASH (partno)
    PARTITIONS 4
        STORE IN (TBS_1,
                  TBS_2,
                  TBS_3,
                  TBS_4);
```

On partitionne la table sur la colonne "partno" avec 4 partitions.

> Par list.

```
CREATE TABLE CUSTOMERS (
    custcode    NUMBER(5),
    name        VARCHAR2(20),
    addr        VARCHAR2(10, 2),
    city        VARCHAR2(20),
    bal         NUMBER(10, 2)
)
PARTITION BY LIST (city),
PARTITION north_india VALUES ('DELHI', 'CHANDIGARH'),
PARTITION east_india VALUES ('KOLKOTA', 'PATNA'),
PARTITION south_india VALUES ('HYDERABAD', 'BANGALORE', 'CHENNAI'),
PARTITION west_india VALUES (‘BOMBAY’, ’GOA’);
```

> Par composite.

```
CREATE TABLE PRODUCTS (
    partno         NUMBER,
    description    VARCHAR (32),
    costprice      NUMBER
)
PARTITION BY RANGE (partno)
SUBPARTITION BY HASH (description)
SUBPARTITIONS 8 STORE IN (TBS_1,
                          TBS_2,
                          TBS_3,
                          TBS_4)
(
  PARTITION P1 VALUES LESS THAN (100),
  PARTITION P2 VALUES LESS THAN (200),
  PARTITION P3 VALUES LESS THAN (MAXVALUE)
);
```

On partitionne la table sur la colonne "partno" puis pour chaque partition on cree 8 sous-partition.

## Index

> CREATE INDEX index ON table(colonne) PARALLEL ? ONLINE;

```
PARALLEL => Paralleliser le traitement pour aller plus vite.
ONLINE   => Creer ou deplacer un index pendant des operations DML sur la table concernee. Cela peut engendrer des locks si un utilisateur fait des requetes en meme temps sur la table.
```

## Synonymes

> Creation de synonyme.

```
CREATE PUBLIC SYNONYM synonyme (FOR..);
```

## Profils

Le profil permet d'assigner des restrictions au niveau des actions de l'utilisateur sur la base de donnees.

Pour pouvoir creer un profil il faut s'assurer que l'on dispose du privilege pour le creer avec "CREATE PROFILE".

Il existe deux types de limitations que l'on assigne à un nouveau profil : <u>ressources systemes</u> et <u>mots de passe</u>.

> Selectionner les profils.

```
SELECT resource_name FROM dba_profiles;
```

> Nombre de tentatives de connexions echouees avant le blocage du compte.

```
ALTER PROFILE default LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED;
```

> Nombre maximal de tentatives de connexion.

```
ALTER PROFILE default LIMIT PASSWORD_LIFE_TIME UNLIMITED;
```

> Expiration automatique des mots de passe.

```
ALTER PROFILE default LIMIT PASSWORD_LOCK_TIME UNLIMITED;
```

> Definit la duree de verrouillage du compte utilisateur apres avoir bloque le compte avec le parametre FAILED_LOGIN_ATTEMPTS.

```
ALTER PROFILE default LIMIT PASSWORD_GRACE_TIME UNLIMITED;
```

```
PASSWORD_REUSE_TIME => Definit en nombre de jours le delai entre deux utilisations du meme mot de passe.
PASSWORD_REUSE_MAX  => Definir le nombre de reutilisation du meme mot de passe.
```

## Roles

```
CREATE ROLE role;
GRANT SELECT ANY TABLE role;
GRANT role TO USER;
SELECT * FROM session_roles;
SET ROLE nouveau_role;
```
# tnsnames [-oracle]

Le fichier tnsnames.ora est le fichier de communication reseau Oracle.

Configurer des entrees pour acceder a une ou plusieurs bases depuis un client exterieur SQLDev / Toad ou encore pouvoir joindre des services ou des bases sur d'autres machines.

> Ajouter une entree pour la base dans le fichier tnsnames.

```
DB.HELIOS.CP =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = serveur)(PORT = 00000))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = DB)
    )
  )
```

> Ping de ma base situee sur le serveur <serveur> port 00000 via le nom de domaine DB.DNS.

```
tnsping DB
```

## Configurer le client SQLDev / Toad

> Configurer le client SQLDev sur Windows en copiant le fichier tnsnames.ora dans le repertoire d'installation de SQLDev puis dans l'outil.

```
Outils => Preferences => Base de donnees => Avance => "Repertoire tnsnames"
```

> Configurer le client Toad sur Windows en copiant le fichier tnsnames.ora dans le repertoire d'installation de Toad pour acceder aux bases.

```
C:\Program Files\Quest Software\Toad for Oracle 2022 R2 Edition\Toad for Oracle 16.0\tnsnames.ora
```
# sessions [-oracle]

## Tuer une session

Si une requete consomme trop de CPU on peut être amené à "tuer" une session.

> Tuer une session avec son SID et son SERIAL.

```
ALTER SYSTEM KILL SESSION 'SID, SERIAL' IMMEDIATE;
```

<u>NB :</u> Si des transactions sont en cours ou que la session est en attente, son statut appraîtra KILLED mais ne le sera pas pour autant.

> Deconnecte la session apres le prochain COMMIT / ROLLBACK en precisant POST_TRANSACTION ou de maniere instantannee avec IMMEDIATE et termine le processus systeme.

```
ALTER SYSTEM DISCONNECT SESSION 'SID, SERIAL' POST_TRANSACTION | IMMEDIATE;
```

> Tuer une transaction en attente.

```
ROLLBACK FORCE 'TRANS_ID';
EXECUTE DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('TRANS_ID');
COMMIT;
```
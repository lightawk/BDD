# jobs [-oracle]

Un job Oracle est l'equivalent d'une tache de fond comme un demon ou un processus qui tourne et qui execute un traitement specifique toutes les x-minutes.

Les differentes fonctionnalites sont integrees dans le package DBMS_JOB.

Il est possible de selectionner l'ensemble des jobs qui tournent sur une base de donnees via la vue "dba_jobs" avec la requete "SELECT * FROM dba_jobs".

L'etat BROKEN=N (NO) signifie que le job est actif selon l'intervalle defini. A contrario l'etat "Y" signifie que le job est rompu.

> Recuperer les informations sur les jobs appartenant au schema SCHEMA%.

```
SET LINES 200
COL INTERVAL FORMAT A35
COL WHAT FORMAT A35
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YY HH24:MI:SS';
SELECT job,
       last_date,
       next_date,
       broken,
       interval,
       failures,
       what
  FROM dba_jobs
 WHERE log_user LIKE 'SCHEMA%';
```

> Creation d'un job.

```
Prompt création d'un nouveau job statspack.snap avec 15 minutes d'intervalle
BEGIN
    SELECT instance_number INTO :instno FROM v$instance;
    DBMS_JOB.SUBMIT(
        :jobno,
        'begin execute immediate ''alter SESSION set "_cursor_plan_unparse_enabled"=false''; STATSPACK.SNAP; end;',
        TRUNC (SYSDATE + (1 / 96), 'HH'),
        'SYSDATE+ (1/96)',
        TRUE,
        :instno);
    COMMIT;
END;
/
```

> Modifier la fréquence d'exécution du job (sysdate+30/1440 = 30 minutes).

```
EXECUTE DBMS_JOB.CHANGE(
    72,
    'begin execute immediate ''alter SESSION set "_cursor_plan_unparse_enabled"=false''; STATSPACK.SNAP; end;',
    null,
    'sysdate+15/1440'
);
```

> Suppression du job 1020.

```
BEGIN
  DBMS_JOB.REMOVE (1020);
  COMMIT;
END;
/
```

> Execution du job 1.

```
BEGIN
  DBMS_JOB.RUN ('1');
END;
/
COMMIT;
```

## Activer les jobs

> Déclaration de la fonction d'activation des jobs.

```
SPOOL /app/log/enable_allusers_jobs_${ORACLE_SID}.log
-- Déclaration de la fonction d'activation des jobs
DECLARE
resultat   VARCHAR2 (10);
FUNCTION ACTIVE_JOB (p_job_id IN NUMBER, p_nom_utilisateur IN VARCHAR2)
    RETURN VARCHAR2
IS
    UID        NUMBER;
    l_result   INTEGER;
    sqltext    VARCHAR2 (1000);
    myint      INTEGER;
BEGIN
    SELECT user_id
      INTO UID
      FROM all_users
     WHERE username = P_NOM_UTILISATEUR;

    myint := sys.DBMS_SYS_SQL.open_cursor ();
    sqltext :=
           'begin dbms_job.broken('
        || TO_CHAR (p_job_id)
        || ', FALSE); end;  ';
    sys.DBMS_SYS_SQL.parse_as_user (myint,
                                    sqltext,
                                    DBMS_SQL.native,
                                    UID);
    l_result := sys.DBMS_SYS_SQL.execute (myint);
    sys.DBMS_SYS_SQL.close_cursor (myint);
    RETURN ('ok');
EXCEPTION
    WHEN OTHERS
    THEN
        RETURN ('ko');
END;
```

> Exécution de la fonction d'activation pour chaque job.

```
BEGIN
    DBMS_OUTPUT.enable (NULL);
    resultat := NULL;

    FOR x IN (SELECT * FROM dba_jobs)
    LOOP
        resultat := ACTIVE_JOB (x.job, x.schema_user);

        IF NVL (resultat, 'ko') = 'ok'
        THEN
            DBMS_OUTPUT.put_line (
                   'le job '
                || TO_CHAR (x.job)
                || ' du user '
                || x.schema_user
                || ' a bien ete active');
        ELSE
            DBMS_OUTPUT.put_line (
                   'activation du job '
                || TO_CHAR (x.job)
                || ' du user '
                || x.schema_user
                || ' en erreur');
        END IF;

        COMMIT; -- important sinon les modifs faites aux jobs ne sont pas conservees
    END LOOP;
END;
/
```

> Sélectionner les jobs pour vérification.

```
SET LINESIZE 250;
COL log_user FORMAT A50;
SELECT job, log_user, broken FROM dba_jobs;
```

## Desactiver les jobs

> Déclaration de la fonction de desactivation des jobs.

```
SPOOL $HX_LOG/disable_allusers_jobs_${ORACLE_SID}.log
-- Déclaration de la fonction de desactivation des jobs

DECLARE
resultat   VARCHAR2 (10);

FUNCTION DESACTIVE_JOB (p_job_id            IN NUMBER,
                        p_nom_utilisateur   IN VARCHAR2)
    RETURN VARCHAR2
IS
    UID        NUMBER;
    l_result   INTEGER;
    sqltext    VARCHAR2 (1000);
    myint      INTEGER;
BEGIN
    SELECT user_id
      INTO UID
      FROM all_users
     WHERE username = P_NOM_UTILISATEUR;

    myint := sys.DBMS_SYS_SQL.open_cursor ();
    sqltext :=
           'begin dbms_job.broken('
        || TO_CHAR (p_job_id)
        || ', TRUE); end;  ';
    sys.DBMS_SYS_SQL.parse_as_user (myint,
                                    sqltext,
                                    DBMS_SQL.native,
                                    UID);
    l_result := sys.DBMS_SYS_SQL.execute (myint);
    sys.DBMS_SYS_SQL.close_cursor (myint);
    RETURN ('ok');
EXCEPTION
    WHEN OTHERS
    THEN
        RETURN ('ko');
END;
```

> Exécution de la fonction de desactivation pour chaque job.

```
BEGIN
    DBMS_OUTPUT.enable (NULL);
    resultat := NULL;

    FOR x IN (SELECT * FROM dba_jobs)
    LOOP
        resultat := DESACTIVE_JOB (x.job, x.schema_user);

        IF NVL (resultat, 'ko') = 'ok'
        THEN
            DBMS_OUTPUT.put_line (
                   'le job '
                || TO_CHAR (x.job)
                || ' du user '
                || x.schema_user
                || ' a bien ete desactive');
        ELSE
            DBMS_OUTPUT.put_line (
                   'desactivation du job '
                || TO_CHAR (x.job)
                || ' du user '
                || x.schema_user
                || ' en erreur');
        END IF;

        COMMIT; -- important sinon les modifs faites aux jobs ne sont pas conservees
    END LOOP;
END;
/
```

> Sélectionner les jobs pour vérification.

```
SET LINESIZE 250;
COL log_user FORMAT A50;
SELECT job, log_user, broken FROM dba_jobs;
```

> Désactiver un job.

```
SET PAGES 0
SET FEED OFF
SPOOL /app/log/disable_jobs_${ORACLE_SID}.log
SELECT    'EXEC DBMS_JOB.BROKEN('
       || JOB
       || ',TRUE); ==> avec le user : '
       || log_user
  FROM dba_jobs;

SPOOL OFF;
SET FEED ON
```

> Désactiver les jobs.

```
BEGIN
    FOR x IN (SELECT * FROM user_jobs)
    LOOP
        DBMS_JOB.broken (x.job, TRUE);
    END LOOP;
END;
/
COMMIT;
```

## Divers

> Modification du snap level.

```
EXEC STATSPACK.MODIFY_STATSPACK_PARAMETER(I_SNAP_LEVEL => 7);
```

> Activer ou désactiver les options payantes (taches de maintenance automatique). Equivalent d'un switch ON/OFF en PLSQL.

```
-- COLUMN  xxdate NEW_VALUE xx_date
-- SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MISS') xxdate FROM DUAL;
SPOOL /app/log/invert_stats_auto_${ORACLE_SID}_&xx_date..log
SELECT client_name, status FROM dba_autotask_client;
DECLARE
BEGIN
    FOR This_
        IN (SELECT    'begin DBMS_AUTO_TASK_ADMIN.'
                   || CASE
                          WHEN status = 'DISABLED' THEN 'ENABLE'
                          ELSE 'DISABLE'
                      END
                   || '( client_name => '''
                   || CLIENT_NAME
                   || ''', operation => NULL, window_name => NULL); end;'    AS cmd
              FROM dba_autotask_client)
    LOOP
        EXECUTE IMMEDIATE This_.cmd;
    END LOOP;
END;
/
SELECT client_name, status FROM dba_autotask_client;
SPOOL OFF
```

- Desactiver les options payantes (taches de maintenance automatique).

```
SET PAGES 20 LINES 150 ECHO ON FEED ON
SPOOL /app/log/disable_stats_auto_${ORACLE_SID}.log
SELECT client_name, status FROM dba_autotask_client;
EXEC DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => 'auto optimizer stats collection', operation => NULL, window_name => NULL);
EXEC DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => 'auto space advisor', operation => NULL, window_name => NULL);
EXEC DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => 'sql tuning advisor', operation => NULL, window_name => NULL);
SELECT client_name, status FROM dba_autotask_client;
SPOOL OFF;
```
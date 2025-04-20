# transportable tablespace [-oracle]

Permet de copier un tablespace entier d'une base vers une autre.

Necessite au prealable qu'un tablespace soit cree avec au moins un utilisateur et une table.

> Verification prealable.

```
EXEC SYS.DBMS_TTS.TRANSPORT_SET_CHECK(ts_list => 'TBS', incl_constraints => TRUE);
```

<u>ts_list</u> correspond a la liste de tablespaces sur lesquels lancer la procedure de verification.
<u>incl_constraints</u> indique si les contraintes doivent etre incluses dans la verification.

> Verification des violations.

```
SELECT * FROM transport_set_violations;
```

> Export TTS.

```
ALTER TABLESPACE TBS READ ONLY;
CREATE OR REPLACE DIRECTORY EXPDP_DIR AS '/tmp';
GRANT READ, WRITE ON DIRECTORY EXPDP_DIR TO SYSTEM;
expdp USERID=SYSTEM/****** DIRECTORY=EXPDP_DIR TRANSPORT_TABLESPACES=TBS DUMPFILE=tbs.dmp LOGFILE=logfile_exp_tbs.log
ALTER TABLESPACE TBS READ WRITE;
```

> Import TTS.

```
impdp USERID=SYSTEM/****** DIRECTORY=EXPDP_DIR DUMPFILE=tbs.dmp LOGFILE=logfile_imp_tbs.log TRANSPORT_DATAFILES='/u01/app/oracle/oradata/DB/tbs_01.dbf'
ALTER TABLESPACE TBS READ WRITE;
SELECT tablespace_name, plugged_in, status FROM dba_tablespaces WHERE tablespace_name='TBS';
```
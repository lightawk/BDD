# scheduler jobs [-oracle]

## Creation du job pour la prise de cliches avec statspack

> Création du programme, activation, création du schedule (fréquence d'exécution) et création du job (program_action=STATSPACK.snap).

```
BEGIN

    -- Creation du programme pour la prise de cliches
    DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name => 'SP_SNAP_PROG'
      , program_type => 'STORED_PROCEDURE'
      , program_action => 'STATSPACK.snap'
      , number_of_arguments => 0
      , enabled => FALSE
    );

    -- Activation du programme pour la prise de cliches
    DBMS_SCHEDULER.ENABLE(name => 'SP_SNAP_PROG');

    -- Creation du schedule pour la prise de cliches
    DBMS_SCHEDULER.CREATE_SCHEDULE (
        schedule_name => 'SP_SNAP_SCHED'
      , repeat_interval => 'freq=hourly; byminute=0,30; bysecond=0'
      , end_date => null
      , comments => 'Schedule Statspack pour la prise de cliches'
    );

    -- Creation du job pour la prise de cliches
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'SP_SNAP_JOB'
      , program_name => 'SP_SNAP_PROG'
      , schedule_name => 'SP_SNAP_SCHED'
      , enabled => TRUE
      , auto_drop => FALSE
      , comments => 'Job Statspack pour la prise de cliches'
    );
END;
/
```

## Creation du job pour purger les cliches avec statspack

> Creation de la procedure pour purger les cliches (program_action).

```
-- Creation de la procedure pour purger les cliches
CREATE OR REPLACE PROCEDURE extended_purge(num_days IN NUMBER)
IS
BEGIN
    STATSPACK.purge (
        i_num_days => num_days
      , i_extended_purge => TRUE
    );
END extended_purge;
/
```

> Création du programme, définition de l'argument pour la procedure, activation, création du schedule (fréquence d'exécution) et création du job.

```
BEGIN
    -- Creation du programme pour la purge des cliches
    DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name => 'SP_PURGE_PROG'
      , program_type => 'STORED_PROCEDURE'
      , program_action => 'extended_purge'
      , number_of_arguments => 1
      , enabled => FALSE
    );

    -- Description de l'argument pour la purge des cliches
    DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT (
        program_name => 'SP_PURGE_PROG'
      , argument_name => 'i_num_days'
      , argument_position => 1
      , argument_type => 'NUMBER'
      , default_value => 30
    );

    -- Activation du programme pour la purge des cliches
    DBMS_SCHEDULER.ENABLE(name => 'SP_PURGE_PROG');

    -- Creation du schedule pour la purge des cliches
    DBMS_SCHEDULER.CREATE_SCHEDULE (
        schedule_name => 'SP_PURGE_SCHED'
      , repeat_interval => 'freq=weekly; byday=SUN; byhour=0; byminute=20'
      , end_date => null
      , comments => 'Schedule Statspack pour la purge des cliches'
    );

    -- Creation du job pour la purge des cliches
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'SP_PURGE_JOB'
      , program_name => 'SP_PURGE_PROG'
      , schedule_name => 'SP_PURGE_SCHED'
      , enabled => TRUE
      , auto_drop => FALSE
      , comments => 'Job Statspack pour la purge des cliches'
    );

END;
/
```

> CREATE_PROGRAM          => Création du programme.
> DEFINE_PROGRAM_ARGUMENT => Définition de l'argument pour le traitement a executer.
> ENABLE                  => Activation du programme.
> CREATE_SCHEDULE         => Creation du schedule (fréquence d'execution).
> CREATE_JOB              => Creation du job.
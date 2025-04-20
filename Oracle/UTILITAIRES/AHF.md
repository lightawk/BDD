# AHF (Autonomous Health Framework) - Trace File Analyzer (TFA) & ORAchk/EXAchk [-oracle]

Oracle Stack Health Checks on non-engineered systems.

Oracle Stack Health Checks on Engineered Systems.

> Installer AHF dans $ORACLE_HOME/ahf en tant qu'utilisateur non-root ; va creer un sous-repertoire "oracle.ahf".

```
ahf_setup -ahf_loc $ORACLE_HOME/ahf
```

> Effectuer une SRDC (Service Request Data Collections) sur un type d'erreur en particulier.

```
${ORACLE_HOME}/ahf/oracle.ahf/bin/tfactl diagcollect -srdc ORA-00600
```
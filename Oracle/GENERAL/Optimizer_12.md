# basculer en optimizer 12 [-oracle]

> Installer les sqlpatches.

```
ALTER SYSTEM SET "_optimizer_use_feedback"=FALSE SCOPE=SPFILE;
ALTER SYSTEM SET optimizer_adaptive_plans=FALSE SCOPE=BOTH;
ALTER SYSTEM SET optimizer_features_enable='12.2.0.1' SCOPE=BOTH;
SHUTDOWN IMMEDIATE;
STARTUP;
```

> Modifier les parametres en avance de phase.

```
ALTER SYSTEM SET "_optimizer_use_feedback"=FALSE SCOPE=SPFILE;
ALTER SYSTEM SET optimizer_adaptive_plans=FALSE SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;
```

> Modifier le paramètre optimizer_features_enable.

```
ALTER SYSTEM SET optimizer_features_enable='12.2.0.1' SCOPE=SPFILE;
```

> Retour arriere.

```
ALTER SYSTEM SET optimizer_features_enable='10.2.0.4' SCOPE=BOTH;
```
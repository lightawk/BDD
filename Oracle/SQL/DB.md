# sql [-db]

## dba_objects

> Liste des objets invalides.

```
SET LINES WINDOW
COLUMN object_name FORMAT A30;
  SELECT owner,
         object_type,
         object_name,
         status,
         created
    FROM dba_objects
   WHERE status = 'INVALID'
ORDER BY owner, object_type, object_name;
```

## dba_constraints

> Constraintes desactivees.

```
SELECT owner,
       constraint_name,
       constraint_type,
       table_name,
       status
  FROM dba_constraints
 WHERE status != 'ENABLED';
```

## dba_indexes

### index

> Reconstruction index.

```
ALTER INDEX index REBUILD TABLESPACE tbs;
```

> Generer reconstruction index UNUSABLE.

```
SELECT 'ALTER INDEX '
       || owner
       || '.'
       || index_name
       || ' REBUILD TABLESPACE '
       || tablespace_name
       || ' ONLINE;'
  FROM dba_indexes
 WHERE status = 'UNUSABLE' AND owner = '?';
```

### index partitionne

> Reconstruction index partitionnes.

```
ALTER INDEX index REBUILD PARTITION part ONLINE;
```

> Generer reconstruction index partitionne.

```
SELECT 'ALTER INDEX '
       || index_owner
       || '.'
       || index_name
       || ' REBUILD PARTITION '
       || partition_name
       || ' ONLINE;'
  FROM dba_ind_partitions
 WHERE index_name = 'index';
```

### index sous-partitionne

> Reconstruction index sous-partitionne.

```
ALTER INDEX index REBUILD SUBPARTITION sub_part ONLINE;
```

> Generer reconstruction index sous-partitionne.

```
SELECT 'ALTER INDEX '
       || index_owner
       || '.'
       || index_name
       || ' REBUILD SUBPARTITION '
       || subpartition_name
       || ' ONLINE;'
  FROM dba_ind_subpartitions
 WHERE index_name = 'index';
```

## dba_role_privs | dba_sys_privs | dba_tab_privs

> Recuperer les roles.

```
SELECT DBMS_METADATA.GET_GRANTED_DDL ('ROLE_GRANT', 'SCHEMA') FROM DUAL;

SELECT 'GRANT "' || granted_role || '" TO "' || grantee || '"' || ';'
  FROM dba_role_privs
 WHERE grantee = 'SCHEMA';
```

> Recuperer les prvileges systeme.

```
SELECT DBMS_METADATA.GET_GRANTED_DDL ('SYSTEM_GRANT', 'SCHEMA') FROM DUAL;

SELECT 'GRANT ' || privilege || ' TO "' || grantee || '"' || ';'
  FROM dba_sys_privs
 WHERE grantee = 'SCHEMA';
```

> Recuperer les prvileges objets.

```
SELECT DBMS_METADATA.GET_GRANTED_DDL ('OBJECT_GRANT', 'SCHEMA') FROM DUAL;

SELECT 'GRANT '
       || privilege
       || ' ON "'
       || owner
       || '"."'
       || table_name
       || '" TO "'
       || grantee
       || '"'
       || DECODE (GRANTABLE, 'YES', ' WITH GRANT OPTION')
       || ';'
  FROM dba_tab_privs
 WHERE owner IN ('SYS', 'SYSTEM') AND grantee = 'SCHEMA';
```

> Selectionne les privileges objet pour les users définis.

```
SELECT 'GRANT '
  || privilege
  || ' ON "'
  || owner
  || '"."'
  || table_name
  || '" TO "'
  || grantee
  || '"'
  || DECODE (grantable, 'YES', ' WITH GRANT OPTION')
  || ';'

FROM dba_tab_privs
WHERE     owner IN ('SYS', 'SYSTEM')
  AND grantee IN ('USER_1',
                  'USER_2');
```

> Recuperer les prvileges detailles.

```
SELECT USERNAME,
     PRIVILEGE,
     OBJ_OWNER,
     OBJ_NAME,
     LISTAGG (GRANT_TARGET, ',') WITHIN GROUP (ORDER BY GRANT_TARGET)
         AS GRANT_SOURCES,          -- Lists the sources of the permission
     MAX (ADMIN_OR_GRANT_OPT)
         AS ADMIN_OR_GRANT_OPT, -- MAX acts as a Boolean OR by picking 'YES' over 'NO'
     MAX (HIERARCHY_OPT)
         AS HIERARCHY_OPT -- MAX acts as a Boolean OR by picking 'YES' over 'NO'
FROM (                   -- Gets all roles a user has, even inherited ones
      WITH
          ALL_ROLES_FOR_USER
          AS
              (    SELECT DISTINCT
                          CONNECT_BY_ROOT GRANTEE AS GRANTED_USER, GRANTED_ROLE
                     FROM DBA_ROLE_PRIVS
               CONNECT BY GRANTEE = PRIOR GRANTED_ROLE)
      SELECT PRIVILEGE,
             OBJ_OWNER,
             OBJ_NAME,
             USERNAME,
             REPLACE (GRANT_TARGET, USERNAME, 'Direct to user')
                 AS GRANT_TARGET,
             ADMIN_OR_GRANT_OPT,
             HIERARCHY_OPT
        FROM (              -- System privileges granted directly to users
              SELECT PRIVILEGE,
                     NULL             AS OBJ_OWNER,
                     NULL             AS OBJ_NAME,
                     GRANTEE          AS USERNAME,
                     GRANTEE          AS GRANT_TARGET,
                     ADMIN_OPTION     AS ADMIN_OR_GRANT_OPT,
                     NULL             AS HIERARCHY_OPT
                FROM DBA_SYS_PRIVS
               WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
              UNION ALL
              -- System privileges granted users through roles
              SELECT PRIVILEGE,
                     NULL
                         AS OBJ_OWNER,
                     NULL
                         AS OBJ_NAME,
                     ALL_ROLES_FOR_USER.GRANTED_USER
                         AS USERNAME,
                     GRANTEE
                         AS GRANT_TARGET,
                     ADMIN_OPTION
                         AS ADMIN_OR_GRANT_OPT,
                     NULL
                         AS HIERARCHY_OPT
                FROM DBA_SYS_PRIVS
                     JOIN ALL_ROLES_FOR_USER
                         ON ALL_ROLES_FOR_USER.GRANTED_ROLE =
                            DBA_SYS_PRIVS.GRANTEE
              UNION ALL
              -- Object privileges granted directly to users
              SELECT PRIVILEGE,
                     OWNER          AS OBJ_OWNER,
                     TABLE_NAME     AS OBJ_NAME,
                     GRANTEE        AS USERNAME,
                     GRANTEE        AS GRANT_TARGET,
                     GRANTABLE,
                     HIERARCHY
                FROM DBA_TAB_PRIVS
               WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
              UNION ALL
              -- Object privileges granted users through roles
              SELECT PRIVILEGE,
                     OWNER                               AS OBJ_OWNER,
                     TABLE_NAME                          AS OBJ_NAME,
                     GRANTEE                             AS USERNAME,
                     ALL_ROLES_FOR_USER.GRANTED_ROLE     AS GRANT_TARGET,
                     GRANTABLE,
                     HIERARCHY
                FROM DBA_TAB_PRIVS
                     JOIN ALL_ROLES_FOR_USER
                         ON ALL_ROLES_FOR_USER.GRANTED_ROLE =
                            DBA_TAB_PRIVS.GRANTEE) ALL_USER_PRIVS
       -- Adjust your filter here
       WHERE USERNAME IN (SELECT username
                            FROM dba_users
                           WHERE username NOT IN ('SYSTEM',
                                                  'SYS',
                                                  'GGSYS',
                                                  'ANONYMOUS',
                                                  'XS\$NULL',
                                                  'SYSDG',
                                                  'SYSKM',
                                                  'GSMCATUSER',
                                                  'REMOTE_SCHEDULER_AGENT',
                                                  'SYS$UMF',
                                                  'SYSBACKUP',
                                                  'GSMADMIN_INTERNAL',
                                                  'SYSRAC',
                                                  'WMSYS',
                                                  'XDB',
                                                  'AUDSYS',
                                                  'DBSFWUSER',
                                                  'APPQOSSYS',
                                                  'GSMUSER')))
     DISTINCT_USER_PRIVS
GROUP BY USERNAME,
     PRIVILEGE,
     OBJ_OWNER,
     OBJ_NAME
ORDER BY USERNAME ASC;
```
# dblink [-oracle]

Les dblinks sont privés par défaut ; se connecter avec l'utilisateur proprietaire du dblink pour le créer.

> Créer un dblink.

```
CREATE [ PUBLIC ] DATABASE LINK DBLINK CONNECT TO SCHEMA IDENTIFIED BY password USING 'DB';
```

> Suppression d'un dblink.

```
DROP [ PUBLIC ] DATABASE LINK DBLINK;
```

> Tester un dblink sur la table dual.

```
SELECT * FROM DUAL@DBLINK;
```

> Tester l'ensemble des dblinks d'un schéma.

```
REM Validate Database Links
REM Private links under connected user and Public links
REM
REM Biju Thomas - 29-Oct-2013
REM
SET SERVEROUTPUT ON SIZE 99999
SET PAGES 0 LINES 300 TRIMS ON
COL spoolfile NEW_VALUE spoolfname

SELECT    '$HX_LOG/checklinks_'
       || USER
       || '_'
       || SUBSTR (global_name, 1, INSTR (global_name, '.') - 1)
       || '.txt'    spoolfile
  FROM global_name;

SPOOL '&spoolfname'

DECLARE
    --
    -- Get list of links the user has access to
    CURSOR mylinks IS
        SELECT db_link, owner, created, HOST, username FROM all_db_links;

    --
    -- Identify other links in the DB for information
    CURSOR otherlinks IS
        SELECT db_link, owner FROM dba_db_links
        MINUS
        SELECT db_link, owner FROM all_db_links;

    dbname        VARCHAR2 (200);
    currentuser   VARCHAR2 (30);
    linkno        NUMBER := 0;
BEGIN
    -- Current database and connected user
    SELECT name, USER
      INTO dbname, currentuser
      FROM v$database;

    DBMS_OUTPUT.put_line (
        'Verifying Database Links ' || currentuser || '@' || dbname);
    DBMS_OUTPUT.put_line (
        '========================================================');

    --
    FOR linkcur IN mylinks
    LOOP
        linkno := linkno + 1;
        DBMS_OUTPUT.put_line ('Checking Link: ' || linkno);
        DBMS_OUTPUT.put_line ('Link Name    : ' || linkcur.db_link);
        DBMS_OUTPUT.put_line ('Link Owner   : ' || linkcur.owner);
        DBMS_OUTPUT.put_line ('Connect User : ' || linkcur.username);
        DBMS_OUTPUT.put_line ('Connect To   : ' || linkcur.HOST);

        BEGIN
            --
            -- Connect to the link to validate, get global name of destination database
            EXECUTE IMMEDIATE   'select global_name from global_name@"'
                             || linkcur.db_link
                             || '"'
                INTO dbname;

            DBMS_OUTPUT.put_line (
                '$$$$ DB LINK SUCCESSFULLY connected to ' || dbname);
            --
            -- end the transaction and explicitly close the db link
            COMMIT;

            EXECUTE IMMEDIATE   'alter session close database link "'
                             || linkcur.db_link
                             || '"';
        EXCEPTION
            --
            -- DB Link connection failed, show error message
            WHEN OTHERS
            THEN
                DBMS_OUTPUT.put_line ('@@@@ DB LINK FAILED  @@@@');
                DBMS_OUTPUT.put_line ('Error: ' || SQLERRM);
        END;

        DBMS_OUTPUT.put_line ('---------------------------------------');
        DBMS_OUTPUT.put_line (' ');
    END LOOP;

    DBMS_OUTPUT.put_line ('Tests Completed.');
    --
    -- List other Links in the DB
    DBMS_OUTPUT.put_line ('Other Private Links in the Database');
    DBMS_OUTPUT.put_line ('Connect as respective owner to validate these.');
    DBMS_OUTPUT.put_line ('----------------------------------------------');

    FOR olinks IN otherlinks
    LOOP
        DBMS_OUTPUT.put_line (olinks.owner || ' :: ' || olinks.db_link);
    END LOOP;
END;
/

spool
SPOOL OFF
SET PAGES 99 LINES 80 TRIMS OFF
```

> Tester tous les dblinks de la base.

```
CREATE OR REPLACE PROCEDURE test_any_db_link ( p_owner IN varchar2 , p_link  IN varchar2)
AS
   l_owner  varchar2(100);
BEGIN
   IF p_owner = 'PUBLIC' THEN
      l_owner := 'SYSTEM';
   ELSE
      l_owner := p_owner;
   END IF;
   --
   BEGIN
     EXECUTE IMMEDIATE 'create procedure '||l_owner||'.test_any_db_link_temp '||
                       'as '||
                       '  l_dummy varchar2(1); '||
                       'begin '||
                       '  select * into l_dummy from dual@'||p_link||'; '||
                       '  dbms_output.put_line(''OK : '||p_owner||'.'||
                                                         p_link||'''); '||
                       'exception '||
                       ' when others then '||
                       '   dbms_output.put_line(''NOK: '||p_owner||'.'||
                                                          p_link||'''||'' ''||
                                                          sqlcode); '||
                       'end;';
     EXECUTE IMMEDIATE 'begin '||l_owner||'.test_any_db_link_temp; end;';
   EXCEPTION
     WHEN OTHERS THEN
       dbms_output.put_line('ERR: '||p_owner||'.'||p_link||' '||sqlcode);
   END;
   EXECUTE IMMEDIATE 'drop procedure '||l_owner||'.test_any_db_link_temp';
END;
/
set serveroutput on size 1000000;
spool ${HX_LOG}/test_db_links
BEGIN
  FOR r_stmt IN (select 'begin test_any_db_link('''||owner||''','''||
                                                     db_link||'''); end;' stmt
                   from dba_db_links
                  order by owner, db_link
                )
  LOOP
    execute immediate r_stmt.stmt;
  END LOOP;
END;
/
spool off
drop procedure test_any_db_link;
-- done
--
```
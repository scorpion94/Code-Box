*This document has been created with OpenAI*
# ORDS + Apache: Einfacher Webservice für INSERT/UPDATE/DELETE in Oracle (ohne AutoREST)

Diese Anleitung beschreibt, wie du mit ORDS 25.4 hinter Apache einen
kleinen REST-Service baust, der in eine Oracle-Tabelle schreibt -- ohne
AutoREST und ohne Trigger-Workarounds.

------------------------------------------------------------------------

## Zielbild

-   Oracle Tabelle `APACHE.OBST`
-   ORDS Schema-Mapping: `/ords/apache/...`
-   ORDS Modul: `/ords/apache/obstapi/...`
-   Endpunkte:
    -   GET `/ords/apache/obstapi/obst/`
    -   GET `/ords/apache/obstapi/obst/{id}`
    -   POST `/ords/apache/obstapi/obst/`
    -   PUT `/ords/apache/obstapi/obst/{id}`
    -   DELETE `/ords/apache/obstapi/obst/{id}`

------------------------------------------------------------------------

## Schritt 1: Tabelle anlegen

``` sql
CREATE TABLE obst (
    id NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
    name VARCHAR2(100) NOT NULL,
    created_at DATE DEFAULT SYSDATE,
    CONSTRAINT obst_pk PRIMARY KEY (id)
);

```

------------------------------------------------------------------------

## Schritt 2: ORDS Schema-Mapping aktivieren

``` sql
begin
  ords.enable_schema(
    p_enabled             => true,
    p_schema              => 'APACHE',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'apache',
    p_auto_rest_auth      => false
  );
  commit;
end;
/
```

------------------------------------------------------------------------

## Schritt 3: AutoREST deaktivieren

``` sql
begin
  ords.enable_object(
    p_enabled      => false,
    p_schema       => 'APACHE',
    p_object       => 'OBST',
    p_object_type  => 'TABLE',
    p_object_alias => 'obst'
  );
  commit;
end;
/
```

------------------------------------------------------------------------

## Schritt 4: ORDS Modul anlegen

``` sql
begin
  ords.define_module(
    p_module_name => 'obstapi',
    p_base_path   => '/obstapi/',
    p_status      => 'PUBLISHED'
  );
  commit;
end;
/
```

------------------------------------------------------------------------

## Schritt 5: Templates anlegen

``` sql
begin
  ords.define_template(p_module_name => 'obstapi', p_pattern => 'obst/');
  ords.define_template(p_module_name => 'obstapi', p_pattern => 'obst/:id');
  commit;
end;
/
```

------------------------------------------------------------------------

## Schritt 6: GET Handler (Collection)

``` sql
begin
  ords.define_handler(
    p_module_name => 'obstapi',
    p_pattern     => 'obst/',
    p_method      => 'GET',
    p_source_type => 'json/query',
    p_source      => 'select id, name, created_at from obst order by id'
  );
  commit;
end;
/
```

------------------------------------------------------------------------

## Schritt 7: GET Handler (Item)

``` sql
begin
  ords.define_handler(
    p_module_name => 'obstapi',
    p_pattern     => 'obst/:id',
    p_method      => 'GET',
    p_source_type => 'json/query',
    p_source      => 'select id, name, created_at from obst where id = :id'
  );
  commit;
end;
/
```

------------------------------------------------------------------------

## Schritt 8: POST Handler

``` sql
begin
  ords.define_handler(
    p_module_name => 'obstapi',
    p_pattern     => 'obst/',
    p_method      => 'POST',
    p_source_type => 'plsql/block',
    p_source      => q'[
      begin
        insert into obst(name) values (:name);
        commit;
      end;
    ]'
  );
  commit;
end;
/
```

------------------------------------------------------------------------

## Schritt 9: PUT Handler

``` sql
begin
  ords.define_handler(
    p_module_name => 'obstapi',
    p_pattern     => 'obst/:id',
    p_method      => 'PUT',
    p_source_type => 'plsql/block',
    p_source      => q'[
      begin
        update obst
           set name = :name
         where id = :id;
        commit;
      end;
    ]'
  );
  commit;
end;
/
```

------------------------------------------------------------------------

## Schritt 10: DELETE Handler

``` sql
begin
  ords.define_handler(
    p_module_name => 'obstapi',
    p_pattern     => 'obst/:id',
    p_method      => 'DELETE',
    p_source_type => 'plsql/block',
    p_source      => q'[
      begin
        delete from obst where id = :id;
        commit;
      end;
    ]'
  );
  commit;
end;
/
```

------------------------------------------------------------------------

## Test mit curl

``` bash
curl -s "http://localhost:80/ords/apache/obstapi/obst/"
curl -i -X POST "http://localhost:80/ords/apache/obstapi/obst/" -H "Content-Type: application/json" -d '{"name":"KIWI"}'
curl -i -X PUT "http://localhost:80/ords/apache/obstapi/obst/1" -H "Content-Type: application/json" -d '{"name":"MANGO"}'
curl -i -X DELETE "http://localhost:80/ords/apache/obstapi/obst/1"
```

------------------------------------------------------------------------

Fertig.

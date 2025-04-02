CREATE TABLE obst(name VARCHAR2(8)); 
INSERT INTO obst (name) VALUES ('BANANE');
COMMIT;
BEGIN
  ords.enable_schema;
  COMMIT;
END;
/

BEGIN
  ords.create_service(p_module_name    => 'examples.obst',
                      p_base_path      => '/examples/obst/',
                      p_pattern        => '.',
                      p_items_per_page => 7,
                      p_source         => 'select * from obst');
  COMMIT;
END;
/

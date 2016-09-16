CREATE TABLE realtime(
    id SERIAL NOT NULL PRIMARY KEY,
    title character varying(128)
);

CREATE OR REPLACE FUNCTION table_update_notify() RETURNS trigger AS $$
DECLARE
  id bigint;
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    id = NEW.id;
    PERFORM pg_notify('table_update', json_build_object('table', TG_TABLE_NAME, 'id', id, 'type', TG_OP, 'row', row_to_json(NEW))::text);
  ELSE
    id = OLD.id;
	  PERFORM pg_notify('table_update', json_build_object('table', TG_TABLE_NAME, 'id', id, 'type', TG_OP, 'row', row_to_json(OLD))::text);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--DROP TRIGGER notify_update ON realtime;
CREATE TRIGGER notify_update AFTER UPDATE ON realtime FOR EACH ROW EXECUTE PROCEDURE table_update_notify();

--DROP TRIGGER notify_insert ON realtime;
CREATE TRIGGER notify_insert AFTER INSERT ON realtime FOR EACH ROW EXECUTE PROCEDURE table_update_notify();

--DROP TRIGGER notify_delete ON realtime;
CREATE TRIGGER notify_delete AFTER DELETE ON realtime FOR EACH ROW EXECUTE PROCEDURE table_update_notify();

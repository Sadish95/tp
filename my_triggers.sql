CREATE OR REPLACE TRIGGER trg_all_workers_elapsed_insert
INSTEAD OF INSERT ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
  INSERT INTO WORKERS (worker_id, first_name, last_name, start_date, factory_id)
  VALUES (:NEW.worker_id, :NEW.first_name, :NEW.last_name, :NEW.start_date, :NEW.factory_id);
END;
/

CREATE OR REPLACE TRIGGER trg_robot_creation
AFTER INSERT ON ROBOTS
FOR EACH ROW
BEGIN
  INSERT INTO AUDIT_ROBOT (robot_id, creation_date)
  VALUES (:NEW.robot_id, SYSDATE);
END;
/

CREATE OR REPLACE TRIGGER trg_factories_consistency
BEFORE INSERT OR UPDATE OR DELETE ON ROBOTS_FACTORIES
DECLARE
  num_factories NUMBER;
  num_tables NUMBER;
BEGIN
  SELECT COUNT(*) INTO num_factories FROM FACTORIES;
  SELECT COUNT(*) INTO num_tables FROM all_tables WHERE table_name LIKE 'WORKERS_FACTORY_%';
  
  IF num_factories != num_tables THEN
    RAISE_APPLICATION_ERROR(-20001, 'The number of factories does not match the number of WORKERS_FACTORY tables.');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_worker_departure
AFTER UPDATE OF departure_date ON WORKERS
FOR EACH ROW
BEGIN
  :NEW.employment_duration := :NEW.departure_date - :OLD.start_date;
END;
/

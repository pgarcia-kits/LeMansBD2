CREATE OR REPLACE FUNCTION SIMULATION(timer integer) RETURNS TABLE AS $$
    BEGIN
        INSERT INTO evento(id,ano,tipo,id_organizacion,id_pista) VALUES (timer,2021,'Carrera',1,1);
        RETURN SELECT * FROM evento;
    END;
$$ LANGUAGE plpgsql;
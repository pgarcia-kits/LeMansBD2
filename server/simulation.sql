CREATE OR REPLACE FUNCTION simulation (timer numeric) RETURNS void AS $$
    DECLARE 
        count numeric := 10;
        prev_event_id evento.id%TYPE;
        aux_event_id evento.id%TYPE;
        event_id evento.id%TYPE;
        position numeric := 1;
    BEGIN
        SELECT * FROM evento ORDER BY id DESC LIMIT 1; -- OBTENEMOS ID DEL ULTIMO EVENTO REGISTRADO
        RETURNING id INTO prev_event_id;    -- ASIGNAMOS EL ID PARA INCREMENTARLO EN UNA UNIDAD Y UTILIZARLO PARA CREAR EL NUEVO EVENTO

        aux_event_id := prev_event_id + 1;  -- INCREMENTAMOS EN UNA UNIDAD EL ID DEL EVENTO ANTERIOR

        INSERT INTO evento(id, ano, tipo, id_organizacion, id_pista) -- CREAMOS EL NUEVO EVENTO
        VALUES (aux_event_id, 2021, 'Carrera', 1, 1);
        RETURNING id INTO event_id; -- ALMACENAMOS EL NUEVO ID PARA PODER UTILIZARLO EN CADA UNA DE LAS ITERACIONES DE LA SIMULACION
        
        FOR team IN SELECT * FROM equipo LOOP -- ITERAMOS SOBRE LA LISTA DE EQUIPOS REGISTRADOS PARA ESTE NUEVO EVENTO
            FOR car IN SELECT * FROM vehiculo WHERE LOOP -- ITERAMOS SOBRE LA LISTA DE VEHICULOS ASOCIADOS A LOS EQUIPOS
                position := position + 1;
                INSERT INTO ranking(pocision, vueltas, fecha, id_equipo, id_vehiculo, id_evento) -- HACEMOS EL INSERT DEL RANKING INICIAL PARA DICHO EVENTO
                VALUES (position, timer, to_date(now(), 'DD-MM-YYYY'), team.id, car.id, event_id);
            END LOOP;
        END LOOP;
        
        LOOP
            count := count + 1;
            EXIT WHEN count = timer;
        END LOOP;
    END;
$$ LANGUAGE plpgsql;
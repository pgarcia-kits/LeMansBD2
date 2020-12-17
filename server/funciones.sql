-------------------------------COMENTARIOS------------------------------------
--	1.- Como haremos para ordenar por hora? se sumaran los minutos hasta obtener 1 hora por competidor o los guardamos en algun lado?
--	2.- Crear funcion que compare diferencia entre dos lugares, vueltas, y si son la misma cantidad, tiempo
--	
--	
--
--
--
--
---------------------------------------------------------------------------------------------------------------------------
--												Calculo Marcas
---------------------------------------------------------------------------------------------------------------------------


--Esta funcion servira para los calculos que se realizaran en el TDA MARCAS
CREATE OR REPLACE FUNCTION minutos_a_decimales(a varchar, b float)
RETURNS float as $$
BEGIN
	b := ((cast(SUBSTRING(a,1,1) as float))/60)+(cast(SUBSTRING(a,1,1) as float));
	RETURN b;
END;
$$LANGUAGE plpgsql

--Esta funcion sirve para calcular la velocidad_promedio en base al tiempo
CREATE OR REPLACE FUNCTION velocidad_promedio(km float, tiempo float)
RETURNS float as $$
BEGIN
	RETURN km * tiempo;
END;
$$LANGUAGE plpgsql

--Esta funcion sirve para calcular un aproximado de kilometraje por vuelta
CREATE OR REPLACE FUNCTION kilometraje_promedio(km float, vueltas integer)
RETURNS float as $$
BEGIN
	RETURN km / vueltas;
END;
$$LANGUAGE plpgsql


---------------------------------------------------------------------------------------------------------------------------
--												Carreras
---------------------------------------------------------------------------------------------------------------------------


--Esta funcion genera los tiempos de la vuelta
CREATE OR REPLACE FUNCTION tiempo_vueltas(tiempo_rapido float, tiempo_promedio float)
RETURNS float as $$
BEGIN
	RETURN random()*(tiempo_promedio-tiempo_rapido)+tiempo_rapido;
END;
$$LA-GUAGE plpgsql;

--Esta funcion genera el kilometraje por vuelta
CREATE OR REPLACE FUNCTION kilometraje_vuelta(promedio_anterior float, maximo float)
RETURNS float as $$
BEGIN
	RETURN random()*(maximo-promedio_anterior)+promedio_anterior;
END;
$$LANGUAGE plpgsql;

--Esta funcion genera la velocidad promedio de una vuelta
CREATE OR REPLACE FUNCTION velocidad_vuelta(promedio float)
RETURNS float as $$
DECLARE
	maximo float;
	minimo float;
BEGIN
	maximo := promedio + 20;
	minimo := promedio - 20;
	RETURN random()*(maximo-minimo)+minimo;
END;
$$LANGUAGE plpgsql;

--Esta funcion genera el kilometraje de una vuelta
CREATE OR REPLACE FUNCTION kilometraje_vuelta(promedio float)
RETURNS float as $$
DECLARE
	maximo float;
	minimo float;
BEGIN
	maximo := 13.626;
	minimo := promedio;
	RETURN random()*(maximo-minimo)+minimo+0.02;
END;
$$LANGUAGE plpgsql;

--Esta funcion va a registrar las vueltas
CREATE OR REPLACE FUNCTION insertar_vuelta(id_eq numeric,id_eve numeric, id_rank numeric, id numeric, km_prom float, t_prom varchar, vel_med float, mas_rapida float)
RETURNS TABLE as $$
DECLARE 
	km_vuelta float;
	vel_vuelta float;
	tiempo_vuelta float;
BEGIN
	km_vuelta := kilometraje_vuelta(km_prom);
	vel_vuelta := velocidad_vuelta(vel_med);
	t_prom := tiempo_vueltas(mas_rapida,t_prom);
	RETURN QUERY
	INSERT INTO public.vuelta (id,distancia,tiempo,velocidad_media,id_equipo,id_evento,id_ranking)
	VALUES (id,km_vuelta,t_prom,vel_vuelta,id_eq,id_eve,id_rank);
END;
$$LANGUAJE plpgsql;

---------------------------------------------------------------------------------------------------------------------------
--												Posiciones Relativas
---------------------------------------------------------------------------------------------------------------------------


drop sequence secuenciaposicion;
create sequence secuenciaposicion
  start with 1
  increment by 1
  maxvalue 100
  minvalue 1
  cycle;

---------------------------------------------------------------------------------------------------------------------------
--												Procedimiento Reportes
---------------------------------------------------------------------------------------------------------------------------

--Reporte 1
CREATE OR REPLACE FUNCTION ranking_anho_categoria (an numeric, cat varchar, tip varchar)
RETURNS TABLE (ranking ranking.posicion%TYPE, vueltas ranking.vueltas%TYPE, kilometraje ranking.kilometraje%TYPE, numero_equipo equipo.numero_equipo%TYPE, nombre equipo.nombre%TYPE, fabricante fabricante.nombre%TYPE, modelo modelo.nombre%TYPE, categoria vehiculo.categoria%TYPE) AS $$
BEGIN
	IF(cat='Todos')THEN
		RETURN QUERY
			SELECT 
			--RANKING
			r.posicion, r.vueltas, r.kilometraje, 
			--INFORMACION EQUIPO
			e.numero_equipo, e.nombre as nombreequipo, 
			--INFORMACION VEHICULO
			f.nombre, m.nombre,v.categoria
			FROM ranking r, evento ev, vehiculo v, modelo m, equipo e, fabricante f
			WHERE r.id_evento = ev.id
			AND ev.tipo = tip			    
			AND ev.ano= an						
			AND v.id = r.id_vehiculo
			AND m.id = v.id_modelo
			AND r.id_equipo = e.id
			AND f.id = m.id_fabricante;
	ELSE
		RETURN QUERY
			SELECT 
			--RANKING
			r.posicion, r.vueltas, r.kilometraje, 
			--INFORMACION EQUIPO
			e.numero_equipo, e.nombre as nombreequipo, 
			--INFORMACION VEHICULO
			f.nombre, m.nombre,v.categoria
			FROM ranking r, evento ev, vehiculo v, modelo m, equipo e, fabricante f
			WHERE r.id_evento = ev.id
			AND ev.tipo = tip			    
			AND ev.ano= an						
			AND v.categoria = cat				
			AND v.id = r.id_vehiculo
			AND m.id = v.id_modelo
			AND r.id_equipo = e.id
			AND f.id = m.id_fabricante;
	END IF;
END;
$$LANGUAGE plpgsql;

--Reporte 2

CREATE OR REPLACE FUNCTION ranking_hora_categoria (an numeric, cat varchar, hor numeric)
RETURNS TABLE (ranking ranking.posicion%TYPE, vueltas ranking.vueltas%TYPE, kilometraje ranking.kilometraje%TYPE, numero_equipo equipo.numero_equipo%TYPE, nombre equipo.nombre%TYPE, fabricante fabricante.nombre%TYPE, modelo modelo.nombre%TYPE, categoria vehiculo.categoria%TYPE) AS $$
BEGIN
RETURN QUERY
	SELECT 
	--RANKING
	r.posicion, r.vueltas, r.kilometraje, 
	--INFORMACION EQUIPO
	e.numero_equipo, e.nombre as nombreequipo, 
	--INFORMACION VEHICULO
	f.nombre, m.nombre,v.categoria
	FROM ranking r, evento ev, vehiculo v, modelo m, equipo e, fabricante f, ranking_por_hora rh
	WHERE r.id_evento = ev.id
	AND ev.tipo = 'Carrera'
	AND ev.ano= an					   --Se sustituira por el insertado por el usuario
	AND v.categoria = cat			--Se sustituira por el insertado por el usuario
	AND v.id = r.id_vehiculo
	AND m.id = v.id_modelo
	AND r.id_equipo = e.id
	AND f.id = m.id_fabricante
	AND rh.id_ranking = r.id
	AND rh.hora = hor;					--Se sustituira por el insertado por el usuario
END;
$$LANGUAGE plpgsql;

--Reporte 3

CREATE OR REPLACE FUNCTION ganadores_categoria(cat varchar, an numeric)
RETURNS TABLE (posicion ranking.posicion%TYPE, vueltas ranking.vueltas%TYPE, kilometraje ranking.kilometraje%TYPE, numero_equipo equipo.numero_equipo%TYPE, nombre_equipo equipo.nombre%TYPE, nombre_fabricante fabricante.nombre%TYPE, modelo modelo.nombre%TYPE, categoria_vehiculo vehiculo.categoria%TYPE) AS $$
BEGIN
	RETURN QUERY
		SELECT 
		--RANKING
		r.posicion, r.vueltas, r.kilometraje, 
		--INFORMACION EQUIPO
		e.numero_equipo, e.nombre as nombreequipo, 
		--INFORMACION VEHICULO
		f.nombre, m.nombre,v.categoria
		FROM ranking r, evento ev, vehiculo v, modelo m, equipo e, fabricante f
		WHERE r.id_evento = ev.id
		AND ev.tipo = 'Carrera'
		AND ev.ano= an					--REVISAR USO DE IN CUANDO NO SE INSERTAN
		AND v.categoria = cat
		AND v.id = r.id_vehiculo
		AND m.id = v.id_modelo
		AND r.id_equipo = e.id
		AND f.id = m.id_fabricante
		AND r.posicion =1;
END;
$$LANGUAGE plpgsql;
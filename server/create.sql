CREATE TYPE Persona as
(
    nombre varchar(20),
    nombre2 varchar(20),
    apellido varchar(20),
    apellido2 varchar(20),
    fecha_nacimiento varchar,
    estatura varchar, 
    peso varchar,
    fecha_fallecimiento varchar, 
    genero varchar(1)
);

CREATE TYPE Tiempo as
(
    fecha_inicial date,
    fecha_final date
);

CREATE TYPE Marcas as
(
    vuelta_mas_rapida date,
    vuelta_promedio date,
    kilometraje_promedio_vuelta float,
    velocidad_media float
);

--------------------------------------------------------------------------------

CREATE TABLE public.fabricante
(
    id numeric(3) NOT NULL,
    nombre varchar NOT NULL,
    logo BYTEA,
    CONSTRAINT pk_fabricante PRIMARY KEY (id)
);

CREATE TABLE public.modelo
(
    id numeric(10) NOT NULL,
    nombre varchar NOT NULL,
    id_fabricante numeric NOT NULL,
    CONSTRAINT pk_modelo PRIMARY KEY (id),
    CONSTRAINT fk_modelo FOREIGN KEY (id_fabricante) REFERENCES fabricante(id)
);

CREATE TABLE public.equipo
(
    id numeric(4) NOT NULL,
    nombre varchar NOT NULL,
    numero_equipo numeric (3) NOT NULL,
    activo boolean NOT NULL,
    id_fabricante numeric NOT NULL,
    CONSTRAINT pk_equipo PRIMARY KEY (id),
    CONSTRAINT fk_fabricante FOREIGN KEY (id_fabricante) REFERENCES fabricante(id)
);

CREATE TABLE public.nacionalidad
(
    id numeric(3) NOT NULL,
    gentilicio varchar(15) NOT NULL,
    nombre_pais varchar NOT NULL,
    foto_bandera BYTEA,
    CONSTRAINT pk_nacionalidad PRIMARY KEY (id)
);

CREATE TABLE public.organizacion
(
    id numeric(2) NOT NULL,
    nombre varchar NOT NULL,
    CONSTRAINT pk_organizacion PRIMARY KEY (id)
);

CREATE TABLE public.pista 
(
    id numeric NOT NULL,
    nombre varchar NOT NULL,
    kilometraje float NOT NULL,
    CONSTRAINT pk_pista PRIMARY KEY (id)
);

CREATE TABLE public.sector
(
    id numeric(2) NOT NULL,
    nombre varchar NOT NULL,
    descripcion varchar(55),
    id_pista numeric NOT NULL,
    CONSTRAINT pk_sector PRIMARY KEY (id),
    CONSTRAINT fk_pista FOREIGN KEY (id_pista) REFERENCES pista(id)
);

CREATE TABLE public.evento
(
    id numeric(2) NOT NULL,
    ano numeric NOT NULL,
    tipo varchar(7),
    id_organizacion numeric NOT NULL,
    id_pista numeric NOT NULL,
    CONSTRAINT pk_evento PRIMARY KEY (id),
    CONSTRAINT chk_tipo CHECK(tipo in('Ensayo','Carrera')),
    CONSTRAINT fk_organizacion FOREIGN KEY (id_organizacion) REFERENCES organizacion(id),
    CONSTRAINT fk_pista FOREIGN KEY (id_pista) REFERENCES pista(id)
);

CREATE TABLE public.piloto
(
    id numeric(5) NOT NULL,
    informacion Persona,  --Esto debe ser obligatorio
    idiomas varchar[5], --Esto debe ser obligatorio
    foto BYTEA,
    id_nacionalidad numeric NOT NULL,
    CONSTRAINT pk_piloto PRIMARY KEY (id),
    CONSTRAINT fk_nacionalidad FOREIGN KEY (id_nacionalidad) REFERENCES nacionalidad(id)
);

CREATE TABLE public.vehiculo
(
    id numeric(10) NOT NULL,
    numero numeric(3) NOT NULL,
    categoria varchar NOT NULL,
    tipo varchar NOT NULL,
    --caracteristicas varchar[5] NOT NULL,
    --piezas [][],
    --serial varchar(40),
    foto BYTEA,
    id_equipo numeric NOT NULL,
    id_modelo numeric NOT NULL,
    CONSTRAINT pk_vehiculo PRIMARY KEY (id),
    CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES equipo(id),
    CONSTRAINT fk_modelo FOREIGN KEY (id_modelo) REFERENCES modelo(id)
);

CREATE TABLE public.contrato
(
    id numeric NOT NULL,
    duracion Tiempo,
    id_piloto numeric NOT NULL,
    id_equipo numeric NOT NULL,
    CONSTRAINT pk_contrato PRIMARY KEY (id,id_equipo,id_piloto),
    CONSTRAINT fk_piloto FOREIGN KEY (id_piloto) REFERENCES piloto(id),
    CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES equipo(id)
);

CREATE TABLE public.ranking
(
    id numeric NOT NULL,
    posicion numeric,
    kilometraje float,
    vueltas numeric NOT NULL,
    tiempo_total Tiempo,
    desempeno Marcas,
    fecha date,
    id_equipo numeric NOT NULL,
    id_vehiculo numeric NOT NULL,
    id_evento numeric NOT NULL,
    CONSTRAINT pk_ranking PRIMARY KEY (id),
    CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES equipo(id),
    CONSTRAINT fk_evento FOREIGN KEY (id_evento) REFERENCES evento(id),
    CONSTRAINT fk_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id)
);

CREATE TABLE public.ranking_por_hora
(
    id_ranking numeric NOT NULL,
    hora numeric NOT NULL,
    posicion numeric NOT NULL,
    CONSTRAINT pk_rkg_hora PRIMARY KEY (id_ranking,hora),
    CONSTRAINT fk_ranking FOREIGN KEY (id_ranking) REFERENCES ranking(id)
);

CREATE TABLE public.vuelta
(
    id numeric NOT NULL,
    distancia float NOT NULL,           --Aqui va la distancia, sacada con distancia promedio del año anterior
    tiempo varchar NOT NULL,            --Aqui va el tiempo de las vueltas, se manejara en varchar para una presentacion mas comoda y exacta
    velocidad_media float NOT NULL,     --Aqui va la velocidad media, calculada con la velocidad_media del año anterior
    temperatura_cockpit float,
    id_equipo numeric NOT NULL,
    id_evento numeric NOT NULL,
    id_ranking numeric NOT NULL,
    CONSTRAINT pk_vuelta PRIMARY KEY (id),
    CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES equipo(id),
    CONSTRAINT fk_evento FOREIGN KEY (id_evento) REFERENCES evento(id),
    CONSTRAINT fk_ranking FOREIGN KEY (id_ranking) REFERENCES ranking(id)
);

CREATE TABLE public.patrocinador
(
    id numeric NOT NULL,
    nombre varchar NOT NULL,
    logo BYTEA,
    CONSTRAINT pk_patrocinador PRIMARY KEY (id)
);

CREATE TABLE public.patrocinio
(
    id numeric NOT NULL,
    duracion Tiempo NOT NULL,
    id_patrocinador numeric NOT NULL,
    id_evento numeric,
    id_equipo numeric,
    CONSTRAINT pk_patrocinio PRIMARY KEY (id,id_patrocinador),
    CONSTRAINT fk_evento FOREIGN KEY (id_evento) REFERENCES evento(id),
    CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES equipo(id)
);

CREATE TABLE public.equipo_evento
(
    id_equipo numeric NOT NULL,
    id_evento numeric NOT NULL,
    CONSTRAINT pk_equipo_evento PRIMARY KEY (id_equipo,id_evento),
    CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES equipo(id),
    CONSTRAINT fk_evento FOREIGN KEY (id_evento) REFERENCES evento(id)
);

CREATE TABLE public.suceso
(
    id numeric NOT NULL,
    descripcion varchar,
    tipo varchar(20) NOT NULL,
    bandera varchar(7),
    momento Tiempo NOT NULL,
    retraso date NOT NULL,
    id_vuelta numeric NOT NULL,
    id_sector numeric,
    CONSTRAINT pk_suceso PRIMARY KEY (id),
    CONSTRAINT fk_vuelta FOREIGN KEY (id_vuelta) REFERENCES vuelta(id),
    CONSTRAINT fk_sector FOREIGN KEY (id_sector) REFERENCES sector(id)
);

CREATE TABLE public.suceso_vehiculo
(
    id_suceso numeric NOT NULL,
    id_vehiculo numeric NOT NULL,
    directo varchar NOT NULL,       --pensar si de verdad se necesita
    CONSTRAINT pk_suceso_vehiculo PRIMARY KEY (id_suceso,id_vehiculo),
    CONSTRAINT fk_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id),
    CONSTRAINT fk_suceso FOREIGN KEY (id_suceso) REFERENCES suceso(id)
);

CREATE TABLE public.parada
(
    id numeric NOT NULL,
    duracion Tiempo NOT NULL,
    tipo varchar[10] NOT NULL,      --Cambios que se hicieron en la parada ej: cambio de piloto, cambio de cauchos, cambio de piezas, revisar si es necesario hacerle check
    id_vuelta numeric NOT NULL,
    CONSTRAINT pk_parada PRIMARY KEY (id),
    CONSTRAINT fk_vuelta FOREIGN KEY (id_vuelta) REFERENCES vuelta(id)
);

CREATE TABLE public.alerta
(
    id numeric NOT NULL,
--    fallas [][],  REVISAR
    tiempo date NOT NULL,
    pendiente boolean NOT NULL,
    id_suceso numeric,
    id_parada numeric,
    CONSTRAINT pk_alerta PRIMARY KEY (id),
    CONSTRAINT pk_suceso FOREIGN KEY (id_suceso) REFERENCES suceso(id),
    CONSTRAINT pk_parada FOREIGN KEY (id_parada) REFERENCES parada(id)
);

CREATE TABLE public.inventario_repuesto
(
    id numeric NOT NULL,
    nombre_pieza varchar(15) NOT NULL,
    cantidad numeric(2) NOT NULL,
    marca varchar,
    fecha_actualizacion date NOT NULL,
    operacion varchar NOT NULL,
    id_parada numeric NOT NULL,
    id_vehiculo numeric NOT NULL,
    CONSTRAINT pk_inventario_repuesto PRIMARY KEY (id,id_vehiculo,id_parada),
    CONSTRAINT fk_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id),
    CONSTRAINT fk_parada FOREIGN KEY (id_parada) REFERENCES parada(id),
    CONSTRAINT chk_operacion CHECK (operacion in ('Inicial','Salida','Final'))
);
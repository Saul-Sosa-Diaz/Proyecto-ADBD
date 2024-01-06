DROP SCHEMA public CASCADE;
CREATE SCHEMA public;


CREATE TYPE TIPO_HABITACION AS ENUM(
  'Suite',
  'Doble',
  'Individual',
  'Triple',
  'Familiar',
  'Presidencial',
  'Estudio'
);

-- Creación de la tabla Proveedor
CREATE TABLE PROVEEDOR (
    codigo_proveedor SERIAL,
    nombre_proveedor VARCHAR(255),
    telefono VARCHAR(9) CHECK (telefono ~ '^[0-9]{9}$') NOT NULL, 
    PRIMARY KEY (codigo_proveedor)
);

-- Creación de la tabla Servicio
CREATE TABLE SERVICIO (
    codigo_servicio SERIAL PRIMARY KEY,
    nombre_servicio VARCHAR(255),
    tarifa MONEY CHECK (tarifa > 0.0::money) NOT NULL, --Asegurar que la tarifa es positiva
    premium BOOLEAN DEFAULT FALSE
);

-- Creación de la tabla Contrato
CREATE TABLE CONTRATO (
    codigo_contrato SERIAL,
    codigo_proveedor INT NOT NULL REFERENCES PROVEEDOR(codigo_proveedor) ON DELETE CASCADE ON UPDATE CASCADE,
    codigo_servicio INT NOT NULL REFERENCES SERVICIO(codigo_servicio) ON DELETE CASCADE ON UPDATE CASCADE,
    fin_vigencia DATE NOT NULL CHECK (fin_vigencia >= CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (codigo_contrato, codigo_proveedor, codigo_servicio)
);


CREATE TYPE NOMBRE_COMPLETO AS (
  Nombre_Pila VARCHAR(20),
  Apellido_1 VARCHAR(20),
  Apellido_2 VARCHAR(20)
);

-- Creación de la tabla Cliente
CREATE TABLE CLIENTE (
    dni_cliente VARCHAR(10) PRIMARY KEY CHECK (dni_cliente ~ '^[0-9]{8}[A-Z]$'),
    nombre_cliente NOMBRE_COMPLETO,
    correo_electronico VARCHAR(255)[] NOT NULL,
    premium BOOLEAN DEFAULT FALSE
);

-- Creación de la tabla Habitación
CREATE TABLE HABITACION (
     codigo_habitacion SERIAL PRIMARY KEY,
     tarifa MONEY NOT NULL CHECK (tarifa > 0.0::money), --Asegurar que la tarifa es positiva
     tipo TIPO_HABITACION
);


-- Creación de la tabla Registro Mantenimiento
CREATE TABLE REGISTRO_MANTENIMIENTO (
    codigo_registro SERIAL,
    codigo_habitacion INT NOT NULL REFERENCES HABITACION(codigo_habitacion) ON DELETE CASCADE ON UPDATE CASCADE,
    fecha DATE CHECK (fecha <= CURRENT_DATE),
    descripcion VARCHAR(255),
    PRIMARY KEY (codigo_registro, fecha)
);

-- Creación de la tabla Reserva
CREATE TABLE RESERVA (
    codigo_reserva SERIAL,
    dni_cliente varchar(10) NOT NULL CHECK (dni_cliente ~ '^[0-9]{8}[A-Z]$') REFERENCES CLIENTE(dni_cliente) ON DELETE CASCADE ON UPDATE CASCADE,
    fecha DATE NOT NULL CHECK (fecha >= CURRENT_DATE),
    numero_dias INT NOT NULL CHECK (numero_dias > 0),
    importe MONEY DEFAULT 0,                               
    PRIMARY KEY (codigo_reserva)
);


-- Creación de la tabla ReservaHabitacion
CREATE TABLE RESERVA_HABITACION (
    codigo_reserva INT NOT NULL REFERENCES RESERVA(codigo_reserva) ON DELETE CASCADE ON UPDATE CASCADE,
    codigo_habitacion INT NOT NULL REFERENCES HABITACION(codigo_habitacion) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (codigo_reserva, codigo_habitacion)
);


-- Creación de la tabla ReservaServicio
CREATE TABLE RESERVA_SERVICIO (
    codigo_reserva INT NOT NULL REFERENCES RESERVA(codigo_reserva) ON DELETE CASCADE ON UPDATE CASCADE,
    codigo_servicio INT NOT NULL REFERENCES SERVICIO(codigo_servicio) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (codigo_reserva, codigo_servicio)
);


-- Creación de la tabla Empleado
CREATE TABLE EMPLEADO (
    dni_empleado VARCHAR(10) NOT NULL CHECK (dni_empleado ~ '^[0-9]{8}[A-Z]$') PRIMARY KEY,
    dni_supervisor VARCHAR(10) CHECK (dni_supervisor ~ '^[0-9]{8}[A-Z]$') REFERENCES EMPLEADO(dni_empleado) ON DELETE CASCADE ON UPDATE CASCADE,
    nombre_empleado NOMBRE_COMPLETO,
    salario DECIMAL NOT NULL CHECK (salario > 700.0 AND salario < 10000.0),
    horas_totales INT DEFAULT 0
);


-- Creación de la tabla Departamento
CREATE TABLE DEPARTAMENTO (
	codigo_departamento SERIAL PRIMARY KEY,
    dni_gerente VARCHAR(10) NOT NULL CHECK (dni_gerente ~ '^[0-9]{8}[A-Z]$') REFERENCES EMPLEADO(dni_empleado) ON DELETE CASCADE ON UPDATE CASCADE,
    nombre_departamento VARCHAR(255)
);

-- Creación de la tabla 
CREATE TABLE EMPLEADO_DEPARTAMENTO (
    dni_empleado VARCHAR(10) NOT NULL CHECK (dni_empleado ~ '^[0-9]{8}[A-Z]$') REFERENCES EMPLEADO(dni_empleado) ON DELETE CASCADE ON UPDATE CASCADE,
    codigo_departamento INT NOT NULL REFERENCES DEPARTAMENTO(codigo_departamento),
    PRIMARY KEY (dni_empleado, codigo_departamento)
);

-- Creación de la tabla Curso
CREATE TABLE CURSO (
     codigo_curso SERIAL PRIMARY KEY,
     codigo_departamento INT NOT NULL REFERENCES DEPARTAMENTO(codigo_departamento) ON DELETE CASCADE ON UPDATE CASCADE,
     nombre_curso VARCHAR(255) NOT NULL,
     numero_horas INT NOT NULL CHECK (numero_horas > 0),
     categoria VARCHAR(100) 
);

-- Creación de la tabla RealizaCurso
CREATE TABLE EMPLEADO_REALIZA_CURSO (
     dni_empleado VARCHAR(9) NOT NULL CHECK (dni_empleado ~ '^[0-9]{8}[A-Z]$') REFERENCES EMPLEADO(dni_empleado) ON DELETE CASCADE ON UPDATE CASCADE,
     codigo_curso INT NOT NULL REFERENCES CURSO(codigo_curso) ON DELETE CASCADE ON UPDATE CASCADE,
     fecha DATE,
     PRIMARY KEY (dni_empleado, codigo_curso)
);

CREATE TABLE DEPARTAMENTO_SERVICIO (
    codigo_servicio INT NOT NULL REFERENCES SERVICIO(codigo_servicio) ON DELETE CASCADE ON UPDATE CASCADE,
    codigo_departamento INT NOT NULL REFERENCES DEPARTAMENTO(codigo_departamento) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (codigo_servicio, codigo_departamento)
);

CREATE TABLE JORNADA (
    codigo_jornada SERIAL PRIMARY KEY,
    fecha_hora_entrada timestamp NOT NULL CHECK(fecha_hora_entrada <= CURRENT_TIMESTAMP) NOT NULL,
    fecha_hora_salida timestamp NOT NULL CHECK (fecha_hora_salida > fecha_hora_entrada) NOT NULL
);

-- Creación de la tabla Realiza
CREATE TABLE EMPLEADO_JORNADA (
    dni_empleado VARCHAR(9) NOT NULL CHECK (dni_empleado ~ '^[0-9]{8}[A-Z]$') REFERENCES EMPLEADO(dni_empleado) ON DELETE CASCADE ON UPDATE CASCADE,
    codigo_jornada INT NOT NULL REFERENCES JORNADA(codigo_jornada) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (dni_empleado, codigo_jornada)
);

-- Función para validar correos electrónicos en un array
CREATE OR REPLACE FUNCTION validate_email_array(emails VARCHAR(255)[])
RETURNS BOOLEAN AS $$
DECLARE
    email VARCHAR(255);
BEGIN
    IF array_length(emails, 1) IS NULL THEN
        RETURN FALSE;               -- El array está vacío
    END IF;
    FOREACH email IN ARRAY emails
    LOOP
        IF email !~ '^[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$' THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar correos electrónicos al insertar o actualizar
CREATE OR REPLACE FUNCTION check_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT validate_email_array(NEW.correo_electronico) THEN
        RAISE EXCEPTION 'Correo electrónico inválido %', NEW.correo_electronico;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_email
BEFORE INSERT OR UPDATE ON CLIENTE
FOR EACH ROW EXECUTE FUNCTION check_email();



-- Trigger para obtener el importe de la reserva
CREATE OR REPLACE FUNCTION calcular_importe_reserva()
RETURNS TRIGGER AS $$
DECLARE
    total_tarifa_habitacion NUMERIC;
    total_tarifa_servicio NUMERIC;
	nuevo_importe NUMERIC;
BEGIN
    -- Calcular la tarifa total de la habitación
    SELECT tarifa INTO total_tarifa_habitacion
    FROM HABITACION
    WHERE codigo_habitacion IN (SELECT codigo_habitacion FROM RESERVA_HABITACION WHERE codigo_reserva = NEW.codigo_reserva);

    -- Calcular la suma total de las tarifas de los servicios
    SELECT SUM(tarifa) INTO total_tarifa_servicio
    FROM SERVICIO
    WHERE codigo_servicio IN (SELECT codigo_servicio FROM RESERVA_SERVICIO WHERE codigo_reserva = NEW.codigo_reserva);
	
	IF total_tarifa_habitacion IS NULL THEN
		total_tarifa_habitacion := 0;
	END IF;
	
	IF total_tarifa_servicio IS NULL THEN
		total_tarifa_servicio := 0;
	END IF;
	
    -- Actualizar la tabla RESERVA con el nuevo importe
    UPDATE RESERVA
    SET importe = total_tarifa_habitacion * RESERVA.numero_dias + total_tarifa_servicio
    WHERE codigo_reserva = NEW.codigo_reserva;
    
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER trg_calcular_importe_reservahabitacion
AFTER INSERT OR UPDATE ON RESERVA_HABITACION
FOR EACH ROW
EXECUTE FUNCTION calcular_importe_reserva();

CREATE TRIGGER trg_calcular_importe_reservaservicio
AFTER INSERT OR UPDATE ON RESERVA_SERVICIO
FOR EACH ROW
EXECUTE FUNCTION calcular_importe_reserva();


-- Trigger para verificar que no se reserven dos habitaciones en el mismo rango de fechas
CREATE OR REPLACE FUNCTION verificar_reserva_simultanea()
RETURNS TRIGGER AS $$
DECLARE
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
BEGIN
    -- Obtener las fechas de inicio y fin de la nueva reserva
    SELECT fecha, fecha + numero_dias INTO v_fecha_inicio, v_fecha_fin
    FROM RESERVA
    WHERE codigo_reserva = NEW.codigo_reserva;

    -- Verificar si existe alguna reserva para la misma habitación en el rango de fechas
    IF EXISTS (
        SELECT 1
        FROM RESERVA_HABITACION RH
        JOIN RESERVA R ON RH.codigo_reserva = R.codigo_reserva
        WHERE RH.codigo_habitacion = NEW.codigo_habitacion
          AND R.fecha < v_fecha_fin
          AND R.fecha + R.numero_dias > v_fecha_inicio
    ) THEN
        RAISE EXCEPTION 'La habitación ya está reservada en las fechas seleccionadas';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_verificar_reserva_simultanea
BEFORE INSERT OR UPDATE ON RESERVA_HABITACION
FOR EACH ROW EXECUTE FUNCTION verificar_reserva_simultanea();

-- Trigger para verificar que un mismo empeado no puede tener dos jornadas que se solapen
CREATE OR REPLACE FUNCTION verificar_jornada_simultanea()
RETURNS TRIGGER AS $$
DECLARE
    fecha_hora_entrada_var TIMESTAMP;
    fecha_hora_salida_var TIMESTAMP;
    contador INT;
BEGIN
    -- Obtener las horas de entrada y salida de la nueva jornada
    SELECT j.fecha_hora_entrada, j.fecha_hora_salida INTO fecha_hora_entrada_var, fecha_hora_salida_var
    FROM jornada j
    WHERE codigo_jornada = NEW.codigo_jornada;
    -- Verificar solapamiento
    SELECT COUNT(*)
    INTO contador
    FROM empleado_jornada ej
    JOIN jornada j ON ej.codigo_jornada = j.codigo_jornada
    WHERE ej.dni_empleado = NEW.dni_empleado
    AND ej.codigo_jornada != NEW.codigo_jornada -- Excluir la jornada actual en caso de actualización
    AND ( -- Comprobar que no se solape con otra
        (fecha_hora_entrada_var BETWEEN j.fecha_hora_entrada AND j.fecha_hora_salida)
        OR (fecha_hora_salida_var BETWEEN j.fecha_hora_entrada AND j.fecha_hora_salida)
        OR (j.fecha_hora_entrada BETWEEN fecha_hora_entrada_var AND fecha_hora_salida_var)
        OR (j.fecha_hora_salida BETWEEN fecha_hora_entrada_var AND fecha_hora_salida_var)
    );

    IF contador > 0 THEN
        RAISE EXCEPTION 'La jornada de empleado % se solapa con otra existente.', NEW.dni_empleado;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_solapamiento_jornada
BEFORE INSERT OR UPDATE ON EMPLEADO_JORNADA
FOR EACH ROW EXECUTE FUNCTION verificar_jornada_simultanea();



-- Trigger para calcular las horas truncadas trabajadas de un empleado
CREATE OR REPLACE FUNCTION calcular_horas_trabajadas()
RETURNS TRIGGER AS $$
DECLARE
    num_horas DOUBLE PRECISION;
BEGIN
    -- Obtener las horas trabajadas
    SELECT FLOOR(SUM(EXTRACT(EPOCH FROM (J.fecha_hora_salida - J.fecha_hora_entrada))) / 3600) INTO num_horas --Calcular las horas trabajadas truncando
    FROM JORNADA J
    JOIN EMPLEADO_JORNADA ON J.codigo_jornada = EMPLEADO_JORNADA.codigo_jornada
    WHERE dni_empleado = NEW.dni_empleado;
    -- Actualizar las horas trabajadas del empleado
    UPDATE EMPLEADO
    SET horas_totales = num_horas
    WHERE dni_empleado = NEW.dni_empleado;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_horas_trabajadas
AFTER INSERT OR UPDATE ON EMPLEADO_JORNADA
FOR EACH ROW EXECUTE FUNCTION calcular_horas_trabajadas();



-- Trigger para comprobar que solo los clientes premium reservan servicios premium
CREATE OR REPLACE FUNCTION verificar_reserva_premium()
RETURNS TRIGGER AS $$
DECLARE
    dni_cliente VARCHAR(10);
    es_premium BOOLEAN;
BEGIN
    -- Obtener DNI del cliente y si es premium
    SELECT C.dni_cliente, C.premium INTO dni_cliente, es_premium
    FROM cliente C 
    JOIN reserva R ON C.dni_cliente = R.dni_cliente
    WHERE R.codigo_reserva = NEW.codigo_reserva;
    -- Comprobar si el cliente es premium
    IF es_premium THEN
        -- Si el cliente es premium puede reservar cualquier servicio
        RETURN NEW;
    ELSE
        -- Comprobar si el servicio es premium
        IF EXISTS (
            SELECT 1
            FROM servicio
            WHERE codigo_servicio = NEW.codigo_servicio
            AND premium = true
        )
        THEN
            RAISE EXCEPTION 'El cliente % no es premium y no puede reservar servicios premium: %', dni_cliente, NEW.codigo_servicio;
        ELSE
            RETURN NEW;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_verificar_reserva_premium
AFTER INSERT OR UPDATE ON RESERVA_SERVICIO
FOR EACH ROW EXECUTE FUNCTION verificar_reserva_premium();


-- Trigger para comprobar que un empleado solo puede trabajar en un departamento si tiene al menos un curso asociado a ese departamento
CREATE OR REPLACE FUNCTION verificar_empleado_curso()
RETURNS TRIGGER AS $$
BEGIN
    -- Comprobar si el empleado tiene algún curso asociado al departamento
    IF EXISTS (
        SELECT 1
        FROM EMPLEADO_REALIZA_CURSO EC
        INNER JOIN CURSO C ON EC.codigo_curso = C.codigo_curso
        WHERE EC.dni_empleado = NEW.dni_empleado
        AND C.codigo_departamento = NEW.codigo_departamento
    ) OR EXISTS ( -- No hace falta que los gerentes tengan ningún curso.
        SELECT 1
        FROM DEPARTAMENTO
        WHERE codigo_departamento = NEW.codigo_departamento 
        AND dni_gerente = NEW.dni_empleado
    )
    THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'El empleado % no tiene ningún curso asociado al departamento %, no puede trabajar en ese departamento.', NEW.dni_empleado, NEW.codigo_departamento;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_verificar_empleado_curso
BEFORE INSERT OR UPDATE ON EMPLEADO_DEPARTAMENTO
FOR EACH ROW EXECUTE FUNCTION verificar_empleado_curso();


-- Trigger para obligar que un empleado si es gerente debe trabajar en el departamento que gestiona
CREATE OR REPLACE FUNCTION obligar_gerente_departamento()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO EMPLEADO_DEPARTAMENTO 
	VALUES
	(NEW.dni_gerente, NEW.codigo_departamento);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_obligar_gerente_departamento
AFTER INSERT OR UPDATE ON DEPARTAMENTO
FOR EACH ROW EXECUTE FUNCTION obligar_gerente_departamento();


-- Trigger para comprobar que un proveedor no puede tener dos contratos activos para un mismo servicio
CREATE OR REPLACE FUNCTION verificar_proveedor_contrato()
RETURNS TRIGGER AS $$
DECLARE
    contador INT;
BEGIN
    -- Comprobar si el proveedor tiene algún contrato activo para el servicio
    SELECT COUNT(*) INTO contador
    FROM CONTRATO
    WHERE codigo_proveedor = NEW.codigo_proveedor
    AND codigo_servicio = NEW.codigo_servicio
    AND activo = true;

    IF contador > 0 THEN -- Si es mayor que 0 significa que ya tiene 1
        RAISE EXCEPTION 'El proveedor % ya tiene un contrato activo para el servicio %', NEW.codigo_proveedor, NEW.codigo_servicio;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_verificar_proveedor_contrato
BEFORE INSERT OR UPDATE ON CONTRATO
FOR EACH ROW EXECUTE FUNCTION verificar_proveedor_contrato();

INSERT INTO
  PROVEEDOR (nombre_proveedor, telefono)
VALUES
	('Proveedor A', '123456789'),--1
	('Proveedor B', '987654321'),--2
	('Proveedor C', '456789123'),--3
	('Proveedor D', '321654987'),--4
	('Proveedor E', '258963147'),--5
	('Proveedor F', '741852963'),--6
	('Proveedor G', '159357486'),--7
	('Proveedor H', '369258147'),--8
	('Proveedor I', '123987456'),--9
	('Proveedor J', '987123654'),--10
	('Proveedor K', '654789321'),--11
	('Proveedor L', '789456123');--12


INSERT INTO
  SERVICIO (nombre_servicio, tarifa)
VALUES
	('Restaurante', 130.0),--1
	('SPA', 140.0),--2
	('Piscina', 16.0),--3
	('Gimnasio', 15.0),--4
	('Bar', 120.0),--5
	('Salón de Eventos', 2000.0),--6
	( 'Servicio de Habitación', 1000.0),--7
	('Lavandería', 150.0),--8
	( 'Guía Turístico', 250.0),--9
	( 'Masajes', 90.0);--10

INSERT INTO --Servicios premium
  SERVICIO (nombre_servicio, tarifa, premium)
VALUES
	('Cine', 11000.0, true),--11
  ('Servicio de Niñera', 13000.0, true),--12
	('Transporte al Aeropuerto', 18000.0, true),--13
  ('Servicio de Taxi', 15000.0,true);--14

INSERT INTO
  CONTRATO (codigo_proveedor, codigo_servicio, fin_vigencia, activo)
VALUES
  (3, 1, '2024-05-30', true),--1
  (8, 2, '2024-06-15', true),--2
  (9, 3, '2024-07-20', true),--3
  (1, 4, '2024-08-10', true),--4
  (2, 5, '2024-09-05', true),--5
  (7, 6, '2024-10-25', true),--6
  (11, 7, '2024-11-15', true),--7
  (6, 8, '2024-12-30', true),--8
  (5, 9, '2025-01-20', true),--9
  (10, 10, '2025-02-10', true),--10
  (12, 11, '2025-03-30', true),--11
  (4, 12, '2025-04-15', true);--12


INSERT INTO
  CLIENTE (dni_cliente, nombre_cliente, correo_electronico, premium)
VALUES
('12345678Z', ROW('Juan', 'Pérez', 'García'), ARRAY['juanperez@example.com', 'juanperez1@example.com'], TRUE),
('23456789X', ROW('Ana', 'López', 'Martín'), ARRAY['analopez@example.com','analopez1@example.com'], FALSE),
('34567891Z', ROW('Pedro', 'Pérez', 'Rodríguez'), ARRAY['pedroperez@example.com','pedroperez1@example.com'], TRUE),
('45678912X', ROW('Maria', 'Martín', 'Martín'), ARRAY['mariamartin@example.com','mariamartin1@example.com'], FALSE),
('56789123Z', ROW('Cristobal', 'Hernández', 'Vega'), ARRAY['cristobalhernandez@example.com', 'cristobalhernandez1@example.com'], TRUE),
('67891234X', ROW('Daniel', 'Zamora', 'Herrera'), ARRAY['danielzamora@example.com','danielzamora1@example.com'], TRUE),
('11234567Z', ROW('Raul', 'Pérez', 'Rodríguez'), ARRAY['raulperez@example.com','raulperez1@example.com'], TRUE),
('12234567X', ROW('Claudia', 'Martín', 'Martín'), ARRAY['claudiamartin@example.com','claudiamartin1@example.com'], FALSE),
('12334567Z', ROW('Paula', 'Hernández', 'Vega'), ARRAY['paulahernandez@example.com', 'paulahernandez1@example.com'], TRUE),
('12344567X', ROW('Miguel', 'Zamora', 'Herrera'), ARRAY['miguelzamora@example.com','miguelzamora1@example.com'], FALSE);


INSERT INTO
  HABITACION (tarifa, tipo)
VALUES
  (250.0, 'Familiar'),--1
  (140.0,  'Individual'),--2
  (475.0,  'Presidencial'),--3
  (615.0, 'Triple'),--4
  (310.0,  'Estudio'),--5
  (520.0,  'Suite'),--6
  (250.0, 'Familiar'),--7
  (140.0,  'Individual'),--8
  (475.0,  'Presidencial'),--9
  (615.0, 'Triple'),--10
  (310.0,  'Estudio'),--11
  (520.0,  'Suite');--12

INSERT INTO
  REGISTRO_MANTENIMIENTO(codigo_habitacion, fecha, descripcion)
VALUES
  (1, '2023-11-09', 'Limpieza de la habitación'),--1
  (2, '2023-09-22', 'Limpieza de la habitación'),--2
  (3, '2023-10-01', 'Limpieza de la habitación'),--3
  (4, '2023-05-29', 'Reponer toallas'),          --4
  (5, '2023-06-20', 'Limpieza de la habitación'),--5
  (6, '2023-07-01', 'Limpieza de la habitación'),--6
  (1, '2023-11-09', 'Reponer toallas'),          --7
  (2, '2023-09-22', 'Limpieza camas'),--8
  (3, '2023-10-01', 'Limpieza de la habitación'),--9
  (4, '2023-05-29', 'Reponer toallas'),--10
  (5, '2023-06-20', 'Limpieza de baños'),--11
  (6, '2023-07-01', 'Reponer toallas');--12



INSERT INTO
  EMPLEADO (dni_empleado, dni_supervisor, nombre_empleado, salario)
VALUES
  ('11111111X',NULL,('Kilian', 'Gonzalez', 'Rodriguez'),2200),
  ('31111113X',NULL,('Saul', 'Sosa', 'Diaz'),2200),
  ('51111115X',NULL,('Lucas', 'Perez', 'Rosario'),2200),
	('21111112X','11111111X',('Willy', 'Rex', 'Golem'),1500),
	('41111114X','31111113X',('Pedro', 'Pica', 'Piedra'),1500),
	('61111116X','51111115X',('Monkey', 'Di', 'Luffy'),1500),
  ('71111117X','11111111X',('Monica', 'Martinez', 'Alonso'),1500),
  ('81111118X','31111113X',('Mauricio', 'Torres', 'Afonso'),1500),
  ('91111119X','51111115X',('Sergio', 'García', 'Vázquez'),1500),
	('62111126X','51111115X',('Salomon', 'Ferxxo', 'Pérez'),1500),
  ('72111127X','11111111X',('Julio', 'Maldini', 'Maldonado'),1500),
  ('82111128X','31111113X',('Brahim', 'Diaz', 'Lopez'),1500),
  ('92111129X','51111115X',('Samuel', 'García', 'Vázquez'),1500);


INSERT INTO
  RESERVA (dni_cliente, fecha, numero_dias)
VALUES
  ('12345678Z','2025-01-09',4), --1
  ('23456789X','2025-02-22',3), --2
  ('34567891Z','2025-03-01',2), --3
  ('45678912X','2025-04-11',6), --4
  ('56789123Z','2025-05-02',4), --5
  ('67891234X','2025-09-22',3), --6
  ('11234567Z','2025-10-01',2), --7
  ('12234567X','2025-12-29',6), --8
  ('12334567Z','2025-07-01',2), --9
  ('12344567X','2025-06-20',6), --10
  ('12345678Z','2026-01-09',4); --11


INSERT INTO
  RESERVA_HABITACION (codigo_reserva, codigo_habitacion)
VALUES
  (1,1),
  (2,2),
  (3,3),
  (4,4),
  (5,5),
  (6,6),
  (7,1),
  (8,2),
  (9,3),
  (10,4),
  (11,3),
  (11,4),
  (11,1);

INSERT INTO
  DEPARTAMENTO(dni_gerente, nombre_departamento)
VALUES
  ('11111111X','Saneamiento'), --1
  ('31111113X','Recepción'), --2
  ('51111115X','Restauracion y hostelería'), --3
  ('21111112X','Contabilidad'), --4
  ('21111112X','Ventas y Reservas'), --5
  ('41111114X','Eventos'), --6
  ('51111115X','Tecnologías de información'), --7
  ('61111116X','Instalaciones'), --8
  ('71111117X','Seguridad'), --9
  ('61111116X','Alimentacion'); --10


INSERT INTO
  CURSO (codigo_departamento, nombre_curso, numero_horas, categoria)
VALUES
    (1,'La importancia de la limpieza',10,'Saneamiento'),--1
    (1,'Limpieza de instalaciones',7,'Saneamiento'),--2
    (1,'La pulcritud necesaria',8,'Saneamiento'),--3
    (2,'Recibimiento correcto',5,'Recepción'),--4
    (3,'Sirviendo con clase',8,'Hostelería'),--5
    (4,'Gestión de ingresos',12,'Contabilidad'),--6
    (5,'Comercio en el hotel',6,'Comercio'),--7
    (6,'Animando la estancia',6,'Eventos'),--8
    (7,'La informática en los hoteles',9,'Tecnologías'),--9
    (8,'Instalaciones de calidad', 10, 'Instalaciones'),--10
    (9,'Principios de seguridad',6,'Seguridad'),--11
    (9,'Seguridad de avanzada',10,'Seguridad'),--12
    (9,'Primeros auxilios',11,'Seguridad'),--13
    (9,'Evacuaciones',13,'Seguridad'),--14
    (10,'Cocinando como Carlos',7,'Cocina');--15

INSERT INTO
  EMPLEADO_REALIZA_CURSO (dni_empleado, codigo_curso, fecha)
VALUES
    ('81111118X',1, '2023-11-01'),
    ('81111118X',6, '2023-04-01'),
    ('81111118X',8, '2023-03-01'),
    ('91111119X',11, '2023-11-02'),
    ('91111119X',15, '2023-04-02'),
    ('91111119X',9, '2023-04-02'),
    ('62111126X',2, '2023-11-03'),
    ('62111126X',6, '2023-04-03'),
    ('72111127X',10, '2023-11-04'),
    ('72111127X',2, '2023-04-04'),
    ('82111128X',11, '2023-11-05'),
    ('82111128X',1, '2023-10-05'),
    ('82111128X',4, '2023-04-05'),
    ('92111129X',5, '2023-11-06'),
    ('92111129X',8, '2023-04-06');




INSERT INTO
  EMPLEADO_DEPARTAMENTO(dni_empleado, codigo_departamento)
VALUES 
  ('81111118X',6),
  ('81111118X',1),
  ('81111118X',4),
  ('91111119X',7),
  ('91111119X',9),
  ('91111119X',10),
  ('62111126X',1),
  ('62111126X',4),
  ('72111127X',1),
  ('72111127X',8),
  ('82111128X',1),
  ('82111128X',2),
  ('82111128X',9),
  ('92111129X',3),
  ('92111129X',6);

--Reserva_servicio

INSERT INTO
  RESERVA_SERVICIO (codigo_reserva, codigo_servicio)
VALUES
    (1, 11),
    (1, 13),
    (1, 4),
    (2, 2),
    (2, 4),
    (3, 10),
    (4, 5),
    (4, 8),
    (5, 7),
    (6, 11),
    (7, 6),
    (7, 8),
    (8, 3),
    (9, 8),
    (9, 14),
    (10, 9),
	(11,2),
	(11,6),
	(11,4);

--Departamento_servicio

INSERT INTO
  DEPARTAMENTO_SERVICIO (codigo_servicio, codigo_departamento)
VALUES
    (1, 3),
    (2, 8),
    (3, 8),
    (4, 8),
    (5, 3),
    (6, 3),
    (7, 1),
    (8, 1),
    (9, 5),
    (10, 5),
    (11, 8),
    (12, 5),
    (13, 5),
    (14, 5);

--Jornadas
INSERT INTO
  JORNADA (fecha_hora_entrada, fecha_hora_salida)
VALUES
  ('2023-01-01 04:05:06', '2023-01-01 12:05:06'),--1
  ('2023-02-04 15:05:06', '2023-02-04 23:05:06'),--2
  ('2023-03-07 19:05:06', '2023-03-08 05:05:06'),--3
  ('2023-04-10 10:05:06', '2023-04-10 18:05:06'),--4
  ('2023-05-13 11:05:06', '2023-05-13 19:05:06'),--5
  ('2023-06-16 00:05:06', '2023-06-16 08:05:06'),--6
  ('2023-07-19 20:05:06', '2023-07-20 04:05:06'),--7
  ('2023-08-22 08:05:06', '2023-08-22 16:05:06'),--8
  ('2023-09-25 09:05:06', '2023-09-25 17:05:06'),--9
  ('2023-10-28 22:05:06', '2023-10-29 07:05:06'),--10
  ('2023-11-01 13:00:06', '2023-11-01 13:45:06'),--11
  ('2023-12-04 15:00:06', '2023-12-04 15:45:06'),--12
  ('2023-01-13 19:00:06', '2023-01-13 19:45:06');--13

INSERT INTO
  EMPLEADO_JORNADA (dni_empleado, codigo_jornada)
VALUES
  ('21111112X', 1),
  ('41111114X', 2),
  ('61111116X', 3),
  ('71111117X', 4),
  ('81111118X', 5),
  ('91111119X', 6),
  ('62111126X', 7),
  ('72111127X', 8),
  ('82111128X', 9),
  ('92111129X', 10),
  ('11111111X', 11),
  ('31111113X', 12),
  ('51111115X', 13);

-- Estamos teniendo problemas con el almacenamiento de los datos de nuestra base de datos, queremos hacer un vaciado de las reservas,
--por contrato debemos matener la reservas hata 2 años previos a la fehca actual
DELETE FROM RESERVA WHERE fecha <  current_date - interval '2 YEAR';

-- El cliente con dni '11234567Z' quiere cancelar su reserva en la fecha 2025-10-01
DELETE FROM RESERVA WHERE dni_cliente = '11234567Z' AND fecha ='2025-10-01';

-- Eliminar jornadas mas antiguas que febrero
DELETE FROM JORNADA WHERE fecha_hora_entrada < '2023-02-01 00:00:01';

-- Eliminar Servicio
DELETE FROM SERVICIO where codigo_servicio = 10;

-- Eliminar Empleados 
DELETE FROM EMPLEADO_DEPARTAMENTO WHERE dni_empleado IN (SELECT dni_empleado FROM EMPLEADO WHERE horas_totales >8);

-- Operaciones de Actualización

--Actualizar servicios de una reserva
UPDATE RESERVA_SERVICIO SET codigo_servicio = 2 WHERE codigo_reserva = 1 AND codigo_servicio = 13;


--Actualizar  los nombres de los empleados que tengan el dni 11111111X de supervisor
UPDATE EMPLEADO SET nombre_empleado = ('Knekro', 'Numero', '1') where dni_supervisor = '11111111X';

-- Aumentar el sueldo del empleado con más horas
UPDATE EMPLEADO SET salario = salario * 1.1 WHERE dni_empleado = (SELECT dni_empleado from EMPLEADO 
    ORDER BY horas_totales DESC LIMIT 1);

-- Cambiar a cliente premium un cliente no premium
UPDATE CLIENTE SET premium = TRUE WHERE dni_cliente = (SELECT dni_cliente FROM CLIENTE
    WHERE premium = FALSE
    ORDER BY dni_cliente  ASC LIMIT 1);

-- Cambiar el nombre de algun curso y aumentar el numero de horas del curso
UPDATE CURSO SET nombre_curso = 'Aprender a ahorrar', numero_horas = numero_horas + 5 WHERE codigo_curso = 6;


-- Cambiar el nombre de un servicio
UPDATE SERVICIO SET nombre_servicio = 'Servicio de lavandería' WHERE nombre_servicio = 'Lavandería';

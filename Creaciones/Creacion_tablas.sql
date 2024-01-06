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

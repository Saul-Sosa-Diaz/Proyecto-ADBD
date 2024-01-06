
-- Validación de emails correctos

INSERT INTO
  CLIENTE (dni_cliente, nombre_cliente, correo_electronico, premium)
VALUES
('12378978Z', ROW('Juan', 'Perez', 'Garcia'), ARRAY['juanperezexample.com', 'juanperez1@example'], TRUE);

-- Validación de DNI correcto

INSERT INTO
  CLIENTE (dni_cliente, nombre_cliente, correo_electronico, premium)
VALUES
('a', ROW('Juan', 'Perez', 'Garcia'), ARRAY['juanperez@example.com', 'juanperez1@example.com'], TRUE);


-- Comprobar reservas con número de días mayor a 0

INSERT INTO
  RESERVA (dni_cliente, fecha, numero_dias)
VALUES
  ('23456789X','2025-01-11',-1);

-- Comprobar cursos con número de horas mayor a 0

INSERT INTO
  EMPLEADO (dni_empleado, dni_supervisor, nombre_empleado, salario)
VALUES
    ('11111111X',NULL,('Kilian', 'Gonzalez', 'Rodriguez'),2200);

INSERT INTO
  DEPARTAMENTO(dni_gerente, nombre_departamento)
VALUES
  ('11111111X','Saneamiento'),
  ('11111111X','Recepción');

INSERT INTO
  CURSO (codigo_departamento, nombre_curso, numero_horas, categoria)
VALUES
    (1,'La importancia de la limpieza',0,'Saneamiento');

-- Comprobar que la hora de salida de una jornada es mayor que la de entrada

INSERT INTO
  JORNADA (fecha_hora_entrada, fecha_hora_salida)
VALUES
  ('2023-01-01 07:05:06', '2023-01-01 04:05:06');


-- Comprobar que el sueldo de un empleado es correcto

INSERT INTO
  EMPLEADO (dni_empleado, dni_supervisor, nombre_empleado, salario)
VALUES
    ('11111111X',NULL,('Kilian', 'Gonzalez', 'Rodriguez'),3000000);

-- Comprobar que la tarifa de una habitación es mayor a 0

INSERT INTO
  HABITACION (tarifa, tipo)
VALUES
  (-1, 'Familiar');

-- Un usuario no puede hacer una reserva de una habitación que ya está reservada

INSERT INTO
  CLIENTE (dni_cliente, nombre_cliente, correo_electronico, premium)
VALUES
('12345678Z', ROW('Juan', 'Perez', 'Garcia'), ARRAY['juanperez@example.com', 'juanperez1@example.com'], TRUE),
('23456789X', ROW('Ana', 'Lopez', 'Martin'), ARRAY['analopez@example.com','analopez1@example.com'], FALSE);

INSERT INTO
  HABITACION (tarifa, tipo)
VALUES
  (250.0, 'Familiar');

INSERT INTO
  RESERVA (dni_cliente, fecha, numero_dias)
VALUES
  ('12345678Z','2025-01-09',4), --1
  ('23456789X','2025-01-11',3); --4

INSERT INTO
  RESERVA_HABITACION (codigo_reserva, codigo_habitacion)
VALUES
  (1,1),
  (2,1);


-- Un empleado no puede tener dos jornadas que se solapen

INSERT INTO
  EMPLEADO (dni_empleado, dni_supervisor, nombre_empleado, salario)
VALUES
  ('11111111X',NULL,('Kilian', 'Gonzalez', 'Rodriguez'),2200);

INSERT INTO
  JORNADA (fecha_hora_entrada, fecha_hora_salida)
VALUES
  ('2023-01-01 04:05:06', '2023-01-01 12:05:06'),--1
  ('2023-01-01 06:05:06', '2023-01-01 07:05:06');--2

INSERT INTO
  EMPLEADO_JORNADA (dni_empleado, codigo_jornada)
VALUES
  ('11111111X', 1),
  ('11111111X', 2);

-- Comprobar que los clientes standar no pueden reservar servicios premium
INSERT INTO
  CLIENTE (dni_cliente, nombre_cliente, correo_electronico, premium)
VALUES
('23456789X', ROW('Ana', 'Lopez', 'Martin'), ARRAY['analopez@example.com','analopez1@example.com'], FALSE);

INSERT INTO --Servicios premium
  SERVICIO (nombre_servicio, tarifa, premium)
VALUES
	('Cine', 11000.0, true);

INSERT INTO
  RESERVA (dni_cliente, fecha, numero_dias)
VALUES
  ('23456789X','2025-01-09',4);

INSERT INTO
  RESERVA_SERVICIO (codigo_reserva, codigo_servicio)
VALUES
    (1, 1);

-- Comprobar salario negativo
INSERT INTO
  EMPLEADO (dni_empleado, dni_supervisor, nombre_empleado, salario)
VALUES
  ('11111111X',NULL,('Kilian', 'Gonzalez', 'Rodriguez'),-2200);



-- Comprobar que un empleado solo puede trabajar en un departamento si tiene al menos un curso asociado a ese departamento

INSERT INTO
  EMPLEADO (dni_empleado, dni_supervisor, nombre_empleado, salario)
VALUES
    ('11111111X',NULL,('Kilian', 'Gonzalez', 'Rodriguez'),2200),
    ('31111113X',NULL,('Saul', 'Sosa', 'Diaz'),2200);

INSERT INTO
  DEPARTAMENTO(dni_gerente, nombre_departamento)
VALUES
  ('11111111X','Saneamiento'),
  ('11111111X','Recepción');

INSERT INTO
  CURSO (codigo_departamento, nombre_curso, numero_horas, categoria)
VALUES
    (1,'La importancia de la limpieza',10,'Saneamiento');

INSERT INTO
  EMPLEADO_REALIZA_CURSO (dni_empleado, codigo_curso, fecha)
VALUES
    ('31111113X',1, '2023-11-01');

INSERT INTO
  EMPLEADO_DEPARTAMENTO(dni_empleado, codigo_departamento)
VALUES 
  ('31111113X',2);

-- Comprobar que un proveedor no puede tener dos contratos activos para un mismo servicio

INSERT INTO
  PROVEEDOR (nombre_proveedor, telefono)
VALUES
	('Proveedor A', '123456789');

INSERT INTO
  SERVICIO (nombre_servicio, tarifa)
VALUES
	('Restaurante', 13000.0);

INSERT INTO
  CONTRATO (codigo_proveedor, codigo_servicio, fin_vigencia, activo)
VALUES
  (1, 1, '2024-05-30', true),
  (1, 1, '2024-06-10', true);
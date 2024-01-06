--Trigger para obtener el importe de la reserva
INSERT INTO
  CLIENTE (dni_cliente, nombre_cliente, correo_electronico, premium)
VALUES
('12345678Z', ROW('Juan', 'Pérez', 'García'), ARRAY['juanperez@example.com', 'juanperez1@example.com'], TRUE);
INSERT INTO
  SERVICIO (nombre_servicio, tarifa)
VALUES
	('Restaurante', 130.0),--1
	('SPA', 140.0);
INSERT INTO
  HABITACION (tarifa, tipo)
VALUES
  (250.0, 'Familiar');

INSERT INTO
  RESERVA (dni_cliente, fecha, numero_dias)
VALUES
  ('12345678Z','2025-01-09',4); --1
--Importe por defecto 0

SELECT * FROM RESERVA;

INSERT INTO
  RESERVA_HABITACION (codigo_reserva, codigo_habitacion)
VALUES
  (1, 1);

SELECT * FROM RESERVA;

INSERT INTO
  RESERVA_SERVICIO (codigo_reserva, codigo_servicio)
VALUES
  (1, 1),
  (1, 2);

SELECT * FROM RESERVA;


-- Trigger para calcular las horas truncadas trabajadas de un empleado
INSERT INTO
  EMPLEADO (dni_empleado, dni_supervisor, nombre_empleado, salario)
VALUES
  ('11111111X',NULL,('Kilian', 'Gonzalez', 'Rodriguez'),2200);

SELECT * FROM EMPLEADO;

INSERT INTO
    JORNADA (fecha_hora_entrada, fecha_hora_salida)
VALUES
    ('2023-01-01 04:05:06', '2023-01-01 12:05:06');

INSERT INTO
  EMPLEADO_JORNADA (dni_empleado, codigo_jornada)
VALUES
    ('11111111X', 1);--1

SELECT * FROM EMPLEADO;

-- Trigger para obligar que un gerente tenga que trabajar en ese departamento.

INSERT INTO
  EMPLEADO (dni_empleado, dni_supervisor, nombre_empleado, salario)
VALUES
  ('11111111X',NULL,('Kilian', 'Gonzalez', 'Rodriguez'),2200);

SELECT * FROM EMPLEADO_DEPARTAMENTO;

INSERT INTO
  DEPARTAMENTO (dni_gerente, nombre_departamento)
VALUES
  ('11111111X', 'Recepción');

SELECT * FROM EMPLEADO_DEPARTAMENTO;
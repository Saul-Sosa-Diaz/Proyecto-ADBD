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
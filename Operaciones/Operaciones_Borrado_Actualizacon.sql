-- Operaciones de Borrado
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

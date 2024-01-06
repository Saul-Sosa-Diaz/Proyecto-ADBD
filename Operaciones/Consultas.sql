-- Consultas

--Queremos crear un nuevo departamento y para ello queremos otorgarle el puesto de gerente a nuestro
-- empleado con más horas trabajadas

select nombre_empleado as "Empleado", dni_empleado as "Documento de identidad" from empleado
    ORDER BY horas_totales DESC LIMIT 1;

--Se nos han ofertado a la compañia una serie de cursos gratis para 3 empleados, queremos reforzar
-- los conocimientos de los empleados con menos cursos

SELECT e.nombre_empleado AS "Empleado", count(erc) AS "Numero de cursos"
    FROM EMPLEADO AS e
    JOIN EMPLEADO_REALIZA_CURSO AS erc ON  erc.dni_empleado = e.dni_empleado
    GROUP BY e.nombre_empleado
    ORDER BY "Numero de cursos"
    ASC  LIMIT 3;

--Queremos saber cual es el cliente que más a invertido en nuestro hotel para ofrecerle una tarjeta 
-- de descuento a modo de agradecimiento
SELECT c.nombre_cliente, c.dni_cliente, SUM(r.importe) AS "Cantidad Gastada" FROM CLIENTE AS c
    JOIN RESERVA as r on r.dni_cliente = c.dni_cliente
    GROUP BY c.nombre_cliente, c.dni_cliente
    ORDER BY SUM(r.importe)
    desc LIMIT 1;

-- Queremos saber los cursos que han realizado cada uno de nuestros empleados 
--así como el numero total de horas dedicadas
    
SELECT e.nombre_empleado AS "Empleado", e.dni_empleado as "Documento de identidad", string_agg(c.nombre_curso, ': ') AS "Cursos", SUM(c.numero_horas)  AS "Horas Totales"
    FROM EMPLEADO AS e
    JOIN EMPLEADO_REALIZA_CURSO AS erc ON  erc.dni_empleado = e.dni_empleado
    JOIN CURSO AS c ON c.codigo_curso = erc.codigo_curso
    GROUP BY e.nombre_empleado,  e.dni_empleado;

-- Queremos el nombre de los clientes premium así como el listado de reservas
SELECT c.nombre_cliente, c.dni_cliente, count(r.codigo_reserva) as "Total de reservas",
    string_agg('{' || r.fecha || ' (' || r.importe || ')}', ' : ') as "Fechas(Importe)"
    FROM CLIENTE as c
    JOIN RESERVA as r on r.dni_cliente = c.dni_cliente
    WHERE c.premium =true
    GROUP BY c.nombre_cliente, c.dni_cliente;

-- Queremos saber cuales son los servicios que más veces ha sido solicitado,
-- para replantearnos la distribución de responsabilidades de los empleados
SELECT s.codigo_servicio, s.nombre_servicio as "Servicio", count(r.codigo_servicio) as "Solicitudes Totales del Servicio"
	FROM SERVICIO AS s 
	JOIN RESERVA_SERVICIO AS r ON r.codigo_servicio = s.codigo_servicio
	GROUP BY s.codigo_servicio, s.nombre_servicio
	ORDER BY "Solicitudes Totales del Servicio"
	desc;


-- Estamos planeando reducir el numero de servicios no premium, para ello 
-- queremos saber cuales son los 5 servicios que menos dinero generarán en las reservas planificadas
SELECT s.codigo_servicio, s.nombre_servicio as "Servicio", SUM(r.importe) as "Dinero generado"
	FROM SERVICIO AS s 
	JOIN RESERVA_SERVICIO AS rs ON rs.codigo_servicio = s.codigo_servicio
	JOIN RESERVA AS r ON r.codigo_reserva = rs.codigo_reserva
	WHERE r.fecha >= current_date AND s.premium = FALSE
	GROUP BY s.codigo_servicio, s.nombre_servicio
	ORDER BY "Dinero generado"
	asc LIMIT 5;

--Ha venido un grupo de personas que necesitan alquilar una habitación ahora,
-- para ello necesitamos la lista de habitaciones sin ocupar actualemente

SELECT * FROM HABITACION h WHERE h.codigo_habitacion NOT IN 
	(SELECT codigo_habitacion FROM RESERVA_HABITACION JOIN RESERVA ON RESERVA_HABITACION.codigo_reserva = RESERVA.codigo_reserva WHERE RESERVA.fecha + RESERVA.numero_dias > current_date);


--Estamos pensando en reorganizar nuestra estructura de departamentos y reasignar a los empleados, para ello queremos saber los empleados que trabajan en cada departamento	
-- el número de horas que han trabajado para la empresa, así como el numero de trabajadores de cada departamento
select d.codigo_departamento as "Codigo Departamento", d.nombre_departamento, string_agg('{' ||e.nombre_empleado ||',' || e.horas_totales || 'h}', ' : ') as "Empleados y horas",
	COUNT(e.dni_empleado) as "Cantidad de Trabajadores"
	FROM DEPARTAMENTO as d
	JOIN EMPLEADO_DEPARTAMENTO as ed on ed.codigo_departamento = d.codigo_departamento
	JOIN EMPLEADO as e on e.dni_empleado = ed.dni_empleado
	GROUP BY d.codigo_departamento,d.nombre_departamento;


-- Dado un DNI de un cliente, en concreto 12345678Z, dar las reservas que tiene a su nombre
SELECT R.codigo_reserva,R.fecha, R.numero_dias, STRING_AGG(S.nombre_servicio, ', ') AS servicios_agregados,
                (
                    SELECT STRING_AGG(CAST(codigo_habitacion AS VARCHAR), ', ')
                    FROM (
                        SELECT DISTINCT RH.codigo_habitacion as codigo_habitacion
                        FROM RESERVA_HABITACION RH
                        WHERE RH.codigo_reserva = R.codigo_reserva
                    ) AS habitaciones_unicas
                ) AS habitaciones_agregadas
                FROM RESERVA R
                JOIN RESERVA_SERVICIO RS ON R.codigo_reserva = RS.codigo_reserva
                JOIN SERVICIO S ON RS.codigo_servicio = S.codigo_servicio
                WHERE R.dni_cliente = '12345678Z'
                GROUP BY R.fecha, R.numero_dias, R.codigo_reserva;
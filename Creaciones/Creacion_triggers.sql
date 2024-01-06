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

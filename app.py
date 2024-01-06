import os
import psycopg2
from flask import Flask, request
from flask import jsonify

app = Flask(__name__)



def get_db_connection():
    try:
        conn = psycopg2.connect(host='localhost',
                                database="hotel",
                                user="postgres",
                                password="postgres")
        return conn
    except psycopg2.DatabaseError as e:
        # Manejar errores de la base de datos
        print(f'\033[91mError en la base de datos:\033[0m {e}')
        return None



# Obtener los servicios disponibles
@app.route('/api/servicios', methods=['GET'])
def servicios():
    try:
        # Establecer conexión con la base de datos
        conn = get_db_connection()
        cur = conn.cursor()
        # Ejecutar la consulta
        cur.execute('SELECT nombre_servicio,tarifa,premium FROM SERVICIO order by codigo_servicio;')
        # obtener todos los registros
        servicios = cur.fetchall()
    except psycopg2.DatabaseError as e:
        # Manejar errores de la base de datos
        print(f'\033[91mError in database:\033[0m {e}')
        servicios = []
        return jsonify({'servicios': servicios}), 500
    except servicios == []:
        return jsonify('No se encontraron servicios'), 404
    finally:
        # Asegurar que las conexiones se cierran
        if cur is not None:
            cur.close()
        if conn is not None:
            conn.close()
    return jsonify({'servicios': servicios}), 200



# Obtener las habitaciones dispoinibles
@app.route('/api/habitaciones', methods=['GET'])
def habitaciones():
    habitaciones = []
    try:
        # Establecer conexión con la base de datos
        conn = get_db_connection()
        cur = conn.cursor()
        # Conseguir las habitaciones que están disponibles ahora mismo
        consulta = """
            SELECT codigo_habitacion, tipo, tarifa
            FROM HABITACION
            WHERE codigo_habitacion NOT IN (
                SELECT codigo_habitacion
                FROM RESERVA_HABITACION
                JOIN RESERVA ON RESERVA_HABITACION.codigo_reserva = RESERVA.codigo_reserva
                WHERE RESERVA.fecha + RESERVA.numero_dias > current_date
            )
        """
        cur.execute(consulta)
        # obtener todos los registros
        habitaciones = cur.fetchall()
    except psycopg2.DatabaseError as e:
        # Manejar errores de la base de datos
        print(f'\033[91mError in database:\033[0m {e}')
        habitaciones = []
        return jsonify({'habitaciones': habitaciones}), 500
    except habitaciones == []:
        return jsonify('No se encontraron habitaciones'), 404
    finally:
        # Asegurar que las conexiones se cierran
        if cur is not None:
            cur.close()
        if conn is not None:
            conn.close()
    return jsonify({'habitaciones': habitaciones}), 200


@app.route('/api/reservas/', methods=['POST', 'PUT', 'DELETE', 'GET'])
def reservas():
    try:
        # Crear una reserva
        if request.method == 'POST': 
            json = request.get_json() 
            if json:
                # Obtener los datos del JSON
                codigos_habitaciones = json.get('codigos_habitaciones')
                codigos_servicios = json.get('codigos_servicios')
                fecha = json.get('fecha')
                numero_dias = json.get('numero_dias')
                if (not codigos_habitaciones or not codigos_servicios or not fecha or not numero_dias):
                    return jsonify('Error en los parametros, es necesario el codigo de la habitacion, el codigo del servicio, la fecha y el numero de dias'), 400

                # Comprobar que se pasa por argumento el dni del cliente
                if (not request.args.get('dni_cliente')):
                    return jsonify('Error en los parametros, es necesario el DNI'), 400
                dni_cliente = request.args.get('dni_cliente')
                # conectar con la base de datos
                conn = get_db_connection()
                cur = conn.cursor()

                # Hacer la reserva
                cur.execute('INSERT INTO RESERVA (dni_cliente, fecha, numero_dias)'
                            'VALUES (%s, %s, %s)',
                            (dni_cliente, fecha, numero_dias))
                
                # Obtener el código de esa reserva.
                cur.execute('SELECT codigo_reserva FROM RESERVA WHERE dni_cliente = %s AND fecha = %s AND numero_dias = %s', (dni_cliente, fecha, numero_dias)) 
                codigo_reserva = cur.fetchone()
                
                # Hacer la reserva de las habitaciones
                for codigo_habitacion in codigos_habitaciones:
                    cur.execute('INSERT INTO RESERVA_HABITACION (codigo_reserva, codigo_habitacion)'
                                'VALUES (%s, %s)',
                                (codigo_reserva, codigo_habitacion))
                
                # Hacer la reserva de los servicios
                for codigo_servicio in codigos_servicios:
                    cur.execute('INSERT INTO RESERVA_SERVICIO (codigo_reserva, codigo_servicio)'
                                'VALUES (%s, %s)',
                                (codigo_reserva, codigo_servicio))
                
                conn.commit()
                
                # Obtener el importe de la reserva
                cur.execute('SELECT importe FROM RESERVA WHERE codigo_reserva = %s', (codigo_reserva))
                importe = cur.fetchone()

                # Asegurar que se cierra la conexión correctamente
                if cur is not None:
                    cur.close()
                if conn is not None:
                    conn.close()
                
                return jsonify({'codigo_reserva':codigo_reserva, 
                                'codigos_habitaciones':codigos_habitaciones, 
                                'codigos_servicios':codigos_servicios,
                                'fecha': fecha, 
                                'numero_dias': numero_dias, 
                                'importe':importe }
                                ), 200
            else:
                return jsonify('Error en el body, es necesario pasar un JSON con el codigo de la habitacion, el codigo del servicio, la fecha y el numero de dias'), 400
        
        
        # Modificar una reserva para añadirle o quitarle servicios 
        if request.method == 'PUT': 
            json = request.get_json() 
            if json:
                # Obtener los datos del JSON
                codigos_servicios = json.get('codigos_servicios')
                anadir = json.get('anadir')
                if (not codigos_servicios or anadir == None):
                    return jsonify('Error en los parametros, es necesario el codigo de los servicios, y la operacion que se realizara indicada mediante un booleano.'), 400
                # Comprobar que se pasa por argumento el dni del cliente y el codigo de la reserva
                if (not request.args.get('dni_cliente') and not request.args.get('codigo_reserva')):
                    return jsonify('Error en los parametros, es necesario el DNI y el codigo de la reserva'), 400
                dni_cliente = request.args.get('dni_cliente')
                codigo_reserva = request.args.get('codigo_reserva')
                # conectar con la base de datos
                conn = get_db_connection()
                cur = conn.cursor()
                # Comprobar que el DNI coincide con el de la reserva de id ${codigo_reserva}, tambien comprobar que la reserva no ha empezado
                cur.execute('SELECT codigo_reserva FROM RESERVA WHERE codigo_reserva = %s AND dni_cliente = %s AND fecha > CURRENT_DATE', (codigo_reserva, dni_cliente)) 
                codigo_reserva = cur.fetchone()
                # Si no coincide el DNI o la reserva ya ha empezado, devolver error
                if codigo_reserva == None:
                    return jsonify('La reserva no existe o ya ha empezado'), 304
                servicios_rechazados = []
                # Añadir o quitar los servicios que indica el cliente
                for codigo_servicio in codigos_servicios:
                    if anadir == True: # Añadir los servicios que indica el cliente
                        #Comprobar si ya está añadido el servicio
                        cur.execute('SELECT codigo_servicio FROM RESERVA_SERVICIO WHERE codigo_reserva = %s AND codigo_servicio = %s', (codigo_reserva, codigo_servicio))
                        nuevo_codigo_servicio = cur.fetchone()
                        if nuevo_codigo_servicio == None: # Si no está añadido, añadirlo
                            cur.execute('INSERT INTO RESERVA_SERVICIO (codigo_reserva, codigo_servicio)'
                                    'VALUES (%s, %s)',
                                    (codigo_reserva, codigo_servicio))
                        else: # El servicio ya está añadido
                            servicios_rechazados.append(codigo_servicio)
                    else: # Eliminar los servicios que indica el cliente
                        #Comprobar si no está añadido el servicio
                        cur.execute('SELECT codigo_servicio FROM RESERVA_SERVICIO WHERE codigo_reserva = %s AND codigo_servicio = %s', (codigo_reserva, codigo_servicio))
                        nuevo_codigo_servicio = cur.fetchone()
                        if nuevo_codigo_servicio == None: # Si no está añadido
                            servicios_rechazados.append(codigo_servicio)
                        else: 
                            cur.execute('DELETE FROM RESERVA_SERVICIO WHERE codigo_reserva = %s AND codigo_servicio = %s', (codigo_reserva, codigo_servicio))
                            
                conn.commit()
                # Obtener el nuevo importe completo de la reserva
                cur.execute('SELECT importe FROM RESERVA WHERE codigo_reserva = %s', (codigo_reserva))
                importe = cur.fetchone()
                
                # Asegurar que se cierra la conexión correctamente
                if cur is not None:
                    cur.close()
                if conn is not None:
                    conn.close()
                
                return jsonify({'codigo_reserva':codigo_reserva,
                                'propuesta_codigos_servicios':codigos_servicios,
                                'servicios_rechazados':servicios_rechazados,
                                'importe':importe }
                                ), 200
                    
            else:
                return jsonify('Error en el body, es necesario pasar un JSON con el codigos de servicios y la accióna realizar, añadir o quitar servicios'), 400

        # Eliminar una reserva específica
        if request.method == 'DELETE':

            # Comprobar que se pasa por argumento el dni del cliente y el codigo de la reserva
            if (not request.args.get('dni_cliente') and not request.args.get('codigo_reserva')):
                return jsonify('Error en los parametros, es necesario el DNI asociado a la reserva con id ${codigo_reserva}'), 400
            dni_cliente = request.args.get('dni_cliente')
            codigo_reserva = request.args.get('codigo_reserva')
            # conectar con la base de datos
            conn = get_db_connection()
            cur = conn.cursor()
            # Comprobar que la reserva corresponde al cliente y que no ha comenzado
            cur.execute('SELECT codigo_reserva FROM RESERVA WHERE codigo_reserva = %s AND dni_cliente = %s AND fecha > CURRENT_DATE', (codigo_reserva, dni_cliente))
            codigo_reserva = cur.fetchone()
            # Si no coincide el DNI o la reserva ya ha empezado, devolver error
            if codigo_reserva == None:
                return jsonify('La reserva no existe, no corresponde al dni o ya está en curso'), 400

            # Eliminar la reserva correspondiente
            cur.execute('DELETE FROM RESERVA WHERE codigo_reserva = %s AND dni_cliente = %s', (codigo_reserva, dni_cliente))
            conn.commit()

            if cur is not None:
                cur.close()
            if conn is not None:
                conn.close()
            return jsonify('La reserva se ha borrado correctamente'), 200

        #Obtener las reservas del cliente
        if request.method == 'GET':
            # Comprobar que se pasa por argumento el dni del cliente
            if (not request.args.get('dni_cliente')):
                return jsonify('Error en los parametros, es necesario el DNI'), 400
            dni_cliente = request.args.get('dni_cliente')
            # conectar con la base de datos
            conn = get_db_connection()
            cur = conn.cursor()
            #Consulta para obtener las reservas del cliente con DNI especificado
            consulta_sql = """
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
                WHERE R.dni_cliente = %s
                GROUP BY R.fecha, R.numero_dias, R.codigo_reserva
            """
            cur.execute(consulta_sql, (dni_cliente,))
            reservas = cur.fetchall()
            if reservas == None:
                return jsonify('No hay reservas asociadas al dni'), 400

            if cur is not None:
                cur.close()
            if conn is not None:
                conn.close()
            return jsonify({'reservas': reservas}), 200

    except psycopg2.DatabaseError as e:
        # Manejar errores de la base de datos
        print(f'\033[91mError en la base de datos:\033[0m {e}')
        return jsonify('Error en la base de datos ' + str(e)), 400
    
# Ruta para manejar cualquier otra ruta no especificada
@app.route('/<path:invalid_path>')
def invalid_route(invalid_path):
    return jsonify({'error': f'Ruta no válida: /{invalid_path}'}), 404

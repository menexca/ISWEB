/// Importaciones de paquetes
import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqlite_api.dart' as sqlite; // Cambio para soportar sqflite_common
//import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importa sqflite_common_ffi
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Importaciones locales
import 'class/vendedor.dart';
import 'class/cliente.dart';
import 'class/producto.dart';
import 'class/pedido.dart';
import 'class/pedidorenglon.dart';
import 'class/usuario.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  //sqfliteFfiWebInit();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<bool> tableExists(String tableName, sqlite.Database database) async {
    final result = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return result.isNotEmpty;
  }

  Future<sqlite.Database> openDatabase() async {
    final dbPath = 'blanking.db'; // El path puede ser más simple en web

    // Verifica si la base de datos ya existe antes de intentar abrirla
    final databaseExists = await databaseFactoryFfiWeb.databaseExists(dbPath);
    
    if (!databaseExists) {
      // Crear una nueva base de datos con las tablas si no existe
      var db = await databaseFactoryFfiWeb.openDatabase(dbPath,
          options: sqlite.OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              // Aquí se ejecutan las sentencias SQL para crear las tablas
              print('Creating database...');
              await db.execute(
                "CREATE TABLE vendedores(codigoVendedor TEXT PRIMARY KEY, nombre TEXT, zona TEXT, almacen TEXT, rif TEXT, nit TEXT, cantidadClientes INTEGER, cantidadClientesNuevosMes INTEGER, cantidadPedidosHoy INTEGER, cantidadPedidosMes INTEGER, cantidadClientesAtendidosHoy INTEGER, cantidadClientesAtendidosMes INTEGER, meta REAL, porcentajeEfectividad REAL, totalVentaBruta2 REAL, totalDevolucionBruta2 REAL, totalFacturacionBruta2 REAL, porcentajeAlcanzadoMeta REAL, diasHabilesMes INTEGER, diasHabilesTranscurridos INTEGER, diasHabilesRestantes INTEGER, promedioVentaDiaria REAL, diferenciaMeta REAL, objetivoDiario REAL, saldo REAL, vencido REAL, porcentajeSaldoVencido REAL, porcentajeVentaVencido REAL, supervisadoPor TEXT, cajasVendidas REAL, activo INTEGER)",
              );
              await db.execute(
                "CREATE TABLE clientes(codigoCliente TEXT PRIMARY KEY, nombre TEXT, nombreBusqueda TEXT, razonSocial TEXT, direccion TEXT, diasVisita INTEGER, telefonos TEXT, limiteCredito REAL, saldoMonedaTotal REAL, saldoMonedaVencido REAL, ultimoPago TEXT, proximoVencer INTEGER, estatus TEXT)",
              );
              await db.execute(
                "CREATE TABLE productos(codigoProducto TEXT PRIMARY KEY, nombre TEXT, nombreBusqueda TEXT, iva TEXT, cantidadxBulto REAL, existencia REAL, existencia02 REAL, existencia03 REAL, existenciaVenta REAL, pedidoVenta REAL, precioMoneda REAL, codigoGrupo TEXT, marca TEXT)",
              );
              await db.execute(
                "CREATE TABLE pedidosEspera(numero TEXT PRIMARY KEY, codigoCliente TEXT, totalNeto REAL, totalImpuesto REAL, totalPedido REAL, vendedor TEXT, comentario TEXT, nombreCliente TEXT, fecha TEXT, nombreVendedor TEXT, estatus TEXT, items INTEGER, bultos REAL, rif TEXT, descuentoGlobal REAL, diasCredito INTEGER)"
              );
              await db.execute(
                "CREATE TABLE pedidosRenglonesEspera(numeroCodigoProducto TEXT PRIMARY KEY, numero TEXT, almacen TEXT, cantidad REAL, precioMoneda REAL, totalRenglon REAL, indice INTEGER, tarifa TEXT, codigoProducto TEXT, nombreProducto TEXT, iva TEXT, cantidadxBulto REAL, descuento REAL, dsctoAdic REAL)"
              );
              await db.execute(
                "CREATE TABLE pedidosEsperaTemp(numero TEXT PRIMARY KEY, codigoCliente TEXT, totalNeto REAL, totalImpuesto REAL, totalPedido REAL, vendedor TEXT, comentario TEXT, nombreCliente TEXT, fecha TEXT, nombreVendedor TEXT, estatus TEXT, items INTEGER, bultos REAL, rif TEXT, descuentoGlobal REAL, diasCredito INTEGER)"
              );
              await db.execute(
                "CREATE TABLE pedidosRenglonesEsperaTemp(numeroCodigoProducto TEXT PRIMARY KEY, numero TEXT, almacen TEXT, cantidad REAL, precioMoneda REAL, totalRenglon REAL, indice INTEGER, tarifa TEXT, codigoProducto TEXT, nombreProducto TEXT, iva TEXT, cantidadxBulto REAL, descuento REAL, dsctoAdic REAL)"
              );
              await db.execute(
                "CREATE TABLE contadores(documento TEXT PRIMARY KEY, contador TEXT)",
              );
              await db.rawInsert(
                "INSERT INTO contadores (documento, contador) VALUES ('ESP', '00001')"
              );
              await db.execute(
                "CREATE TABLE informacion(info TEXT PRIMARY KEY, valorText TEXT, valorReal REAL)",
              );
              await db.rawInsert(
                "INSERT INTO informacion (info, valorText) VALUES ('fechaSincronizacion', '2000-01-01 00:00:00')"
              );
              await db.rawInsert(
                "INSERT INTO informacion (info, valorReal) VALUES ('tasaActual', 0.00)"
              );
              await db.rawInsert(
                "INSERT INTO informacion (info, valorText) VALUES ('vendedorActual', 'T')"
              );
              await db.rawInsert(
                "INSERT INTO informacion (info, valorText) VALUES ('logged', 'N')"
              );
              await db.rawInsert(
                "INSERT INTO informacion (info, valorText) VALUES ('usuarioActual', 'N')"
              );
              await db.rawInsert(
                "INSERT INTO informacion (info, valorText) VALUES ('busquedaActual', ' ')"
              );
              await db.execute(
                "CREATE TABLE usuarios(usuario TEXT PRIMARY KEY, contrasena TEXT, nombreCompleto TEXT, correoElectronico TEXT, fechaRegistro TEXT, ultimoInicioSesion TEXT, rol TEXT, estatus INTEGER, codigoVendedor TEXT, fechaNacimiento TEXT, direccion TEXT, numeroTelefono TEXT, cedula TEXT)"
              );
              print('Database created successfully');
            },
          ));
      return db;
    } else {
      // Si la base de datos ya existe, simplemente ábrela
      var db = await databaseFactoryFfiWeb.openDatabase(dbPath);

      //////////
      // Ejecuta la consulta PRAGMA table_info()
      List<Map<String, dynamic>> tablaVendedores2 = await db.rawQuery('PRAGMA table_info(vendedores)');

      // Busca el nombre del campo en los resultados de la consulta
      bool isExistv9 = false;
      for (var columnv9 in tablaVendedores2) {
        String namev9 = columnv9['name'];
        if (namev9 == 'cajasVendidas') {
          isExistv9 = true;
          break;
        }
      }

      if (!isExistv9) {
        await db.rawQuery(
          "drop table vendedores"
        );
      }


      //////////
      // Ejecuta la consulta PRAGMA table_info()
      List<Map<String, dynamic>> tablaVendedores3 = await db.rawQuery('PRAGMA table_info(vendedores)');

      // Busca el nombre del campo en los resultados de la consulta
      bool isExistv10 = false;
      for (var columnv10 in tablaVendedores3) {
        String namev10 = columnv10['name'];
        if (namev10 == 'activo') {
          isExistv10 = true;
          break;
        }
      }

      if (!isExistv10) {
        await db.rawQuery(
          "drop table vendedores"
        );
      }


      // Verificar si la tabla "vendedores" existe
      final existsVendedores = await tableExists('vendedores', db);

      if (!existsVendedores) {
        await db.execute(
          "CREATE TABLE vendedores(codigoVendedor TEXT PRIMARY KEY, nombre TEXT, zona TEXT, almacen TEXT, rif TEXT, nit TEXT, cantidadClientes INTEGER, cantidadClientesNuevosMes INTEGER, cantidadPedidosHoy INTEGER, cantidadPedidosMes INTEGER, cantidadClientesAtendidosHoy INTEGER, cantidadClientesAtendidosMes INTEGER, meta REAL, porcentajeEfectividad REAL, totalVentaBruta2 REAL, totalDevolucionBruta2 REAL, totalFacturacionBruta2 REAL, porcentajeAlcanzadoMeta REAL, diasHabilesMes INTEGER, diasHabilesTranscurridos INTEGER, diasHabilesRestantes INTEGER, promedioVentaDiaria REAL, diferenciaMeta REAL, objetivoDiario REAL, saldo REAL, vencido REAL, porcentajeSaldoVencido REAL, porcentajeVentaVencido REAL, supervisadoPor TEXT, cajasVendidas REAL, activo INTEGER)",
        );
      }

      //return await databaseFactoryFfiWeb.openDatabase(dbPath);
      return db;
    }
  }



 
  Future<void> insertVendedor(Vendedor vendedor) async {
    final db = await openDatabase();
    await db.insert(
      'vendedores',
      vendedor.toMap(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAllVendedores() async {
    final db = await openDatabase();
    await db.delete('vendedores');
    print("vendedores borrados");
  }

  Future<void> cargaVendedores(String fechaRefresh) async {
    //print('${codigoVendedor} ');
    //String? fechaSincronizacion = fechaRefresh;
    String? fechaSincronizacion = await getFechaSync();

    if (fechaRefresh!='carga'){
      if (fechaSincronizacion != null) {
      DateTime fecha1 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(fechaSincronizacion);
      DateTime fecha2 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(fechaRefresh);

      // Ahora puedes comparar las fechas
      int comparacion = fecha1.compareTo(fecha2);

      if (comparacion < 0) {
        print('fechaSincronizacion es más antigua que fechaRefresh: ${fechaSincronizacion}');
      } else if (comparacion > 0) {
        print('fechaRefresh es más antigua que fechaSincronizacion: ${fechaRefresh}');
        fechaSincronizacion = fechaRefresh;
      } else {
        print('Ambas fechas son iguales');
      }
      
      } else {
        print('Una o ambas fechas son nulas');
      }  
    }

    try {
      final response = await http.get(Uri.parse(
        'https://nodejs-mysql-railway-blanking-production.up.railway.app/Vendedores/$fechaSincronizacion',
      ));
      if (response.statusCode == 200) {
        print(' exito api Vendedoressssss');
        var data = json.decode(response.body);
        //print('${data} - data cargavendedor');
        for (var vendedorData in data) {
          //print(vendedorData);
          Vendedor vendedor = Vendedor(
            codigoVendedor: vendedorData['codigo'],
            nombre: vendedorData['nombre'],
            zona: vendedorData['Zona'],
            almacen: vendedorData['Almacen'],
            rif: vendedorData['rif'],
            nit: vendedorData['nit'],
            cantidadClientes: vendedorData['CantidadClientes'],
            cantidadClientesNuevosMes: vendedorData['CantidadClientesNuevosMes'],
            cantidadPedidosHoy: vendedorData['CantidadPedidosHoy'],
            cantidadPedidosMes: vendedorData['CantidadPedidosMes'],
            cantidadClientesAtendidosHoy: vendedorData['CantidadClientesAtendidosHoy'],
            cantidadClientesAtendidosMes: vendedorData['CantidadClientesAtendidosMes'],
            meta: double.parse(vendedorData['meta']),
            porcentajeEfectividad: double.parse(vendedorData['PorcentajeEfectividad']), 
            totalVentaBruta2: double.parse(vendedorData['TotalVentaBruta2']),
            totalDevolucionBruta2: double.parse(vendedorData['TotalDevolucionBruta2']),
            totalFacturacionBruta2: double.parse(vendedorData['TotalFacturacionBruta2']),
            porcentajeAlcanzadoMeta: double.parse(vendedorData['PorcentajeAlcanzadoMeta']), 
            diasHabilesMes: vendedorData['DiasHabilesMes'],
            diasHabilesTranscurridos: vendedorData['DiasHabilesTranscurridos'],
            diasHabilesRestantes: vendedorData['DiasHabilesRestantes'], 
            promedioVentaDiaria: double.parse(vendedorData['PromedioVentaDiaria']),
            diferenciaMeta: double.parse(vendedorData['DiferenciaMeta']),
            objetivoDiario: double.parse(vendedorData['ObjetivoDiario']),
            saldo: double.parse(vendedorData['Saldo']),
            vencido: double.parse(vendedorData['Vencido']), 
            porcentajeSaldoVencido: double.parse(vendedorData['PorcentajeSaldoVencido']), 
            porcentajeVentaVencido: double.parse(vendedorData['PorcentajeVentaVencido']),
            supervisadoPor: vendedorData['SupervisadoPor'],
            cajasVendidas: double.parse(vendedorData['CajasVendidas']),
            activo: vendedorData['Estatus'],
          );

          print('creado: ${vendedor.codigoVendedor} - ${vendedor.cantidadClientes}');
          // Guardar el vendedor en la base de datos
          await insertVendedor(vendedor);          
        }
        

        // Puedes retornar la lista de productos si lo deseas
        // return productos;
      } else {
        throw Exception('Failed to fetch vendedores');
      }
    } catch (error) {
      print('Error al cargar los vendedores fecha sync: $error');
    }
  }

  Future<void> cargaInicialVendedores() async {
    //print('${codigoVendedor} ');
    //String? fechaSincronizacion = await getFechaSync();

    try {
      final response = await http.get(Uri.parse(
        'https://nodejs-mysql-railway-blanking-production.up.railway.app/Vendedores',
      ));
      if (response.statusCode == 200) {
        print(' exito api vendedores ini');
        var data = json.decode(response.body);

        // Borrar todos los registros existentes en la tabla 'vendedores'
        await deleteAllVendedores();

        for (var vendedorData in data) {

          print(vendedorData);

          Vendedor vendedor = Vendedor(
            codigoVendedor: vendedorData['codigo'],
            nombre: vendedorData['nombre'],
            zona: vendedorData['Zona'],
            almacen: vendedorData['Almacen'],
            rif: vendedorData['rif'],
            nit: vendedorData['nit'],
            cantidadClientes: vendedorData['CantidadClientes'],
            cantidadClientesNuevosMes: vendedorData['CantidadClientesNuevosMes'],
            cantidadPedidosHoy: vendedorData['CantidadPedidosHoy'],
            cantidadPedidosMes: vendedorData['CantidadPedidosMes'],
            cantidadClientesAtendidosHoy: vendedorData['CantidadClientesAtendidosHoy'],
            cantidadClientesAtendidosMes: vendedorData['CantidadClientesAtendidosMes'],
            meta: double.parse(vendedorData['meta']),
            porcentajeEfectividad: double.parse(vendedorData['PorcentajeEfectividad']), 
            totalVentaBruta2: double.parse(vendedorData['TotalVentaBruta2']),
            totalDevolucionBruta2: double.parse(vendedorData['TotalDevolucionBruta2']),
            totalFacturacionBruta2: double.parse(vendedorData['TotalFacturacionBruta2']),
            porcentajeAlcanzadoMeta: double.parse(vendedorData['PorcentajeAlcanzadoMeta']), 
            diasHabilesMes: vendedorData['DiasHabilesMes'],
            diasHabilesTranscurridos: vendedorData['DiasHabilesTranscurridos'],
            diasHabilesRestantes: vendedorData['DiasHabilesRestantes'], 
            promedioVentaDiaria: double.parse(vendedorData['PromedioVentaDiaria']),
            diferenciaMeta: double.parse(vendedorData['DiferenciaMeta']),
            objetivoDiario: double.parse(vendedorData['ObjetivoDiario']),
            saldo: double.parse(vendedorData['Saldo']),
            vencido: double.parse(vendedorData['Vencido']), 
            porcentajeSaldoVencido: double.parse(vendedorData['PorcentajeSaldoVencido']), 
            porcentajeVentaVencido: double.parse(vendedorData['PorcentajeVentaVencido']),
            supervisadoPor: vendedorData['SupervisadoPor'],
            cajasVendidas: double.parse(vendedorData['CajasVendidas']),
            activo: vendedorData['Estatus'],
          );
          
          print('creado: ${vendedor.codigoVendedor} - ${vendedor.cantidadClientes}');
          // Guardar el vendedor en la base de datos
          await insertVendedor(vendedor);       
        }
        

        // Puedes retornar la lista de productos si lo deseas
        // return productos;
      } else {
        throw Exception('Failed to fetch vendedores');
      }
    } catch (error) {
      print('Error al cargar los vendedoreseses: $error');
    }
  }

  Future<List<Vendedor>> getVendedores(String codigoSupervisor) async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "vendedores"
    final List<Map<String, dynamic>> result;

    if (codigoSupervisor=='T'){
      //result = await db.query('vendedores');
      result = await db.query('vendedores', where: 'activo = ?', whereArgs: [1]);
    } else {
      result = await db.query(
        'vendedores',
        /*
        where: 'supervisadoPor = ? OR codigoVendedor = ?',
        whereArgs: [codigoSupervisor, codigoSupervisor],
        */
        where: '(supervisadoPor = ? OR codigoVendedor = ?) AND activo = ?',
        whereArgs: [codigoSupervisor, codigoSupervisor, 1],
      );
    }

    // Convierte cada mapa en un objeto Vendedor
    final List<Vendedor> vendedores = result.map((map) => Vendedor.fromMap(map)).toList();

    // Retorna los vendedores obtenidos
    return vendedores;
  }

  Future<void> cargaUsuarios() async {

    try {
      final response = await http.get(Uri.parse(
        'https://nodejs-mysql-railway-blanking-production.up.railway.app/Usuarios',
      ));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        //List<Cliente> clientes = [];
        for (var usuarioData in data) {
                   
          Usuario usuario = Usuario(
            usuario: usuarioData['usuario'].toLowerCase().trim(),
            contrasena: usuarioData['contrasena'],
            nombreCompleto: usuarioData['nombreCompleto'],
            correoElectronico: usuarioData['correoElectronico'],
            fechaRegistro: DateTime.parse(usuarioData['fechaRegistro']),
            ultimoInicioSesion: DateTime.parse(usuarioData['ultimoInicioSesion']),
            rol: usuarioData['rol'],
            estatus: int.parse(usuarioData['estatus'].toString()),
            codigoVendedor: usuarioData['codigoVendedor'],
            fechaNacimiento: DateTime.parse(usuarioData['fechaNacimiento']),
            direccion: usuarioData['direccion'],
            numeroTelefono: usuarioData['numeroTelefono'],
            cedula: usuarioData['cedula'],
          );

          //print('${clienteData['CodigoCliente']} - ${clienteData['CodigoCliente']} ');
          
          // Guardar el cliente en la base de datos
          await insertUsuario(usuario);

          //clientes.add(cliente);
        }

        // Puedes retornar la lista de clientes si lo deseas
        // return clientes;
      } else {
        throw Exception('Failed to fetch clientes');
      }
    } catch (error) {
      print('Error al cargar los clientess: $error');
    }
  }

  Future<void> insertUsuario(Usuario usuario) async {
    final db = await openDatabase();
    await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Usuario>> getUsuarios() async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "vendedores"
    final List<Map<String, dynamic>> result = await db.query('usuarios');

    // Convierte cada mapa en un objeto Vendedor
    final List<Usuario> usuarios = result.map((map) => Usuario.fromMap(map)).toList();

    // Retorna los Usuarioes obtenidos
    return usuarios;
  }

  Future<Usuario> getUsuarioSeleccionado(String usuario) async {
    final db = await openDatabase();
    
    // Realiza una consulta a la tabla "vendedores" filtrando por el código de vendedor
    final List<Map<String, dynamic>> result = await db.query('usuarios', where: 'usuario = ?', whereArgs: [usuario]);

    if (result.isNotEmpty) {
      // Convierte el mapa en un objeto Vendedor
      Usuario usuario = Usuario.fromMap(result.first);

      // Retorna el vendedor obtenido
      return usuario;
    } else {
      // No se encontró ningún vendedor con el código especificado
      return Usuario(
            usuario: 'noEncontrado',
            contrasena: 'noEncontrado',
            nombreCompleto: 'noEncontrado',
            correoElectronico: 'noEncontrado',
            fechaRegistro: DateTime.parse('2000-01-01 00:00:00'),
            ultimoInicioSesion: DateTime.parse('2000-01-01 00:00:00'),
            rol: 'noEncontrado',
            estatus: 0,
            codigoVendedor: 'noEncontrado',
            fechaNacimiento: DateTime.parse('2000-01-01 00:00:00'),
            direccion: 'noEncontrado',
            numeroTelefono: 'noEncontrado',
            cedula: 'noEncontrado',
          );
    }
  }

  Future<void> cargaClientes(String fechaRefresh) async {
    //print('${codigoVendedor} ');
    String? fechaSincronizacion = await getFechaSync();
    //String? fechaSincronizacion = fechaRefresh;
    String? codigoVendedor = await getVendedorActual();
    Usuario? usuarioActual; 

    if (fechaRefresh!='carga'){
      if (fechaSincronizacion != null) {
      DateTime fecha1 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(fechaSincronizacion);
      DateTime fecha2 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(fechaRefresh);

      // Ahora puedes comparar las fechas
      int comparacion = fecha1.compareTo(fecha2);

      if (comparacion < 0) {
        print('fechaSincronizacion es más antigua que fechaRefresh: ${fechaSincronizacion}');
      } else if (comparacion > 0) {
        print('fechaRefresh es más antigua que fechaSincronizacion: ${fechaRefresh}');
        fechaSincronizacion = fechaRefresh;
      } else {
        print('Ambas fechas son iguales');
      }
      
      } else {
        print('Una o ambas fechas son nulas');
      }  
    }

    usuarioActual = await getUsuarioObj(); 

    try {
      final response;
      
      if (usuarioActual!.rol=='Vendedor') {
        print('cargando clientesvendedor');
        response = await http.get(Uri.parse(
          'https://nodejs-mysql-railway-blanking-production.up.railway.app/ClientesFechaSync/$codigoVendedor/$fechaSincronizacion',
        ));
      } else {
        if (usuarioActual.rol=='Supervisor') {
           print('cargando clientessupervisor');
          response = await http.get(Uri.parse(
            'https://nodejs-mysql-railway-blanking-production.up.railway.app/ClientesSupervisorFechaSync/$codigoVendedor/$fechaSincronizacion',
          ));
        } else {
           print('cargando todos los clientes');
          response = await http.get(Uri.parse(
            'https://nodejs-mysql-railway-blanking-production.up.railway.app/ClientesFechaSync/$fechaSincronizacion',
          ));
        }
      }

      if (response.statusCode == 200) {
        print(' exito api clientes');
        var data = json.decode(response.body);

        //List<Cliente> clientes = [];
        for (var clienteData in data) {
          
          //print(' exito api ${clienteData['CodigoCliente']} - ${clienteData['Nombre']} - ${clienteData['NombreBusqueda']} - ${clienteData['RazonSocial']} - ${clienteData['Direccion']} - ${int.parse(clienteData['DiasVisita'])} - ${clienteData['Telefonos']} - ${double.parse(clienteData['LimiteCredito'])} - ${double.parse(clienteData['SaldoMonedaTotal'])} - ${double.parse(clienteData['SaldoMonedaVencido'])} - ${clienteData['ultimopago']} - ${clienteData['ProximoVencer']} -   ');
          
          Cliente cliente = Cliente( 
            codigoCliente: clienteData['CodigoCliente'],
            nombre: clienteData['Nombre'],
            nombreBusqueda: clienteData['NombreBusqueda'],
            razonSocial: clienteData['RazonSocial'],
            direccion: clienteData['Direccion'],
            diasVisita: int.parse(clienteData['DiasVisita'].toString()),
            telefonos: clienteData['Telefonos'],
            limiteCredito: double.parse(clienteData['LimiteCredito']),
            saldoMonedaTotal: double.parse(clienteData['SaldoMonedaTotal']),
            saldoMonedaVencido: double.parse(clienteData['SaldoMonedaVencido']),
            ultimoPago: DateTime.parse(clienteData['ultimopago']),
            proximoVencer: int.parse(clienteData['ProximoVencer'].toString()),
            estatus: clienteData['Estatus'],
          );

          //print('${clienteData['CodigoCliente']} - ${clienteData['CodigoCliente']} ');
          
          // Guardar el cliente en la base de datos
          await insertCliente(cliente);

          //clientes.add(cliente);
        }

        // Puedes retornar la lista de clientes si lo deseas
        // return clientes;
      } else {
        throw Exception('Failed to fetch clientes');
      }
    } catch (error) {
      print('Error al cargar los clientess: $error');
    }
  }

  Future<void> cargaInicialClientes() async {
    //print('${codigoVendedor} ');
    String? codigoVendedor = await getVendedorActual();
    Usuario? usuarioActual; 

    usuarioActual = await getUsuarioObj(); 

    try {
      final response;

      if (usuarioActual!.rol=='Vendedor') {
        response = await http.get(Uri.parse(
          'https://nodejs-mysql-railway-blanking-production.up.railway.app/clientes/$codigoVendedor',
        ));
      } else {
        if (usuarioActual.rol=='Supervisor') {
          response = await http.get(Uri.parse(
            'https://nodejs-mysql-railway-blanking-production.up.railway.app/ClientesSupervisor/$codigoVendedor',
          ));
        } else {
          response = await http.get(Uri.parse(
            'https://nodejs-mysql-railway-blanking-production.up.railway.app/clientes',
          ));
        }
      }

      if (response.statusCode == 200) {
        print(' exito api clientes');
        var data = json.decode(response.body);

        //List<Cliente> clientes = [];
        for (var clienteData in data) {
          
          //print(' exito api ${clienteData['CodigoCliente']} - ${clienteData['Nombre']} - ${clienteData['NombreBusqueda']} - ${clienteData['RazonSocial']} - ${clienteData['Direccion']} - ${int.parse(clienteData['DiasVisita'])} - ${clienteData['Telefonos']} - ${double.parse(clienteData['LimiteCredito'])} - ${double.parse(clienteData['SaldoMonedaTotal'])} - ${double.parse(clienteData['SaldoMonedaVencido'])} - ${clienteData['ultimopago']} - ${clienteData['ProximoVencer']} -   ');
          
          Cliente cliente = Cliente(
            codigoCliente: clienteData['CodigoCliente'],
            nombre: clienteData['Nombre'],
            nombreBusqueda: clienteData['NombreBusqueda'],
            razonSocial: clienteData['RazonSocial'],
            direccion: clienteData['Direccion'],
            diasVisita: int.parse(clienteData['DiasVisita'].toString()),
            telefonos: clienteData['Telefonos'],
            limiteCredito: double.parse(clienteData['LimiteCredito']),
            saldoMonedaTotal: double.parse(clienteData['SaldoMonedaTotal']),
            saldoMonedaVencido: double.parse(clienteData['SaldoMonedaVencido']),
            ultimoPago: DateTime.parse(clienteData['ultimopago']),
            proximoVencer: int.parse(clienteData['ProximoVencer'].toString()),
            estatus: clienteData['Estatus'],
          );

          //print('${clienteData['CodigoCliente']} - ${clienteData['CodigoCliente']} ');
          
          // Guardar el cliente en la base de datos
          await insertCliente(cliente);

          //clientes.add(cliente);
        }

        // Puedes retornar la lista de clientes si lo deseas
        // return clientes;
      } else {
        throw Exception('Failed to fetch clientes');
      }
    } catch (error) {
      print('Error al cargar los clientess: $error');
    }
  }

  Future<void> insertCliente(Cliente cliente) async {
    final db = await openDatabase();
    await db.insert(
      'clientes',
      cliente.toMap(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Cliente>> getClientes() async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "clientes"
    final List<Map<String, dynamic>> result = await db.query(
      'clientes',
      where: 'Estatus = ?',
      whereArgs: ['A'],
      orderBy: 'SaldoMonedaTotal DESC', 
    );

    // Convierte cada mapa en un objeto Cliente
    final List<Cliente> clientes =
        result.map((map) => Cliente.fromMap(map)).toList();

    // Retorna los clientes obtenidos
    return clientes;
  }

  Future<Cliente> getClienteEspecifico(String codigoCliente) async {
    final db = await openDatabase();
    
    // Realiza una consulta a la tabla "clientes"
    final List<Map<String, dynamic>> result = await db.query('clientes', where: 'codigoCliente = ?', whereArgs: [codigoCliente]);
      
    // Convierte cada mapa en un objeto Cliente
    Cliente clienteEspecifico = Cliente.fromMap(result.first);

    // Retorna los clientes obtenidos
    return clienteEspecifico;
  }

  Future<Cliente> getClienteEspecificohttp(String codigoCliente) async {
    final response = await http.get(Uri.parse(
      'https://nodejs-mysql-railway-blanking-production.up.railway.app/ClientesEspecifico/$codigoCliente',
    ));

    var data = json.decode(response.body);

    Cliente clienteEspecifico = Cliente(
      codigoCliente: data[0]['CodigoCliente'],
      nombre: data[0]['Nombre'],
      nombreBusqueda: data[0]['NombreBusqueda'],
      razonSocial: data[0]['RazonSocial'],
      direccion: data[0]['Direccion'],
      diasVisita: int.parse(data[0]['DiasVisita'].toString()),
      telefonos: data[0]['Telefonos'],
      limiteCredito: double.parse(data[0]['LimiteCredito']),
      saldoMonedaTotal: double.parse(data[0]['SaldoMonedaTotal']),
      saldoMonedaVencido: double.parse(data[0]['SaldoMonedaVencido']),
      ultimoPago: DateTime.parse(data[0]['ultimopago']),
      proximoVencer: int.parse(data[0]['ProximoVencer'].toString()),
      estatus: data[0]['Estatus'],
    );
    
    return clienteEspecifico;
  }

  Future<void> cargaProductos(String fechaRefresh) async {
    //print('${codigoVendedor} ');
    //String? fechaSincronizacion = fechaRefresh;
    String? fechaSincronizacion = await getFechaSync();

    if (fechaRefresh!='carga'){
      if (fechaSincronizacion != null) {
      DateTime fecha1 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(fechaSincronizacion);
      DateTime fecha2 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(fechaRefresh);

      // Ahora puedes comparar las fechas
      int comparacion = fecha1.compareTo(fecha2);

      if (comparacion < 0) {
        print('fechaSincronizacion es más antigua que fechaRefresh: ${fechaSincronizacion}');
      } else if (comparacion > 0) {
        print('fechaRefresh es más antigua que fechaSincronizacion: ${fechaRefresh}');
        fechaSincronizacion = fechaRefresh;
      } else {
        print('Ambas fechas son iguales');
      }
      
      } else {
        print('Una o ambas fechas son nulas');
      }  
    }

    try {
      final response = await http.get(Uri.parse(
        'https://nodejs-mysql-railway-blanking-production.up.railway.app/productos/$fechaSincronizacion',
      ));
      if (response.statusCode == 200) {
        print(' exito api productos');
        var data = json.decode(response.body);

        //List<Cliente> clientes = [];
        for (var productoData in data) {
          
          //print(' exito api ${productoData['CodigoProducto']} - ${productoData['Nombre']} - ${productoData['NombreBusqueda']} - ${productoData['IVA']} - ${productoData['CantidadxBulto']} - ${double.parse(productoData['Existencia'])} - ${double.parse(productoData['Existencia02'])} - ${double.parse(productoData['Existencia03'])} - ${double.parse(productoData['ExistenciaVenta'])} - ${double.parse(productoData['PedidoVenta'])} - ${double.parse(productoData['PrecioMoneda'])}  -  -   ');
          
          Producto producto = Producto(
            codigoProducto: productoData['CodigoProducto'],
            nombre: productoData['Nombre'],
            nombreBusqueda: productoData['NombreBusqueda'],
            iva: productoData['IVA'],
            cantidadxBulto: double.parse(productoData['CantidadxBulto']),
            existencia: double.parse(productoData['Existencia']),
            existencia02: double.parse(productoData['Existencia02']),
            existencia03: double.parse(productoData['Existencia03']),
            existenciaVenta: double.parse(productoData['ExistenciaVenta']),
            pedidoVenta: double.parse(productoData['PedidoVenta']),
            precioMoneda: double.parse(productoData['PrecioMoneda']),
            codigoGrupo: productoData['CodigoGrupo'],
            marca: productoData['Marca'],
          );

          //print('${productoData['CodigoCliente']} - ${productoData['CodigoCliente']} ');
          
          // Guardar el producto en la base de datos
          await insertProducto(producto);

          //productos.add(producto);
        }

        // Puedes retornar la lista de productos si lo deseas
        // return productos;
      } else {
        throw Exception('Failed to fetch productos');
      }
    } catch (error) {
      print('Error al cargar los productoss: $error');
    }
  }

  Future<void> cargaInicialProductos() async {
    //print('${codigoVendedor} ');
    //String? fechaSincronizacion = await getFechaSync();

    try {
      final response = await http.get(Uri.parse(
        'https://nodejs-mysql-railway-blanking-production.up.railway.app/productos',
      ));
      if (response.statusCode == 200) {
        print(' exito api productos ini');
        var data = json.decode(response.body);

        //List<Cliente> clientes = [];
        for (var productoData in data) {
          
          //print(' exito api ${productoData['CodigoProducto']} - ${productoData['Nombre']} - ${productoData['NombreBusqueda']} - ${productoData['IVA']} - ${productoData['CantidadxBulto']} - ${double.parse(productoData['Existencia'])} - ${double.parse(productoData['Existencia02'])} - ${double.parse(productoData['Existencia03'])} - ${double.parse(productoData['ExistenciaVenta'])} - ${double.parse(productoData['PedidoVenta'])} - ${double.parse(productoData['PrecioMoneda'])}  -  -   ');
          
          Producto producto = Producto(
            codigoProducto: productoData['CodigoProducto'],
            nombre: productoData['Nombre'],
            nombreBusqueda: productoData['NombreBusqueda'],
            iva: productoData['IVA'],
            cantidadxBulto: double.parse(productoData['CantidadxBulto']),
            existencia: double.parse(productoData['Existencia']),
            existencia02: double.parse(productoData['Existencia02']),
            existencia03: double.parse(productoData['Existencia03']),
            existenciaVenta: double.parse(productoData['ExistenciaVenta']),
            pedidoVenta: double.parse(productoData['PedidoVenta']),
            precioMoneda: double.parse(productoData['PrecioMoneda']),
            codigoGrupo: productoData['CodigoGrupo'],
            marca: productoData['Marca'],
          );

          //print('${productoData['CodigoCliente']} - ${productoData['CodigoCliente']} ');
          
          // Guardar el producto en la base de datos
          await insertProducto(producto);

          //productos.add(producto);
        }

        // Puedes retornar la lista de productos si lo deseas
        // return productos;
      } else {
        throw Exception('Failed to fetch productos');
      }
    } catch (error) {
      print('Error al cargar los productoss: $error');
    }
  }

  Future<void> insertProducto(Producto producto) async {
    final db = await openDatabase();
    await db.insert(
      'productos',
      producto.toMap(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Producto>> getProductos() async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "productos"
    final List<Map<String, dynamic>> result = await db.query('productos', orderBy: 'CodigoGrupo ASC, CodigoProducto ASC');

    // Convierte cada mapa en un objeto producto
    final List<Producto> productos =
        result.map((map) => Producto.fromMap(map)).toList();

    // Retorna los productos obtenidos
    return productos;
  }

  Future<String?> getContadores(String documento) async {
    final db = await openDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT contador FROM contadores WHERE documento = ? LIMIT 1",
      [documento],
    );

    if (result.isNotEmpty) {
      return result[0]['contador'].toString();
    } else {
      return '';
    }
  }

  Future<String?> getFechaSync() async {
    final db = await openDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT valorText FROM informacion WHERE info = 'fechaSincronizacion' LIMIT 1",
    );

    if (result.isNotEmpty) {
      // Obtiene el valor del campo 'valorText' como cadena
      String fechaTexto = result[0]['valorText'].toString();

      // Convierte la cadena de fecha a un objeto DateTime
      DateTime fecha = DateTime.parse(fechaTexto);

      // Formatea la fecha y hora en el formato deseado
      String fechaFormateada = DateFormat('yyyy-MM-dd HH:mm:ss').format(fecha);

      // Devuelve la fecha formateada
      return fechaFormateada;
      
    } else {
      return '2020-01-01 00:00:00';
    }
  }

  Future<void> updateFechaSync() async {
    final db = await openDatabase();

    // Obtén la fecha y hora actual en UTC
    DateTime fechaActual = DateTime.now().toUtc();

    // Ajusta la fecha y hora a la zona horaria de Caracas (UTC-4)
    DateTime fechaFormateada = fechaActual.subtract(Duration(hours: 4));

    // Formatea la fecha y hora en el formato deseado
    String fechaFormateadaString = DateFormat('yyyy-MM-dd HH:mm:ss').format(fechaFormateada);

    // Actualiza el registro fechaSincronizacion en la tabla informacion
    await db.update(
      'informacion',
      {'valorText': fechaFormateadaString},
      where: 'info = ?',
      whereArgs: ['fechaSincronizacion'],
    );
  }
  
  Future<String?> getUsuarioActual() async {
    final db = await openDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT valorText FROM informacion WHERE info = 'usuarioActual' LIMIT 1",
    );

    if (result.isNotEmpty) {
      // Obtiene el valor del campo 'valorText' como cadena
      String usuarioActual = result[0]['valorText'].toString();

      // Devuelve la cadena de usuarioActual
      return usuarioActual;
      
    } else {
      return 'N';
    }
  }

  Future<Usuario?> getUsuarioObj() async {
    final db = await openDatabase();
    String? usuario = await getUsuarioActual();
    
    // Realiza una consulta a la tabla "vendedores" filtrando por el código de vendedor
    final List<Map<String, dynamic>> result = await db.query('usuarios', where: 'usuario = ?', whereArgs: [usuario]);

    if (result.isNotEmpty) {
      // Convierte el mapa en un objeto Vendedor
      Usuario usuario = Usuario.fromMap(result.first);

      // Retorna el usuario obtenido
      return usuario;
    } else {
      // No se encontró ningún usuario con el código especificado
      return null;
    }
  }

  Future<void> updateUsuarioActual(String usuarioActual) async {
    final db = await openDatabase(); 

    // Actualiza el registro usuarioActual en la tabla informacion
    await db.update(
      'informacion',
      {'valorText': usuarioActual},
      where: 'info = ?',
      whereArgs: ['usuarioActual'],
    );
  }

  Future<String?> getVendedorActual() async {
    final db = await openDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT valorText FROM informacion WHERE info = 'vendedorActual' LIMIT 1",
    );

    if (result.isNotEmpty) {
      // Obtiene el valor del campo 'valorText' como cadena
      String vendedorActual = result[0]['valorText'].toString();

      // Devuelve la cadena de vendedorActual
      return vendedorActual;
      
    } else {
      return 'T';
    }
  }

  Future<void> updateBusquedaActual(String busquedaActual) async {
    final db = await openDatabase(); 

    print("objectaaaaa");
    // Actualiza el registro usuarioActual en la tabla informacion
    await db.update(
      'informacion',
      {'valorText': busquedaActual},
      where: 'info = ?',
      whereArgs: ['busquedaActual'],
    );
    print("object");
  }
  
  Future<String> getBusquedaActual() async {
    final db = await openDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT valorText FROM informacion WHERE info = 'busquedaActual' LIMIT 1",
    );

    if (result.isNotEmpty) {
      // Obtiene el valor del campo 'valorText' como cadena
      String busquedaActual = result[0]['valorText'].toString();

      // Devuelve la cadena de vendedorActual
      return busquedaActual;
      
    } else {
      return '';
    }
  }

  Future<Vendedor> getVendedorObj() async {
    final db = await openDatabase();

    String? codigoVendedor = await getVendedorActual();
    
    // Realiza una consulta a la tabla "vendedores" filtrando por el código de vendedor
    final List<Map<String, dynamic>> result = await db.query('vendedores', where: 'codigoVendedor = ?', whereArgs: [codigoVendedor]);
    //print('objectaaax ${codigoVendedor}');
    //print('objectaaasx ${result.first['nombre']}');
    if (result.isNotEmpty) {
      // Convierte el mapa en un objeto Vendedor
      Vendedor vendedor = Vendedor.fromMap(result.first);
      // Retorna el vendedor obtenido
      return vendedor;
    } else {
      // No se encontró ningún vendedor con el código especificado
      final List<Map<String, dynamic>> result2 = await db.query('vendedores');
      Vendedor vendedor2 = Vendedor.fromMap(result2.first);
      return vendedor2;
    }
  }

  Future<Vendedor> getVendedorObjSelect(String codigoVendedor) async {
    final db = await openDatabase();

    //String? codigoVendedor = await getVendedorActual();
    
    // Realiza una consulta a la tabla "vendedores" filtrando por el código de vendedor
    final List<Map<String, dynamic>> result = await db.query('vendedores', where: 'codigoVendedor = ?', whereArgs: [codigoVendedor]);
    //print('objectaaax ${codigoVendedor}');
    //print('objectaaasx ${result.first['nombre']}');
    if (result.isNotEmpty) {
      // Convierte el mapa en un objeto Vendedor
      Vendedor vendedor = Vendedor.fromMap(result.first);
      // Retorna el vendedor obtenido
      return vendedor;
    } else {
      // No se encontró ningún vendedor con el código especificado
      final List<Map<String, dynamic>> result2 = await db.query('vendedores');
      Vendedor vendedor2 = Vendedor.fromMap(result2.first);
      return vendedor2;
    }
  }

  Future<void> updateVendedorActual(String vendedorActual) async {
    final db = await openDatabase(); 

    // Actualiza el registro vendedorActual en la tabla informacion
    await db.update(
      'informacion',
      {'valorText': vendedorActual},
      where: 'info = ?',
      whereArgs: ['vendedorActual'],
    );
  }

  Future<bool?> getLogged() async {
    final db = await openDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT valorText FROM informacion WHERE info = 'logged' LIMIT 1",
    );

    if (result.isNotEmpty) {
      // Obtiene el valor del campo 'valorText' como cadena
      String logged= result[0]['valorText'].toString();

      if (logged=='S') {
        return true;
      } else {
        return false;
      }      
    } else {
      return false;
    }
  }

  Future<void> updateLogged() async {
    final db = await openDatabase(); 

    // Actualiza el registro vendedorActual en la tabla informacion
    await db.update(
      'informacion',
      {'valorText': 'S'},
      where: 'info = ?',
      whereArgs: ['logged'],
    );
  }

  Future<void> updateLogout() async {
    final db = await openDatabase(); 

    // Actualiza el registro vendedorActual en la tabla informacion
    await db.update(
      'informacion',
      {'valorText': 'N'},
      where: 'info = ?',
      whereArgs: ['logged'],
    );

    // Borra todo el contenido de la tabla clientes
    await db.delete('clientes');
  }

  Future<void> validarUsuarioActivo() async {
    final db = await openDatabase();
    String? usuario = await getUsuarioActual();
    
    //print ('ANTES DE HTTP VALIDAR USUARIO');
    // Realiza una consulta a la tabla "vendedores" filtrando por el código de vendedor
    final response = await http.get(
      Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/Usuarios/$usuario')
    );
    //print ('DESPUES DE HTTP VALIDAR USUARIO');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      String estatus = data[0]['Estatus'].toString();
      //print ('200 DE HTTP VALIDAR USUARIO, ${estatus}');
      if (estatus == '0') {
        updateLogout();
        print ('salir login, ${estatus}');
      }
    }
  }
  
  Future<void> updateContador(String documento) async {
    final db = await openDatabase();

    // Obtener el contador actual
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT contador FROM contadores WHERE documento = ? LIMIT 1",
      [documento],
    );

    if (result.isNotEmpty) {
      // Obtener el contador actual y convertirlo a un entero
      final int currentCount = int.parse(result[0]['contador'].toString());

      // Incrementar el contador en 1
      final int newCount = currentCount + 1;

      // Formatear el nuevo contador con ceros a la izquierda
      final String formattedCount = newCount.toString().padLeft(5, '0');

      // Actualizar el campo contador en la base de datos
      await db.rawUpdate(
        "UPDATE contadores SET contador = ? WHERE documento = ?",
        [formattedCount, documento],
      );
    }
  }

  Future<void> insertPedidosEspera(PedidoEspera pedidoEspera) async {
    final db = await openDatabase();
    await db.insert(
      'pedidosEspera',
      pedidoEspera.toMap(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }
  
  Future<void> insertPedidosEsperaTemp(PedidoEspera pedidoEspera) async {
    final db = await openDatabase();
    await db.insert(
      'pedidosEsperaTemp',
      pedidoEspera.toMap(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<List<PedidoEspera>> getPedidosEsperaAll() async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "pedidosEspera"
    final List<Map<String, dynamic>> result = await db.query('pedidosEspera', orderBy: 'fecha DESC');

    // Convierte cada mapa en un objeto pedidosEspera
    final List<PedidoEspera> pedidosEspera =
        result.map((map) => PedidoEspera.fromMap(map)).toList();

    // Retorna los productos obtenidos
    return pedidosEspera;
  }

  Future<PedidoEspera> getPedidosEspera(String numero) async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "pedidosEspera"
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT * FROM pedidosEspera WHERE numero = ?",
      [numero],
    );

    // Convierte cada mapa en un objeto pedidosEspera
    final List<PedidoEspera> pedidosEspera =
        result.map((map) => PedidoEspera.fromMap(map)).toList();

    // Retorna los productos obtenidos
    return pedidosEspera[0];
  }

  Future<PedidoEspera> getPedidosEsperaTemp(String numero) async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "pedidosEspera"
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT * FROM pedidosEsperaTemp WHERE numero = ?",
      [numero],
    );

    // Convierte cada mapa en un objeto pedidosEspera
    final List<PedidoEspera> pedidosEspera =
        result.map((map) => PedidoEspera.fromMap(map)).toList();

    // Retorna los productos obtenidos
    return pedidosEspera[0];
  }

  Future<bool> hayPedidosEsperaTemp() async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "pedidosEsperaTemp"
    final List<Map<String, dynamic>> result =
        await db.rawQuery("SELECT * FROM pedidosEsperaTemp");

    // Convierte cada mapa en un objeto pedidosEspera
    final List<PedidoEspera> pedidosEspera =
        result.map((map) => PedidoEspera.fromMap(map)).toList();

    // Retorna true si hay al menos un pedido en espera, false de lo contrario
    return pedidosEspera.isNotEmpty;
  }

  Future<void> insertPedidosRenglonesEspera(PedidoRenglonEspera pedidoRenglonEspera) async {
    final db = await openDatabase();
    await db.insert(
      'pedidosRenglonesEspera',
      pedidoRenglonEspera.toMap(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPedidosRenglonesEsperaTemp(PedidoRenglonEspera pedidoRenglonEspera) async {
    final db = await openDatabase();
    await db.insert(
      'pedidosRenglonesEsperaTemp',
      pedidoRenglonEspera.toMap(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<List<PedidoRenglonEspera>> getPedidosRenglonesEspera(String numero) async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "pedidosEspera"
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT * FROM pedidosRenglonesEspera WHERE numero = ? ORDER BY indice ASC",
      [numero],
    );

    // Convierte cada mapa en un objeto pedidosEspera
    final List<PedidoRenglonEspera> pedidosEspera =
        result.map((map) => PedidoRenglonEspera.fromMap(map)).toList();

    // Retorna los productos obtenidos
    return pedidosEspera;
  }

  Future<List<PedidoRenglonEspera>> getPedidosRenglonesEsperaTemp(String numero) async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "pedidosEspera"
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT * FROM pedidosRenglonesEsperaTemp WHERE numero = ? ORDER BY indice ASC",
      [numero],
    );

    // Convierte cada mapa en un objeto pedidosEspera
    final List<PedidoRenglonEspera> pedidosEspera =
        result.map((map) => PedidoRenglonEspera.fromMap(map)).toList();

    // Retorna los productos obtenidos
    return pedidosEspera;
  }

  Future<List<PedidoRenglonEspera>> getPedidosRenglonesEsperaAll() async {
    final db = await openDatabase();

    // Realiza una consulta a la tabla "pedidosEspera"
    final List<Map<String, dynamic>> result = await db.query('pedidosRenglonesEspera');

    // Convierte cada mapa en un objeto pedidosEspera
    final List<PedidoRenglonEspera> pedidosEspera =
        result.map((map) => PedidoRenglonEspera.fromMap(map)).toList();

    // Retorna los productos obtenidos
    return pedidosEspera;
  }

  Future<void> eliminarPedido(String numeroPedido) async {
    final db = await openDatabase();

    // Eliminar el pedido de la tabla "pedidosEspera"
    await db.delete(
      'pedidosEspera',
      where: 'numero = ?',
      whereArgs: [numeroPedido],
    );

    // Eliminar los renglones del pedido de la tabla "pedidosRenglonesEspera"
    await db.delete(
      'pedidosRenglonesEspera',
      where: 'numero = ?',
      whereArgs: [numeroPedido],
    );
  }

  Future<void> eliminarPedidoTemp(String numeroPedido) async {
    final db = await openDatabase();

    // Eliminar el pedido de la tabla "pedidosEspera"
    await db.delete(
      'pedidosEsperaTemp',
      where: 'numero = ?',
      whereArgs: [numeroPedido],
    );

    // Eliminar los renglones del pedido de la tabla "pedidosRenglonesEspera"
    await db.delete(
      'pedidosRenglonesEsperaTemp',
      where: 'numero = ?',
      whereArgs: [numeroPedido],
    );
  }

  Future<bool> checkInternetConnectivity() async {
    try {
      var response = await http.get(Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/online')).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        return true; // Hay conexión a Internet
      } else {
        return false; // No hay conexión a Internet
      }
    } catch (error) {
      return false; // Hubo un error en la solicitud (puede ser por falta de conexión)
    }
  }

  Future<String> _fetchContador() async {
    final responseContadorVer = await http.get(
      Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/ContadorPedidoVer')
    );

    final responseContador = await http.get(
      Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/ContadorPedido')
    );
    
    if (responseContadorVer.statusCode == 200) {
      final data = json.decode(responseContadorVer.body);
      final contador = data[0]["Numero"];
      return contador;
      
    } else {
      throw Exception('Failed to fetch Contador');
    }
  }
  
  Future<Map<String, dynamic>> enviarPedido(String numeroPedido) async {
    
    
    bool hayInternet = await checkInternetConnectivity();
    String numeroPedidoApi;

    List<PedidoRenglonEspera> pedidoRenglonEspera = await getPedidosRenglonesEspera(numeroPedido);
    PedidoEspera pedidoEspera = await getPedidosEspera(numeroPedido);
    int exitoRenglones = 0;
    List<Map<String, dynamic>> renglonesLista = [];


    if (hayInternet==true) {
      numeroPedidoApi = "AS-";

      //inicio pedido completo
          
      int indice = 1;

      for (PedidoRenglonEspera articulo in pedidoRenglonEspera) {
        final pedidoRenglon = {
          'numero': numeroPedidoApi,
          'almacen': articulo.almacen,
          'cantidad': articulo.cantidad,
          'precioMoneda': articulo.precioMoneda,
          'totalRenglon': articulo.totalRenglon,
          'indice': indice,
          'tarifa': articulo.tarifa,
          'codigoProducto': articulo.codigoProducto,
          'descuento': articulo.descuento,
        };

        renglonesLista.add(pedidoRenglon);
        indice++;        
      }

      final pedidocompleto = {
        'numero': numeroPedidoApi,
        'codigoCliente': pedidoEspera.codigoCliente,
        'totalNeto': pedidoEspera.totalNeto,
        'totalImpuesto': pedidoEspera.totalImpuesto,
        'totalPedido': pedidoEspera.totalPedido,
        'vendedor': pedidoEspera.vendedor,
        //'comentario': pedidoEspera.comentario,
        'comentario': '${pedidoEspera.comentario} / Días de Crédito: ${pedidoEspera.diasCredito}',
        'renglones': renglonesLista,
      };

      final response = await http.post(
        Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/CrearPedido'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pedidocompleto),
      ).timeout(Duration(seconds: 60));

      renglonesLista.clear(); 
      // fin pedido completo
      
      final numeroPedidoEnviado;
      // Verifica si la respuesta no es nula antes de acceder a su cuerpo
      if (response != null) {
        final jsonResponse = json.decode(response.body);

        // Accede al valor nuevoContador de la respuesta JSON
        numeroPedidoEnviado = jsonResponse['nuevoContador'];

      } else {
        numeroPedidoEnviado = '';
      }
      
      //if (response.statusCode == 200 && exitoRenglones == 0) {
      if (response != null && response.statusCode == 200) {
        eliminarPedido(numeroPedido);
        return {'exito': true, 'mensaje': numeroPedidoEnviado};    
      } else {
        return {'exito': false, 'mensaje': ' '};
      }
      
    } else {
      return {'exito': false, 'mensaje': ' '};
    }
  }

  Future<void> refrescarInfo() async {
    bool? hasInternet = await checkInternetConnectivity();

    // Obtiene la fecha actual
    DateTime fechaActual = DateTime.now();

    // Resta un día a la fecha actual
    DateTime fechaMenosUnDia = fechaActual.subtract(Duration(days: 1));

    // Formatea la fecha en el formato deseado
    String fechaFormateada = DateFormat('yyyy-MM-dd HH:mm:ss').format(fechaMenosUnDia);

    // Muestra la fecha formateada
    print('Fecha actual menos un día: $fechaFormateada');


    try {
      if (hasInternet != null && hasInternet){
        await cargaClientes(fechaFormateada);
        await cargaProductos(fechaFormateada);
        await cargaVendedores(fechaFormateada);
      }
      if (hasInternet != null && hasInternet){
        await updateFechaSync();
      }
    } catch (error) {
    }

  }
}

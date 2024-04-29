import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'src/myApp.dart';
import 'src/pages/database_local.dart';

void main() async {
  // Asegura la inicialización de los widgets de Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  

  // Crea una instancia de DatabaseHelper.
  DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // Realiza las operaciones asincrónicas.
  bool? logged = await _databaseHelper.getLogged();
  bool? hasInternet = await _databaseHelper.checkInternetConnectivity();

  // Ahora puedes lanzar tu aplicación.
  runApp(MyApp());

  // Ejecutar las funciones en segundo plano cada 15 segundos.
  Timer.periodic(Duration(seconds: 15), (Timer timer) async {
    if (logged != null && logged) {
      try {
        if (hasInternet != null && hasInternet){
          await _databaseHelper.cargaClientes('carga');
          await _databaseHelper.cargaProductos('carga');
          await _databaseHelper.cargaVendedores('carga');
          await _databaseHelper.validarUsuarioActivo();
        }
        if (hasInternet != null && hasInternet){
          await _databaseHelper.updateFechaSync();
        }
      } catch (error) {
        print("Error durante la sincronización: $error");
      }
    }
  });
}


/*
-- - Pendientes - --

  xx -Fecha Sincronizacion (que no actualice cuando no hay internet)

  xx -Verificacion de internet (la funcion actual revisar si estas conectado a datos o wifi y de ser asi devuelve un true, pero ocasiona error por ejemplo: tengo el wifi encendido pero sin internet en el wifi, entonces la funcion me retorna true pero en realidad deberia retornar false)

  xx -Bloqueo de pantalla al enviar pedido (nuevo pedido y lista de pedidos en espera), actualmente la pantalla se queda en gris pero igual si toco fuera del recuadro del boton ok, entonces se cierra el recuadro y queda un circulo de espera que nunca termina.

-Implementacion de usuario supervisor que vea todos los clientes y todos los pedidos.
 -hay que hacer un modulo de creacion de usuario, mapeo de acceso, cambio de contraseña, entre otros.

*/
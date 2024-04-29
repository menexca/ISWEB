import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'pages/home_page.dart';
import 'pages/clientes_page.dart';
import 'pages/nuevoPedido_page.dart';
import 'pages/productos_page.dart';
import 'pages/login_page.dart';
import 'pages/Pedidos_page.dart' as PedidosPage;
import 'pages/Pedidos_espera_page.dart' as PedidosEsperaPage;
import 'pages/usuarios_page.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF79B42C), // Cambia el color del cursor aquí
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Página de Inicio',
      //initialRoute: 'Login',
      initialRoute: 'Nuevo Pedido',
      routes: <String, WidgetBuilder>{
        'Login': (BuildContext context) => LoginPage(),
        'Inicio': (BuildContext context) => HomePage(),
        'Clientes': (BuildContext context) => ClientesPage(),
        'Productos': (BuildContext context) => ProductosPage(),
        'Nuevo Pedido': (BuildContext context) => NuevoPedidoPage(),
        'Lista De Pedidos': (BuildContext context) => PedidosPage.PedidosPage(),
        'Pedidos En Espera': (BuildContext context) => PedidosEsperaPage.PedidosPage(),
        'Usuario(s)': (BuildContext context) => UsuariosPage(),
      },
    );
  }
}
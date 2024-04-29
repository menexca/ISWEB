import 'package:flutter/material.dart';
import 'class/usuario.dart'; // Importa la clase Vendedor desde el archivo vendedor.dart
import 'database_local.dart';

class DrawerWidget extends StatelessWidget {
  final List<String> opciones = ['Inicio', 'Clientes', 'Productos', 'Nuevo Pedido','Lista De Pedidos','Pedidos En Espera','Usuario(s)'];
  final Usuario selectedUsuario;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  
  DrawerWidget({required this.selectedUsuario});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: 
                DrawerHeader(
                  decoration: BoxDecoration(
                    //color: Colors.blue,
                    color: Color(0xFF79B42C),
                  ),
                  child: Text(
                    'Menú',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var opcion in opciones)
                  ListTile(
                    title: Text(opcion),
                    onTap: () {
                      Navigator.pushNamed(context, opcion, arguments: selectedUsuario);
                    },
                  ),
              ],
            ),
          ),
          ListTile(
            title: Text('Cerrar Sesión'),
            onTap: () async {
              // Llama al método cerrarSesion de DatabaseHelper para cerrar la sesión
              await _databaseHelper.updateLogout();

              // Navega a la página de inicio de sesión (LoginPage) y elimina todas las rutas anteriores de la pila de navegación
              Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
            },
          ),
          // Divider(
          //   height: 1,
          //   color: Colors.grey,
          // ),
          Row(
            children: [
              Expanded(
                child: 
                Container(
                  //color: Colors.lightBlue[800], // Cambia el color de fondo aquí
                  color: Color(0xFF79B42C),
                  height: 24, // Puedes ajustar la altura a la que desees
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '     Version: 1.0.1',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white, // Cambia el color del texto aquí
                        ),
                      ),
                    ],
                  ), 
                )
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}

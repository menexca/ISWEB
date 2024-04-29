import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'class/vendedor.dart'; // Importa la clase Vendedor desde el archivo vendedor.dart
import 'dart:async';
// import 'package:path/path.dart' as path;
// import 'package:sqflite/sqflite.dart' as sqflite;

import 'class/usuario.dart'; // Importa la clase Usuario desde el archivo vendedor.dart
import 'database_local.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  //List<Vendedor> _vendedores = [];
  //List<Vendedor> _vendedoresdb = [];
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosdb = [];
  Vendedor? selectedVendedor;
  Usuario? savedVendedor;
  //late sqflite.Database _database;
  DatabaseHelper _databaseHelper = DatabaseHelper();

  

  @override
  void initState() {
    super.initState();
    //_createDatabase();
    saltoInicio();
    _loadUsuarios();
    /*
    _userController.text='amogollon';
    _passwordController.text='123';
    login();
    */
  }
  
  Future<void> saltoInicio() async {
    savedVendedor = await _databaseHelper.getUsuarioObj(); 
    bool? logged = await _databaseHelper.getLogged();

    if (logged != null && logged) {
      Navigator.pushReplacementNamed(
        context,
        'Inicio',
        arguments: savedVendedor,
      );
    }
  }

  Future<void> _loadUsuarios() async {
    try {
      final response = await http.get(Uri.parse(
          'https://nodejs-mysql-railway-blanking-production.up.railway.app/usuarios'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List<Usuario> usuarios = [];
        for (var usuarioData in data) {
          Usuario usuario = Usuario(
            usuario: usuarioData['Usuario'].toLowerCase().trim(),
            contrasena: usuarioData['Contrasena'],
            nombreCompleto: usuarioData['NombreCompleto'],
            correoElectronico: usuarioData['CorreoElectronico'],
            fechaRegistro: DateTime.parse(usuarioData['FechaRegistro'].toString()),
            ultimoInicioSesion: DateTime.parse(usuarioData['UltimoInicioSesion'].toString()),
            rol: usuarioData['Rol'],
            estatus: int.parse(usuarioData['Estatus'].toString()),
            codigoVendedor: usuarioData['CodigoVendedor'],
            fechaNacimiento: DateTime.parse(usuarioData['FechaNacimiento'].toString()),
            direccion: usuarioData['Direccion'],
            numeroTelefono: usuarioData['NumeroTelefono'],
            cedula: usuarioData['Cedula'],
          );

          // Guardar el vendedor en la base de datos
          await _databaseHelper.insertUsuario(usuario);

          usuarios.add(usuario);
        }

        setState(() {
          _usuarios = usuarios;
        });
      } else {
        throw Exception('Failed to fetch Usuarios');
      }
    } catch (error) {
      print('Error al cargar los usuariosss: $error');
      List<Usuario> usuarios = await _databaseHelper.getUsuarios();
      setState(() {
        _usuarios = usuarios;
      });
    }
  }


  void login() async {
    //if (_formKey.currentState!.validate()) {
    
      String user = _userController.text;
      user = user.toLowerCase().trim();
      String password = _passwordController.text;
      print('print entre al login');
      Usuario usuarioEncontrado = await _databaseHelper.getUsuarioSeleccionado(user);


      print('print despues buscar el usuario, $user ,,,, ${usuarioEncontrado.usuario}');
      print('print despues revisar pw, ${usuarioEncontrado.contrasena}');
      if (usuarioEncontrado.estatus != 0) {
        //if (selectedVendedor != null && selectedVendedor!.nit == password) {
        if (usuarioEncontrado.contrasena == password) {
          showDialog(
            context: context,
            barrierDismissible: false, // Impide cerrar el diálogo al hacer clic fuera de él
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Inicio de sesión'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Cargando clientes...'), 
                    Text('Cargando productos...'), 
                  ],
                ),
              );
            },
          );

          try {
            // Llama a Actualiza VendedorActual
            await _databaseHelper.updateVendedorActual(usuarioEncontrado.codigoVendedor);
            // Llama a Actualiza UsuarioActual
            await _databaseHelper.updateUsuarioActual(usuarioEncontrado.usuario);

            try {
              // Llama a cargaClientes
              await _databaseHelper.cargaInicialClientes();
              // Llama a cargaProductos
              await _databaseHelper.cargaInicialProductos();
              // Llama a cargaInicialVendedores
              await _databaseHelper.cargaInicialVendedores();
              // Actualiza FechaSync
              await _databaseHelper.updateFechaSync();
            } catch (error) {
            }
            
            await _databaseHelper.updateLogged();

          } catch (error) {
          }
          

          // Cerrando el diálogo
          Navigator.of(context).pop();

          // Redirigir a la página principal de la aplicación
          Navigator.pushReplacementNamed(
            context,
            'Inicio',
            arguments: usuarioEncontrado,
          );
        } else {
          // Credenciales inválidas
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Inicio de sesión fallido'),
                content: Text('${usuarioEncontrado.usuario} la contraseña es incorrecta.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Inicio de sesión fallido'),
              content: Text('${user} usuario no registrado / suspendido'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo-login.jpg'), // Reemplaza 'fondo.jpg' con el nombre de tu imagen
            fit: BoxFit.cover, // Ajusta la imagen para cubrir todo el área del fondo
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black.withOpacity(0.45),
                    //color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    //padding: const EdgeInsets.all(24.0),
                    padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //SizedBox(height: 96.0),
                        Image.asset(
                          'assets/images/Inv_A_las_Rocas.png',
                          height: 146, // ajusta la altura de la imagen según tus necesidades
                          width: 303, // ajusta el ancho de la imagen según tus necesidades                          
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xFF79B42C),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 24.0,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                //width: 32.0,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  //borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.only(left: 12.0),
                                child: TextFormField(
                                  controller: _userController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'Usuario',
                                    labelStyle: TextStyle(
                                      fontSize: 18, 
                                      color: Colors.black, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold), // Cambia el tamaño, color y negrita del texto ingresado
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Por favor, ingresa tu usuario';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xFF79B42C),
                              ),
                              child: Icon(
                                Icons.lock,
                                size: 24.0,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                //width: 32.0,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  //borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.only(left: 12.0),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    labelStyle: TextStyle(
                                      fontSize: 18, 
                                      color: Colors.black, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold), // Cambia el tamaño, color y negrita del texto ingresado
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Por favor, ingresa tu contraseña';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: login,
                          child: Text('Iniciar sesión',
                            style: TextStyle(
                              fontSize: 18, 
                              color: Colors.white, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Cambia el color de fondo
                            // Otros atributos visuales aquí, si los deseas
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),  
      ),
    );
  }
}
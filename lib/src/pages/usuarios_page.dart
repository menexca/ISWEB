import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'usuarios_editar_page.dart';
import 'usuarios_nuevo_page.dart';
import 'class/usuario.dart'; // Importa la clase Usuario desde el archivo usuario.dart
import 'drawer_widget.dart'; // Importa el archivo drawer_widget.dart
import 'class/pedidoclass.dart'; // Importa la clase Pedido desde el archivo pedidoclass.dart

class UsuariosPage extends StatelessWidget {
  //final List<String> opciones = ['Inicio', 'Clientes', 'Productos', 'Nuevo Pedido','Lista De Pedidos','Pedidos En Espera']; // Opciones del menú

  @override
  Widget build(BuildContext context) {
    final selectedUsuario = ModalRoute.of(context)?.settings.arguments as Usuario;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBar
        title: Text('Listado De Usuarios'),
      ),
      drawer: DrawerWidget(selectedUsuario: selectedUsuario), // Utiliza el DrawerWidget aquí
      body: UsuariosList(usuario: selectedUsuario.usuario, rol: selectedUsuario.rol)
    );
  }
}


class UsuariosList extends StatefulWidget {
  final String usuario;
  final String rol;

  UsuariosList({required this.usuario, required this.rol});
  
  @override
  _UsuariosListState createState() => _UsuariosListState();
}

class _UsuariosListState extends State<UsuariosList> {
  List<Usuario> _usuarios = [];
  List<Usuario> _searchedUsuarios = [];
  TextEditingController _searchController = TextEditingController();
  List<Usuario> usuariosList = [];
  late Future<void> _fetchUsuariosFuture;

  @override
  void initState() {
    super.initState();
    //_fetchUsuarios(widget.rol, widget.usuario);
    _fetchUsuariosFuture = _fetchUsuarios(widget.usuario, widget.rol);
  }


  Future<void> _fetchUsuarios(String usuario, String rol) async {
  final response;
  _usuarios.clear();
  _searchedUsuarios.clear();
  //print('${rol} errrr');
  if (rol != 'Gerente') {
    response = await http.get(
      Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/Usuarios/$usuario')
    );
    print('captura filtrada');
  } else {
    response = await http.get(
      Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/Usuarios')
    );
    print('captura todos');
  }

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    //print('entra con exito -   ');
    for (dynamic usuarios in data) {
      Usuario usuarioo = Usuario(
        usuario: usuarios['Usuario'].toString(),
        contrasena: usuarios['Contrasena'].toString(),
        nombreCompleto: usuarios['NombreCompleto'].toString(),
        correoElectronico: usuarios['CorreoElectronico'].toString(),
        fechaRegistro: DateTime.parse(usuarios['FechaRegistro']),
        ultimoInicioSesion: DateTime.parse(usuarios['UltimoInicioSesion']),
        rol: usuarios['Rol'].toString(),
        estatus: usuarios['Estatus'],
        codigoVendedor: usuarios['CodigoVendedor'].toString(),
        fechaNacimiento: DateTime.parse(usuarios['FechaNacimiento']),
        direccion: usuarios['Direccion'].toString(),
        numeroTelefono: usuarios['NumeroTelefono'].toString(),
        cedula: usuarios['Cedula'].toString(),
      );
      //print('despues de revisar el usuario');
      usuariosList.add(usuarioo);
      //print('agrega usuario ${usuarioo.codigoVendedor}');
    }

    setState(() {
      _usuarios = usuariosList;
      _searchedUsuarios = usuariosList;
      print('actualiuzo el set state');
    });
  } else {
    throw Exception('Failed to fetch Usuarios');
  }
}

  void _search(String query) {
    setState(() {
      _searchedUsuarios = _usuarios
          .where((user) => user.nombreCompleto.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _openEditarUsuarioPage(Usuario user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarUsuarioPage(usuario: user), // Pasar el usuario seleccionado
      ),
    );

    if (result == 'Actualizado') {
      // Realiza la lógica para actualizar la lista de usuarios
      _fetchUsuarios(widget.usuario, widget.rol);
    }    
  }

  Widget _buildUsuariosList() {
    return FutureBuilder(
      future: _fetchUsuariosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // La llamada HTTP ha terminado, ahora puedes construir la lista
          return _usuarios.isNotEmpty
              ? _buildUsuariosListWidget()
              : Center(child: Text('No se encontraron usuarios'));
        } else if (snapshot.hasError) {
          // Ocurrió un error durante la llamada HTTP
          return Center(child: Text('Error al cargar usuarios'));
        } else {
          // La llamada HTTP está en progreso
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildUsuariosListWidget() {
    // ... el código de tu función _buildUsuariosList actualizado ...
    return ListView.builder(
      //controller: _scrollController,
      itemCount: _searchedUsuarios.length,
      itemBuilder: (BuildContext context, int index) {
        
        Usuario user = _searchedUsuarios[index];

        return GestureDetector(
        onTap: () {
          setState(() {
            for (Usuario usuarios in _usuarios){
              usuarios.visibilidadBoton=false;
            }
            user.visibilidadBoton=true;
          });
        },
        child: ListTile(
            //title: Text(user['Nombre - ${widget.codigoVendedor}']),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('dd/MM/yyyy hh:mm a').format(user.fechaRegistro)}',
                      style: TextStyle(
                        fontSize: 16, // Tamaño de fuente deseado
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                Text(
                  '${user.usuario}',
                  style: TextStyle(
                    fontSize: 20, // Tamaño de fuente deseado
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ), 
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre:      ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            '${user.nombreCompleto}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendedor:        ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${user.codigoVendedor}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rol:  ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Estatus:  ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${user.rol}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${user.estatus==1 ? 'Activo' : 'Inactivo'}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cedula: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Telefono: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${user.cedula}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${user.numeroTelefono}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 3),
                user.visibilidadBoton
                ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _openEditarUsuarioPage(user);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Editar Información ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            Icons.list_alt_rounded,
                            color: Color(0xFF79B42C),
                          ),
                        ],  
                      ),
                    ),
                  ],
                )
                :
                SizedBox(height: 1),
                SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: Colors.black,
                ),
                SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                labelStyle: TextStyle(
                  color: Colors.grey, 
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                ),
              ),
            ),
          ),
          Expanded(child: _buildUsuariosList()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CrearUsuarioPage(),
                  ),
                );

                if (result == 'actualizado') {
                  // Realiza la lógica para actualizar la lista de usuarios
                  _fetchUsuarios(widget.usuario, widget.rol);
                }
                  /*
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearUsuarioPage(),
                    ),
                  );
                  */
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.black,
              ),

              FloatingActionButton(
                onPressed: () => _fetchUsuarios(widget.usuario, widget.rol),
                child: Icon(Icons.refresh),
                backgroundColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
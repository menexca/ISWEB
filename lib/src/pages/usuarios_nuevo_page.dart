import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'class/vendedorSimple.dart';

class CrearUsuarioPage extends StatefulWidget {
  @override
  _CrearUsuarioPageState createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _nombreCompletoController = TextEditingController();
  final _correoElectronicoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _numeroTelefonoController = TextEditingController();
  final _cedulaController = TextEditingController();
  String _selectedRol = 'Gerente';
  Vendedor? _selectedCodigoVendedor;
  List<Vendedor> _vendedores = [];
  Vendedor? _selectedSupervisadoPor;
  List<Vendedor> _supervisores = [];
  

  @override
  void initState() {
    super.initState();
    _fetchVendedores();
    _fetchSupervisores();
  }

  Future<void> _fetchVendedores() async {
    final response = await http.get(Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/VendedoresDisponibles'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {

        for (dynamic vendedoresList in data) {
          Vendedor vendedor = Vendedor(
            codigoVendedor: vendedoresList['codigo'].toString(),
            nombre: vendedoresList['nombre'].toString(),
            zona: vendedoresList['Zona'].toString(),
            almacen: vendedoresList['Almacen'].toString(),
            rif: vendedoresList['rif'].toString(),
            nit: vendedoresList['nit'].toString(),
            supervisadoPor: vendedoresList['supervisadoPor'].toString(),
          );
          _vendedores.add(vendedor);
          print(vendedor.codigoVendedor);
        }
      });
    } else {
      throw Exception('Failed to fetch Vendedores');
    }
  }


  void _saveUsuario() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> newUser = {
        'usuario': _usuarioController.text,
        'contrasena': _contrasenaController.text,
        'nombreCompleto': _nombreCompletoController.text,
        'correoElectronico': _correoElectronicoController.text,
        'rol': _selectedRol,
        'codigoVendedor': _selectedRol == 'Gerente' ? 'T' : _selectedCodigoVendedor!.codigoVendedor,
        'direccion': _direccionController.text,
        'numeroTelefono': _numeroTelefonoController.text,
        'cedula': _cedulaController.text,
        'supervisadoPor': _selectedSupervisadoPor?.codigoVendedor ?? ' ',
      };

      // Realiza la solicitud POST para guardar el nuevo usuario en el servidor
      final response = await http.post(
        Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/Usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newUser),
      );

      if (response.statusCode == 200) {
        // Cerrar la página y regresar a la anterior
        Navigator.pop(context, true);
      } else {
        // Manejar el error en caso de que la solicitud no sea exitosa
        print('Error al guardar el usuario');
      }
    }
  }

  Future<void> _fetchSupervisores() async {
    final response = await http.get(Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/SupervisoresDisponibles'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        for (dynamic vendedoresList in data) {
          Vendedor vendedor = Vendedor(
            codigoVendedor: vendedoresList['codigo'].toString(),
            nombre: vendedoresList['nombre'].toString(),
            zona: vendedoresList['Zona'].toString(),
            almacen: vendedoresList['Almacen'].toString(),
            rif: vendedoresList['rif'].toString(),
            nit: vendedoresList['nit'].toString(),
            supervisadoPor: vendedoresList['SupervisadoPor'].toString(),
          );
          _supervisores.add(vendedor);
          //print(vendedor.codigoVendedor);
        }
      });
    } else {
      throw Exception('Failed to fetch Vendedores');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBar
        title: Text('Crear Nuevo Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contrasenaController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contraseña';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nombreCompletoController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre';
                  }
                  return null;
                },
              ),
              // ... Otros campos de texto y selección aquí

              // Dropdown para seleccionar el rol
              DropdownButtonFormField<String>(
                value: _selectedRol,
                items: ['Gerente', 'Supervisor', 'Vendedor'].map((rol) {
                  return DropdownMenuItem<String>(
                    value: rol,
                    child: Text(rol),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRol = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Rol',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
              ),

              // Dropdown para seleccionar el vendedor
              if (_selectedRol != 'Gerente')
                DropdownButtonFormField<Vendedor>(
                  value: _selectedCodigoVendedor,
                  items: _vendedores.map((vendedor) {
                    return DropdownMenuItem<Vendedor>(
                      value: vendedor,
                      child: 
                      Row(
                        children: [
                          Text('${vendedor.codigoVendedor} - ${vendedor.nombre}')
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCodigoVendedor = newValue;
                    });
                  },
                  decoration: InputDecoration(
                  labelText: 'Código de Vendedor',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
                ),
              
              // Campos de texto adicionales
              TextFormField(
                controller: _cedulaController,
                decoration: InputDecoration(
                  labelText: 'Cédula',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ' ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ' ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numeroTelefonoController,
                decoration: InputDecoration(
                  labelText: 'Número de Teléfono',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ' ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correoElectronicoController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: TextStyle(
                    color: Colors.grey, 
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ' ';
                  }
                  return null;
                },
              ),
              if (_selectedRol == 'Vendedor')
                DropdownButtonFormField<Vendedor>(
                  /*
                  value: _supervisores.firstWhere(
                    (vendedor) => vendedor.codigoVendedor == _selectedCodigoVendedor32.first.supervisadoPor,                     
                    orElse: () => primerElemento
                  ),
                  */
                  value: _selectedSupervisadoPor,
                  items: _supervisores.map((vendedor) {
                    return DropdownMenuItem<Vendedor>(
                      value: vendedor,
                      child: 
                      Row(
                        children: [
                          Text('${vendedor.codigoVendedor} - ${vendedor.nombre}')
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSupervisadoPor = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Código de Supervisor',
                    labelStyle: TextStyle(
                      color: Colors.grey, 
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                    ),
                  ),
                ),

              ElevatedButton( 
                onPressed: _saveUsuario,
                child: Text('Guardar'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF79B42C)), // Cambia el color del fondo del botón
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'class/usuario.dart';
import 'class/vendedorSimple.dart';

class EditarUsuarioPage extends StatefulWidget {
  final Usuario usuario;

  EditarUsuarioPage({required this.usuario});

  @override
  _EditarUsuarioPageState createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  late TextEditingController contrasenaController;
  late TextEditingController nombreCompletoController;
  late TextEditingController correoElectronicoController;
  //late TextEditingController fechaNacimientoController;
  late TextEditingController direccionController;
  late TextEditingController numeroTelefonoController;
  late TextEditingController cedulaController;
  Vendedor? _selectedCodigoVendedor;
  List<Vendedor> _selectedCodigoVendedor22 = [];
  List<Vendedor> _selectedCodigoVendedor32 = [];
  List<Vendedor> _supervisores = [];
  Vendedor primerElemento = Vendedor(
            codigoVendedor:' ',
            nombre:' ',
            zona:' ',
            almacen:' ',
            rif:' ',
            nit:' ',
            supervisadoPor:' ',
          );

  @override
  void initState() {
    super.initState();
    contrasenaController = TextEditingController(text: widget.usuario.contrasena);
    nombreCompletoController = TextEditingController(text: widget.usuario.nombreCompleto);

    correoElectronicoController = TextEditingController(
      text: widget.usuario.correoElectronico == '' ? ' ' : widget.usuario.correoElectronico,
    );
    direccionController = TextEditingController(
      text: widget.usuario.direccion == '' ? ' ' : widget.usuario.direccion,
    );
    numeroTelefonoController = TextEditingController(
      text: widget.usuario.numeroTelefono == '' ? ' ' : widget.usuario.numeroTelefono,
    );
    cedulaController = TextEditingController(
      text: widget.usuario.cedula == '' ? ' ' : widget.usuario.cedula,
    );
    
    //fechaNacimientoController = TextEditingController(text: widget.usuario.fechaNacimiento.toString());
    //direccionController = TextEditingController(text: widget.usuario.direccion);
    //numeroTelefonoController = TextEditingController(text: widget.usuario.numeroTelefono);
    //cedulaController = TextEditingController(text: widget.usuario.cedula);
    //await _fetchVendedores(widget.usuario.codigoVendedor);
    _fetchSupervisores();
    _fetchVendedores();
  }

  Future<void> _guardarCambios() async {
    final usuarioActualizado = {
      //'usuario': widget.usuario.usuario,
      'contrasena': contrasenaController.text,
      'nombreCompleto': nombreCompletoController.text,
      'correoElectronico': correoElectronicoController.text,
      'rol': widget.usuario.rol,
      'estatus': widget.usuario.estatus,
      'codigoVendedor': widget.usuario.codigoVendedor,
      //'fechaNacimiento': DateTime.parse(fechaNacimientoController.text),
      'direccion': direccionController.text,
      'numeroTelefono': numeroTelefonoController.text,
      'cedula': cedulaController.text,
      'supervisadoPor': _selectedCodigoVendedor?.codigoVendedor ?? ' ',
    };

    //print(usuarioActualizado);
    final response = await http.put( 
      Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/Usuarios/${widget.usuario.usuario}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(usuarioActualizado),
    );

    if (response.statusCode == 200) {
      // Cambios guardados exitosamente
      Navigator.pop(context, 'Actualizado');
    } else {
      // Manejo del error en caso de que la solicitud falle
      print('Error al guardar cambios: ${response.statusCode}');
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

  Future<void> _fetchVendedores() async {
    String codigoVendedor =widget.usuario.codigoVendedor;
    print('${codigoVendedor} aaaaaaaaaa');
    final response = await http.get(Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/VendedoresEspecifico/$codigoVendedor'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print('entra con exito -   ');
      //print('${data} // - - -- - -- - --- sdasd');
      for (dynamic dataVendedores in data) {
        Vendedor vendedor = Vendedor(
          codigoVendedor: dataVendedores['codigo'].toString(),
          nombre: dataVendedores['nombre'].toString(),
          zona: dataVendedores['Zona'].toString(),
          almacen: dataVendedores['Almacen'].toString(),
          rif: dataVendedores['rif'].toString(),
          nit: dataVendedores['nit'].toString(),
          supervisadoPor: dataVendedores['SupervisadoPor'].toString(),
        );
        //print('despues de revisar el usuario');
        _selectedCodigoVendedor22.add(vendedor);
        //print('agrega vendedor seleccionado ${vendedor.codigoVendedor}');
      }

      setState(() {
        _selectedCodigoVendedor32 = _selectedCodigoVendedor22;
        procesarLista(_selectedCodigoVendedor22);
      });
    } else {
      throw Exception('Failed to fetch Vendedor especifico');
    }
  }

  void procesarLista(List<Vendedor> miLista) {
    if (miLista.isNotEmpty) {
      primerElemento = miLista.first;
      // Resto del código que deseas ejecutar con el primer elemento
      //print('El primer elemento es: $primerElemento');

    } else {
      print('La lista está vacía.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBar
        title: Text('Editar información de usuario'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: contrasenaController,
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                labelStyle: TextStyle(
                  color: Colors.grey, 
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                ),
              ),
              obscureText: true,
            ),
            TextField(
              controller: nombreCompletoController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                labelStyle: TextStyle(
                  color: Colors.grey, 
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                ),
              ),
            ),
            TextField(
              controller: correoElectronicoController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                labelStyle: TextStyle(
                  color: Colors.grey, 
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                ),
              ),
            ),
            TextField(
              controller: direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                labelStyle: TextStyle(
                  color: Colors.grey, 
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                ),
              ),
            ),
            TextField(
              controller: numeroTelefonoController,
              decoration: InputDecoration(
                labelText: 'Número de Teléfono',
                labelStyle: TextStyle(
                  color: Colors.grey, 
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                ),
              ),
            ),
            TextField(
              controller: cedulaController,
              decoration: InputDecoration(
                labelText: 'Cédula',
                labelStyle: TextStyle(
                  color: Colors.grey, 
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                ),
              ),
            ),
            if (widget.usuario.rol == 'Vendedor')
              DropdownButtonFormField<Vendedor>(
                value: _supervisores.firstWhere(
                  (vendedor) => vendedor.codigoVendedor == _selectedCodigoVendedor32.first.supervisadoPor,                     
                  orElse: () => primerElemento
                ),
                
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
                    _selectedCodigoVendedor = newValue;
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
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: Text('Guardar'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF79B42C)), // Cambia el color del fondo del botón
              ),
            ),              
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    contrasenaController.dispose();
    nombreCompletoController.dispose();
    correoElectronicoController.dispose();
    //fechaNacimientoController.dispose();
    direccionController.dispose();
    numeroTelefonoController.dispose();
    cedulaController.dispose();
    super.dispose();
  }
}

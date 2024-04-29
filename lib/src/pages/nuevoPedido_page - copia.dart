import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NuevoPedidoPage extends StatelessWidget {
  final List<String> opciones = ['Inicio', 'Clientes', 'Productos', 'Nuevo Pedido']; // Opciones del menú

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Nuevo Pedido'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            for (var opcion in opciones)
              ListTile(
                title: Text(opcion),
                onTap: () {
                  Navigator.pushNamed(context, opcion);
                },
              ),
          ],
        ),
      ),
      body: PedidoForm()
    );
  }
}


class PedidoForm extends StatefulWidget {
  @override
  _PedidoFormState createState() => _PedidoFormState();
}

class _PedidoFormState extends State<PedidoForm> {
  TextEditingController _codigoClienteController = TextEditingController();
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _totalPedidoController = TextEditingController();

  DateTime _selectedDate = DateTime.now(); // Fecha de emisión por defecto

  Future<void> _submitPedido() async {
    final pedido = {
      'CodigoCliente': _codigoClienteController.text,
      'Numero': _numeroController.text,
      'FechaEmision': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'Cantidad': double.parse(_totalPedidoController.text),
    };

    print(pedido);

    final response = await http.post(
      Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/pedidos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(pedido),
    );

    if (response.statusCode == 200) {
      // Pedido enviado exitosamente
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pedido enviado'),
            content: Text('El pedido se ha enviado correctamente.'),
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
    } else {
      // Error al enviar el pedido
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Ocurrió un error al enviar el pedido.'),
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
      appBar: AppBar(
        title: Text('Formulario de Pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codigoClienteController,
              decoration: InputDecoration(labelText: 'Código de Cliente'),
              maxLength: 20,
            ),
            TextField(
              controller: _numeroController,
              decoration: InputDecoration(labelText: 'Número de Pedido'),
              maxLength: 12,
            ),
            TextField(
              controller: _totalPedidoController,
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPedido,
              child: Text('Enviar Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}

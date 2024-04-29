import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'class/clienteIS.dart'; // Importa la clase Cliente desde el archivo cliente.dart
import 'database_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientesPage extends StatelessWidget {
  ClientesPage();  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4E73DF), // Cambia el color de la AppBar
        title: Text('Selección de Clientes'),
      ),
      body: CustomerList()
      //body: CustomerList()
    );
  }
}

class CustomerList extends StatefulWidget {
  CustomerList();
  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  //List<dynamic> _customers = [];
  //List<dynamic> _searchedCustomers = [];
  List<Cliente> _searchedCustomers = [];
  TextEditingController _searchController = TextEditingController();
  List<Cliente> _clientesdb = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  dynamic _selectedCustomer;

  void _selectCustomer(dynamic customer) {
    setState(() {
      _selectedCustomer = customer;
    });
  }

  @override
  void initState() {
    super.initState();
    //_fetchCustomers(widget.codigoVendedor);
    cargaInicialClientes();
  }

  Future<void> cargaInicialClientes() async {
    List<Cliente> clientes = [];
    
    try {
      final response = await http.get(Uri.parse(
        'https://proyectois-production.up.railway.app/Clientes',
      ));

      print(response.statusCode);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        for (var clienteData in data) {
          Cliente cliente = Cliente(
            usuario: clienteData['Usuario'],
            nombre: clienteData['Nombre'],
            estatus: clienteData['Estatus'],
            edad: clienteData['Edad'],
            genero: clienteData['Genero'],
          );

          clientes.add(cliente);
        }

        // Puedes retornar la lista de clientes si lo deseas
        // return clientes;
      } else {
        throw Exception('Failed to fetch clientes');
      }
    } catch (error) {
      print('Error al cargar los clientess ISIS: $error');
    }

    setState(() {
      _clientesdb = clientes;
      _searchedCustomers = _clientesdb;
    });
  }

  void _search(String query) {
    setState(() {
      _searchedCustomers = _clientesdb
          .where((clienteLista) => clienteLista.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


  Widget _buildCustomerList() {
    return ListView.builder(
      //controller: _scrollController,
      itemCount: _searchedCustomers.length,
      itemBuilder: (BuildContext context, int index) {
        
        final Cliente clienteLista = _searchedCustomers[index];

        return GestureDetector(
        onTap: () {
          _selectCustomer(clienteLista);
          Navigator.pop(context, clienteLista); // Retorna el cliente seleccionado
        },
        child: ListTile(
            //title: Text(customer['Nombre - ${widget.codigoVendedor}']),
            title: Text(
              '${clienteLista.usuario} / ${clienteLista.nombre}',
              style: TextStyle(
                fontSize: 18, // Tamaño de fuente deseado
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Estatus: ${clienteLista.estatus == 1 ? 'Activo' : 'Inactivo'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      child: Text(
                        'Edad: ${clienteLista.edad}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      child: Text(
                        'Genero: ${clienteLista.genero == 'F' ? 'Femenino' : 'Masculino'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
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
                  borderSide: BorderSide(color: Color(0xFF4E73DF)), // Cambia el color del borde cuando está seleccionado
                ),
              ),
            ),
          ),
          Expanded(child: _buildCustomerList()),
        ],
      ),
    );
  }
}

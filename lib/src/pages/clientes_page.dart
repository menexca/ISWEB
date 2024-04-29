import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'drawer_widget.dart'; // Importa el archivo drawer_widget.dart
import 'class/cliente.dart'; // Importa la clase Cliente desde el archivo vendedor.dart
import 'class/usuario.dart'; // Importa la clase Usuario desde el archivo usuario.dart
import 'database_local.dart';


class ClientesPage extends StatelessWidget {
  final List<String> opciones = ['Inicio', 'Clientes', 'Productos', 'Nuevo Pedido','Lista De Pedidos','Pedidos En Espera']; // Opciones del menú
//Vendedor
  @override
  Widget build(BuildContext context) {
    final selectedUsuario = ModalRoute.of(context)?.settings.arguments as Usuario;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBar
        title: Text('Página de Clientes'),
      ),
      drawer: DrawerWidget(selectedUsuario: selectedUsuario), // Utiliza el DrawerWidget aquí
      body: CustomerList(codigoVendedor: selectedUsuario.codigoVendedor)
    );
  }
}


class CustomerList extends StatefulWidget {
  final String codigoVendedor;

  CustomerList({required this.codigoVendedor});
  
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

  @override
  void initState() {
    super.initState();
    //_fetchCustomers(widget.codigoVendedor);
    _loadClientesdb();
  }

  Future<void> _loadClientesdb() async {
    List<Cliente> clientes = await _databaseHelper.getClientes();

    setState(() {
      _clientesdb = clientes;
      _searchedCustomers = clientes;
    });
  }

  void _search(String query) {
    setState(() {
      _searchedCustomers = _clientesdb
          .where((clienteLista) => clienteLista.nombreBusqueda.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
 
  Widget _buildCustomerList() {
    return ListView.builder(
      //controller: _scrollController,
      itemCount: _searchedCustomers.length,
      itemBuilder: (BuildContext context, int index) {

        final Cliente clienteLista = _searchedCustomers[index];

        return ListTile(
          //title: Text(customer['Nombre - ${widget.codigoVendedor}']),
          title: Text(
            clienteLista.nombre,
            style: TextStyle(
              fontSize: 18, // Tamaño de fuente deseado
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              
              Row(children: [
                  Text(
                    'Código/RIF:     ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${clienteLista.codigoCliente}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dirección:         ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          '${clienteLista.direccion}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(children: [
                  Text(
                    'Teléfono(s):      ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${clienteLista.telefonos}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
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
                        'Saldo:  ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        'Vencido:  ',
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
                        '${clienteLista.saldoMonedaTotal}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${clienteLista.saldoMonedaVencido}',
                        style: TextStyle(
                          fontSize: 16,
                          color: clienteLista.saldoMonedaVencido > 0 ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Limite de Crédito: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        'Próximo Vencer: ',
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
                        '${clienteLista.limiteCredito.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${clienteLista.proximoVencer}',
                        style: TextStyle(
                          fontSize: 16,
                          color: clienteLista.proximoVencer < 0
                              ? Colors.red
                              : clienteLista.proximoVencer == 0
                                  ? Colors.grey[600]
                                  : Colors.green,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha Último Pago:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(clienteLista.ultimoPago)}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.right,
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
          Expanded(child: _buildCustomerList()),
        ],
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () => _loadClientesdb(),
        child: Icon(Icons.refresh),
        backgroundColor: Colors.black,
      ),
      */
    );
  }
}

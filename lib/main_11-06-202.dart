import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List',
      home: ProductList(),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String _selectedOption = 'Productos';
  List<dynamic> _products = [];
  List<dynamic> _customers = [];
  List<dynamic> _searchedProducts = [];
  List<dynamic> _searchedCustomers = [];
  List<dynamic> _invoices = [];
  List<dynamic> _orders = [];
  int _selectedCustomerIndex = -1;
  TextEditingController _searchController = TextEditingController();
  dynamic _selectedCustomer; // Variable para almacenar el cliente seleccionado

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCustomers();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('https://nodejs-mysql-railway-production-3789.up.railway.app/productos'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _products = data;
      });
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  Future<void> _fetchCustomers() async {
    final response = await http.get(Uri.parse('https://nodejs-mysql-railway-production-3789.up.railway.app/clientes'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _customers = data;
      });
    } else {
      throw Exception('Failed to fetch customers');
    }
  }

  Future<void> _fetchInvoices(String customerId) async {
    final response = await http.get(Uri.parse('https://nodejs-mysql-railway-production-3789.up.railway.app/facturas'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _invoices = data.where((invoice) => invoice['CodigoCliente'] == customerId).toList();
      });
    } else {
      throw Exception('Failed to fetch invoices');
    }
  }

  Future<void> _fetchOrders(String customerId) async {
    final response = await http.get(Uri.parse('https://nodejs-mysql-railway-production-3789.up.railway.app/pedidos'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _orders = data.where((order) => order['CodigoCliente'] == customerId).toList();
      });
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  void _search(String query) {
    if (_selectedOption == 'Productos') {
      setState(() {
        _searchedProducts = _products.where((product) =>
            product['Nombre'].toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    } else if (_selectedOption == 'Clientes') {
      setState(() {
        _searchedCustomers = _customers.where((customer) =>
            customer['Nombre'].toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    }
  }

  Widget _buildProductList() {
    final products = _searchedProducts.isEmpty ? _products : _searchedProducts;

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        final product = products[index];
        return ListTile(
          title: Text(product['Nombre']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Precio: ${product['PrecioMoneda']}'),
              Text('Existencia: ${product['existencia']}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerList() {
    final customers = _searchedCustomers.isEmpty ? _customers : _searchedCustomers;

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (BuildContext context, int index) {
        final customer = customers[index];
        final isSelected = customer == _selectedCustomer;

        return ListTile(
          title: Text(customer['Nombre']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo: ${customer['SaldoMonedaTotal']}'),
              Text('Vencido: ${customer['SaldoMonedaVencido']}'),
              Text('Fecha Ultimo Pago: ${customer['ultimopago']}'),
            ],
          ),
          tileColor: isSelected ? Colors.blue[100] : null,
          onTap: () async {
            await _fetchInvoices(customer['CodigoCliente']);
            await _fetchOrders(customer['CodigoCliente']);
            setState(() {
              _selectedCustomer = customer;
              _selectedCustomerIndex = index;
            });
          },
        );
      },
    );
  }

  Widget _buildInvoiceList() {
    return ListView.builder(
      itemCount: _invoices.length,
      itemBuilder: (BuildContext context, int index) {
        final invoice = _invoices[index];
        return ListTile(
          title: Text('Factura #${invoice['Numero']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha Emisión: ${invoice['FechaEmision']}'),
              Text('Total Factura: ${invoice['TotalFactura2']}'),
              Text('Vendedor: ${invoice['Vendedor']}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (BuildContext context, int index) {
        final order = _orders[index];
        return ListTile(
          title: Text('Pedido #${order['Numero']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha Emisión: ${order['FechaEmision']}'),
              Text('Total Pedido: ${order['TotalPedido2']}'),
              Text('Vendedor: ${order['Vendedor']}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedList() {
    if (_selectedOption == 'Productos') {
      return _buildProductList();
    } else if (_selectedOption == 'Clientes') {
      if (_selectedCustomerIndex != -1) {
        return Expanded(child: _buildCustomerList());
      } else {
        return _buildCustomerList();
      }
    }
    return SizedBox.shrink();
  }


  void _onOptionSelected(String option) {
    setState(() {
      _selectedOption = option;
      _selectedCustomerIndex = -1;
      _searchController.clear();
      _search('');
    });

    if (_selectedOption == 'Productos') {
      _fetchProducts();
    } else if (_selectedOption == 'Clientes') {
      _fetchCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de $_selectedOption'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onOptionSelected,
            itemBuilder: (BuildContext context) {
              return ['Productos', 'Clientes'].map((String option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
              ),
            ),
          ),
          Expanded(child: _buildSelectedList()),
        ],
      ),
      floatingActionButton: _selectedOption == 'Clientes'
          ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceList(invoices: _invoices),
                ),
              );
            },
            child: Icon(Icons.list),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderList(orders: _orders),
                ),
              );
            },
            child: Icon(Icons.shopping_cart),
          ),
        ],
      )
          : FloatingActionButton(
        onPressed: () {
          _onOptionSelected(_selectedOption);
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class InvoiceList extends StatelessWidget {
  final List<dynamic> invoices;

  const InvoiceList({Key? key, required this.invoices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Facturas'),
      ),
      body: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (BuildContext context, int index) {
          final invoice = invoices[index];
          return ListTile(
            title: Text('Factura #${invoice['Numero']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha Emisión: ${invoice['FechaEmision']}'),
                Text('Total Factura: ${invoice['TotalFactura2']}'),
                Text('Vendedor: ${invoice['Vendedor']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final List<dynamic> orders;

  const OrderList({Key? key, required this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Pedidos'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) {
          final order = orders[index];
          return ListTile(
            title: Text('Pedido #${order['Numero']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha Emisión: ${order['FechaEmision']}'),
                Text('Total Pedido: ${order['TotalPedido2']}'),
                Text('Vendedor: ${order['Vendedor']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

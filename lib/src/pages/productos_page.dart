import 'package:flutter/material.dart';
import 'dart:async';

import 'drawer_widget.dart'; // Importa el archivo drawer_widget.dart
import 'class/usuario.dart'; // Importa la clase Usuario desde el archivo usuario.dart
import 'class/producto.dart'; // Importa la clase Producto desde el archivo vendedor.dart
import 'database_local.dart';

class ProductosPage extends StatelessWidget {
  final List<String> opciones = ['Inicio', 'Clientes', 'Productos', 'Nuevo Pedido','Lista De Pedidos','Pedidos En Espera']; // Opciones del menú

  @override
  Widget build(BuildContext context) {
    final selectedUsuario = ModalRoute.of(context)?.settings.arguments as Usuario;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBar
        title: Text('Página de Productos'),
      ),
      drawer: DrawerWidget(selectedUsuario: selectedUsuario), // Utiliza el DrawerWidget aquí
      body: ProductList(codigoVendedor: selectedUsuario.codigoVendedor)
    );
  }
}

class ProductList extends StatefulWidget {
  final String codigoVendedor;

  ProductList({required this.codigoVendedor});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  //List<dynamic> _Products = [];
  //List<dynamic> _searchedProducts = [];
  List<Producto> _searchedProducts = [];
  TextEditingController _searchController = TextEditingController();
  List<Producto> _productosdb = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    //_fetchProducts();
    _loadProductosdb();
  }

  Future<void> _loadProductosdb() async {
    List<Producto> productos = await _databaseHelper.getProductos();

    setState(() {
      _productosdb = productos;
      _searchedProducts = productos;
    });
  }

  void _search(String query) {
    setState(() {
      _searchedProducts = _productosdb
          .where((productoLista) => productoLista.nombreBusqueda.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildProductList() {
    return ListView.builder(
      //controller: _scrollController,
      itemCount: _searchedProducts.length,
      itemBuilder: (BuildContext context, int index) {
        final Producto productoLista = _searchedProducts[index];

        return ListTile(
          title: 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child:
                  Text(
                    '${productoLista.nombre} (${productoLista.iva == 'A' ? 'G' : productoLista.iva})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  //productoLista.existencia > 0 ? Icons.circle : Icons.circle_outlined,
                  Icons.circle,
                  //color: productoLista.existencia > 0 ? Colors.green : Colors.red,
                  color: productoLista.existencia > 0 ? Color(0xDD006A4E) : Color(0xDDF42A40),
                  size: 18,
                ),
              ],
            ),
          subtitle: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 80,
                            child: Text(
                              'Código:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 120,
                            child: Text(
                              '${productoLista.codigoProducto}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      //SizedBox(height: 4),
                      
                      //if (widget.codigoVendedor == 'T')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            child: Text(
                              'Existencia:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            width: 80,
                            child: Text(
                              '${productoLista.existencia.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    
                      /*
                      if (widget.codigoVendedor == 'T')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 120,
                              child: Text(
                                'Comprometido: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: 80,
                              child: Text(
                                '${productoLista.pedidoVenta.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      */
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              
                              Text(
                                'Precio: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                '${productoLista.precioMoneda.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ), 
                        ],
                      ),
                    ],
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
          Expanded(child: _buildProductList()),
        ],
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _loadProductosdb,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.black,
      ),
      */
    );
  }
}

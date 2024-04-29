import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'pedidos_renglon_page.dart';
import 'class/usuario.dart'; // Importa la clase Usuario desde el archivo usuario.dart
import 'drawer_widget.dart'; // Importa el archivo drawer_widget.dart
import 'class/pedidoclass.dart'; // Importa la clase Pedido desde el archivo pedidoclass.dart
import 'package:expandable_text/expandable_text.dart';
import 'pdf.dart';

class PedidosPage extends StatelessWidget {
  final List<String> opciones = ['Inicio', 'Clientes', 'Productos', 'Nuevo Pedido','Lista De Pedidos','Pedidos En Espera']; // Opciones del menú

  @override
  Widget build(BuildContext context) {
    final selectedUsuario = ModalRoute.of(context)?.settings.arguments as Usuario;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBar
        title: Text('Listado De Pedidos'),
      ),
      drawer: DrawerWidget(selectedUsuario: selectedUsuario), // Utiliza el DrawerWidget aquí
      body: PedidosList(selectedUsuario: selectedUsuario)
    );
  }
}


class PedidosList extends StatefulWidget {
  final Usuario selectedUsuario;

  PedidosList({required this.selectedUsuario});
  
  @override
  _PedidosListState createState() => _PedidosListState();
}

class _PedidosListState extends State<PedidosList> {
  List<Pedido> _pedidos = [];
  List<Pedido> _searchedPedidos = [];
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int _loadedPedidosCount = 10;
  String _selectedFecha = '7 Dias';

  @override
  void initState() {
    super.initState();
    _fetchPedidos(widget.selectedUsuario.codigoVendedor);
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchPedidos(String codigoVendedor) async {
    print('entro en _fechaPedidos');
    _pedidos.clear();
    _searchedPedidos.clear();

    DateTime today = DateTime.now();
    
    DateTime fechaModificada;
  
    switch (_selectedFecha) {
      case '1 Dia':
        fechaModificada = today.subtract(Duration(days: 1));
        break;
      case '3 Dias':
        fechaModificada = today.subtract(Duration(days: 3));
        break;
      case '7 Dias':
        fechaModificada = today.subtract(Duration(days: 7));
        break;
      case '30 Dias':
        fechaModificada = today.subtract(Duration(days: 30));
        break;
      case 'Todos':
        fechaModificada = today; // No resta días
        break;
      default:
        fechaModificada = today; // Caso por defecto, no resta días
    }

    String fechaFormateada = DateFormat('yyyy-MM-dd 00:00:00').format(fechaModificada);

    final response;
    if (widget.selectedUsuario.rol=='Vendedor') {
      response = await http.get(
        Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/pedidos/PedidosVendedorFecha/$codigoVendedor/$fechaFormateada')
      );
      //print('https://nodejs-mysql-railway-t-production.up.railway.app/pedidos/PedidosVendedorFecha/$codigoVendedor/$fechaFormateada');
    } else {
      if (widget.selectedUsuario.rol=='Supervisor') {
        response = await http.get(
          Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/PedidosSupervisorFecha/$codigoVendedor/$fechaFormateada')
        );
      } else {
        print('https://nodejs-mysql-railway-blanking-production.up.railway.app/PedidosFecha/$fechaFormateada');
        response = await http.get(
          Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/PedidosFecha/$fechaFormateada')
        );
      }
    }

    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        //_pedidos = data;

        for (dynamic pedidos in data) {
          Pedido pedido = Pedido(
            numero: pedidos['Numero'].toString(),
            fechaEmision: pedidos['FechaEmision'].toString(),
            nombre: pedidos['Nombre'].toString(),
            nombreBusqueda: pedidos['NombreBusqueda'].toString(),
            vendedor: pedidos['Vendedor'].toString(),
            nombreVendedor: pedidos['NombreVendedor'].toString(),
            totalBruto2: double.parse(pedidos['TotalBruto2'].toString()),
            impuesto2: double.parse(pedidos['Impuesto2'].toString()),
            totalPedido2: double.parse(pedidos['TotalPedido2'].toString()),
            estatus: pedidos['Estatus'].toString(),
            items: int.parse(pedidos['Items'].toString()),
            bultos: double.parse(pedidos['Bultos'].toString()),
            comentario: pedidos['Comentarios'] ?? '',
            rif: pedidos['RIF'] ?? '',
            diasCredito: 0,
            porcentajeFacturado: double.parse(pedidos['PorcentajeFacturado'].toString()),
          );
          _pedidos.add(pedido);
        }

        if (_loadedPedidosCount <= _pedidos.length) { // Verifica el límite válido
          _searchedPedidos = _pedidos.sublist(0, _loadedPedidosCount);
        } else {
          _searchedPedidos = _pedidos.sublist(0, _pedidos.length);
        }
      });
    } else {
      throw Exception('Failed to fetch Pedidos');
    }
  }

  void _search(String query) {
    setState(() {
      _searchedPedidos = _pedidos
          .where((order) => order.nombreBusqueda.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        if (_loadedPedidosCount < _pedidos.length) {
          _loadedPedidosCount += 50;
          if (_loadedPedidosCount > _pedidos.length) {
            _loadedPedidosCount = _pedidos.length;
          }
          _searchedPedidos = _pedidos.sublist(0, _loadedPedidosCount);
        }
      });
    }
  }

  Color _getColorForPercentage(double porcentajeFacturado) {
    if (porcentajeFacturado == 0) {
      return Colors.red; // Rojo para porcentaje 0
    } else if (porcentajeFacturado > 0 && porcentajeFacturado <= 20) {
      return Color(0xFFFFA500); // Amarillo para porcentaje entre 0 y 100
    } else if (porcentajeFacturado > 20 && porcentajeFacturado < 80) {
      return Colors.yellow; // Amarillo para porcentaje entre 0 y 100
    } else if (porcentajeFacturado >= 80 && porcentajeFacturado < 100) {
      return Color(0xFFBFFF00); // Amarillo para porcentaje entre 0 y 100
    } else {
      return Colors.green; // Verde para porcentaje igual o mayor a 100
    }
  }

  Widget _buildPedidosList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _searchedPedidos.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _searchedPedidos.length) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // Cambia Colors.blue por el color que desees
              ),
            ),
          );
        }

        Pedido order = _searchedPedidos[index];

        return GestureDetector(
        onTap: () {
          setState(() {
            for (Pedido pedidos in _pedidos){
              pedidos.visibilidadBoton=false;
            }
            order.visibilidadBoton=true;
          });
        },
        child: ListTile(
            //title: Text(order['Nombre - ${widget.codigoVendedor}']),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(order.fechaEmision))}',
                      style: TextStyle(
                        fontSize: 16, // Tamaño de fuente deseado
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                Text(
                  '${order.numero}',
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
                      'Cliente:      ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            '${order.nombre}',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendedor:  ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            '${order.nombreVendedor}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    /*
                    Text(
                      '${order.porcentajeFacturado.toStringAsFixed(2)} %',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.sticky_note_2,
                      color: _getColorForPercentage(order.porcentajeFacturado),
                    ),
                    */
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comentario:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: 
                      Column(
                        children: [ 
                          ExpandableText(
                            '${order.comentario}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            maxLines: 2, // Número de líneas a mostrar inicialmente
                            expandText: 'Ver más', // Texto del botón para expandir
                            collapseText: 'Ver menos', // Texto del botón para colapsar (opcional)
                            linkColor: Color(0xFF79B42C), //Colors.red,
                            collapseOnTextTap: true,
                            expandOnTextTap: true,
                            
                          ),
                        ],
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
                          'Estatus: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Items: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Unidades: ',
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
                          '${order.estatus}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${order.items}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${order.bultos.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subtotal:  ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Impuesto:  ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Total Pedido:  ',
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
                          '${order.totalBruto2.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${order.impuesto2.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${order.totalPedido2.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 3),
                order.visibilidadBoton
                ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PedidoRenglonPage(pedidoSelected: order),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            'Detalle',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],  
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Llama a la función para generar el PDF con la lista de pedidos actuales
                        await generatePDF(order);
                        // Muestra un mensaje o realiza otras acciones después de generar el PDF
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('PDF generado exitosamente'),
                          ),
                        );
                        //openPdf(order);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.deepPurpleAccent[700],
                            size: 26,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            'Exportar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
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
            child: 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(  // Asegúrate de que el TextField está envuelto en Expanded
                  child: TextField(
                    controller: _searchController,
                    onChanged: _search,
                    decoration: InputDecoration(
                      labelText: 'Buscar por número de pedido o nombre de cliente',
                      labelStyle: TextStyle(
                        color: Colors.grey, 
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 90,
                  child: DropdownButtonFormField<String>(                    
                    value: _selectedFecha,
                    items: ['1 Dia', '3 Dias', '7 Dias', '30 Dias', 'Todos'].map((fecha) {
                      return DropdownMenuItem<String>(
                        value: fecha,
                        child: Text(fecha),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFecha = newValue!;
                        _fetchPedidos(widget.selectedUsuario.codigoVendedor);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      labelStyle: TextStyle(
                        color: Colors.grey, 
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF79B42C)), // Cambia el color del borde cuando está seleccionado
                      ),
                    ),                    
                  ),
                ), 
              ],
            ),
          ),
          Expanded(child: _buildPedidosList()),
        ],
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fetchPedidos(widget.selectedUsuario.codigoVendedor),
        child: Icon(Icons.refresh),
        backgroundColor: Colors.black, // Asigna el color al botón
      ),
      */
    );
  }
}

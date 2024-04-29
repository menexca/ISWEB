import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'class/pedidoclass.dart'; // Importa la clase Pedido desde el archivo pedidoclass.dart
import 'package:expandable_text/expandable_text.dart';

class PedidoRenglonPage extends StatelessWidget {
  final Pedido pedidoSelected;

  PedidoRenglonPage({required this.pedidoSelected});  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBarbackgroundColor: Color(0xCCE30613), // Cambia el color de la AppBar
      ),
      body: PedidoRenglonList(pedidoSelected: pedidoSelected),
    );
  }
}

class PedidoRenglonList extends StatefulWidget {
  final Pedido pedidoSelected;

  PedidoRenglonList({required this.pedidoSelected});
  @override
  _PedidoRenglonListState createState() => _PedidoRenglonListState();
}

class _PedidoRenglonListState extends State<PedidoRenglonList> {
  List<dynamic> _pedidosRenglones = [];

  @override
  void initState() {
    super.initState();
    _fetchPedidoRenglon(widget.pedidoSelected.numero);
  }

  Future<void> _fetchPedidoRenglon(String numeroPedido) async {
    final response = await http.get(
      Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/PedidosRenglones/$numeroPedido')
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _pedidosRenglones = data;
      });
    } else {
      throw Exception('Failed to fetch Pedido Renglon');
    }
  }

  Widget _buildPedidoRenglonList() {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(widget.pedidoSelected.fechaEmision))}',
                          style: TextStyle(
                            fontSize: 16, // Tamaño de fuente deseado
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Text(
                      '${widget.pedidoSelected.numero}',
                      style: TextStyle(
                        fontSize: 20, // Tamaño de fuente deseado
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
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
                            '${widget.pedidoSelected.nombre}',
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
                            '${widget.pedidoSelected.nombreVendedor}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),      
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 160, // Ancho fijo deseado
                      child: Text(
                        'Nombre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                        width: 40, // Ancho fijo deseado
                        child: Text(
                        'Cant.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                        width: 50, // Ancho fijo deseado
                        child: Text(
                        'Precio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Container(
                        width: 50, // Ancho fijo deseado
                        child: Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pedidosRenglones.length,
              itemBuilder: (BuildContext context, int index) {
                final renglon = _pedidosRenglones[index];

                return Container(
                  /*
                  decoration: BoxDecoration(
                    color: renglon['Despacho'] == 0 ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5), // Color de fondo deseado
                    borderRadius: BorderRadius.circular(8), // Opcional: Bordess redondeados
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Color y opacidad de la sombra
                        spreadRadius: 2, // Radio de expansión de la sombra
                        blurRadius: 4, // Desenfoque de la sombra
                        offset: Offset(0, 2), // Desplazamiento de la sombra en x e y
                      ),
                    ],
                  ),
                  */
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 160, // Ancho fijo deseado
                          child: Text(
                            '${renglon['Descripcion']}',
                            style: TextStyle(
                              fontSize: 16, // Tamaño de fuente deseado
                            ),
                            overflow: TextOverflow.clip, // Recorta el texto si es demasiado largo para caber
                          ),
                        ),
                        Container(
                          width: 40, // Ancho fijo deseado
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${double.parse(renglon['Cantidad']).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 50, // Ancho fijo deseado
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${double.parse(renglon['Precio2']).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 50, // Ancho fijo deseado
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${double.parse(renglon['TotalRenglon2']).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(
                  height: 1,
                  color: Colors.black,
                ),
                SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comentario: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Expanded(child: 
                      ExpandableText(
                        '${widget.pedidoSelected.comentario}',
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
                    ),
                  ],
                ),
                SizedBox(height: 1),
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
                          '${widget.pedidoSelected.estatus}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${widget.pedidoSelected.items}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${widget.pedidoSelected.bultos.toStringAsFixed(0)}',
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
                          '${widget.pedidoSelected.totalBruto2}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${widget.pedidoSelected.impuesto2}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${widget.pedidoSelected.totalPedido2}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPedidoRenglonList(),
    );
  }
}

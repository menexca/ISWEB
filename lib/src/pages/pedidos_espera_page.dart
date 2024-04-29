import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'class/cliente.dart'; // Importa la clase Cliente desde el archivo vendedor.dart
import 'class/pedidorenglon.dart'; // Importa la clase PedidoRenglon desde el archivo pedidorenglon.dart
import 'pedidos_renglon_espera_page.dart';
import 'class/usuario.dart'; // Importa la clase Usuario desde el archivo usuario.dart
import 'drawer_widget.dart'; // Importa el archivo drawer_widget.dart
import 'class/pedidoclass.dart'; // Importa la clase Pedido desde el archivo pedidoclass.dart
import 'class/pedido.dart'; // Importa la clase Pedido desde el archivo pedido.dart
import 'database_local.dart';
import 'package:expandable_text/expandable_text.dart';

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:open_document/open_document.dart';
import 'pdf.dart';

//import 'package:downloads_path_provider/downloads_path_provider.dart';


class PedidosPage extends StatelessWidget {
  final List<String> opciones = ['Inicio', 'Clientes', 'Productos', 'Nuevo Pedido','Lista De Pedidos','Pedidos En Espera']; // Opciones del menú

  @override
  Widget build(BuildContext context) {
    final selectedUsuario = ModalRoute.of(context)?.settings.arguments as Usuario;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBar
        title: Text('Pedidos En Espera'),
      ),
      drawer: DrawerWidget(selectedUsuario: selectedUsuario), // Utiliza el DrawerWidget aquí
      body: PedidosList(usuarioSeleccionado: selectedUsuario)
    );
  }
}


class PedidosList extends StatefulWidget {
  //final String codigoVendedor;
  final Usuario usuarioSeleccionado;

  PedidosList({required this.usuarioSeleccionado});
  
  @override
  _PedidosListState createState() => _PedidosListState();
}

class _PedidosListState extends State<PedidosList> {
  List<Pedido> _pedidos = [];
  List<Pedido> _searchedPedidos = [];
  TextEditingController _searchController = TextEditingController();
  int _loadedPedidosCount = 20;
  List<PedidoEspera> _pedidosEsperadb = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isSending = false; // Variable para controlar el estado de envío del pedido

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }


  Future<void> _fetchPedidos() async {

    List<PedidoEspera> pedidosEspera = await _databaseHelper.getPedidosEsperaAll();

    setState(() {
      _pedidos.clear();
      for (PedidoEspera pedidoEspera in pedidosEspera) {
        Pedido pedido = Pedido(
          numero: pedidoEspera.numero,
          fechaEmision: pedidoEspera.fecha.toString(),
          nombre: pedidoEspera.nombreCliente,
          nombreBusqueda: '${pedidoEspera.nombreCliente} ${pedidoEspera.numero}',
          vendedor: pedidoEspera.vendedor,
          comentario: pedidoEspera.comentario,
          nombreVendedor: pedidoEspera.nombreVendedor,
          totalBruto2: pedidoEspera.totalNeto,
          impuesto2: pedidoEspera.totalImpuesto,
          totalPedido2: pedidoEspera.totalPedido,
          estatus: pedidoEspera.estatus,
          items: pedidoEspera.items,
          bultos: pedidoEspera.bultos,
          rif: pedidoEspera.rif,
          diasCredito: pedidoEspera.diasCredito,
          porcentajeFacturado: 0,
        );
        _pedidos.add(pedido);
      }

      if (_loadedPedidosCount <= _pedidos.length) { // Verifica el límite válido
        _searchedPedidos = _pedidos.sublist(0, _loadedPedidosCount);
      } else {
        _searchedPedidos = _pedidos.sublist(0, _pedidos.length);
      }
    });
  
  }

  void _search(String query) {
    setState(() {
      _searchedPedidos = _pedidos
          .where((order) => order.nombreBusqueda.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildPedidosList() {
    return Scaffold(
      body: IgnorePointer(
          ignoring: _isSending, // Ignorar interacción mientras se envía el pedido
          child: Stack(
          children: [
            ListView.builder(
              //controller: _scrollController,
              itemCount: _searchedPedidos.length,
              itemBuilder: (BuildContext context, int index) {
            
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
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comentario: ',
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
                                    //'${order.comentario}',
                                    '${order.comentario} / Días de Crédito: ${order.diasCredito}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    maxLines: 2, // Número de líneas a mostrar inicialmente
                                    expandText: 'Ver más', // Texto del botón para expandir
                                    collapseText: 'Ver menos', // Texto del botón para colapsar (opcional)
                                    linkColor: Color(0xCCE30613), //Colors.red,
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
                                  '${order.totalBruto2}',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${order.impuesto2}',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () async {
                                bool confirmarEliminar = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Cancelar envío'),
                                      content: Text('¿Está seguro de eliminar el pedido?'),
                                      actions: [
                                        TextButton(
                                          child: Text('No'),
                                          onPressed: () {
                                            Navigator.of(context).pop(false); // Cancelar el envío
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Si'),
                                          onPressed: () {
                                            Navigator.of(context).pop(true); // Confirmar el envío
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmarEliminar == true) {
                                  await _databaseHelper.eliminarPedido(order.numero);
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false, // Evitar que el usuario cierre el diálogo haciendo clic fuera de él
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Pedido eliminado'),
                                        content: Text('Número ${order.numero}'),
                                        actions: [
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Cerrar el diálogo
                                              setState(() {
                                                _fetchPedidos();
                                                // Actualizar la lista de pedidos
                                                // Aquí puedes llamar a la función que obtiene la lista de pedidos nuevamente
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cancel_rounded,
                                    color: Colors.redAccent[700],
                                  ),
                                  
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    'Eliminar',
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
                                //logica modificar
                                Navigator.pushNamed(
                                  context, 
                                  'Nuevo Pedido', 
                                  arguments: {
                                    'usuario': widget.usuarioSeleccionado,
                                    'pedido': order.numero,
                                    // Agrega más argumentos según sea necesario
                                  },
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    color: Colors.brown,
                                    size: 26,
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    'Modificar',
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
                            TextButton(
                              onPressed: () async {
                                bool confirmarEnvio = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmar envío'),
                                      content: Text('¿Está seguro de enviar el pedido?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(context).pop(false); // Cancelar el envío
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Aceptar'),
                                          onPressed: () {
                                            Navigator.of(context).pop(true); // Confirmar el envío
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmarEnvio == true) {
                                  // El usuario confirmó el envío
                                  setState(() {
                                    _isSending = true; // Cambia el estado a "enviando"
                                  });
                                  Map<String, dynamic> resultado = await _databaseHelper.enviarPedido(order.numero);
                                  bool exito = resultado['exito'];
                                  String numeroPedidoApi = resultado['mensaje'];

                                  if (exito) {
                                  // Pedido enviado exitosamente
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false, // Evitar que el usuario cierre el diálogo haciendo clic fuera de él
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Pedido enviado'),
                                          content: Text('El pedido se ha enviado correctamente: ${numeroPedidoApi}'),
                                          actions: [
                                            TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  _isSending = false; // Cambia el estado a "no enviando"
                                                  _fetchPedidos();
                                                });
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
                                      barrierDismissible: false, // Evitar que el usuario cierre el diálogo haciendo clic fuera de él
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Sin Conexión'),
                                          content: Text('El pedido: ${order.numero} no se pudo enviar.'),
                                          actions: [
                                            TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  _isSending = false; // Cambia el estado a "no enviando"
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_rounded,
                                    color: Color.fromARGB(255, 29, 143, 32),
                                    size: 26,
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    'Enviar',
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
            ),
            if (_isSending) // Mostrar un indicador de carga mientras se envía el pedido
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );          
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IgnorePointer(
          ignoring: _isSending, // Ignorar interacción mientras se envía el pedido
          child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _search,
                    decoration: InputDecoration(
                      labelText: 'Buscar por numero de pedido o nombre de cliente',
                      labelStyle: TextStyle(
                        color: Colors.grey, 
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xCCE30613)), // Cambia el color del borde cuando está seleccionado
                      ),
                    ),
                  ),
                ),
                Expanded(child: _buildPedidosList()),
              ],
            ),
            if (_isSending) // Mostrar un indicador de carga mientras se envía el pedido
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

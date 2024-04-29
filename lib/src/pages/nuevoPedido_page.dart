import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blanking/src/pages/class/pedidoclass.dart';
import 'dart:math';
import '../pages/clientes_page_pedido.dart';
import 'class/usuario.dart'; // Importa la clase Usuario desde el archivo usuario.dart
import 'drawer_widget.dart'; // Importa el archivo drawer_widget.dart
import 'class/clienteIS.dart'; // Importa la clase Cliente desde el archivo cliente.dart
import 'class/producto.dart'; // Importa la clase Producto desde el archivo producto.dart
import 'class/pedido.dart'; // Importa la clase Pedido desde el archivo pedido.dart
import 'class/pedidorenglon.dart'; // Importa la clase PedidoRenglon desde el archivo pedidorenglon.dart
//import 'class/pedidoclass.dart'; // Importa la clase Pedido desde el archivo pedidoclass.dart

import 'database_local.dart';
import 'package:connectivity/connectivity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';


class NuevoPedidoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final selectedUsuario = ModalRoute.of(context)?.settings.arguments as Usuario;

    final dynamic args = ModalRoute.of(context)?.settings.arguments;

    //final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    // Accede a otros argumentos según sea necesario

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4E73DF), // Cambia el color de la AppBar
        title: Text('Control de Acceso'),
        actions: [
          InkWell(
            onTap: () {
              // Acción al presionar la imagen en la esquina derecha
            },
            child: Container(
              width: 100,
              height: 50,
              child: 
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/ic_launcher_negro.png', width: 80, height: 40),
                  SizedBox(width: 20,),
                ],
              ),
            ),
          ),
        ],
      ),      
      //drawer: DrawerWidget(selectedUsuario: selectedUsuario), // Utiliza el DrawerWidget aquí
      body: NuevoPedidoSeccion()
    );
  }
}


class NuevoPedidoSeccion extends StatefulWidget {
  NuevoPedidoSeccion(); // Constructor que recibe selectedUsuario

  @override
  _NuevoPedidoSeccionState createState() => _NuevoPedidoSeccionState();
}

class _NuevoPedidoSeccionState extends State<NuevoPedidoSeccion> {
  List<Cliente> _clientes = [];
  //Map<String, dynamic>? _clienteSeleccionado;
  Cliente? _clienteSeleccionado;
  bool _isSending = false; // Variable para controlar el estado de envío del pedido
  TextEditingController _comentarioController = TextEditingController();
  TextEditingController _diasCreditoController = TextEditingController();
  bool mostrarPrecioConIVA = false;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  //List<TextEditingController> cantidadControllers = [];
  //List<TextEditingController> dsctoAdicControllers = [];
  TextEditingController descuentoController = TextEditingController();
  List<Map<String, dynamic>> renglonesLista = [];
  late TooltipBehavior _tooltipBehavior;
  List<SaldoData> _saldoData = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _saldoData = getSaldoData(_clientes);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {}); // Actualizar el estado del widget cada segundo
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancelar el Timer cuando el widget se dispose
    super.dispose();
  }

  int _calcularTotalClientes() {
    return _clientes.length;
  }

  Future<void> _seleccionarCliente() async {
    final Cliente clienteSeleccionado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientesPage()),
    );

    if (clienteSeleccionado != null) {
      setState(() {
        _clienteSeleccionado = clienteSeleccionado;
      });
    }
  }

  List<SaldoData> getSaldoData(List<Cliente> clientes) {
    double hombres = 0;
    double mujeres = 0;

    if (clientes.isNotEmpty) {  
      for (var cliente in clientes) {
        if (cliente.genero == 'M') {
          hombres++;
        } else if (cliente.genero == 'F') {
          mujeres++;
        }
      }
    }

    final List<SaldoData> saldoData = [
      SaldoData('Genero', hombres, mujeres),
    ];

    return saldoData;
  }
  
  Future<void> _ingresarCliente() async {
    final Cliente clienteIngresado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientesPage()),
    );

    if (clienteIngresado != null) {
      // Verifica si el artículo ya está en la lista
      bool clienteYaEnLista = _clientes.any((cliente) => cliente.usuario == clienteIngresado.usuario);

      if (clienteYaEnLista) {
        // Muestra un aviso de que el producto ya está en la lista
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Aviso'),
              content: Text('El Cliente "${clienteIngresado.usuario}" ya está en la lista'),
              actions: [
                TextButton(
                  child: Text('OK',
                    style: TextStyle(color: Colors.red),
                  ),
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
      else {
        Cliente cliente = Cliente(
          usuario: clienteIngresado.usuario,
          nombre: clienteIngresado.nombre,
          estatus: clienteIngresado.estatus,
          edad: clienteIngresado.edad,
          genero: clienteIngresado.genero,
        );

        setState(() {
          _clientes.add(cliente);
        });
      }
    }    
  }

  void limpiarPedido() {
    setState(() {
      _clientes.clear();
      _clienteSeleccionado = null;
      _comentarioController.text = '';
      //_aplicarDescuento(0.0);
      descuentoController.clear();
      _diasCreditoController.text = '';
    });  
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Mostrar un diálogo de confirmación antes de salir de la página
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('¿Salir?'),
            content: Text('¿Estás seguro de que quieres abandonar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Permanecer en la página
                child: Text('Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Salir de la página
                child: Text('Salir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        body: IgnorePointer(
                ignoring: _isSending, // Ignorar interacción mientras se envía el pedido
                child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sección: Datos del Cliente
                          
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Capacidad',
                                        style: TextStyle(
                                          fontSize: 18, // Tamaño de fuente deseado
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Clientes',
                                        style: TextStyle(
                                          fontSize: 18, // Tamaño de fuente deseado
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Porcentaje',
                                        style: TextStyle(
                                          fontSize: 18, // Tamaño de fuente deseado
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '50',
                                        style: TextStyle(
                                          fontSize: 18, // Tamaño de fuente deseado
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '${_clientes.length}',
                                        style: TextStyle(
                                          fontSize: 18, // Tamaño de fuente deseado
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '${roundDouble((_clientes.length*(100/50)),0)} %',
                                        style: TextStyle(
                                          fontSize: 18, // Tamaño de fuente deseado
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                          /*
                                          Text(
                                            '${_saldoData.first.titulo } ${_saldoData.first.saldo} ${_saldoData.first.vencido} ${_saldoData.first.porcentajevencido}',
                                            style: TextStyle(
                                              fontSize: 18, // Tamaño de fuente deseado
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          */
                                          
/*
                                      Container(
                                        height: 100.0,
                                        width: 100.0, 
                                        child: 
                                        SfCircularChart(
                                          margin: EdgeInsets.all(0), // Establece todos los márgenes a cero
                                          //title: ChartTitle(text: 'Meta vs Venta'),
                                          //legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                                          tooltipBehavior: _tooltipBehavior,
                                          series: <CircularSeries>[
                                            RadialBarSeries<SaldoData, String>(
                                              dataSource: _saldoData,
                                              xValueMapper: (SaldoData data, _) => data.titulo,
                                              yValueMapper: (SaldoData data, _) => data.porcentajevencido,
                                              maximumValue: 100, 
                                              radius: '85%', // El valor máximo es 100, que representa el 100% (la meta del vendedor)
                                              innerRadius: '80%',  // Cambia este valor según tus necesidades para controlar el tamaño del agujero
                                              useSeriesColor: true,
                                              trackOpacity: 0.18,
                                              cornerStyle: CornerStyle.bothCurve, // Opción para redondear las esquinas
                                              dataLabelSettings: DataLabelSettings(
                                                isVisible: true,
                                                labelPosition: ChartDataLabelPosition.outside,
                                                connectorLineSettings: ConnectorLineSettings(
                                                                  // Type of the connector line
                                                                  type: ConnectorType.curve
                                                              ),
                                                alignment: ChartAlignment.far,
                                                textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1,
                                                ),
                                                //useSeriesColor: true,
                                              ),
                                              enableTooltip: true,
                                              pointColorMapper: (SaldoData data, _) => Color.fromARGB(255, 152, 21, 21), // Color #159898
                                              dataLabelMapper: (SaldoData data, _) {
                                                // Mostrar el porcentaje y el monto de venta en la etiqueta
                                                //return '${data.porcentajeVenta.toStringAsFixed(2)} %\n \$ ${data.venta.toStringAsFixed(2)}';
                                                return '';

                                              },
                                            )
                                          ],
                                          // Añadir un Container con el texto en el centro
                                          annotations: <CircularChartAnnotation>[
                                            CircularChartAnnotation(
                                              widget: Container(
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Vencido',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                    ),
                                                    /*
                                                    Text(
                                                      '${formatNumberDecimal(vendedorIndicadores.porcentajeSaldoVencido)} %',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                                    ),
                                                    */
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
*/


                                    
                                  /*
                                  SizedBox(
                                    height: 10,
                                  ),
                                  */

                                 
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Sección: Agregar Artículos
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 8.0, right: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Clientes',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),    
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            //mostrarPrecioConIVA = !mostrarPrecioConIVA;
                                          });
                                        },
                                        icon: Icon(Icons.swap_horiz),
                                        iconSize: 45, // Tamaño deseado del icono
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 8),
                                  Divider(
                                                    height: 1.5,
                                                    color: Colors.grey,
                                                  ),
                                  ListView.builder(
    shrinkWrap: true,
    itemCount: _clientes.length,
    itemBuilder: (BuildContext context, int index) {
      Cliente clienteLista = _clientes[index];
      //Duration diferencia = DateTime.now().subtract(Duration(hours: 4)).difference(clienteLista.ingreso);
      Duration diferencia = DateTime.now().difference(clienteLista.ingreso);
      
      return Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 0, right: 0),
        child: Column(
          children: [
            Dismissible(
              key: Key(clienteLista.usuario),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Color.fromARGB(255, 235, 89, 78),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
              onDismissed: (direction) {
                setState(() {
                  _clientes.removeAt(index);
                });
              },
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: 
                      Text(
                        '${clienteLista.nombre}',
                        style: TextStyle(
                          fontSize: 20, // Tamaño de fuente deseado
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 0, right: 0),
                  child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: 70, // Ancho fijo deseado
                                child: Text(
                                'Estatus',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                                width: 70, // Ancho fijo deseado
                                child: Text(
                                'Edad',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                                width: 70, // Ancho fijo deseado
                                child: Text(
                                'Genero',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                                width: 140, // Ancho fijo deseado
                                child: Text(
                                'Ingreso',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                                width: 140, // Ancho fijo deseado
                                child: Text(
                                'Tiempo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            
                            Container(
                              width: 70, // Ancho fijo deseado
                              child: Text(
                                '${clienteLista.estatus}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 70, // Ancho fijo deseado
                              child: Text(
                                '${clienteLista.edad}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 70, // Ancho fijo deseado
                              child: Text(
                                '${clienteLista.genero}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                                width: 140, // Ancho fijo deseado
                                child: Text(
                                DateFormat('h:mm:ss a').format(clienteLista.ingreso),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                                width: 140, // Ancho fijo deseado
                                child: Text(
                                //'${DateTime.now().subtract(Duration(hours: 4)).difference(clienteLista.ingreso)}',

                                '${diferencia.inHours.abs()} h ${diferencia.inMinutes.abs() % 60} m ${diferencia.inSeconds.abs() % 60} s',
                            
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ),

              ),
            ),
            Divider(
              height: 1,
              color: Colors.black,
            ),
          ],
        ),
      );
    },
  ),

                                  Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                    child: ElevatedButton(
                                      onPressed: _ingresarCliente,
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Cambia el color de fondo
                                      ),
                                      child: Text('Agregar Cliente'),
                                    ),
                                    //SizedBox(height: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Sección: Total del Pedido
                          
                        ],
                      ),
                    ),
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
      ),
    );
  }
}

double roundDouble(double value, int places){ 
  num mod = pow( 10, places); 
  return ((value * mod).round().toDouble() / mod); 
}

String toCamelCase(String text) {
  List<String> words = text.split(' ');
  
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
  }
  
  return words.join(' ');
}

class SaldoData {
  SaldoData(this.titulo, this.saldo, this.vencido);

  final String titulo;
  final double saldo;
  final double vencido;

  double get porcentajevencido {
    return roundDouble((vencido/saldo)*100 ,2);
    //return roundDouble(4,2);
  }
}
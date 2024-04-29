import 'package:flutter/material.dart';
import 'drawer_widget.dart'; // Importa el archivo drawer_widget.dart
import 'database_local.dart';
import 'class/pedidorenglon.dart'; // Importa la clase Pedido desde el archivo pedido.dart
import 'class/usuario.dart'; // Importa la clase Usuario desde el archivo usuario.dart
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'class/vendedor.dart'; // Importa la clase Vendedor desde el archivo vendedor.dart
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';


class HomePage extends StatelessWidget {
  final List<String> opciones = ['Inicio', 'Clientes', 'Productos', 'Nuevo Pedido','Lista De Pedidos','Pedidos En Espera']; // Opciones del menú

  @override
  Widget build(BuildContext context) {
    final selectedUsuario = ModalRoute.of(context)?.settings.arguments as Usuario;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B42C), // Cambia el color de la AppBar
        //title: Text('Página de Inicio'),
        title: Text(selectedUsuario.rol.toUpperCase()),
      ),
      drawer: DrawerWidget(selectedUsuario: selectedUsuario), // Utiliza el DrawerWidget aquí
      body: HomeList(selectedUsuario: selectedUsuario)
    );
  }
}

 
class HomeList extends StatefulWidget {
  final Usuario selectedUsuario;

  HomeList({required this.selectedUsuario});
  
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  List<dynamic> _Homes = [];
  List<dynamic> _searchedCustomers = [];
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int _loadedCustomersCount = 50;
  List<PedidoRenglonEspera> _vendedoresdb = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();
  Future<String?>? _fechaSyncFuture; // Agregar un Future para almacenar el resultado de obtenerFechaSync
  //Vendedor vendedorIndicadores ; // Variable para almacenar el vendedor
  List<GoalData> _charData = [];
  List<ClientsData> _barrasData = [];
  List<SaldoData> _saldoData = [];
  List<DiasData> _diasData = [];
  late TooltipBehavior _tooltipBehavior;
  List<Vendedor> _vendedores = [];
  Vendedor? _selectedCodigoVendedor;

  Vendedor vendedorIndicadores = Vendedor(
    codigoVendedor: 'V123',
    nombre: 'Juan Pérez',
    zona: 'Zona',
    almacen: '01',
    rif: 'V123456789',
    nit: 'J-123456789',
    cantidadClientes: 1,
    cantidadClientesNuevosMes: 1,
    cantidadPedidosHoy: 1,
    cantidadPedidosMes: 1,
    cantidadClientesAtendidosHoy: 1,
    cantidadClientesAtendidosMes: 1,
    meta: 1.0,
    porcentajeEfectividad: 1.0,
    totalVentaBruta2: 1.0,
    totalDevolucionBruta2: 1.0,
    totalFacturacionBruta2: 1.0,
    porcentajeAlcanzadoMeta: 1.0,
    diasHabilesMes: 1,
    diasHabilesTranscurridos: 1,
    diasHabilesRestantes: 1,
    promedioVentaDiaria: 1.0,
    diferenciaMeta: 1.0,
    objetivoDiario: 1.0,
    saldo: 1.0,
    vencido: 1.0,
    porcentajeSaldoVencido: 1,
    porcentajeVentaVencido: 1,
    supervisadoPor: ' ',
    cajasVendidas: 0,
    activo: 1,
  );

  
  @override
  void initState() {
    // Aquí asignamos el vendedor con código 'T' como predeterminado
    getVendedorIndicadores();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
    _fechaSyncFuture = obtenerFechaSync(); // Asignar el Future a _fechaSyncFuture
    validarSesion();
  }

  Future<void> validarSesion() async {

    bool? logeado = await _databaseHelper.getLogged();
    print ('dentro de home, ${logeado}');
    if (logeado == null) {
      logeado = true;
    }

    if (!logeado) {
      Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
    }
  }

  Future<String?> obtenerFechaSync() async {
    return await _databaseHelper.getFechaSync();
  } 

  Future<String> getInternetStatus() async {
    bool hasInternet = await _databaseHelper.checkInternetConnectivity();
    return hasInternet ? 'Hay internet' : 'No hay internet';
  }

  Future<void> getVendedorIndicadores() async {
    Vendedor vendedorActual = await _databaseHelper.getVendedorObj();

    List<Vendedor> vendedoresLista;

    if (widget.selectedUsuario.rol == 'Supervisor'){
      vendedoresLista = await _databaseHelper.getVendedores(widget.selectedUsuario.codigoVendedor);
    } else {
      vendedoresLista = await _databaseHelper.getVendedores('T');
    }
    

    //List<Vendedor> vendedoresLista = await _databaseHelper.getVendedores();

    // Actualiza el estado con el vendedor obtenido
    setState(() {
      vendedorIndicadores = vendedorActual;
      _charData = getCharData();
      _barrasData = getBarrasData();
      _saldoData = getSaldoData();
      _diasData = getDiasData();
      _vendedores = vendedoresLista;
      // _selectedCodigoVendedor = vendedoresLista.firstWhere((vendedor) => vendedor.codigoVendedor == 'T', orElse: () => _vendedores.first);
      _selectedCodigoVendedor = vendedoresLista.firstWhere(
        (vendedor) => vendedor.codigoVendedor == 'T',
        orElse: () {
          // Si no se encuentra ningún vendedor con código 'T', buscar por el código del usuario
          return vendedoresLista.firstWhere(
            (vendedor) => vendedor.codigoVendedor == widget.selectedUsuario.codigoVendedor,
            orElse: () {
              // Si no se encuentra ningún vendedor con el código del usuario, seleccionar el primero de la lista completa
              return _vendedores.first;
            },
          );
        },
      );
    });
  }

  Future<void> getVendedorIndicadoresSelect(String codigoVendedorSelect) async {
    Vendedor vendedorActual = await _databaseHelper.getVendedorObjSelect(codigoVendedorSelect);

    // Actualiza el estado con el vendedor obtenido
    setState(() {
      vendedorIndicadores = vendedorActual;
      _charData = getCharData();
      _barrasData = getBarrasData();
      _saldoData = getSaldoData();
      _diasData = getDiasData();
    });
  }

  List<GoalData> getCharData() {
    double metaAqui = 0;

    if (vendedorIndicadores.meta == 0) {
      metaAqui = 1;
    } else {
      metaAqui = vendedorIndicadores.meta;
    }

    final List<GoalData> charData = [
      //GoalData('Proyeccion', vendedorIndicadores.meta, vendedorIndicadores.promedioVentaDiaria*vendedorIndicadores.diasHabilesMes, Color.fromARGB(255, 223, 220, 40)),
      //GoalData('Venta', vendedorIndicadores.meta, vendedorIndicadores.totalFacturacionBruta2, Color(0xFF159898)),
      GoalData('Proyeccion', metaAqui, vendedorIndicadores.promedioVentaDiaria*vendedorIndicadores.diasHabilesMes, Color.fromARGB(255, 223, 220, 40)),
      GoalData('Venta', metaAqui, vendedorIndicadores.totalFacturacionBruta2, Color(0xFF159898)),
      
      //GoalData('Venta2', 20000, 4000),
      //GoalData('Venta', 1500),
    ];
    return charData;
  }

  List<ClientsData> getBarrasData() {
    int cantidadClientesAqui = 0;

    if (vendedorIndicadores.cantidadClientes == 0) {
      cantidadClientesAqui = 1;
    } else {
      cantidadClientesAqui = vendedorIndicadores.cantidadClientes;
    }
    
    final List<ClientsData> barrasData = [
      //ClientsData('Cartera\n (${vendedorIndicadores.cantidadClientes}) ', vendedorIndicadores.cantidadClientes, vendedorIndicadores.cantidadClientes),
      //ClientsData('Atendidos\n (${vendedorIndicadores.cantidadClientesAtendidosMes}) ', vendedorIndicadores.cantidadClientes, vendedorIndicadores.cantidadClientesAtendidosMes),
      ClientsData('Cartera\n (${vendedorIndicadores.cantidadClientes}) ', cantidadClientesAqui, cantidadClientesAqui),
      ClientsData('Atendidos\n (${vendedorIndicadores.cantidadClientesAtendidosMes}) ', cantidadClientesAqui, vendedorIndicadores.cantidadClientesAtendidosMes),

      //GoalData('Venta2', 20000, 4000),
      //GoalData('Venta', 1500),
    ];
    return barrasData;
  }

  List<SaldoData> getSaldoData() {
    double saldoAqui = 0;

    if (vendedorIndicadores.saldo == 0) {
      saldoAqui = 100;
    } else {
      saldoAqui = vendedorIndicadores.saldo;
    }
    
    final List<SaldoData> saldoData = [
      //SaldoData('saldovencido', vendedorIndicadores.saldo, vendedorIndicadores.vencido),
      SaldoData('saldovencido', saldoAqui, vendedorIndicadores.vencido),
    ];

    return saldoData;
  }

  List<DiasData> getDiasData() {
    final List<DiasData> diasData = [
      DiasData('Dias Habiles (${vendedorIndicadores.diasHabilesMes})', vendedorIndicadores.diasHabilesTranscurridos, vendedorIndicadores.diasHabilesRestantes),
      //SaldoData('saldovencidoNO', vendedorIndicadores.saldo, vendedorIndicadores.saldo),
      //GoalData('Venta2', 20000, 4000),
      //GoalData('Venta', 1500),
    ];
    return diasData;
  }

  @override
  Widget build(BuildContext context) {
    final selectedUsuario = ModalRoute.of(context)?.settings.arguments as Usuario?;

    return Scaffold(
      body: SingleChildScrollView(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    //color: Colors.blue, // Color de fondo
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 1),
                    alignment: Alignment.center,
                    height: 140.0, // Altura deseada del segundo contenedor
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          '¡Bienvenido!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black, // Color del texto
                            fontWeight: FontWeight.bold, // Texto en negrita
                          ),
                        ),
                        Text(
                          '${selectedUsuario!.nombreCompleto}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black, // Color del texto
                            fontWeight: FontWeight.bold, // Texto en negrita
                          ),
                        ),  
                        if (widget.selectedUsuario.rol != 'Vendedor')
                        Container(
                          //width: 150,
                          //height: 50,
                          child:
                          DropdownButtonFormField<Vendedor>(
                            value: _selectedCodigoVendedor,
                            items: _vendedores.map((vendedor) {
                              return DropdownMenuItem<Vendedor>(
                                value: vendedor,
                                child: Text('${vendedor.nombre.length > 20 ? vendedor.nombre.substring(0, 20) : vendedor.nombre}',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black, // Color del texto
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCodigoVendedor = newValue;
                                getVendedorIndicadoresSelect(newValue!.codigoVendedor);
                              });
                            },
                            decoration: InputDecoration(
                              //labelText: 'Selecciona un vendedor',  // Texto del label
                              //labelStyle: TextStyle(fontSize: 12.0),  // Tamaño de fuente del label
                              //contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0.0),  // Padding del contenido
                              border: InputBorder.none, // Borde vacío
                            ),
                          ),
                        ),                      
                      ]
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100.0,
                    //color: Colors.green,
                    //padding: EdgeInsets.all(10.0),
                    padding: EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 1),
                    alignment: Alignment.centerRight,
                    child: 
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black, // Color del borde
                            width: 1.0, // Ancho del borde
                          ),
                        ),
                        child:
                          Image.asset(
                          'assets/images/usuario.jpg', // Reemplaza con la ruta de tu imagen
                          fit: BoxFit.contain, // Ajusta la imagen dentro del contenedor
                        ),
                      ),
                  ),
                ),
                SizedBox(width: 25),
              ],
            ),
            //Text('--------------------------------------data--------------------------------------'),
  /*          
            SizedBox(height: 10),

            //if (vendedorIndicadores != null)
            Text('Código: ${vendedorIndicadores.cantidadClientes}'),
            Text('Total Venta: ${vendedorIndicadores.totalVentaBruta2}'),
            Text('dfs: ${_charData.first.meta} '),
            */
            //SizedBox(height: 5),

            //Text('nombre: ${vendedorIndicadores.nombre}, ${vendedorIndicadores.codigoVendedor}'),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 26.0,),  
                Expanded(
                  child: Container(
                    //color: Colors.blue, // Color de fondo
                    //padding: EdgeInsets.all(10.0) , // Relleno
                    alignment: Alignment.center,
                    // Altura deseada del segundo contenedor
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Cajas Vendidas:   ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                Text(
                                  '${formatNumberDecimal(vendedorIndicadores.cajasVendidas)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ]
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Saldo:',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    Text('Vencido:',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${formatNumberDecimal(vendedorIndicadores.saldo)} \$',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    Text(
                                      '${formatNumberDecimal(vendedorIndicadores.vencido)} \$',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(
                                  //productoLista.existencia > 0 ? Icons.circle : Icons.circle_outlined,
                                  Icons.circle,
                                  //color: productoLista.existencia > 0 ? Colors.green : Colors.red,
                                  color: Color(0xFF159898),
                                  size: 14,
                                ),
                                Text(
                                  'Venta Actual',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  //productoLista.existencia > 0 ? Icons.circle : Icons.circle_outlined,
                                  Icons.circle,
                                  //color: productoLista.existencia > 0 ? Colors.green : Colors.red,
                                  color: Color.fromARGB(255, 223, 220, 40),
                                  size: 14,
                                ),
                                Text(
                                  'Proyección ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),

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
                                      Text(
                                        '${formatNumberDecimal(vendedorIndicadores.porcentajeSaldoVencido)} %',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${formatNumberDecimal(vendedorIndicadores.porcentajeSaldoVencido)} %',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        */
                      ],
                    ),
                  ),
                ),

                
                SizedBox(width: 26.0,),
              ],
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [  
                Expanded(
                  child: Container(
                    //color: Colors.blue, // Color de fondo
                    //padding: EdgeInsets.all(10.0) , // Relleno
                    alignment: Alignment.center,
                    height: 240.0, // Altura deseada del segundo contenedor
                    child:
                    SfCircularChart(
                      margin: EdgeInsets.all(0), // Establece todos los márgenes a cero
                      //title: ChartTitle(text: 'Meta vs Venta'),
                      //legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                      tooltipBehavior: _tooltipBehavior,
                      series: <CircularSeries>[
                        RadialBarSeries<GoalData, String>(
                          //strokeWidth: 10,
                          trackBorderWidth: -25, // Ajusta este valor según tu preferencia para el grosor del aro
                          gap: '3',
                          dataSource: _charData,
                          xValueMapper: (GoalData data, _) => data.titulo,
                          yValueMapper: (GoalData data, _) => data.porcentajeVenta,
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                            //useSeriesColor: true,
                          ),
                          enableTooltip: true,
                          pointColorMapper: (GoalData data, _) => data.color, // Color #159898
                          dataLabelMapper: (GoalData data, _) {
                            // Mostrar el porcentaje y el monto de venta en la etiqueta
                            //return '${data.porcentajeVenta.toStringAsFixed(2)} %\n \$ ${data.venta.toStringAsFixed(2)}';
                            return '${formatNumberDecimal(data.venta)} \$';
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
                                  'Tu Meta',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                Text(
                                  '${formatNumber(vendedorIndicadores.meta)} \$',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                Text(
                                  '${vendedorIndicadores.porcentajeAlcanzadoMeta.toStringAsFixed(2)} %',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 15),
                    Container(
                      //color: Colors.blue, // Color de fondo
                      //padding: EdgeInsets.all(10.0) , // Relleno
                      alignment: Alignment.center,
                      height: 220.0,
                      width: 150.0, // Altura deseada del segundo contenedor
                      child:
                      
                      SfCartesianChart (
                        enableAxisAnimation: true,
                        primaryXAxis: CategoryAxis(
                          //labelRotation: 330,
                        ),
                        primaryYAxis: NumericAxis(
                          maximum: roundDouble(double.parse(vendedorIndicadores.cantidadClientes.toString())*1.15,2) , // Establece el valor máximo en el eje Y
                        ),
                        margin: EdgeInsets.all(0), // Establece todos los márgenes a cero
                        //title: ChartTitle(text: 'Meta vs Venta'),
                        //legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                        tooltipBehavior: _tooltipBehavior,
                        series: <ChartSeries<ClientsData, String>>[
                          ColumnSeries<ClientsData, String>(
                            dataSource: _barrasData,
                            xValueMapper: (ClientsData data, _) => data.titulo,
                            yValueMapper: (ClientsData data, _) => data.clientesAtendidos,
                            //maximumValue: 100, 
                            animationDuration: 2000,
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            //borderWidth: 0.001,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.top,
                              connectorLineSettings: ConnectorLineSettings(
                                                // Type of the connector line
                                                type: ConnectorType.curve
                                            ),
                              alignment: ChartAlignment.far,
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                              //useSeriesColor: true,
                            ),
                            enableTooltip: true,
                            pointColorMapper: (ClientsData data, _) => Color(0xFF159898), // Color #159898
                            dataLabelMapper: (ClientsData data, _) {
                              // Mostrar el porcentaje y el monto de venta en la etiqueta
                              //return '${data.porcentajeVenta.toStringAsFixed(2)} %\n \$ ${data.venta.toStringAsFixed(2)}';
                              return '${data.porcentajeEfectividad.toStringAsFixed(2)} % \n ';

                            },
                          )
                        ],                      
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevos (${vendedorIndicadores.cantidadClientesNuevosMes})',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                            //fontWeight: FontWeight.bold,
                            height: 1,
                            color: Colors.black54,

                          ),
                        ),
                        //SizedBox(width: 2.0,),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 26.0,)
              ],
            ),

            //SizedBox(height: 10.0),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width:12),
                Expanded(
                  child: 
                  Container(
                    height: 50.0,
                    //width: 410,
                    child: SfCartesianChart(
                      enableAxisAnimation: true,
                      plotAreaBorderColor: Colors.white,
                      primaryXAxis: CategoryAxis(
                        axisLine: AxisLine(
                          width: 1,
                          dashArray: <double>[5,5]
                        ),
                      ),
                      primaryYAxis: CategoryAxis(
                        isVisible: false,
                      ),
                      borderColor: Colors.white,
                      borderWidth: 2,
                      // Sets 15 logical pixels as margin for all the 4 sides.
                      margin: EdgeInsets.only(
                        //left: 5.0,
                        //right: 5.0,
                        top: 9.0,
                        bottom: 9.0,
                      ),
                      series: <ChartSeries>[
                        StackedBar100Series<DiasData, String>(
                            dataLabelSettings: DataLabelSettings(isVisible:true),
                            dataSource: _diasData,
                            xValueMapper: (DiasData data, _) => data.titulo,
                            yValueMapper: (DiasData data, _) => data.diasHabilesTranscurridos,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45.0), // Radio para la esquina superior izquierda
                              topRight: Radius.circular(5.0), // Radio para la esquina superior derecha
                              bottomLeft: Radius.circular(45.0), // Radio para la esquina inferior izquierda
                              bottomRight: Radius.circular(5.0), // Radio para la esquina inferior derecha
                            ),
                            //pointColorMapper: (DiasData data, _) => Color.fromARGB(255, 181, 203, 153),
                            //pointColorMapper: (DiasData data, _) => Color(0xFF159898),
                            pointColorMapper: (DiasData data, _) => Color.fromARGB(255, 0, 152, 152),
                            animationDuration: 1000,
                            enableTooltip: true,
                        ),
                        StackedBar100Series<DiasData, String>(
                            dataLabelSettings: DataLabelSettings(isVisible:true),
                            dataSource: _diasData,
                            xValueMapper: (DiasData data, _) => data.titulo,
                            yValueMapper: (DiasData data, _) => data.diasHabilesRestantes,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5.0), // Radio para la esquina superior izquierda
                              topRight: Radius.circular(45.0), // Radio para la esquina superior derecha
                              bottomLeft: Radius.circular(5.0), // Radio para la esquina inferior izquierda
                              bottomRight: Radius.circular(45.0), // Radio para la esquina inferior derecha
                            ),
                            pointColorMapper: (DiasData data, _) => Color.fromARGB(218, 161, 161, 161),
                            animationDuration: 1000,
                            enableTooltip: true,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 6,)
              ],
            ),
            

            Container(
              //alignment: Alignment.center,
              height: 55.0,
              //width: 150.0, // Altura deseada del segundo contenedor
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Promedio\nVenta Diaria',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '${vendedorIndicadores.promedioVentaDiaria} \$',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Diferencia\nMeta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '${vendedorIndicadores.diferenciaMeta} \$',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Objetivo\nDiario',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '${vendedorIndicadores.objetivoDiario} \$',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),                    
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 10),
/*
            if (widget.codigoVendedor != 'T')
              SizedBox(height: 10),
*/
            //SizedBox(height: 20),
            
            FutureBuilder<String?>(
              future: _fechaSyncFuture,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  String? fechaSync = snapshot.data;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Última Sincronización: ${fechaSync != null ? DateFormat('dd/MM/yyyy hh:mm:ss a').format(DateTime.parse(fechaSync)) : 'Fecha de sincronización desconocida'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: 4,),
                      IconButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false, // Impide cerrar el diálogo al hacer clic fuera de él
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Carga de Datos'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Cargando clientes...'), 
                                    Text('Cargando productos...'), 
                                  ],
                                ),
                              );
                            },
                          );
                          await _databaseHelper.refrescarInfo();
                          // Aquí puedes realizar otras acciones después de la actualización
                          Navigator.of(context).pop();
                          setState(() {
                            _fechaSyncFuture = obtenerFechaSync();
                          });
                        },
                        icon: Icon(Icons.sync_rounded),
                        iconSize: 30, // Tamaño deseado del icono
                        color: Colors.black,
                      ),
                    ],
                  );
                } else {
                  return Text(
                    'Error al obtener la información de sincronización',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GoalData {
  GoalData(this.titulo, this.meta, this.venta, this.color);

  final String titulo;
  final double meta;
  final double venta;
  final Color color;

  double get porcentajeVenta {
    return roundDouble((venta/meta)*100 ,2);
    //return roundDouble(4,2);
  }
}

class ClientsData {
  ClientsData(this.titulo, this.carteraClientes, this.clientesAtendidos);

  final String titulo;
  final int carteraClientes;
  final int clientesAtendidos;
  

  double get porcentajeEfectividad {
    return roundDouble((clientesAtendidos/carteraClientes)*100 ,2);
    //return roundDouble(4,2);
  }
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

class DiasData {
  DiasData(this.titulo, this.diasHabilesTranscurridos, this.diasHabilesRestantes);

  final String titulo;
  final int diasHabilesTranscurridos;
  final int diasHabilesRestantes;

  double get porcentajeTranscurrido {
    return roundDouble((diasHabilesTranscurridos/(diasHabilesTranscurridos+diasHabilesRestantes))*100 ,2);
    //return roundDouble(4,2);
  }
}

double roundDouble(double value, int places){ 
  num mod = pow( 10, places); 
  return ((value * mod).round().toDouble() / mod); 
}

String formatNumber(double number) {
  final NumberFormat numberFormat = NumberFormat('#,###');
  return numberFormat.format(number);
}

String formatNumberDecimal(double number) {
  number = roundDouble(number,2);
  final NumberFormat numberFormat = NumberFormat('#,###.##');
  return numberFormat.format(number);
}

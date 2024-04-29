
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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';



DatabaseHelper _databaseHelper = DatabaseHelper();
List<PedidoRenglonEspera> pedidoRenglonEspera = [];


//Funcion para buscar pedidorenglon en nube
Future<void> _fetchPedidoRenglon(String numeroPedido) async {
  final response = await http.get(
    Uri.parse('https://nodejs-mysql-railway-blanking-production.up.railway.app/PedidosRenglones/$numeroPedido'),
  );
  if (response.statusCode == 200) {
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(json.decode(response.body));
    pedidoRenglonEspera = data.map((Map<String, dynamic> map) {
      return PedidoRenglonEspera(
        indice: 1,
        tarifa: 'A',
        codigoProducto: map['CodigoProducto'],
        nombreProducto: map['Descripcion'],
        iva: map['iva'],
        cantidadxBulto: 1,
        descuento: 0,

        numeroCodigoProducto: map['CodigoProducto'],  // Asegúrate de ajustar según tu estructura de datos
        numero: map['Numero'],
        almacen: map['Almacen'],
        cantidad: double.parse(map['Cantidad'].toString()),  // Convierte a String antes de parsear
        precioMoneda: double.parse(map['Precio2'].toString()),
        totalRenglon: double.parse(map['TotalRenglon2'].toString()),
        dsctoAdic: 0,
        // ... otros campos ...
      );
    }).toList();
  } else {
    throw Exception('Failed to fetch Pedido Renglon');
  }
}

// Función para generar el PDF
Future<void> generatePDF(Pedido pedido) async {
  
  var myTheme = pw.ThemeData.withFont(
    base: pw.Font.ttf(await rootBundle.load("assets/arial.ttf")),
    bold: pw.Font.ttf(await rootBundle.load("assets/arial_bold.ttf")),
  );
  
  final pdf = pw.Document(theme: myTheme,);

  

  // Cargar fuente Arial
  final ByteData fontData = await rootBundle.load('assets/arial.ttf');
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());

  final ByteData data = await rootBundle.load('assets/images/ic_launcher.png');
  Uint8List imageData = data.buffer.asUint8List();

  // Crear una imagen a partir de los datos Uint8List
  final pdfImage = pw.MemoryImage(imageData);

  Cliente _cliente;

  if (pedido.numero.substring(0, 2)=='AS') {
    await _fetchPedidoRenglon(pedido.numero);
    _cliente = await _databaseHelper.getClienteEspecificohttp(pedido.rif);
  } else {
    pedidoRenglonEspera = await _databaseHelper.getPedidosRenglonesEspera(pedido.numero);
    _cliente = await _databaseHelper.getClienteEspecifico(pedido.rif);
  }
  
  

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      build: (pw.Context context) {
        return [
          // Header
          pw.Container(
            //alignment: pw.Alignment.center,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(pdfImage, height: 50, width: 154),
                  ],
                ),                
                pw.Text('AV PRINCIPAL LOCAL NRO S/N SECTOR LA FLORESTA\nDESPUES DE HA TRACTOR VALERA TRUJILLO ZONA POSTAL 3101\nTELEFONO(S): 0414-732.84.43\nE-MAIL: inbalpaca@gmail.com', 
                  //style: pw.TextStyle(font: ttf,fontSize: 9),
                  style: pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Container(
            //width: 500, // Ajusta el ancho según tus necesidades
            child: 
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Nombre o Razòn Social: ',
                                style: pw.TextStyle(
                                  fontSize: 10, // Tamaño de fuente deseado
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.left,
                              ),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text('RIF: ',
                                    style: pw.TextStyle(
                                      fontSize: 10, // Tamaño de fuente deseado
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                    textAlign: pw.TextAlign.left,
                                  ),
                                  pw.Column(
                                    mainAxisAlignment: pw.MainAxisAlignment.start,
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.SizedBox(
                                        height: 2
                                      ),
                                      pw.Text( 
                                        '${pedido.rif}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                              ),
                            ],
                          ),
                          pw.Container(
                            width: 234,
                            child: 
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  height: 2
                                ),
                                pw.Text( 
                                  '${pedido.nombre}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Domicilio Fiscal: ',
                            style: pw.TextStyle(
                              fontSize: 10, // Tamaño de fuente deseado
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                          pw.Container(
                            width: 274,
                            child:
                              pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  height: 2
                                ),
                                pw.Text( 
                                  '${_cliente.direccion}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text('Telefono: ',
                                style: pw.TextStyle(
                                  fontSize: 10, // Tamaño de fuente deseado
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.left,
                              ),
                              pw.Container(
                                width: 187,
                                child:
                                pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.SizedBox(
                                      height: 2
                                    ),
                                    pw.Text( 
                                      '${_cliente.telefonos}',
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text('Vendedor: ',
                                style: pw.TextStyle(
                                  fontSize: 10, // Tamaño de fuente deseado
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.left,
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    height: 2
                                  ),
                                  pw.Text( 
                                    '${pedido.nombreVendedor}',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),                          
                        ]
                      ),
                    ]
                  ),
                  
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(pedido.numero.startsWith('AS') ? 'Pedido' : 'Cotizaciòn', 
                        style: pw.TextStyle(
                              fontSize: 10, // Tamaño de fuente deseado
                              fontWeight: pw.FontWeight.bold,
                            ),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.Text(pedido.numero, 
                        style: pw.TextStyle(
                              fontSize: 10, // Tamaño de fuente deseado
                              fontWeight: pw.FontWeight.bold,
                            ),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Emision: ', 
                            style: pw.TextStyle(
                                  fontSize: 10, // Tamaño de fuente deseado
                                ),
                            textAlign: pw.TextAlign.right,
                          ),    
                          pw.Text('${DateFormat('dd/MM/yyyy').format(DateTime.parse(pedido.fechaEmision))}', 
                            style: pw.TextStyle(
                                  fontSize: 10, // Tamaño de fuente deseado
                                ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ],
                      ),
                      
                    ],
                  ),

                ],
            ),
          ),

          pw.Container(
            child: 
            pw.Divider(
              height: 14, 
              color: PdfColors.grey400,
              borderStyle: pw.BorderStyle.dotted,
            ),
          ),
          //pw.SizedBox(height: 10),

          // Encabezado pedido
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 65,
                child:
                pw.Text(
                  'Codigo',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(width: 7),
              pw.Container(
                width: 29,
                child:
                pw.Text(
                  'Cant.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.SizedBox(width: 7),
              pw.Container(
                width: 236,
                child:
                pw.Text(
                  'Descripciòn',
                  // verneuzlasdsadffsasfssf
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(width: 7),
              pw.Container(
                width: 64,
                child:
                pw.Text(
                  'Precio Unit.',
                  // verneuzlasdsadffsasfssf
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.SizedBox(width: 7),
              pw.Container(
                width: 44,
                child:
                pw.Text(
                  'Total',
                  // verneuzlasdsadffsasfssf
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 2),
          // Detalles del Pedido
          pw.Column(
            children: [
              for (var item in pedidoRenglonEspera)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 65,
                    child:
                    pw.Text(
                      item.codigoProducto,
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 7),
                  pw.Container(
                    width: 27,
                    child:
                    pw.Text(
                      '${item.cantidad.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.SizedBox(width: 7),
                  pw.Container(
                    width: 250,
                    child:
                    pw.Text(
                      item.nombreProducto,
                      // verneuzlasdsadffsasfssf
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 7),
                  pw.Container(
                    width: 52,
                    child:
                    pw.Text(
                      '${(item.totalRenglon/item.cantidad).toStringAsFixed(4)}',
                      // verneuzlasdsadffsasfssf
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.SizedBox(width: 7),
                  pw.Container(
                    width: 44,
                    child:
                    pw.Text(
                      '${item.totalRenglon.toStringAsFixed(2)}',
                      // verneuzlasdsadffsasfssf
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),           
        ];
      },
      footer: (pw.Context context) {
        return pw.Container(
          //alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10.0),
          child: 
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                child: 
                pw.Divider(
                  height: 14, 
                  color: PdfColors.grey600,
                  borderStyle: pw.BorderStyle.dotted,
                ),
              ),
              // Total y Detalles Financieros
              pw.Container(
                margin: pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(pedido.numero.startsWith('AS') ? 'Total Bruto' : 'Total Bruto', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,)),
                        
                        pw.Text('\$ ${NumberFormat('#,##0.00', 'es').format(pedido.totalBruto2)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(pedido.numero.startsWith('AS') ? 'Total Impuesto' : 'Total Impuesto', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,)),
                        
                        pw.Text('\$ ${NumberFormat('#,##0.00', 'es').format(pedido.impuesto2)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(pedido.numero.startsWith('AS') ? 'Total Pedido' : 'Total Cotizaciòn', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,)),
                        
                        pw.Text('\$ ${NumberFormat('#,##0.00', 'es').format(pedido.totalPedido2)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,)),
                      ],
                    ),
                  ],
                ),
              ),
              
              /*
              pw.Text('REALIZAR TRANSFERENCIAS A NOMBRE DE: TORNILLOS ESTRADA TORESCA, C.A.', 
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.left,
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 50,
                    child:
                    pw.Text('BANCOS: ', 
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.left,
                    ),
                  ),
                  pw.SizedBox(
                    width: 5
                  ),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        height: 2,
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 80,
                            child:
                            pw.Text('PROVINCIAL \nMERCANTIL \nFONDO COMUN ', 
                              style: pw.TextStyle(fontSize: 10,),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                          pw.Container(
                            width: 120,
                            child:
                            pw.Text('01080108780100072561\n01050056771056310227\n01510140701000203573', 
                              style: pw.TextStyle(fontSize: 10,),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.SizedBox(
                            width: 10
                          ),
                          pw.Container(
                            width: 60,
                            child:
                            pw.Text('BANESCO \nVENEZUELA \nBANCARIBE ', 
                              style: pw.TextStyle(fontSize: 10,),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                          pw.Container(
                            width: 120,
                            child:
                            pw.Text('01340188831881015230\n01020747910000030494\n01140433204330098762', 
                              style: pw.TextStyle(fontSize: 10,),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              */
            ],
          ),
        );
      },
    ),
  );
  
  final output = await getTemporaryDirectory();

  // Obtiene el directorio de descargas
  //final downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    
  // Crea el archivo en el directorio de descargas
  //final file = File('/storage/emulated/0/Download/pedido${pedido.numero}.pdf');

  final Random random = Random();
  final int numeroAleatorio = random.nextInt(10000); // Puedes ajustar el rango según tus necesidades
  final String nombreArchivo = 'pedido${pedido.numero}_$numeroAleatorio.pdf';

  final file = File('/storage/emulated/0/Download/$nombreArchivo');

  final bytes = await pdf.save();
  
  // Guarda el PDF en el archivo
  await file.writeAsBytes(bytes);
      
  // Puedes mostrar la ruta del archivo si lo deseas
  print('PDF guardado en: ${file.path}');
  
  // Abre el documento PDF después de generarlo
  try {
    await OpenDocument.openDocument(filePath: file.path);
  } catch (e) {
    print('Error al abrir el documento PDF: $e');
    // Manejar el error según sea necesario
  }
}
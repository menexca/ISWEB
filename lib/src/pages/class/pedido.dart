class PedidoEspera {
  String numero;
  String codigoCliente; 
  double totalNeto;
  double totalImpuesto;
  double totalPedido;
  String vendedor;
  String comentario;
  String nombreCliente;
  DateTime fecha;
  String nombreVendedor;
  String estatus;
  int items;
  double bultos;
  String rif;
  double descuentoGlobal;
  int diasCredito;

  PedidoEspera({
    required this.numero,
    required this.codigoCliente,
    required this.totalNeto,
    required this.totalImpuesto,
    required this.totalPedido,
    required this.vendedor,
    required this.comentario,
    required this.nombreCliente,
    required this.fecha,
    required this.nombreVendedor,
    required this.estatus,
    required this.items,
    required this.bultos,
    required this.rif,
    required this.descuentoGlobal,
    required this.diasCredito,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'codigoCliente': codigoCliente,
      'totalNeto': totalNeto,
      'totalImpuesto': totalImpuesto,
      'totalPedido': totalPedido,
      'vendedor': vendedor,
      'comentario': comentario,
      'nombreCliente': nombreCliente,
      'fecha': fecha.toIso8601String(), 
      'nombreVendedor': nombreVendedor,
      'estatus': estatus,
      'items': items,
      'bultos': bultos,
      'rif': rif,
      'descuentoGlobal': descuentoGlobal,
      'diasCredito': diasCredito,
    };
  }

  factory PedidoEspera.fromMap(Map<String, dynamic> map) {
    return PedidoEspera(
      numero: map['numero'],
      codigoCliente: map['codigoCliente'],
      totalNeto: map['totalNeto'],
      totalImpuesto: map['totalImpuesto'],
      totalPedido: map['totalPedido'],
      vendedor: map['vendedor'],
      comentario: map['comentario'],
      nombreCliente: map['nombreCliente'],
      fecha: DateTime.parse(map['fecha']),
      nombreVendedor: map['nombreVendedor'],
      estatus: map['estatus'],
      items: map['items'],
      bultos: map['bultos'],
      rif: map['rif'],
      descuentoGlobal: map['descuentoGlobal'],
      diasCredito: map['diasCredito'],
    );
  }
}

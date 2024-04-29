class PedidoRenglonEspera {
  String numeroCodigoProducto;
  String numero;
  String almacen;
  double cantidad;
  double precioMoneda;
  double totalRenglon;
  int indice;
  String tarifa;
  String codigoProducto;
  String nombreProducto;
  String iva;
  double cantidadxBulto;
  double descuento;
  double dsctoAdic;

  PedidoRenglonEspera({
    required this.numeroCodigoProducto,
    required this.numero,
    required this.almacen,
    required this.cantidad,
    required this.precioMoneda,
    required this.totalRenglon,
    required this.indice,
    required this.tarifa,
    required this.codigoProducto,
    required this.nombreProducto,
    required this.iva,
    required this.cantidadxBulto,
    required this.descuento,
    required this.dsctoAdic,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'numeroCodigoProducto': numeroCodigoProducto,
      'numero': numero,
      'almacen': almacen,
      'cantidad': cantidad,
      'precioMoneda': precioMoneda,
      'totalRenglon': totalRenglon,
      'indice': indice,
      'tarifa': tarifa,
      'codigoProducto': codigoProducto,
      'nombreProducto': nombreProducto,
      'iva': iva,
      'cantidadxBulto': cantidadxBulto,
      'descuento': descuento,
      'dsctoAdic': dsctoAdic,
    };
  }

  factory PedidoRenglonEspera.fromMap(Map<String, dynamic> map) {
    return PedidoRenglonEspera(
      numeroCodigoProducto: map['numeroCodigoProducto'],
      numero: map['numero'],
      almacen: map['almacen'],
      cantidad: map['cantidad'],
      precioMoneda: map['precioMoneda'],
      totalRenglon: map['totalRenglon'],
      indice: map['indice'],
      tarifa: map['tarifa'],
      codigoProducto: map['codigoProducto'],
      nombreProducto: map['nombreProducto'],
      iva: map['iva'],
      cantidadxBulto: map['cantidadxBulto'],
      descuento: map['descuento'],
      dsctoAdic: map['dsctoAdic'],
    );
  }
}

class Producto {
  String codigoProducto;
  String nombre;
  String nombreBusqueda;
  String iva;
  double cantidadxBulto;
  double existencia;
  double existencia02;
  double existencia03;
  double existenciaVenta;
  double pedidoVenta;
  double precioMoneda;
  String codigoGrupo;
  String marca;

  Producto({
    required this.codigoProducto,
    required this.nombre,
    required this.nombreBusqueda,
    required this.iva,
    required this.cantidadxBulto,
    required this.existencia,
    required this.existencia02,
    required this.existencia03,
    required this.existenciaVenta,
    required this.pedidoVenta,
    required this.precioMoneda,
    required this.codigoGrupo,
    required this.marca,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigoProducto': codigoProducto,
      'nombre': nombre,
      'nombreBusqueda': nombreBusqueda,
      'iva': iva,
      'cantidadxBulto': cantidadxBulto,
      'existencia': existencia,
      'existencia02': existencia02,
      'existencia03': existencia03,
      'existenciaVenta': existenciaVenta,
      'pedidoVenta': pedidoVenta,
      'precioMoneda': precioMoneda,
      'codigoGrupo': codigoGrupo,
      'marca': marca,
    };
  }
  
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      codigoProducto: map['codigoProducto'],
      nombre: map['nombre'],
      nombreBusqueda: map['nombreBusqueda'],
      iva: map['iva'],
      cantidadxBulto: map['cantidadxBulto'],
      existencia: map['existencia'],
      existencia02: map['existencia02'],
      existencia03: map['existencia03'],
      existenciaVenta: map['existenciaVenta'],
      pedidoVenta: map['pedidoVenta'],
      precioMoneda: map['precioMoneda'],
      codigoGrupo: map['codigoGrupo'],
      marca: map['marca'],
    );
  }
}

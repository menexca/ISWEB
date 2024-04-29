import 'dart:collection';

class Vendedor {
  String codigoVendedor;
  String nombre;
  String zona;
  String almacen;
  String rif;
  String nit;
  String supervisadoPor;

  Vendedor({
    required this.codigoVendedor,
    required this.nombre,
    required this.zona,
    required this.almacen,
    required this.rif,
    required this.nit,
    required this.supervisadoPor,
  }); 

  Map<String, dynamic> toMap() {
    return {
      'codigoVendedor': codigoVendedor,
      'nombre': nombre,
      'zona': zona,
      'almacen': almacen,
      'rif': rif,
      'nit': nit,
      'supervisadoPor': supervisadoPor,
    };
  }

  factory Vendedor.fromMap(Map<String, dynamic> map) {
    return Vendedor(
      codigoVendedor: map['codigoVendedor'],
      nombre: map['nombre'],
      zona: map['zona'],
      almacen: map['almacen'],
      rif: map['rif'],
      nit: map['nit'],
      supervisadoPor: map['supervisadoPor'],
    );
  }

}
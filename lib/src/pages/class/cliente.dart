class Cliente {
  String codigoCliente;
  String nombre;
  String nombreBusqueda;
  String razonSocial;
  String direccion;
  int diasVisita;
  String telefonos;
  double limiteCredito;
  double saldoMonedaTotal;
  double saldoMonedaVencido;
  DateTime ultimoPago;
  int proximoVencer;
  String estatus;

  Cliente({
    required this.codigoCliente,
    required this.nombre,
    required this.nombreBusqueda,
    required this.razonSocial,
    required this.direccion,
    required this.diasVisita,
    required this.telefonos,
    required this.limiteCredito,
    required this.saldoMonedaTotal,
    required this.saldoMonedaVencido,
    required this.ultimoPago,
    required this.proximoVencer,
    required this.estatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigoCliente': codigoCliente,
      'nombre': nombre,
      'nombreBusqueda': nombreBusqueda,
      'razonSocial': razonSocial,
      'direccion': direccion,
      'diasVisita': diasVisita,
      'telefonos': telefonos,
      'limiteCredito': limiteCredito,
      'saldoMonedaTotal': saldoMonedaTotal,
      'saldoMonedaVencido': saldoMonedaVencido,
      'ultimoPago': ultimoPago.toIso8601String(),
      'proximoVencer': proximoVencer,
      'estatus': estatus,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      codigoCliente: map['codigoCliente'],
      nombre: map['nombre'],
      nombreBusqueda: map['nombreBusqueda'],
      razonSocial: map['razonSocial'],
      direccion: map['direccion'],
      diasVisita: map['diasVisita'],
      telefonos: map['telefonos'],
      limiteCredito: map['limiteCredito'],
      saldoMonedaTotal: map['saldoMonedaTotal'],
      saldoMonedaVencido: map['saldoMonedaVencido'],
      ultimoPago: DateTime.parse(map['ultimoPago']),
      proximoVencer: map['proximoVencer'],
      estatus: map['estatus'],
    );
  }
}

class Pedido {
  String numero;
  String fechaEmision;
  String nombre;
  String nombreBusqueda;
  String vendedor;
  String nombreVendedor;
  double totalBruto2;
  double impuesto2;
  double totalPedido2;
  String estatus;
  int items;
  double bultos;
  bool visibilidadBoton;
  String comentario;
  String rif;
  int diasCredito;
  double porcentajeFacturado;

  Pedido({
    required this.numero,
    required this.fechaEmision,
    required this.nombre,
    required this.nombreBusqueda,
    required this.vendedor,
    required this.nombreVendedor,
    required this.totalBruto2,
    required this.impuesto2,
    required this.totalPedido2,
    required this.estatus,
    required this.items,
    required this.bultos,
    required this.comentario,
    required this.rif,
    required this.diasCredito,
    required this.porcentajeFacturado,
  }) : visibilidadBoton = false;
}
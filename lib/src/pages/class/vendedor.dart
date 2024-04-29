import 'dart:collection';

class Vendedor {
  String codigoVendedor;
  String nombre;
  String zona;
  String almacen;
  String rif;
  String nit;
  int cantidadClientes;
  int cantidadClientesNuevosMes;
  int cantidadPedidosHoy;
  int cantidadPedidosMes;
  int cantidadClientesAtendidosHoy;
  int cantidadClientesAtendidosMes;
  double meta;
  double porcentajeEfectividad; 
  double totalVentaBruta2;
  double totalDevolucionBruta2;
  double totalFacturacionBruta2;
  double porcentajeAlcanzadoMeta; 
  int diasHabilesMes;
  int diasHabilesTranscurridos;
  int diasHabilesRestantes; 
  double promedioVentaDiaria;
  double diferenciaMeta;
  double objetivoDiario;
  double saldo;
  double vencido; 
  double porcentajeSaldoVencido; 
  double porcentajeVentaVencido;
  String supervisadoPor;
  double cajasVendidas;
  int activo;

  Vendedor({
    required this.codigoVendedor,
    required this.nombre,
    required this.zona,
    required this.almacen,
    required this.rif,
    required this.nit,
    required this.cantidadClientes,
    required this.cantidadClientesNuevosMes,
    required this.cantidadPedidosHoy,
    required this.cantidadPedidosMes,
    required this.cantidadClientesAtendidosHoy,
    required this.cantidadClientesAtendidosMes,
    required this.meta,
    required this.porcentajeEfectividad, 
    required this.totalVentaBruta2,
    required this.totalDevolucionBruta2,
    required this.totalFacturacionBruta2,
    required this.porcentajeAlcanzadoMeta, 
    required this.diasHabilesMes,
    required this.diasHabilesTranscurridos,
    required this.diasHabilesRestantes, 
    required this.promedioVentaDiaria,
    required this.diferenciaMeta,
    required this.objetivoDiario,
    required this.saldo,
    required this.vencido, 
    required this.porcentajeSaldoVencido, 
    required this.porcentajeVentaVencido,
    required this.supervisadoPor,
    required this.cajasVendidas,
    required this.activo,
  }); 

  Map<String, dynamic> toMap() {
    return {
      'codigoVendedor': codigoVendedor,
      'nombre': nombre,
      'zona': zona,
      'almacen': almacen,
      'rif': rif,
      'nit': nit,
      'cantidadClientes' : cantidadClientes,
      'cantidadClientesNuevosMes' : cantidadClientesNuevosMes,
      'cantidadPedidosHoy' : cantidadPedidosHoy,
      'cantidadPedidosMes' : cantidadPedidosMes,
      'cantidadClientesAtendidosHoy' : cantidadClientesAtendidosHoy,
      'cantidadClientesAtendidosMes' : cantidadClientesAtendidosMes,
      'meta' : meta,
      'porcentajeEfectividad' : porcentajeEfectividad, 
      'totalVentaBruta2' : totalVentaBruta2,
      'totalDevolucionBruta2' : totalDevolucionBruta2,
      'totalFacturacionBruta2' : totalFacturacionBruta2,
      'porcentajeAlcanzadoMeta' : porcentajeAlcanzadoMeta, 
      'diasHabilesMes' : diasHabilesMes,
      'diasHabilesTranscurridos' : diasHabilesTranscurridos,
      'diasHabilesRestantes' : diasHabilesRestantes, 
      'promedioVentaDiaria' : promedioVentaDiaria,
      'diferenciaMeta' : diferenciaMeta,
      'objetivoDiario' : objetivoDiario,
      'saldo' : saldo,
      'vencido' : vencido, 
      'porcentajeSaldoVencido' : porcentajeSaldoVencido, 
      'porcentajeVentaVencido' : porcentajeVentaVencido,
      'supervisadoPor' : supervisadoPor,
      'cajasVendidas': cajasVendidas,
      'activo': activo,
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
      cantidadClientes: map['cantidadClientes'],
      cantidadClientesNuevosMes: map['cantidadClientesNuevosMes'],
      cantidadPedidosHoy: map['cantidadPedidosHoy'],
      cantidadPedidosMes: map['cantidadPedidosMes'],
      cantidadClientesAtendidosHoy: map['cantidadClientesAtendidosHoy'],
      cantidadClientesAtendidosMes: map['cantidadClientesAtendidosMes'],
      meta: map['meta'],
      porcentajeEfectividad: map['porcentajeEfectividad'], 
      totalVentaBruta2: map['totalVentaBruta2'],
      totalDevolucionBruta2: map['totalDevolucionBruta2'],
      totalFacturacionBruta2: map['totalFacturacionBruta2'],
      porcentajeAlcanzadoMeta: map['porcentajeAlcanzadoMeta'], 
      diasHabilesMes: map['diasHabilesMes'],
      diasHabilesTranscurridos: map['diasHabilesTranscurridos'],
      diasHabilesRestantes: map['diasHabilesRestantes'], 
      promedioVentaDiaria: map['promedioVentaDiaria'],
      diferenciaMeta: map['diferenciaMeta'],
      objetivoDiario: map['objetivoDiario'],
      saldo: map['saldo'],
      vencido: map['vencido'], 
      porcentajeSaldoVencido: map['porcentajeSaldoVencido'], 
      porcentajeVentaVencido: map['porcentajeVentaVencido'],
      supervisadoPor: map['supervisadoPor'],
      cajasVendidas: map['cajasVendidas'],
      activo: map['activo'],
    );
  }

}
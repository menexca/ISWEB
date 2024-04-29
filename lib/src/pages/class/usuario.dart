class Usuario {
  String usuario;
  String contrasena;
  String nombreCompleto;
  String correoElectronico;
  DateTime fechaRegistro;
  DateTime ultimoInicioSesion;
  String rol;
  int estatus;
  String codigoVendedor;
  DateTime fechaNacimiento;
  String direccion;
  String numeroTelefono;
  String cedula;
  bool visibilidadBoton;

  Usuario({
    required this.usuario,
    required this.contrasena,
    required this.nombreCompleto,
    required this.correoElectronico,
    required this.fechaRegistro,
    required this.ultimoInicioSesion,
    required this.rol,
    required this.estatus,
    required this.codigoVendedor,
    required this.fechaNacimiento,
    required this.direccion,
    required this.numeroTelefono,
    required this.cedula,
  }) : visibilidadBoton = false;

  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'contrasena': contrasena,
      'nombreCompleto': nombreCompleto,
      'correoElectronico': correoElectronico,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'ultimoInicioSesion': ultimoInicioSesion.toIso8601String(),
      'rol': rol,
      'estatus': estatus,
      'codigoVendedor': codigoVendedor,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'direccion': direccion,
      'numeroTelefono': numeroTelefono,
      'cedula': cedula,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      usuario: map['usuario'],
      contrasena: map['contrasena'],
      nombreCompleto: map['nombreCompleto'],
      correoElectronico: map['correoElectronico'],
      fechaRegistro: DateTime.parse(map['fechaRegistro']),
      ultimoInicioSesion: DateTime.parse(map['ultimoInicioSesion']),
      rol: map['rol'],
      estatus: map['estatus'],
      codigoVendedor: map['codigoVendedor'],
      fechaNacimiento: DateTime.parse(map['fechaNacimiento']),
      direccion: map['direccion'],
      numeroTelefono: map['numeroTelefono'],
      cedula: map['cedula'],
    );
  }
}

class Cliente {
  String usuario;
  String nombre;
  int estatus;
  int edad;
  String genero;
  DateTime ingreso;
  
  Cliente({
    required this.usuario,
    required this.nombre,
    required this.estatus,
    required this.edad,
    required this.genero,
  }) : ingreso = DateTime.now().subtract(Duration(hours: 4));

  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'nombre': nombre,
      'estatus': estatus,
      'edad': edad,
      'genero': genero,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      usuario: map['usuario'],
      nombre: map['nombre'],
      estatus: map['estatus'],
      edad: map['edad'],
      genero: map['genero'],
    );
  }
}

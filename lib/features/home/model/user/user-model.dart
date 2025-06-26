class UserModel {
  final int codigo;
  final String nombres;
  final String apellidos;
  final String correo;
  final String rol;
  final String junta;
  final DateTime fechaCreacion;

  UserModel({
    required this.codigo,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.rol,
    required this.junta,
    required this.fechaCreacion,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      codigo: json['codigo'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      rol: json['rol'],
      junta: json['junta'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}

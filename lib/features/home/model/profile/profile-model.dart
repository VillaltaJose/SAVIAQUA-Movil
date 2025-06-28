class ProfileModel {
  final String nombres;
  final String apellidos;
  final String correo;
  final int codigoRol;
  final String rol;
  final int codigoJunta;
  final String junta;

  ProfileModel({
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.codigoRol,
    required this.rol,
    required this.codigoJunta,
    required this.junta,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      codigoRol: json['codigoRol'],
      rol: json['rol'],
      codigoJunta: json['codigoJunta'],
      junta: json['junta'],
    );
  }
}

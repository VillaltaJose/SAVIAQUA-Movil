class PozoModel {
  final int codigo;
  final String nombre;
  final String junta;
  final int codigoJunta;
  final double latitude;
  final double longitude;
  final String provincia;
  final String ciudad;
  final String parroquia;
  final DateTime fechaCreacion;

  PozoModel({
    required this.codigo,
    required this.nombre,
    required this.junta,
    required this.codigoJunta,
    required this.latitude,
    required this.longitude,
    required this.provincia,
    required this.ciudad,
    required this.parroquia,
    required this.fechaCreacion,
  });

  factory PozoModel.fromJson(Map<String, dynamic> json) {
    return PozoModel(
      codigo: json['codigo'],
      nombre: json['nombre'],
      junta: json['junta'],
      codigoJunta: json['codigoJunta'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      provincia: json['provincia'],
      ciudad: json['ciudad'],
      parroquia: json['parroquia'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}

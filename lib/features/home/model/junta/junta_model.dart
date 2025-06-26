class JuntaModel {
  final int codigo;
  final String nombre;
  final String? urlLogo;
  final double latitude;
  final double longitude;
  final DateTime fechaCreacion;
  final String provincia;
  final String ciudad;
  final String parroquia;

  JuntaModel({
    required this.codigo,
    required this.nombre,
    this.urlLogo,
    required this.latitude,
    required this.longitude,
    required this.fechaCreacion,
    required this.provincia,
    required this.ciudad,
    required this.parroquia,
  });

  factory JuntaModel.fromJson(Map<String, dynamic> json) {
    return JuntaModel(
      codigo: json['codigo'],
      nombre: json['nombre'],
      urlLogo: json['urlLogo'], // puede venir null
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      provincia: json['provincia'],
      ciudad: json['ciudad'],
      parroquia: json['parroquia'],
    );
  }
}

class CreateJuntaDTO {
  final String? nombre;
  final String? descripcion;
  final int? codigoProvincia;
  final int? codigoCiudad;
  final int? codigoParroquia;
  final double? latitude;
  final double? longitude;

  CreateJuntaDTO({
    required this.nombre,
    required this.descripcion,
    required this.codigoProvincia,
    required this.codigoCiudad,
    required this.codigoParroquia,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'codigoProvincia': codigoProvincia,
      'codigoCiudad': codigoCiudad,
      'codigoParroquia': codigoParroquia,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}



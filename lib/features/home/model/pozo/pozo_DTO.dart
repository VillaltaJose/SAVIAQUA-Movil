class CreatePozoDTO {
  final String? nombre;
  final String? descripcion;
  final int? codigoProvincia;
  final int? codigoCiudad;
  final int? codigoParroquia;
  final int? codigoJunta;
  final double? latitude;
  final double? longitude;

  CreatePozoDTO({
    required this.nombre,
    required this.descripcion,
    required this.codigoProvincia,
    required this.codigoCiudad,
    required this.codigoParroquia,
    required this.codigoJunta,
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
      'codigoJunta': codigoJunta,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}



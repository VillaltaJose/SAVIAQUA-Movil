class CreateJuntaDTO {
  final String? nombre;
  final String? descripcion;
  final int? provinciaId;
  final int? ciudadId;
  final int? parroquiaId;
  final double? latitude;
  final double? longitude;

  CreateJuntaDTO({
    required this.nombre,
    required this.descripcion,
    required this.provinciaId,
    required this.ciudadId,
    required this.parroquiaId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'provinciaId': provinciaId,
      'ciudadId': ciudadId,
      'parroquiaId': parroquiaId,
      'latitud': latitude,
      'longitud': longitude,
    };
  }
}



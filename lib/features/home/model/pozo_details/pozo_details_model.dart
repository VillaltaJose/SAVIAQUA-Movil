class PozoDetailsModel {
  final DateTime fechaRegistro;
  final double m1;
  final double m2;
  final double m3;

  PozoDetailsModel({
    required this.fechaRegistro,
    required this.m1,
    required this.m2,
    required this.m3,
  });

  factory PozoDetailsModel.fromJson(Map<String, dynamic> json) {
    return PozoDetailsModel(
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      m1: (json['m1'] as num).toDouble(),
      m2: (json['m2'] as num).toDouble(),
      m3: (json['m3'] as num).toDouble(),
    );
  }
}

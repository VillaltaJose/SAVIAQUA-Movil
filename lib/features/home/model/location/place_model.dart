class LugarModel {
  final int codigo;
  final String nombre;

  LugarModel({required this.codigo, required this.nombre});

  factory LugarModel.fromJson(Map<String, dynamic> json) {
    return LugarModel(
      codigo: json['codigo'],
      nombre: json['nombre'],
    );
  }
}

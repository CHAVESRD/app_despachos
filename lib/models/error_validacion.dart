import 'dart:convert';

enum Severidad { error, aviso, info }

class BErrorValidacion {
  static const _id = "id";
  static const _msj = "mensaje";
  static const _cod = "codigo";
  static const _severidad = "gravedad";
  String? id;
  late String mensaje;
  String? codigo;
  late Severidad gravedad;
  BErrorValidacion({required this.mensaje, required this.gravedad, this.id = "", this.codigo = ""});
  factory BErrorValidacion.fromJson(String texto) => BErrorValidacion.fromMap(json.decode(texto));

  factory BErrorValidacion.fromMap(Map<String, dynamic> json) => BErrorValidacion(
        mensaje: json[_msj],
        gravedad: Severidad.values[json[_severidad]],
        id: json[_id],
        codigo: json[_cod],
      );
  String toJson() => json.encode(toMap());
  Map<String, dynamic> toMap() => {_id: id ?? "", _msj: mensaje, _cod: codigo ?? "", _severidad: gravedad};
}

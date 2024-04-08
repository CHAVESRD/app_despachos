// ignore_for_file: file_names

import 'dart:convert';

class BECompania {
  BECompania(
      {required this.codigo, required this.numero, required this.nombre});

  int codigo;
  String numero;
  String nombre;

  factory BECompania.fromJson(String str) =>
      BECompania.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BECompania.fromMap(Map<String, dynamic> json) => BECompania(
        codigo: json["idCompania"],
        numero: json["numCompania"],
        nombre: json["nomCompania"],
      );

  Map<String, dynamic> toMap() => {
        "idCompania": codigo,
        "numCompania": numero,
        "nomCompania": nombre,
      };
}

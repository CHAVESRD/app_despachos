// ignore_for_file: file_names

import 'dart:convert';

class BEFaltantes {
  BEFaltantes({required this.facturas, required this.bultos});

  String facturas;

  List<String> bultos;

  factory BEFaltantes.fromJson(String str) =>
      BEFaltantes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEFaltantes.fromMap(Map<String, dynamic> json) => BEFaltantes(
        facturas: json["facturas"],
        bultos: List<String>.from(json["bultos"].map((x) => (x))),
      );

  Map<String, dynamic> toMap() => {
        "facturas": facturas,
        "bultos": List<dynamic>.from(bultos.map((x) => x)),
      };
}

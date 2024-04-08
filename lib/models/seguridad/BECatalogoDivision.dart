// ignore_for_file: file_names

import 'dart:convert';

class BECatalogoDivision {
  BECatalogoDivision({required this.codigo, required this.nombre});

  int codigo;
  String nombre;

  factory BECatalogoDivision.fromJson(String str) =>
      BECatalogoDivision.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BECatalogoDivision.fromMap(Map<String, dynamic> json) =>
      BECatalogoDivision(
        codigo: json["codigoConexion"],
        nombre: json["nombreEmpresa"],
      );

  Map<String, dynamic> toMap() => {
        "codigoConexion": codigo,
        "nombreEmpresa": nombre,
      };
}

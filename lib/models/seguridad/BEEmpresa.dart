// ignore_for_file: file_names

import 'dart:convert';

class BEEmpresa {
  BEEmpresa({required this.codigo, required this.nombre});

  int codigo;
  String nombre;

  factory BEEmpresa.fromJson(String str) => BEEmpresa.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEEmpresa.fromMap(Map<String, dynamic> json) => BEEmpresa(
        codigo: json["codigoConexion"],
        nombre: json["nombreEmpresa"],
      );

  Map<String, dynamic> toMap() => {
        "codigoConexion": codigo,
        "nombreEmpresa": nombre,
      };
}

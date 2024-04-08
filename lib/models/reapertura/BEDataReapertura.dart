// ignore_for_file: file_names

import 'dart:convert';

class BEDataReapertura {
  BEDataReapertura({this.codigo, this.usuario, this.fecha});

  int? codigo;
  String? usuario;
  DateTime? fecha;

  factory BEDataReapertura.fromJson(String str) =>
      BEDataReapertura.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEDataReapertura.fromMap(Map<String, dynamic> json) =>
      BEDataReapertura(
        codigo: json["codigo"],
        usuario: json["usuario"],
        fecha: DateTime.tryParse(json["fecha"] ?? ''),
      );

  Map<String, dynamic> toMap() => {
        "codigo": codigo,
        "usuario": usuario,
        "fecha": fecha?.toIso8601String(),
      };
}

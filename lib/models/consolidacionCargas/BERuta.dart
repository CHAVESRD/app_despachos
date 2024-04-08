// ignore_for_file: file_names

import 'dart:convert';

class BERuta {
  BERuta({this.codigoCompania, this.codigo, this.numero, this.nombre});

  int? codigoCompania;
  int? codigo;
  String? numero;
  String? nombre;

  factory BERuta.fromJson(String str) => BERuta.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  List jsonList = [];
  factory BERuta.fromMap(Map<String, dynamic> json) => BERuta(
        codigoCompania: json["codigoCompania"],
        codigo: json["codigo"],
        numero: json["numero"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toMap() => {
        "codigoCompania": codigoCompania,
        "codigo": codigo,
        "numero": numero,
        "nombre": nombre,
      };
}

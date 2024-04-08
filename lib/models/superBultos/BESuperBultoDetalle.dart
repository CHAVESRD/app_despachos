// ignore_for_file: file_names

import 'dart:convert';

class BESuperBultoDetalle {
  BESuperBultoDetalle(
      {required this.idSuperBulto,
      required this.codigoFactura,
      required this.numeroFactura,
      required this.numeroBulto,
      required this.fechaHora,
      required this.nombreUsuario,
       this.totalBultos=0});

  int idSuperBulto;
  int codigoFactura;
  String? numeroFactura;
  String? numeroBulto;
  DateTime? fechaHora;
  String? nombreUsuario;
  int? totalBultos;

  factory BESuperBultoDetalle.fromJson(String str) =>
      BESuperBultoDetalle.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BESuperBultoDetalle.fromMap(Map<String, dynamic> json) =>
      BESuperBultoDetalle(
        idSuperBulto: json["idSuperBulto"],
        codigoFactura: json["codigoFactura"],
        numeroFactura: json["numeroFactura"],
        numeroBulto: json["numeroBulto"],
        fechaHora: DateTime.tryParse(json["fechaHora"] ?? ''),
        nombreUsuario: json["nombreUsuario"],
        totalBultos: json["totalBultos"],
      );

  Map<String, dynamic> toMap() => {
        "idSuperBulto": idSuperBulto,
        "codigoFactura": codigoFactura,
        "numeroFactura": numeroFactura,
        "numeroBulto": numeroBulto,
        "fechaHora": fechaHora?.toIso8601String(),
        "nombreUsuario": nombreUsuario,
           "total": totalBultos,
      };
}

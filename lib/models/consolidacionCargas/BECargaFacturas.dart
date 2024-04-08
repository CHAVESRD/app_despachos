// ignore_for_file: file_names

import 'dart:convert';

class BECargaFacturas {
  BECargaFacturas(
      {this.idCarga,
      this.codigoFactura,
      this.numeroFactura,
      this.fechaHora,
      this.nombreUsuario});

  int? idCarga;
  int? codigoFactura;
  String? numeroFactura;
  DateTime? fechaHora;
  String? nombreUsuario;

  factory BECargaFacturas.fromJson(String str) =>
      BECargaFacturas.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  List jsonList = [];
  factory BECargaFacturas.fromMap(Map<String, dynamic> json) => BECargaFacturas(
        idCarga: json["idCarga"],
        codigoFactura: json["codigoFactura"],
        numeroFactura: json["numeroFactura"],
        fechaHora: DateTime.tryParse(json["fechaHora"] ?? ''),
        nombreUsuario: json["nombreUsuario"],
      );

  Map<String, dynamic> toMap() => {
        "idCarga": idCarga,
        "codigoFactura": codigoFactura,
        "numeroFactura": numeroFactura,
        "fechaHora": fechaHora?.toIso8601String(),
        "nombreUsuario": nombreUsuario,
      };
}

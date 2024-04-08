// ignore_for_file: file_names

import 'dart:convert';

class BEFacturaConsolidar {
  BEFacturaConsolidar({this.codigoFactura, this.numeroFactura});

  int? codigoFactura;
  String? numeroFactura;

  factory BEFacturaConsolidar.fromJson(String str) =>
      BEFacturaConsolidar.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEFacturaConsolidar.fromMap(Map<String, dynamic> json) =>
      BEFacturaConsolidar(
        codigoFactura: json["codigoFactura"],
        numeroFactura: json["numeroFactura"],
      );

  Map<String, dynamic> toMap() => {
        "codigoFactura": codigoFactura,
        "numeroFactura": numeroFactura,
      };
}

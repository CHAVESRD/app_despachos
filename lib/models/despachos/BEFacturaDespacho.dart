// ignore_for_file: file_names

import 'dart:convert';

class BEFacturaDespacho {
  static const String idFactura = "codigoFactura",
                      codFactura ="numeroFactura",
                      cliente = "nombreCliente",
                      codBulto = "numeroBulto",
                      bod= "bodega",
                      sucursal ="nombreSucursal",
                      fechaRegistro ="fecha",
                      tpRetiro = "tipoRetiro";
  BEFacturaDespacho(
      {this.codigoFactura,
      this.numeroFactura,
      this.nombreCliente,
      this.fecha,
      this.numeroBulto,
      this.bodega,
      this.nombreSucursal,
      this.tipoRetiro});

  int? codigoFactura;
  String? numeroFactura;
  String? nombreCliente;
  DateTime? fecha;
  String? numeroBulto;
  String? bodega;
  String? nombreSucursal;
  int? tipoRetiro;

  factory BEFacturaDespacho.fromJson(String str) =>
      BEFacturaDespacho.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEFacturaDespacho.fromMap(Map<String, dynamic> json) =>
      BEFacturaDespacho(
        codigoFactura: json[ idFactura],
        numeroFactura: json[codFactura],
        nombreCliente: json[cliente],
        numeroBulto: json[codBulto],
        bodega: json[bod],
        nombreSucursal: json[sucursal],
        fecha: DateTime.tryParse(json[fechaRegistro] ?? ''),
        tipoRetiro: json[tpRetiro]
      );

  Map<String, dynamic> toMap() => {
        idFactura: codigoFactura,
        codFactura: numeroFactura,
        cliente: nombreCliente,
        codBulto: numeroBulto,
        bod: bodega,
        sucursal: nombreSucursal,
        fechaRegistro: fecha?.toIso8601String(),
        tpRetiro: tipoRetiro
      };
}

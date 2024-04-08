// ignore_for_file: file_names

import 'dart:convert';

class BEBultoConsolidar {
  static const tpRetiro = "tipoRetiro";
  BEBultoConsolidar(
      {this.idSuperBulto,
      this.codigoFactura,
      this.numeroFactura,
      this.numeroBulto,
      this.cliente,
      this.sucursal,
      this.codigoPedido,
      this.numeroOrdenCompra,
      this.numeroBoleta,
      this.numeroPedido,
      this.bodega,
      this.numeroSuperBulto,
      this.tipoRetiro});

  int? idSuperBulto;
  int? codigoFactura;
  String? numeroFactura;
  String? numeroBulto;
  String? cliente;
  String? sucursal;
  int? codigoPedido;
  String? numeroOrdenCompra;
  int? numeroBoleta;
  int? numeroPedido;
  String? bodega;
  String? numeroSuperBulto;
  int? tipoRetiro;

  factory BEBultoConsolidar.fromJson(String str) =>
      BEBultoConsolidar.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEBultoConsolidar.fromMap(Map<String, dynamic> json) =>
      BEBultoConsolidar(
        idSuperBulto: json["idSuperBulto"],
        codigoFactura: json["codigoFactura"],
        numeroFactura: json["numeroFactura"],
        numeroBulto: json["numeroBulto"],
        cliente: json["cliente"],
        sucursal: json["sucursal"],
        codigoPedido: json["codigoPedido"],
        numeroOrdenCompra: json["numeroOrdenCompra"],
        numeroBoleta: json["numeroBoleta"],
        numeroPedido: json["numeroPedido"],
        bodega: json["bodega"],
        numeroSuperBulto: json["numeroSuperBulto"],
        tipoRetiro: json[tpRetiro]
      );

  Map<String, dynamic> toMap() => {
        "idSuperBulto": idSuperBulto,
        "codigoFactura": codigoFactura,
        "numeroFactura": numeroFactura,
        "numeroBulto": numeroBulto,
        "cliente": cliente,
        "sucursal": sucursal,
        "codigoPedido": codigoPedido,
        "numeroOrdenCompra": numeroOrdenCompra,
        "numeroBoleta": numeroBoleta,
        "numeroPedido": numeroPedido,
        "bodega": bodega,
        "numeroSuperBulto": numeroSuperBulto,
        tpRetiro:tipoRetiro
      };
}

// ignore_for_file: file_names

import 'dart:convert';

class BECargaDetalle {
  BECargaDetalle(
      {required this.idCarga,
      required this.idSuperBulto,
      required this.codigoFactura,
      required this.numeroFactura,
      required this.numeroBulto,
      required this.fechaHora,
      required this.nombreUsuario,
      this.nombreCliente,
      this.sucursal,
      this.codigoPedido,
      this.numeroOrdenCompra,
      this.numeroBoleta,
      this.numeroPedido,
      this.numeroBodega,
      this.codigoTipoEmpaque,
      this.numeroSuperBulto});

  int? idCarga;
  int? idSuperBulto;
  int? codigoFactura;
  String? numeroFactura;
  String? numeroBulto;
  DateTime? fechaHora;
  String? nombreUsuario;
  String? nombreCliente;
  String? sucursal;
  int? codigoPedido;
  String? numeroOrdenCompra;
  int? numeroBoleta;
  int? numeroPedido;
  String? numeroBodega;
  int? codigoTipoEmpaque;
  String? numeroSuperBulto;

  factory BECargaDetalle.fromJson(String str) =>
      BECargaDetalle.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BECargaDetalle.fromMap(Map<String, dynamic> json) => BECargaDetalle(
        idCarga: json["idCarga"],
        idSuperBulto: json["idSuperBulto"],
        codigoFactura: json["codigoFactura"],
        numeroFactura: json["numeroFactura"],
        numeroBulto: json["numeroBulto"],
        fechaHora: DateTime.tryParse(json["fechaHora"] ?? ''),
        nombreUsuario: json["nombreUsuario"],
        nombreCliente: json["nombreCliente"],
        sucursal: json["sucursal"],
        codigoPedido: json["codigoPedido"],
        numeroOrdenCompra: json["numeroOrdenCompra"],
        numeroBoleta: json["numeroBoleta"],
        numeroPedido: json["numeroPedido"],
        numeroBodega: json["numeroBodega"],
        codigoTipoEmpaque: json["codigoTipoEmpaque"],
        numeroSuperBulto: json["numeroSuperBulto"],
      );

  Map<String, dynamic> toMap() => {
        "idCarga": idCarga,
        "idSuperBulto": idSuperBulto,
        "codigoFactura": codigoFactura,
        "numeroFactura": numeroFactura,
        "numeroBulto": numeroBulto,
        "fechaHora": fechaHora?.toIso8601String(),
        "nombreUsuario": nombreUsuario,
        "nombreCliente": nombreCliente,
        "sucursal": sucursal,
        "codigoPedido": codigoPedido,
        "numeroOrdenCompra": numeroOrdenCompra,
        "numeroBoleta": numeroBoleta,
        "numeroPedido": numeroPedido,
        "numeroBodega": numeroBodega,
        "codigoTipoEmpaque": codigoTipoEmpaque,
        "numeroSuperBulto": numeroSuperBulto,
      };
}

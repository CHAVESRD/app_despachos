// ignore_for_file: file_names

import 'dart:convert';

import '../models.dart';

class BECargaEncabezado {
  BECargaEncabezado(
      {required this.idCarga,
      required this.numeroCarga,
      required this.nombreUsuario,
      this.fechaHoraInicio,
      this.fechaHoraFin,
     // required this.codigoRuta, DCR(20231005):wi47301
     //required this.ruta,
      required this.estado,
       required this.detalle,
      required this.facturas
      }
      );

  int idCarga;
  int numeroCarga;
  String nombreUsuario;
  DateTime? fechaHoraInicio;
  DateTime? fechaHoraFin;
  //int codigoRuta; DCR(20231005):wi47301
   //String ruta; DCR(20231005):wi47301
 String estado;
  List<BECargaDetalle> detalle;
  List<BECargaFacturas> facturas;

  factory BECargaEncabezado.fromJson(String str) =>
      BECargaEncabezado.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BECargaEncabezado.fromMap(Map<String, dynamic> json) =>
      BECargaEncabezado(
        idCarga: json["idCarga"],
        numeroCarga: json["numeroCarga"],
        nombreUsuario:  json["nombreUsuario"] ??'',
        fechaHoraInicio: DateTime.tryParse(json["fechaHoraInicio"] ?? ''),
        fechaHoraFin: DateTime.tryParse(json["fechaHoraFin"] ?? ''),
        estado: json["estado"]??'',
        //codigoRuta: json["codigoRuta"], DCR(20231005):wi47301
        //ruta: json["ruta"], DCR(20231005):wi47301
        detalle: List<BECargaDetalle>.from(
            json["cargaDetalle"].map((x) => BECargaDetalle.fromMap(x))),
        facturas: List<BECargaFacturas>.from(
            json["facturas"].map((x) => BECargaFacturas.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "idCarga": idCarga,
        "numeroCarga": numeroCarga,
        "nombreUsuario": nombreUsuario,
        "fechaHoraInicio": fechaHoraInicio?.toIso8601String(),
        "fechaHoraFin": fechaHoraFin?.toIso8601String(),
        //"codigoRuta": codigoRuta, DCR(20231005):wi47301
        //"ruta": ruta, DCR(20231005):wi47301
       "estado": estado,
        "cargaDetalle": List<dynamic>.from(detalle.map((x) => x.toMap())),
        "facturas": List<dynamic>.from(facturas.map((x) => x.toMap())),
      };
}

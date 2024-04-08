// ignore_for_file: file_names

import 'dart:convert';

import '../models.dart';

class BESuperBultoEncabezado {
  BESuperBultoEncabezado(
      {this.idSuperBulto,
      this.numeroSuperBulto,
      this.nombreUsuario,
      this.fechaHoraInicio,
      this.fechaHoraFin,
      this.nombreCliente,
      this.nombreSucursal,
      this.estado,
      this.detalle});

  int? idSuperBulto;
  int? numeroSuperBulto;
  String? nombreUsuario;
  DateTime? fechaHoraInicio;
  DateTime? fechaHoraFin;
  String? nombreCliente;
  String? nombreSucursal;
  String? estado;
  List<BESuperBultoDetalle>? detalle;

  /*factory BESuperBultoEncabezado.fromJson(dynamic json) {
    return BESuperBultoEncabezado(
      (int.parse(json["idSuperBulto"].toString())),
      (int.parse(json['numeroSuperBulto'].toString())),
      (json['nombreUsuario'].toString()),
      (DateTime.tryParse(json["fechaHoraInicio"] ?? '')),
      (DateTime.tryParse(json["fechaHoraFin"] ?? '')),
      (json['nombreCliente'].toString()),
      (json['nombreSucursal'].toString()),
      (json['estado'].toString()),
      [],
    );
  }*/

  factory BESuperBultoEncabezado.fromJson(String str) =>
      BESuperBultoEncabezado.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BESuperBultoEncabezado.fromMap(Map<String, dynamic> json) =>
      BESuperBultoEncabezado(
        idSuperBulto: json["idSuperBulto"],
        numeroSuperBulto: json["numeroSuperBulto"],
        nombreUsuario: json["nombreUsuario"],
        fechaHoraInicio: DateTime.tryParse(json["fechaHoraInicio"] ?? ''),
        fechaHoraFin: DateTime.tryParse(json["fechaHoraFin"] ?? ''),
        nombreCliente: json["nombreCliente"],
        nombreSucursal: json["nombreSucursal"],
        estado: json["estado"],
        detalle: List<BESuperBultoDetalle>.from(json["superBultoDetalle"]
            .map((x) => BESuperBultoDetalle.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "idSuperBulto": idSuperBulto,
        "numeroSuperBulto": numeroSuperBulto,
        "nombreUsuario": nombreUsuario,
        "fechaHoraInicio": fechaHoraInicio?.toIso8601String(),
        "fechaHoraFin": fechaHoraFin?.toIso8601String(),
        "nombreCliente": nombreCliente,
        "nombreSucursal": nombreSucursal,
        "estado": estado,
      "superBultoDetalle": detalle.toString().isNotEmpty ?  List<dynamic>.from(detalle!.map((x) => x.toMap())) : [],
      };
    
}




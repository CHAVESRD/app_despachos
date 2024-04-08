// ignore_for_file: file_names

import 'dart:convert';

class BEReapertura {
  BEReapertura(
      {required this.idRegistro,
      required this.nombreUsuario,
      required this.nombreProceso,
      required this.codigoReferencia,
      required this.motivo});

  int idRegistro;
  String nombreUsuario;
  String nombreProceso;
  int codigoReferencia;
  String motivo;

  factory BEReapertura.fromJson(String str) =>
      BEReapertura.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEReapertura.fromMap(Map<String, dynamic> json) => BEReapertura(
        idRegistro: json["idRegistro"],
        nombreUsuario: json["nombreUsuario"],
        nombreProceso: json["nombreProceso"],
        codigoReferencia: json["codigoReferencia"],
        motivo: json["motivo"],
      );

  Map<String, dynamic> toMap() => {
        "idRegistro": idRegistro,
        "nombreUsuario": nombreUsuario,
        "nombreProceso": nombreProceso,
        "codigoReferencia": codigoReferencia,
        "motivo": motivo,
      };
}

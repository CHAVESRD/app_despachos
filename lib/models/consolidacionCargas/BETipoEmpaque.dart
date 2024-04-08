// ignore_for_file: file_names

import 'dart:convert';

class BETipoEmpaque {
  BETipoEmpaque(
      {this.codigoTipoEmpaque,
      this.nombreTipoEmpaque,
      this.siglas,
      this.digitaUnidades});

  int? codigoTipoEmpaque;
  String? nombreTipoEmpaque;
  String? siglas;
  int? digitaUnidades;

  factory BETipoEmpaque.fromJson(String str) =>
      BETipoEmpaque.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  List jsonList = [];
  factory BETipoEmpaque.fromMap(Map<String, dynamic> json) => BETipoEmpaque(
        codigoTipoEmpaque: json["codigoTipoEmpaque"],
        nombreTipoEmpaque: json["nombreTipoEmpaque"],
        siglas: json["siglas"],
        digitaUnidades: json["digitaUnidades"],
      );

  Map<String, dynamic> toMap() => {
        "codigoTipoEmpaque": codigoTipoEmpaque,
        "nombreTipoEmpaque": nombreTipoEmpaque,
        "siglas": siglas,
        "digitaUnidades": digitaUnidades,
      };
}

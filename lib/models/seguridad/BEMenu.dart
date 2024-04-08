// ignore_for_file: file_names

import 'dart:convert';

class BEMenu {
  BEMenu(
      {required this.codigo,
      required this.tipo,
      required this.nombre,
      required this.formulario});

  int codigo;
  int tipo;
  String nombre;
  String formulario;

  factory BEMenu.fromJson(String str) => BEMenu.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEMenu.fromMap(Map<String, dynamic> json) => BEMenu(
        codigo: json["codigoMenu"],
        tipo: json["tipoMenu"],
        nombre: json["nombreMenu"],
        formulario: json["nombreFormulario"],
      );

  Map<String, dynamic> toMap() => {
        "codigoMenu": codigo,
        "tipoMenu": tipo,
        "nombreMenu": nombre,
        "nombreFormulario": formulario,
      };
}

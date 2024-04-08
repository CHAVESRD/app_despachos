// ignore_for_file: file_names

import 'dart:convert';

class BELogin {
  BELogin({required this.usuario, required this.clave, required this.conexion});

  String usuario;
  String clave;
  int conexion;

  factory BELogin.fromJson(String str) => BELogin.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BELogin.fromMap(Map<String, dynamic> json) => BELogin(
        usuario: json["usuario"],
        clave: json["clave"],
        conexion: json["conexion"],
      );

  Map<String, dynamic> toMap() => {
        "usuario": usuario,
        "clave": clave,
        "conexion": conexion,
      };
}

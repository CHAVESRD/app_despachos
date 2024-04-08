// ignore_for_file: file_names

import 'dart:convert';

class BEUsuario {
  BEUsuario(
      {required this.idUsuario, required this.usuario, required this.nombre});

  int idUsuario;
  String usuario;
  String nombre;

  factory BEUsuario.fromJson(String str) => BEUsuario.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEUsuario.fromMap(Map<String, dynamic> json) => BEUsuario(
        idUsuario: json["idUsuario"],
        usuario: json["usuario"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toMap() => {
        "idUsuario": idUsuario,
        "usuario": usuario,
        "nombre": nombre,
      };
}

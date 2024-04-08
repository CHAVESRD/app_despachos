// ignore_for_file: file_names

import 'dart:convert';

class BEFaltantesDetalle {
  BEFaltantesDetalle(
      {required this.bulto, required this.descripcion, required this.cantidad, required this.ordenBlock});
  String bulto;
  String descripcion;
  double cantidad;
  String ordenBlock;

 static const String kBulto = 'bulto', kDescripcion = 'descripcion',kCantidad ='cantidad', kOB='ob',oB='ordenBlock', vacio='';

  factory BEFaltantesDetalle.fromJson(String str) =>
      BEFaltantesDetalle.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEFaltantesDetalle.fromMap(Map<String, dynamic> json) =>
      BEFaltantesDetalle(
        bulto: json[kBulto],
        descripcion: json[kDescripcion],
        cantidad: json[kCantidad],
        ordenBlock: json.containsKey(kOB)?  json[kOB] ?? vacio:vacio 
      );

  Map<String, dynamic> toMap() => {
        kBulto: bulto,
        kDescripcion: descripcion,
        kCantidad: cantidad,
        oB: ordenBlock
      };
}

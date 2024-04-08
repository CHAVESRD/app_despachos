import 'dart:convert';

class BEInfoGuiaDespacho {
  static const String _id = "idGuia";
  static const String _numero = "guia";
  static const String _placa = "placa";
  static const String _chofer = "chofer";
  static const String _observ = "observacionesDespacho";
  late int idGuia;
  late int guia;
  late String placa;
  late String chofer;
  String? observaciones;

  BEInfoGuiaDespacho({required this.idGuia, required this.guia, required this.placa, required this.chofer, this.observaciones});

  factory BEInfoGuiaDespacho.fromJson(String texto, int numGuia) => BEInfoGuiaDespacho.fromMap(json.decode(texto), numGuia);

  factory BEInfoGuiaDespacho.fromMap(Map<String, dynamic> json,int codigoGuia) =>
      BEInfoGuiaDespacho(idGuia: int.parse(json[_id].toString()), guia: codigoGuia, placa: json[_placa], chofer: json[_chofer], observaciones: json[_observ]);
  String toJson() => json.encode(toMap());
  Map<String, dynamic> toMap() => {_id: idGuia, _numero: guia, _placa: placa, _chofer: chofer, _observ: observaciones ?? ""};
}

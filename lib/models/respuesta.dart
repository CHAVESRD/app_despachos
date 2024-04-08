import 'dart:convert';
import 'package:despachos_app/models/error_validacion.dart';

enum EstadoResultado { exito, error, noPermitido, noAutorizado, noValido, noEncontrado, resultadoConErrores, errorHttp }

class BERespuesta<T> {
  static const _val = "valor";
  static const _tipo = "tipo";
  static const _estado = "estado";
  static const _exito = "exitoso";
  static const _fallos = "tieneErrores";
  static const _conResultado = "tieneResultado";
  static const _msjExito = "mensajExito";
  static const _errores = "errores";
  static const _erroresVal = "erroresValidacion";
  ///Valor propiamente consultado en formato json
  dynamic valor;
  ///Tipo de dato en el remitente
  String? tipo;
  ///valor en formato T
  T? objeto;
  ///indica como le fue al final
  late EstadoResultado estado;
  late bool exitoso = false;
  late bool tieneErrores = false;
  late bool tieneResultado = false;
  String? mensaje;
  ///Si ocurrieron errores propiamente del remitente
  dynamic errores;
  ///Validaciones pero de los datos.
  List<BErrorValidacion>? validaciones;

  BERespuesta(
      {this.valor,
      this.tipo,
      required this.estado,
      required this.exitoso,
      required this.tieneErrores,
      required this.tieneResultado,
      this.mensaje = "",
      this.errores = "",
      this.validaciones});

  factory BERespuesta.fromJson(String texto) => BERespuesta.fromMap(json.decode(texto));

  factory BERespuesta.fromMap(Map<String, dynamic> json) => BERespuesta(
      tipo: json[_tipo],
      estado: EstadoResultado.values[int.parse(json[_estado].toString())] ,
      exitoso:json[_exito].toString() == "true",
      tieneErrores: json[_fallos].toString() == "true",
      tieneResultado: json[_conResultado].toString() == "true",
      mensaje: json[_msjExito],
      errores: json[_errores],
      validaciones: json[_erroresVal] == null? null : List<BErrorValidacion>.from(json[_erroresVal].map((x) => BErrorValidacion.fromMap(x))),
      valor: json[_val]);
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        _val: valor ?? "",
        _tipo: tipo ?? "",
        _estado: estado,
        _exito: exitoso,
        _fallos: tieneErrores,
        _conResultado: tieneResultado,
        _msjExito: mensaje ?? "",
        _errores: errores ?? "",
        _erroresVal: validaciones.toString().isNotEmpty ? List<dynamic>.from(validaciones!.map((v) => v.toMap())) : []
      };

      
}

import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:despachos_app/global/api.dart';
import 'package:despachos_app/helpers/screen_helper.dart';
import 'package:despachos_app/models/models.dart';
import 'package:despachos_app/providers/seguridad/login_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProveedorDespachoGuia extends ChangeNotifier {
  GlobalKey<FormState> llaveFormulario = GlobalKey<FormState>();

  static int exito = 200, erroresClienteHttp = 400;

  ///Propiedades
  final String _urlBase = Api.baseUrl;
  static final BEInfoGuiaDespacho _datosNulos = BEInfoGuiaDespacho(idGuia: 0, guia: 0, placa: "", chofer: "");
  BEInfoGuiaDespacho datos = _datosNulos;
  BERespuesta<BEInfoGuiaDespacho> resultado =
      BERespuesta(estado: EstadoResultado.noEncontrado, exitoso: false, tieneErrores: false, tieneResultado: false);

  bool _estaCargando = false;

  bool get cargando => _estaCargando;

  set cargando(bool value) {
    _estaCargando = value;
    notifyListeners();
  }

  bool get formularioEsValido {
    return llaveFormulario.currentState?.validate() ?? false;
  }

  ///Funciones y métodos
  void limpiar() {
    datos = _datosNulos;
    resultado = BERespuesta(estado: EstadoResultado.noEncontrado, exitoso: false, tieneErrores: false, tieneResultado: false);
  }

  Future<BERespuesta<BEInfoGuiaDespacho>> consultarGuia(int guia) async {
    cargando = true;
    const String numero = "numeroGuia";

    final token = await LoginFormProvider.getToken();
    final autorizacion = 'Bearer $token';
    final parametros = {numero: guia.toString()};
    final url = Uri.http(_urlBase, Api.consultarGuia, parametros);
    final respuesta =
        await http.get(url, headers: {HttpHeaders.contentTypeHeader: Api.tipoEncabezado, HttpHeaders.authorizationHeader: autorizacion});

    if (respuesta.statusCode == exito) {
      resultado = BERespuesta.fromMap(jsonDecode(respuesta.body));
      if (resultado.tieneResultado) {
        dynamic v = resultado.valor;

        resultado.objeto = datos = BEInfoGuiaDespacho.fromMap(v, guia);
      } else {
        datos = _datosNulos;
      }
    } else if (respuesta.statusCode >= erroresClienteHttp) {
      BErrorValidacion msj = msjHttp(respuesta.statusCode);
      msj.id = respuesta.statusCode.toString();
      msj.gravedad = Severidad.error;

      resultado.tieneErrores = true;
      resultado.estado = EstadoResultado.errorHttp;
      resultado.errores = msj;
    }
    cargando = false;
    return resultado;
  }

  Future<BERespuesta<void>> despacharGuia(int idGuia, String usuario, String observaciones) async {
    cargando = true;

    const String id = "idGuia", usu = "usuario", momento = "hora", comentarios = "observaciones";

    final token = await LoginFormProvider.getToken();
    final autorizacion = 'Bearer $token';
    final parametros = {id: idGuia.toString(), usu: usuario, momento: DateTime.now().toString(), comentarios: observaciones};
    final url = Uri.http(_urlBase, Api.actualizarDespachoGuia, parametros);
    final respuesta =
        await http.put(url, headers: {HttpHeaders.contentTypeHeader: Api.tipoEncabezado, HttpHeaders.authorizationHeader: autorizacion});
    if (respuesta.statusCode == 200) {
      resultado = BERespuesta.fromMap(jsonDecode(respuesta.body));
    } else if (respuesta.statusCode >= 400) {
      resultado.tieneErrores = true;
      BErrorValidacion msj = msjHttp(respuesta.statusCode);

      resultado.estado = EstadoResultado.errorHttp;
      resultado.errores = msj;
    }
    cargando = false;
    return resultado;
  }
}

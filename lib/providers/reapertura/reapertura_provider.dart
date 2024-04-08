// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:despachos_app/constants/constants.dart';
import 'package:flutter/material.dart';

import '../../global/api.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';

import 'package:http/http.dart' as http;

import '../../screen/screens.dart';
import '../../shared/preferences.dart';
import '../providers.dart';

class ReaperturaProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = Api.baseUrl;

  int _codigo = 0;
  String resultado = '';
  String _motivo = '';
  List<String> validaciones = [];

  List<BEProceso> procesos = [];

  BEDataReapertura data = BEDataReapertura();

  bool _isLoading = false;
  bool _isLoadingData = false;
  bool _isLoadingInsert = false;
  bool _isLoadingValidaciones = false;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isLoadingData => _isLoadingData;

  set isLoadingData(bool value) {
    _isLoadingData = value;
    notifyListeners();
  }

  bool get isLoadingInsert => _isLoadingInsert;

  set isLoadingInsert(bool value) {
    _isLoadingInsert = value;
    notifyListeners();
  }

  bool get isLoadingValidaciones => _isLoadingValidaciones;

  set isLoadingValidaciones(bool value) {
    _isLoadingValidaciones = value;
    notifyListeners();
  }

  int get codigo => _codigo;

  set codigo(int value) {
    _codigo = value;
    notifyListeners();
  }

  String get motivo => _motivo;

  set motivo(String value) {
    _motivo = value;
    notifyListeners();
  }

  //Métodos

  cargarProcesos() async {
    isLoading = true;
    procesos = [];

    if (procesos.isNotEmpty) return;

    BEProceso proceso1 = BEProceso(codigo: 1, proceso: TextConstants.title1);
    procesos.add(proceso1);
    BEProceso proceso2 = BEProceso(codigo: 2, proceso: TextConstants.title2);
    procesos.add(proceso2);

    if (procesos.isNotEmpty) {
      codigo = procesos.first.codigo;
    } else {
      codigo = 0;
    }

    isLoading = false;
  }

  obtenerDatosReaperturas(BuildContext context, int proceso, int numero) async {
    isLoadingData = true;

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerDatosReaperturas,
        {'proceso': proceso.toString(), 'numero': numero.toString()});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingData = false;

    if (response.statusCode == 200) {
      data = BEDataReapertura.fromMap(json.decode(response.body));
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      ScreenHelper.showInfoDialog(
          context,
          'Sesión expirada',
          '¡Por favor inicie sesión nuevamente!',
          TextConstants.ok,
          Icons.error_outline);

      Preferences.usuario = '';
      Preferences.compania = 0;
      Preferences.nombre = '';
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false);

      return;
    } else {
      ScreenHelper.showInfoDialog(context, 'Error', response.body,
          TextConstants.ok, Icons.error_outline);

      return;
    }
  }

  obtenerValidacionesReaperturas(BuildContext context, int codigo) async {
    isLoadingValidaciones = true;
    validaciones = [];

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerValidacionesReaperturas,
        {'codigo': codigo.toString()});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingValidaciones = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      validaciones =
          lista.map((e) => jsonEncode(e).replaceAll('"', '')).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      ScreenHelper.showInfoDialog(
          context,
          'Sesión expirada',
          '¡Por favor inicie sesión nuevamente!',
          TextConstants.ok,
          Icons.error_outline);

      Preferences.usuario = '';
      Preferences.compania = 0;
      Preferences.nombre = '';
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false);

      return;
    } else {
      ScreenHelper.showInfoDialog(context, 'Error', response.body,
          TextConstants.ok, Icons.error_outline);

      return;
    }
  }

  insertarReaperturas(BuildContext context, BEReapertura reapertura) async {
    isLoadingInsert = true;
    notifyListeners();

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.insertarReaperturas);

    final response = await http.post(url,
        body: jsonData(
            reapertura.idRegistro,
            reapertura.nombreUsuario,
            reapertura.nombreProceso,
            reapertura.codigoReferencia,
            reapertura.motivo),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        });

    isLoadingInsert = false;
    notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        resultado = response.body;

        data = BEDataReapertura();
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      ScreenHelper.showInfoDialog(
          context,
          'Sesión expirada',
          '¡Por favor inicie sesión nuevamente!',
          TextConstants.ok,
          Icons.error_outline);

      Preferences.usuario = '';
      Preferences.compania = 0;
      Preferences.nombre = '';
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false);

      return;
    } else {
      ScreenHelper.showInfoDialog(context, 'Error', response.body,
          TextConstants.ok, Icons.error_outline);

      return;
    }
  }

  String jsonData(int idRegistro, String nombreUsuario, String nombreProceso,
      int codigoReferencia, String motivo) {
    final data = {
      'idRegistro': idRegistro,
      'nombreUsuario': nombreUsuario,
      'nombreProceso': nombreProceso,
      'codigoReferencia': codigoReferencia,
      'motivo': motivo
    };

    return jsonEncode(data);
  }
}

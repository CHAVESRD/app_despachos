// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../constants/constants.dart';
import '../../global/api.dart';
import '../../helpers/helpers.dart';
import '../../screen/screens.dart';
import '../../shared/preferences.dart';
import '../providers.dart';

import 'package:despachos_app/models/models.dart';

class ImpresionProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = Api.baseUrl;

  String resultado = '';

  bool _isLoadingImpresion = false;
  bool _isLoading = false;

  late BEUsuario? beUsuario = BEUsuario(idUsuario: 0, usuario: '', nombre: '');

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  bool get isLoadingImpresion => _isLoadingImpresion;

  set isLoadingImpresion(bool value) {
    _isLoadingImpresion = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //Métodos
  Future<String> imprimirEtiquetaSuperBultos(BuildContext context, int usuario,
      int numero, int formato, int copias) async {
        const copies = 'copias';
    isLoadingImpresion = true;

    resultado = '';

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.imprimirEtiquetas, {
      'usuario': usuario.toString(),
      'numero': numero.toString(),
      'formato': formato.toString(),
      copies: copias.toString()
    });
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingImpresion = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        resultado = response.body;
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
    } else {
      ScreenHelper.showInfoDialog(context, 'Error', response.body,
          TextConstants.ok, Icons.error_outline);
    }

    return resultado;
  }

  Future<String> imprimirReporteConsolidacion(BuildContext context, int usuario,
      int numero, int formato, int copias) async {
    const copies = 'copias';
    isLoadingImpresion = true;

    resultado = '';

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.imprimirReporte, {
      'usuario': usuario.toString(),
      'numero': numero.toString(),
      'formato': formato.toString(),
      copies:copias.toString()
    });
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingImpresion = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        resultado = response.body;
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
    } else {
      ScreenHelper.showInfoDialog(
          context,
          'Error',
          '${response.reasonPhrase} ${response.body.isNotEmpty ? ':' : '.'} ${response.body}',
          TextConstants.ok,
          Icons.error_outline);
    }

    return resultado;
  }

  Future<BEUsuario> obtenerUsuario(BuildContext context, String usuario) async {
    isLoading = true;

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerUsuario, {'usuario': usuario});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoading = false;

    if (response.statusCode == 200) {
      beUsuario = BEUsuario.fromMap(json.decode(response.body));
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
    } else {
      ScreenHelper.showInfoDialog(context, 'Error', response.body,
          TextConstants.ok, Icons.error_outline);
    }

    return beUsuario!;
  }
}

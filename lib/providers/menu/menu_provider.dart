// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants/constants.dart';
import '../../global/global.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';
import '../../screen/screens.dart';
import '../../shared/preferences.dart';
import '../providers.dart';

class MenuProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = ApiGeneral.baseUrlSeguridad;

  List<BEMenu> principal = [];
  List<BEMenu> secundario = [];

  String _resultado = '';

  bool _isLoadingPrincipal = false;
  bool _isLoadingSecundario = false;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  MenuProvider() {
    obtenerMenuPermisosPrincipal(
        Preferences.compania, Preferences.usuario, 0, 0);
  }

  bool get isLoadingPrincipal => _isLoadingPrincipal;

  set isLoadingPrincipal(bool value) {
    _isLoadingPrincipal = value;
    notifyListeners();
  }

  bool get isLoadingSecundario => _isLoadingSecundario;

  set isLoadingSecundario(bool value) {
    _isLoadingSecundario = value;
    notifyListeners();
  }

  String get resultado => _resultado;

  set resultado(String value) {
    _resultado = value;
    notifyListeners();
  }

  //Métodos
  obtenerMenuPermisosPrincipal(
      int compania, String usuario, int tipo, int dependencia) async {
    isLoadingPrincipal = true;
    notifyListeners();
    principal = [];

    final token = await LoginFormProvider.getToken();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Sistema': '99',
      'Formulario': ''
    };

    final data = {
      'compania': compania.toString(),
      'usuario': usuario,
      'tipo': tipo.toString(),
      'dependencia': dependencia.toString()
    };

    final url = Uri.http(_baseUrl, ApiGeneral.obtenerMenuPermisos, data);
    final response = await http.get(url, headers: headers);

    isLoadingPrincipal = false;
    notifyListeners();

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      principal = lista.map((e) => BEMenu.fromJson(jsonEncode(e))).toList();
    } else {
      resultado = response.body;
    }

    return principal;
  }

  obtenerMenuPermisosSecundario(BuildContext context, int compania,
      String usuario, int tipo, int dependencia) async {
    isLoadingSecundario = true;
    notifyListeners();
    secundario = [];

    final token = await LoginFormProvider.getToken();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Sistema': '99',
      'Formulario': ''
    };

    final data = {
      'compania': compania.toString(),
      'usuario': usuario,
      'tipo': tipo.toString(),
      'dependencia': dependencia.toString()
    };

    final url = Uri.http(_baseUrl, ApiGeneral.obtenerMenuPermisos, data);
    final response = await http.get(url, headers: headers);

    isLoadingSecundario = false;
    notifyListeners();

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      secundario = lista.map((e) => BEMenu.fromJson(jsonEncode(e))).toList();
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

    return secundario;
  }
}

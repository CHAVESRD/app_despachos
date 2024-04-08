// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:despachos_app/shared/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants/constants.dart';
import '../../global/global.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';
import '../../screen/screens.dart';
import '../providers.dart';

class SucursalProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = ApiGeneral.baseUrlSeguridad;

  List<BECompania> companias = [];

  int _codigoCompania = 0;
  int _codigoEmpresa = 0;

  bool _isLoadingCompanias = false;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  int get codigoCompania => _codigoCompania;

  set codigoCompania(int value) {
    _codigoCompania = value;
    notifyListeners();
  }

  int get codigoEmpresa => _codigoEmpresa;

  set codigoEmpresa(int value) {
    _codigoEmpresa = value;
    notifyListeners();
  }

  bool get isLoadingCompanias => _isLoadingCompanias;

  set isLoadingCompanias(bool value) {
    _isLoadingCompanias = value;
    notifyListeners();
  }

  //Métodos
  Future<List<BECompania>> consultaCompanias(BuildContext context) async {
    isLoadingCompanias = true;
    companias = [];

    final token = await LoginFormProvider.getToken();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Sistema': '99',
      'Formulario': ''
    };

    final url = Uri.http(_baseUrl, ApiGeneral.consultaCompanias);
    final response = await http.get(url, headers: headers);

    isLoadingCompanias = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      companias = lista.map((e) => BECompania.fromJson(jsonEncode(e))).toList();

      codigoCompania = companias.first.codigo;

      Preferences.compania = companias.first.codigo;
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
    } else if (response.statusCode == 204)
       {ScreenHelper.showInfoDialog(
          context,
          'Advertencia',
          'No se obtuvo ninguna compañía para la que el presente usuario tenga permiso.',
          TextConstants.aceptar,
          Icons.error_outline);}
    else {
      ScreenHelper.showInfoDialog(
          context,
          'Error',
          '${response.reasonPhrase}${response.body.isNotEmpty ? ':' : ''}  ${response.body}',
          TextConstants.ok,
          Icons.error_outline);
    }

    return companias;
  }
}

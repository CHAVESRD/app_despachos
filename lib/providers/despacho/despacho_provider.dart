// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants/constants.dart';
import '../../global/api.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';
import '../../screen/screens.dart';
import '../../shared/preferences.dart';
import '../providers.dart';

class DespachoProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = Api.baseUrl;

  BEFacturaDespacho despacho = BEFacturaDespacho();

  BEFacturaConsolidar beFactura = BEFacturaConsolidar();

  List<BEBultoConsolidar> bultos = [];

  int _idCompania = 0;
  String _factura = '';
  int _superBulto = 0;
  String _bulto = '';

  bool _isLoading = false;
  bool _isLoadingFacturas = false;
  bool _isLoadingBultos = false;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  int get idCompania => _idCompania;

  set idCompania(int value) {
    _idCompania = value;
    notifyListeners();
  }

  int get superBulto => _superBulto;

  set superBulto(int value) {
    _superBulto = value;
    notifyListeners();
  }

  String get factura => _factura;

  set factura(String value) {
    _factura = value;
    notifyListeners();
  }

  String get bulto => _bulto;

  set bulto(String value) {
    _bulto = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isLoadingFacturas => _isLoadingFacturas;

  set isLoadingFacturas(bool value) {
    _isLoadingFacturas = value;
    notifyListeners();
  }

  bool get isLoadingBultos => _isLoadingBultos;

  set isLoadingBultos(bool value) {
    _isLoadingBultos = value;
    notifyListeners();
  }

  //Métodos
  Future<BEFacturaDespacho> obtenerFacturasDespachos(
      BuildContext context, int compania, String numero) async {
    isLoading = true;

    final token = await LoginFormProvider.getToken();

    final data = {'compania': compania.toString(), 'numero': numero};
    final url = Uri.http(_baseUrl, Api.obtenerFacturasDespachos, data);
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoading = false;

    if (response.statusCode == 200) {
      despacho = BEFacturaDespacho.fromMap(jsonDecode(response.body));
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

    return despacho;
  }

  Future<BEFacturaConsolidar> obtenerFacturasConsolidar(
      BuildContext context, int compania, String numero) async {
    isLoading = true;

    final token = await LoginFormProvider.getToken();

    final data = {'compania': compania.toString(), 'numero': numero};
    final url = Uri.http(_baseUrl, Api.obtenerFacturasConsolidar, data);
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoading = false;

    if (response.statusCode == 200) {
      beFactura = BEFacturaConsolidar.fromMap(jsonDecode(response.body));
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

    return beFactura;
  }

  Future<List<BEBultoConsolidar>> obtenerBultosConsolidar(
      BuildContext context, int compania, String numero) async {//, int ruta DCR(20231005): wi47301
    isLoading = true;
    bultos = [];

    final data = {
      'compania': compania.toString(),
      'numero': numero
      //,'ruta': ruta.toString()//, int ruta DCR(20231005): wi47301
    };

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerBultosConsolidar, data);
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoading = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        List<dynamic> lista = jsonDecode(response.body);

        bultos = lista
            .map((e) => BEBultoConsolidar.fromJson(jsonEncode(e)))
            .toList();
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

    return bultos;
  }
}

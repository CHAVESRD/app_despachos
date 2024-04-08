// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:despachos_app/shared/preferences.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../constants/constants.dart';
import '../../global/api.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';
import '../../screen/screens.dart';
import '../providers.dart';

class SuperBultoProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = Api.baseUrl;

  List<BESuperBultoEncabezado> encabezado = [];
  List<BESuperBultoEncabezado> listaSuperBultos = [];
  List<BESuperBultoDetalle> listaDetalle = [];
  List<String> validaciones = [];

  late BESuperBultoEncabezado? superBultoSeleccionado;

  late BESuperBultoDetalle? detalle = BESuperBultoDetalle(
      idSuperBulto: 0,
      codigoFactura: 0,
      numeroFactura: '',
      numeroBulto: '',
      fechaHora: DateTime.now(),
      nombreUsuario: '');

  String eliminado = '';
  String actualizado = '';

  String _consecutivo = '';

  bool _isLoading = false;
  bool _isLoadingEncabezado = false;
  bool _isLoadingSuperBulto = false;
  bool _isLoadingDetalle = false;
  bool _isLoadingDelete = false;
  bool _isLoadingValidaciones = false;
  bool _isLoadingExistencia = false;
  bool _isLoadingTotal = false;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    if (!value)
    {notifyListeners();}
  }

  bool get isLoadingEncabezado => _isLoadingEncabezado;

  set isLoadingEncabezado(bool value) {
    _isLoadingEncabezado = value;
   if (!_isLoadingEncabezado)
    {notifyListeners();}

  }

  bool get isLoadingSuperBulto => _isLoadingSuperBulto;

  set isLoadingSuperBulto(bool value) {
    _isLoadingSuperBulto = value;
    notifyListeners();
  }

  bool get isLoadingDetalle => _isLoadingDetalle;

  set isLoadingDetalle(bool value) {
    _isLoadingDetalle = value;
    if (!value)
    {notifyListeners();}
  }

  bool get isLoadingDelete => _isLoadingDelete;

  set isLoadingDelete(bool value) {
    _isLoadingDelete = value;
    notifyListeners();
  }

  bool get isLoadingValidaciones => _isLoadingValidaciones;

  set isLoadingValidaciones(bool value) {
    _isLoadingValidaciones = value;
    notifyListeners();
  }

  bool get isLoadingExistencia => _isLoadingExistencia;

  set isLoadingExistencia(bool value) {
    _isLoadingExistencia = value;
    notifyListeners();
  }

  bool get isLoadingTotal => _isLoadingTotal;

  set isLoadingTotal(bool value) {
    _isLoadingTotal = value;
        if (value == false)
    {notifyListeners();}
  }

  String get consecutivo => _consecutivo;

  set consecutivo(String value) {
    _consecutivo = value;
    notifyListeners();
  }

  //Obtener la lista de superbultos abiertos el pantalla principal
  obtenerListadoSuperBultoEncabezado(
      BuildContext context, String usuario) async {
    isLoading = true;
    listaSuperBultos = [];

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerListadoSuperBultoEncabezado,
        {'usuario': usuario}); //El usuario no es esta usando como filtro
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoading = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      listaSuperBultos = lista
          .map((e) => BESuperBultoEncabezado.fromJson(jsonEncode(e)))
          .toList();
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

//Obtener la lista de bultos asociados al super bulto
  obtenerListaSuperBultoDetalle(
      BuildContext context, int idSuperBulto, String usuario) async {
    isLoadingDetalle = true;
    listaDetalle = [];

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerListaSuperBultoDetalle,
        {'idSuperBulto': idSuperBulto.toString(), 'usuario': usuario});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingDetalle = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      listaDetalle = lista
          .map((e) => BESuperBultoDetalle.fromJson(jsonEncode(e)))
          .toList();
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

  Future <bool> obtenerValidacionesSuperBulto(BuildContext context, int idSuperBulto,
      String? numero, String? cliente, String? sucursal) async {
    isLoadingValidaciones = true;
    validaciones = [];

    final token = await LoginFormProvider.getToken();

    Map<String, String> parameters = {
      'idSuperBulto': idSuperBulto.toString(),
      'numero': numero!,
      'cliente': cliente!,
      'sucursal': sucursal!.isNotEmpty ? sucursal :"red",
    };

    final url =
        Uri.http(_baseUrl, Api.obtenerValidacionesSuperBulto, parameters); 
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingValidaciones = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      validaciones =
          lista.map((e) => jsonEncode(e).replaceAll('"', '')).toList();
          return true;
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

      return false;
    } else {
      ScreenHelper.showInfoDialog(context, 'Error', response.body,
          TextConstants.ok, Icons.error_outline);

      return false;
    }
  }

  insertarSuperBultoEncabezado(BuildContext context, int compania,
      BESuperBultoEncabezado encabezado) async {
    isLoadingSuperBulto = true;

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.insertarSuperBultoEncabezado,
        {'compania': compania.toString()});
    final response = await http.post(url, body: encabezado.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingSuperBulto = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        consecutivo = response.body;
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

  Future<String> actualizarSuperBultoEncabezado(
      BuildContext context, BESuperBultoEncabezado encabezado) async {
    isLoadingSuperBulto = true;


    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.actualizarSuperBultoEncabezado);
    final response = await http.post(url, body: encabezado.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingSuperBulto = false;
 

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        actualizado = response.body;
        await obtenerListaSuperBultoDetalle(
            context, encabezado.idSuperBulto!, Preferences.usuario);

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

    return actualizado;
  }

  eliminarSuperBultoDetalle(
      BuildContext context, String bulto) async {
    isLoadingDelete = true;
    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.eliminarSuperBultoDetalle, {'bulto': bulto});
    final response = await http.post(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingDelete = false;
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        eliminado = response.body;
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

  obtenerSBEncabezadoNumero(
      BuildContext context, int numero, String usuario) async {
    isLoadingEncabezado = true;

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerSBEncabezadoNumero,
        {'numero': numero.toString(), 'usuario': usuario});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingEncabezado = false;

    if (response.statusCode == 200) {
      superBultoSeleccionado =
          BESuperBultoEncabezado.fromMap(json.decode(response.body));
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

  Future<BESuperBultoDetalle> validarExistenciaBulto(
      BuildContext context, int idSuperBulto, String bulto) async {
    isLoadingExistencia = true;

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.validarExistenciaBulto,
        {'idSuperBulto': idSuperBulto.toString(), 'bulto': bulto});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingExistencia = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        detalle = BESuperBultoDetalle?.fromMap(json.decode(response.body));
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

    return detalle!;
  }

   Future<String> insertarBultoSuperBulto(
      BuildContext context, BESuperBultoDetalle detalleBulto) async {
    isLoadingSuperBulto = true;


    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.insertarBultoSuperBulto);
    final response = await http.post(url, body: detalleBulto.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingSuperBulto = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        actualizado = response.body;
        await obtenerListaSuperBultoDetalle(
            context, detalleBulto.idSuperBulto, Preferences.usuario);
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

    return actualizado;
  }
}

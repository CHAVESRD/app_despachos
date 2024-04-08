// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:despachos_app/models/consolidacionCargas/BEFaltantesDetalle.dart';
import 'package:despachos_app/models/models.dart';
import 'package:despachos_app/shared/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/constants.dart';
import '../../global/api.dart';
import '../../helpers/helpers.dart';
import '../../screen/screens.dart';
import '../providers.dart';

class ConsolidacionCargasProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = Api.baseUrl;

  List<BECargaEncabezado> encabezado = [];
  List<BECargaEncabezado> listaCargas = [];
  List<BECargaDetalle> listaDetalle = [];
  List<BECargaFacturas> facturas = [];

  List<String> validaciones = [];

  List<String> validacionesFacturas = [];
  List<String> validacionesBultos = [];

  List<String> validacionesSuperBultos = [];

  List<BERuta> rutas = [];
  List<BETipoEmpaque> tipoEmpaques = [];

  List<BEFaltantes> faltantes = [];
  List<BEFaltantesDetalle> detalleFaltantes = [];

  late BECargaEncabezado? cargaSeleccionado = BECargaEncabezado(
      idCarga: 0,
      numeroCarga: 0,
      nombreUsuario: '',
      fechaHoraInicio: DateTime.now(),
      fechaHoraFin: DateTime.now(),
      /*codigoRuta: 0,
      ruta: '', DCR(20231005): WI47301*/
      estado: 'A',
      detalle: [],
      facturas: []);

  late BECargaFacturas? factura = BECargaFacturas(
      idCarga: 0,
      codigoFactura: 0,
      numeroFactura: '',
      fechaHora: DateTime.now(),
      nombreUsuario: '');

  late BECargaDetalle? detalle = BECargaDetalle(
    idCarga: 0,
    idSuperBulto: 0,
    codigoFactura: 0,
    numeroFactura: '',
    numeroBulto: '',
    fechaHora: DateTime.now(),
    nombreUsuario: '',
    nombreCliente: '',
    sucursal: '',
    codigoPedido: 0,
    numeroOrdenCompra: '',
    numeroBoleta: 0,
    numeroPedido: 0,
    numeroBodega: '',
    codigoTipoEmpaque: 0,
    numeroSuperBulto: '',
  );

  String eliminado = '';
  String actualizado = '';
  String insertado = '';
  String _consecutivo = '';
  String eliminadoFactura = '';

  int _codigoRuta = 0;
  int _codigoContenedor = 0;
  int _codigo = 0;

  int _totalFacturas = 0;
  int _totalBultos = 0;

  bool _isLoading = false;
  bool _isLoadingFactura = false;
  bool _isLoadingFacturas = false;
  bool _isLoadingCarga = false;
  bool _isLoadingDetalle = false;
  bool _isLoadingDelete = false;
  bool _isLoadingValidaciones = false;
  bool _isLoadingRutas = false;
  bool _isLoadingEmpaques = false;
  bool _isLoadingValidacionesFacturas = false;
  bool _isLoadingValidacionesBultos = false;
  bool _isLoadingFaltantes = false;
  bool _isLoadingDetalleFaltantes = false;
  bool _isLoadingExistenciaFacturas = false;
  bool _isLoadingExistenciaBultos = false;

  bool _isLoadingInsertar = false;
  bool _isLoadingActualizar = false;
  bool _isLoadingEliminar = false;
  bool _isLoadingEliminarDetalle = false;

  bool _isLoadingTotalFacturas = false;
  bool _isLoadingTotalBultos = false;

  bool _isLoadingValidacionesSuperBultos = false;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isLoadingFactura => _isLoadingFactura;

  set isLoadingFactura(bool value) {
    _isLoadingFactura = value;
    notifyListeners();
  }

  bool get isLoadingFacturas => _isLoadingFacturas;

  set isLoadingFacturas(bool value) {
    _isLoadingFacturas = value;
    notifyListeners();
  }

  bool get isLoadingCarga => _isLoadingCarga;

  set isLoadingCarga(bool value) {
    _isLoadingCarga = value;
    notifyListeners();
  }

  bool get isLoadingDetalle => _isLoadingDetalle;

  set isLoadingDetalle(bool value) {
    _isLoadingDetalle = value;
    notifyListeners();
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

  bool get isLoadingRutas => _isLoadingRutas;

  set isLoadingRutas(bool value) {
    _isLoadingRutas = value;
    notifyListeners();
  }

  bool get isLoadingEmpaques => _isLoadingEmpaques;

  set isLoadingEmpaques(bool value) {
    _isLoadingEmpaques = value;
    notifyListeners();
  }

  bool get isLoadingValidacionesFacturas => _isLoadingValidacionesFacturas;

  set isLoadingValidacionesFacturas(bool value) {
    _isLoadingValidacionesFacturas = value;
    notifyListeners();
  }

  bool get isLoadingValidacionesBultos => _isLoadingValidacionesBultos;

  set isLoadingValidacionesBultos(bool value) {
    _isLoadingValidacionesBultos = value;
    notifyListeners();
  }

  bool get isLoadingFaltantes => _isLoadingFaltantes;

  set isLoadingFaltantes(bool value) {
    _isLoadingFaltantes = value;
    notifyListeners();
  }

  bool get isLoadingDetalleFaltantes => _isLoadingDetalleFaltantes;

  set isLoadingDetalleFaltantes(bool value) {
    _isLoadingDetalleFaltantes = value;
    notifyListeners();
  }

  bool get isLoadingInsertar => _isLoadingInsertar;

  set isLoadingInsertar(bool value) {
    _isLoadingInsertar = value;
    notifyListeners();
  }

  bool get isLoadingActualizar => _isLoadingActualizar;

  set isLoadingActualizar(bool value) {
    _isLoadingActualizar = value;
    notifyListeners();
  }

  bool get isLoadingEliminar => _isLoadingEliminar;

  set isLoadingEliminar(bool value) {
    _isLoadingEliminar = value;
    notifyListeners();
  }

  bool get isLoadingEliminarDetalle => _isLoadingEliminarDetalle;

  set isLoadingEliminarDetalle(bool value) {
    _isLoadingEliminarDetalle = value;
    notifyListeners();
  }

  bool get isLoadingExistenciaFacturas => _isLoadingExistenciaFacturas;

  set isLoadingExistenciaFacturas(bool value) {
    _isLoadingExistenciaFacturas = value;
    notifyListeners();
  }

  bool get isLoadingExistenciaBultos => _isLoadingExistenciaBultos;

  set isLoadingExistenciaBultos(bool value) {
    _isLoadingExistenciaBultos = value;
    notifyListeners();
  }

  bool get isLoadingTotalFacturas => _isLoadingTotalFacturas;

  set isLoadingTotalFacturas(bool value) {
    _isLoadingTotalFacturas = value;
    notifyListeners();
  }

  bool get isLoadingTotalBultos => _isLoadingTotalBultos;

  set isLoadingTotalBultos(bool value) {
    _isLoadingTotalBultos = value;
    notifyListeners();
  }

  bool get isLoadingValidacionesSuperBultos =>
      _isLoadingValidacionesSuperBultos;

  set isLoadingValidacionesSuperBultos(bool value) {
    _isLoadingValidacionesSuperBultos = value;
    notifyListeners();
  }

  int get codigoRuta => _codigoRuta;

  set codigoRuta(int value) {
    _codigoRuta = value;
    notifyListeners();
  }

  int get codigoContenedor => _codigoContenedor;

  set codigoContenedor(int value) {
    _codigoContenedor = value;
    notifyListeners();
  }

  int get codigo => _codigo;

  set codigo(int value) {
    _codigo = value;
    notifyListeners();
  }

  int get totalFacturas => _totalFacturas;

  set totalFacturas(int value) {
    _totalFacturas = value;
    notifyListeners();
  }

  int get totalBultos => _totalBultos;

  set totalBultos(int value) {
    _totalBultos = value;
    notifyListeners();
  }

  String get consecutivo => _consecutivo;

  set consecutivo(String value) {
    _consecutivo = value;
    notifyListeners();
  }

  /// ***************************************LISTAS**********************************************/

  obtenerListaRutas(BuildContext context, int compania) async {
    isLoadingRutas = true;
    rutas = [];

    final token = await LoginFormProvider.getToken();

    final url =
        Uri.http(_baseUrl, Api.listaRutas, {'compania': compania.toString()});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingRutas = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      rutas = lista.map((e) => BERuta.fromJson(jsonEncode(e))).toList();

      codigoRuta = rutas.first.codigo!;
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

  obtenerTiposEmpaque(BuildContext context) async {
    isLoadingEmpaques = true;
    tipoEmpaques = [];

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerTiposEmpaque);
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingEmpaques = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      tipoEmpaques =
          lista.map((e) => BETipoEmpaque.fromJson(jsonEncode(e))).toList();

      codigoContenedor = tipoEmpaques.first.codigoTipoEmpaque!;
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

  obtenerCargaFactura(BuildContext context, int idCarga, String usuario) async {
    isLoadingFacturas = true;
    facturas = [];

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerCargaFactura,
        {'carga': idCarga.toString(), 'usuario': usuario});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingFacturas = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      facturas =
          lista.map((e) => BECargaFacturas.fromJson(jsonEncode(e))).toList();
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

  obtenerCargaEncabezado(String usuario, BuildContext context) async {
    isLoading = true;
    listaCargas = [];

    final token = await LoginFormProvider.getToken();

    final url =
        Uri.http(_baseUrl, Api.obtenerCargaEncabezado, {'usuario': usuario});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoading = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      listaCargas =
          lista.map((e) => BECargaEncabezado.fromJson(jsonEncode(e))).toList();
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
      ScreenHelper.showInfoDialog(
          context,
          'Error',
          '${response.reasonPhrase} ${response.body.isNotEmpty ? ':' : ''}  ${response.body}',
          TextConstants.ok,
          Icons.error_outline);

      return;
    }
  }

  obtenerCargaDetalle(BuildContext context, int idCarga, String usuario) async {
    isLoadingDetalle = true;
    listaDetalle = [];

    final token = await LoginFormProvider.getToken();
    final url = Uri.http(_baseUrl, Api.obtenerCargaDetalle, {
      'idCarga': idCarga.toString(),
      'idSuperBulto': "0", //Super bulto no se usa
      'usuario': usuario
    });
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingDetalle = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      listaDetalle =
          lista.map((e) => BECargaDetalle.fromJson(jsonEncode(e))).toList();
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

  obtenerFacturasBultosFaltantes(
      BuildContext context, int idCarga, int compania) async {
    isLoadingFaltantes = true;
    faltantes = [];

    final token = await LoginFormProvider.getToken();
    final url = Uri.http(_baseUrl, Api.obtenerFacturasBultosFaltantes, {
      'idCarga': idCarga.toString(),
      'idSuperBulto': "0", // NO se usa
      'compania': compania.toString()
    });
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingFaltantes = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      faltantes =
          lista.map((e) => BEFaltantes.fromJson(jsonEncode(e))).toList();
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

  obtenerDetalleFacturasBultosFaltantes(
      BuildContext context, String bultos) async {
    isLoadingDetalleFaltantes = true;
    detalleFaltantes = [];

    final token = await LoginFormProvider.getToken();
    final url = Uri.http(_baseUrl, Api.obtenerDetalleFacturasBultosFaltantes,
        {'bultos': bultos.toString()});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingDetalleFaltantes = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      detalleFaltantes =
          lista.map((e) => BEFaltantesDetalle.fromJson(jsonEncode(e))).toList();
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

  /// ****************************************VALIDACIONES**********************************************/

  obtenerValidacionesFacturas(
      BuildContext context, int compania, int codigo) async {
    //, int ruta DCR(20231005): WI47301
    isLoadingValidacionesFacturas = true;
    validacionesFacturas = [];

    final token = await LoginFormProvider.getToken();
    final url = Uri.http(_baseUrl, Api.obtenerValidacionesFacturas, {
      'compania': compania.toString(),
      'codigo': codigo
          .toString() /*, DCR(20231005): WI47301
      'ruta': ruta.toString()*/
    });
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingValidacionesFacturas = false;
    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      validacionesFacturas =
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

  Future<void> obtenerValidacionesBultos(BuildContext context, int idCarga,
      int codigoFactura, String numeroFactura, String bulto) async {
    isLoadingValidacionesBultos = true;
    validacionesBultos = [];

    final token = await LoginFormProvider.getToken();
    final url = Uri.http(_baseUrl, Api.obtenerValidacionesBultos, {
      'idCarga': idCarga.toString(),
      'codigoFactura': codigoFactura.toString(),
      'numeroFactura': numeroFactura,
      'bulto': bulto
    });
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingValidacionesBultos = false;

    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      validacionesBultos =
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

  Future<BECargaFacturas> validarExistenciaFactura(
      BuildContext context, int idCarga, String bulto) async {
    isLoadingExistenciaFacturas = true;

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.validarExistenciaFactura,
        {'idCarga': idCarga.toString(), 'numero': bulto});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingExistenciaFacturas = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        factura = BECargaFacturas?.fromMap(json.decode(response.body));
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

    return factura!;
  }

  Future<BECargaDetalle> validarExistenciaBultoFactura(
      BuildContext context, int idCarga, String bulto) async {
    isLoadingExistenciaBultos = true;
    detalle = BECargaDetalle(
      idCarga: 0,
      idSuperBulto: 0,
      codigoFactura: 0,
      numeroFactura: '',
      numeroBulto: '',
      fechaHora: DateTime.now(),
      nombreUsuario: '',
      nombreCliente: '',
      sucursal: '',
      codigoPedido: 0,
      numeroOrdenCompra: '',
      numeroBoleta: 0,
      numeroPedido: 0,
      numeroBodega: '',
      codigoTipoEmpaque: 0,
      numeroSuperBulto: '',
    );

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.validarExistenciaBultoFactura,
        {'idCarga': idCarga.toString(), 'numero': bulto});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingExistenciaBultos = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        detalle = BECargaDetalle?.fromMap(json.decode(response.body));
      }

      return detalle!;
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

  Future<BECargaDetalle> validarExistenciaSuperBultoFactura(
      BuildContext context, int idCarga, String bulto) async {
    isLoadingExistenciaBultos = true;
    detalle = BECargaDetalle(
      idCarga: 0,
      idSuperBulto: 0,
      codigoFactura: 0,
      numeroFactura: '',
      numeroBulto: '',
      fechaHora: DateTime.now(),
      nombreUsuario: '',
      nombreCliente: '',
      sucursal: '',
      codigoPedido: 0,
      numeroOrdenCompra: '',
      numeroBoleta: 0,
      numeroPedido: 0,
      numeroBodega: '',
      codigoTipoEmpaque: 0,
      numeroSuperBulto: '',
    );

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.validarExistenciaSuperBultoFactura,
        {'idCarga': idCarga.toString(), 'numero': bulto});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingExistenciaBultos = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        detalle = BECargaDetalle?.fromMap(json.decode(response.body));
      }

      return detalle!;
    } else {
      detalle?.idCarga = -1;
      if (response.statusCode == 401 || response.statusCode == 403) {
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
    }
    return detalle!;
  }

  obtenerValidacionesSuperBulto(
      BuildContext context, int idCarga, int codigoSuperBulto) async {
    //int ruta DCR(20231005):wi47301
    String errorServicio = 'Error al validar el super bulto $codigoSuperBulto';
    isLoadingValidacionesSuperBultos = true;
    validacionesSuperBultos = [];

    final token = await LoginFormProvider.getToken();
    final url = Uri.http(_baseUrl, Api.obtenerValidacionesSuperBultosCarga, {
      'idCarga': idCarga.toString(),
      'codigoSuperBulto': codigoSuperBulto.toString()
      //,'ruta': ruta.toString() DCR(20231005):wi47301
    });
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingValidacionesSuperBultos = false;
    if (response.statusCode == 200) {
      List<dynamic> lista = jsonDecode(response.body);

      validacionesSuperBultos =
          lista.map((e) => jsonEncode(e).replaceAll('"', '')).toList();
    } else {
      validacionesBultos = [errorServicio];

      if (response.statusCode == 401 || response.statusCode == 403) {
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
    }
    return;
  }

  /// ****************************************MANTENIMIENTO**********************************************/

  insertarConsolidacionCarga(
      BuildContext context, int compania, BECargaEncabezado encabezado) async {
    isLoadingInsertar = true;
    notifyListeners();

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.insertarConsolidacionCarga,
        {'compania': compania.toString()});

    final response = await http.post(url, body: encabezado.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingInsertar = false;
    notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        if (response.body == '-1') {
          ScreenHelper.showInfoDialog(
              context,
              'Error',
              'Error agregando la consolidación de carga',
              TextConstants.ok,
              Icons.error_outline);
          return;
        }
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

  Future<String> actualizarCargaEncabezado(
      BuildContext context, BECargaEncabezado encabezado, int pantalla) async {
    isLoadingActualizar = true;
    notifyListeners();

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.actualizarCargaEncabezado);
    final response = await http.post(url, body: encabezado.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingActualizar = false;
    notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        actualizado = response.body;

        if (pantalla == 1) {
          await obtenerCargaFactura(
              context, encabezado.idCarga, Preferences.usuario);

          await obtenerTotalFacturas(context, encabezado.idCarga);
        } else {
          await obtenerCargaDetalle(
              context, encabezado.idCarga, Preferences.usuario);

          await obtenerTotalBultosFacturas(context, encabezado.idCarga);
        }
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

  Future<String> insertaBultoConsolidacion(
      BuildContext context, BECargaDetalle detalleBulto) async {
    // isLoadingActualizar = true;
    // notifyListeners();

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.insertaBultoConsolidacion);
    final response =
        await http.post(url, body: detalleBulto.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    // isLoadingActualizar = false;
    // notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        actualizado = response.body;

        await obtenerCargaDetalle(context, detalleBulto.idCarga!,
            Preferences.usuario); //Revisar para que se necesista el super bulto

        await obtenerTotalBultosFacturas(context, detalleBulto.idCarga!);
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

  Future<String> insertaFacturaConsolidacion(
      BuildContext context, BECargaFacturas factura) async {
    // isLoadingActualizar = true;
    // notifyListeners();

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.insertarFacturaConsolidacion);
    final response = await http.post(url, body: factura.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    // isLoadingActualizar = false;
    // notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        actualizado = response.body;

        await obtenerCargaFactura(
            context, factura.idCarga!, Preferences.usuario);

        await obtenerTotalFacturas(context, factura.idCarga!);
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

  eliminarCargaFacturas(BuildContext context, BECargaFacturas factura) async {
    isLoadingEliminar = true;
    notifyListeners();
    eliminado = '';

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.eliminarCargaFacturas);
    final response = await http.post(url, body: factura.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingEliminar = false;
    notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        eliminado = response.body;
        await obtenerTotalFacturas(context, factura.idCarga!);
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

  eliminarCargaDetalle(BuildContext context, BECargaDetalle detalle) async {
    isLoadingEliminarDetalle = true;
    notifyListeners();
    eliminado = '';

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.eliminarCargaDetalle);
    final response = await http.post(url, body: detalle.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingEliminarDetalle = false;
    notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        eliminado = response.body;
        await obtenerTotalBultosFacturas(context, detalle.idCarga!);
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
  }

  eliminarCargaFacturasDetalleBultos(
      BuildContext context, BECargaFacturas factura) async {
    isLoadingEliminar = true;
    notifyListeners();
    eliminadoFactura = '';

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.eliminarCargaFacturasDetalleBultos);
    final response = await http.post(url, body: factura.toJson(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingEliminar = false;
    notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        eliminadoFactura = response.body;
        await obtenerTotalFacturas(context, factura.idCarga!);
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
  }

  obtenerCargaEncabezadoNumero(
      BuildContext context, int numero, String usuario) async {
    isLoadingCarga = true;

    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerCargaEncabezadoNumero,
        {'numero': numero.toString(), 'usuario': usuario});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingCarga = false;

    if (response.statusCode == 200) {
      cargaSeleccionado = BECargaEncabezado.fromMap(json.decode(response.body));
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
  }

  obtenerTotalFacturas(BuildContext context, int idCarga) async {
    isLoadingTotalFacturas = true;
    final token = await LoginFormProvider.getToken();

    final url = Uri.http(
        _baseUrl, Api.obtenerTotalFacturas, {'idCarga': idCarga.toString()});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingTotalFacturas = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        totalFacturas = int.parse(response.body);
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
  }

  obtenerTotalBultosFacturas(BuildContext context, int idCarga) async {
    isLoadingTotalBultos = true;
    final token = await LoginFormProvider.getToken();

    final url = Uri.http(_baseUrl, Api.obtenerTotalBultosFacturas,
        {'idCarga': idCarga.toString()});
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingTotalBultos = false;

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        totalBultos = int.parse(response.body);
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
  }

  Future<String> insertarSuperBultoConsolidacion(
      BuildContext context,
      int codigoCarga,
      int? codigoSuperBulto,
      String usuario,
      int codigoTipoContenedor) async {
    final token = await LoginFormProvider.getToken();

    Map<String, String> parameters = {
      'codigoCarga': codigoCarga.toString(),
      'codiogSuperBulto': codigoSuperBulto.toString(),
      'usuario': usuario,
      'codigoTipoEmpaque': codigoTipoContenedor.toString(),
    };

    final url =
        Uri.http(_baseUrl, Api.insertarSuperBultoConsolidacion, parameters);
    final response = await http.post(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });

    isLoadingActualizar = false;
    // notifyListeners();

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        actualizado = response.body;

        // if (encabezado.detalle.isNotEmpty) {
        await obtenerCargaDetalle(context, codigoCarga, Preferences.usuario);
        // }

        await obtenerTotalBultosFacturas(context, codigoCarga);
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

  /// ***************************************DATA JSON*****************************************/

  // String jsonDataFactura(int? idCarga, int? codigoFactura,
  //     String? numeroFactura, DateTime? fechaHora, String? nombreUsuario) {
  //   final data = {
  //     'idCarga': idCarga,
  //     'codigoFactura': codigoFactura,
  //     'numeroFactura': numeroFactura,
  //     'fechaHora': fechaHora?.toIso8601String(),
  //     'nombreUsuario': nombreUsuario
  //   };

  //   return jsonEncode(data);
  // }

  // String jsonDataEncabezado(
  //     int? idCarga,
  //     int? numeroCarga,
  //     String? nombreUsuario,
  //     DateTime? fechaHoraInicio,
  //     DateTime? fechaHoraFin,
  //     int? codigoRuta,
  //     String? estado,
  //     String? ruta,
  //     List<BECargaDetalle> detalle,
  //     List<BECargaFacturas> facturas) {
  //   List jsonDetalle = List<dynamic>.from(detalle.map((x) => x.toMap()));
  //   List jsonFacturas = List<dynamic>.from(facturas.map((x) => x.toMap()));

  //   final data = {
  //     'IdCarga': idCarga,
  //     'NumeroCarga': numeroCarga,
  //     'NombreUsuario': nombreUsuario,
  //     'FechaHoraInicio': fechaHoraInicio?.toIso8601String(),
  //     'FechaHoraFin': fechaHoraFin?.toIso8601String(),
  //     'CodigoRuta': codigoRuta,
  //     'Estado': estado,
  //     "Ruta": ruta,
  //     "CargaDetalle": jsonDetalle,
  //     "Facturas": jsonFacturas,
  //   };

  //   return jsonEncode(data);
  // }

  String jsonDataEncabezadoNumero(int? compania, BECargaEncabezado encabezado) {
    final data = {
      'compania': compania,
      'data': encabezado.toMap(),
    };

    return jsonEncode(data);
  }

  // String jsonDataDetalle(
  //     int? idCarga,
  //     int? idSuperBulto,
  //     int? codigoFactura,
  //     String? numeroFactura,
  //     String? numeroBulto,
  //     DateTime? fechaHora,
  //     String? nombreUsuario,
  //     String? nombreCliente,
  //     String? sucursal,
  //     int? codigoPedido,
  //     String? numeroOrdenCompra,
  //     int? numeroBoleta,
  //     int? numeroPedido,
  //     String? numeroBodega,
  //     int? codigoTipoEmpaque,
  //     String? numeroSuperBulto) {
  //   final data = {
  //     'idCarga': idCarga,
  //     'idSuperBulto': idSuperBulto,
  //     'codigoFactura': codigoFactura,
  //     'numeroFactura': numeroFactura,
  //     'numeroBulto': numeroBulto,
  //     'fechaHora': fechaHora?.toIso8601String(),
  //     'nombreUsuario': nombreUsuario,
  //     'nombreCliente': nombreCliente,
  //     'sucursal': sucursal,
  //     'codigoPedido': codigoPedido,
  //     'numeroOrdenCompra': numeroOrdenCompra,
  //     'numeroBoleta': numeroBoleta,
  //     'numeroPedido': numeroPedido,
  //     'numeroBodega': numeroBodega,
  //     'codigoTipoEmpaque': codigoTipoEmpaque,
  //     'numeroSuperBulto': numeroSuperBulto
  //   };

  //   return jsonEncode(data);
  // }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:despachos_app/providers/providers.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:despachos_app/shared/preferences.dart';
import 'package:provider/provider.dart';

import '../../global/global.dart';
import '../../models/models.dart';

class LoginFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = ApiGeneral.baseUrlSeguridad;

  late BEUsuario? beUsuario = BEUsuario(idUsuario: 0, usuario: '', nombre: '');
  String usuario = '';
  String clave = '';
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static Future<String?> getToken() async {
    // ignore: no_leading_underscores_for_local_identifiers
    const _storage = FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    // ignore: no_leading_underscores_for_local_identifiers
    const _storage = FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future _guardarToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  Future<bool> login(BuildContext context, int codigo) async {
    isLoading = true;

    const int movil = 77;
    final parametro = {'Protocolo': movil.toString()};
    final data = {'usuario': usuario.trim(), 'clave': clave.trim(), 'codigoConexion': codigo};

    final uri = Uri.http(_baseUrl, ApiGeneral.login, parametro);
    final resp = await http.post(uri, body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    isLoading = false;

    if (resp.statusCode == 200) {
      final tokenResponse = resp.body;

      await _guardarToken(tokenResponse);

      Preferences.usuario = usuario.toUpperCase();

      beUsuario = await Provider.of<ImpresionProvider>(context, listen: false).obtenerUsuario(context, Preferences.usuario);

      Preferences.idUsuario = beUsuario!.idUsuario;

      return true;
    } else {
      return false;
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../global/global.dart';
import '../../models/models.dart';

class CatalogoProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String _baseUrl = ApiGeneral.baseUrlSeguridad;

  List<BECatalogoDivision> divisiones = [];

  List<BEEmpresa> empresas = [];

  int _codigoDivision = 0;
  int _codigoEmpresa = 0;

  bool _isLoadingDivisiones = false;
  bool _isLoadingEmpresas = false;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  CatalogoProvider() {
    obtenerDivisiones();
  }

  int get codigoDivision => _codigoDivision;

  set codigoDivision(int value) {
    _codigoDivision = value;
    notifyListeners();
  }

  int get codigoEmpresa => _codigoEmpresa;

  set codigoEmpresa(int value) {
    _codigoEmpresa = value;
    notifyListeners();
  }

  bool get isLoadingDivisiones => _isLoadingDivisiones;

  set isLoadingDivisiones(bool value) {
    _isLoadingDivisiones = value;
    notifyListeners();
  }

  bool get isLoadingEmpresas => _isLoadingEmpresas;

  set isLoadingEmpresas(bool value) {
    _isLoadingEmpresas = value;
    notifyListeners();
  }

  //Métodos
  Future<List<BECatalogoDivision>> obtenerDivisiones() async {
    isLoadingDivisiones = true;
    divisiones = [];

    final url = Uri.http(_baseUrl, ApiGeneral.obtenerDivisiones);
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });

    if (response.statusCode != 200) {
      notifyListeners();
      return divisiones;
    }

    List<dynamic> lista = jsonDecode(response.body);

    divisiones =
        lista.map((e) => BECatalogoDivision.fromJson(jsonEncode(e))).toList();

    codigoDivision = divisiones.first.codigo;

    isLoadingDivisiones = false;

    obtenerEmpresasPorDivision(codigoDivision);

    return divisiones;
  }

  Future<List<BEEmpresa>> obtenerEmpresasPorDivision(int codigo) async {
    isLoadingEmpresas = true;
    empresas = [];

    final data = {'codigoDivision': codigo.toString()};
    final url = Uri.http(_baseUrl, ApiGeneral.obtenerEmpresasPorDivision, data);
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });

    if (response.statusCode != 200) {
      notifyListeners();
      return empresas;
    }

    List<dynamic> lista = jsonDecode(response.body);

    empresas = lista.map((e) => BEEmpresa.fromJson(jsonEncode(e))).toList();

    codigoEmpresa = empresas.first.codigo;

    isLoadingEmpresas = false;

    return empresas;
  }
}

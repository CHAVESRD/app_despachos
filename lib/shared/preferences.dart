import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _prefs;

  static String _ultimaCargaInicial = '';
  static String _nombre = '';
  static String _usuario = '';
  static int _idUsuario = 0;
  static int _compania = 0;
  static int _division = 0;
  static String _empresa = '';
  static int _conexion = 0;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String get ultimaCargaInicial {
    return _prefs.getString('ultimaCargaInicial') ?? _ultimaCargaInicial;
  }

  static set ultimaCargaInicial(String value) {
    _ultimaCargaInicial = value;
    _prefs.setString('ultimaCargaInicial', value);
  }

  static String get nombre {
    return _prefs.getString('nombre') ?? _nombre;
  }

  static set nombre(String value) {
    _nombre = value;
    _prefs.setString('nombre', value);
  }

  static String get usuario {
    return _prefs.getString('usuario') ?? _usuario;
  }

  static set usuario(String value) {
    _usuario = value;
    _prefs.setString('usuario', value);
  }

  static String get empresa {
    return _prefs.getString('empresa') ?? _empresa;
  }

  static set empresa(String value) {
    _empresa = value;
    _prefs.setString('empresa', value);
  }

  static int get idUsuario {
    return _prefs.getInt('idUsuario') ?? _idUsuario;
  }

  static set idUsuario(int value) {
    _idUsuario = value;
    _prefs.setInt('idUsuario', value);
  }

  static int get compania {
    return _prefs.getInt('compania') ?? _compania;
  }

  static set compania(int value) {
    _compania = value;
    _prefs.setInt('compania', value);
  }

  static int get division {
    return _prefs.getInt('division') ?? _division;
  }

  static set division(int value) {
    _division = value;
    _prefs.setInt('division', value);
  }

  static int get conexion {
    return _prefs.getInt('conexion') ?? _conexion;
  }

  static set conexion(int value) {
    _conexion = value;
    _prefs.setInt('conexion', value);
  }
}

class ApiGeneral {
  // static const String baseUrlSeguridad = '10.46.1.6:90';//Producción
  static const String baseUrlSeguridad = '10.46.1.13:8090';//preproducción mfa
  //static const String baseUrlSeguridad = '10.7.13.22:7097';

//**********************************************Login***************************************************/
  static const String login = 'api/sesion/login';

//**********************************************Catalogo***************************************************/
  static const String obtenerDivisiones = 'api/catalogo/ObtenerDivisiones';

  static const String obtenerEmpresasPorDivision = 'api/catalogo/ObtenerEmpresasPorDivision';

//**********************************************Sucursal***************************************************/
  static const String consultaCompanias = 'api/sucursal/ConsultaCompanias';

//**********************************************Menu***************************************************/
  static const String obtenerMenuPermisos = 'api/menu/ObtenerMenuPermisos';
}

class Api {
  static const String baseUrl = '10.46.1.13:8088'; //PRUEBAS
//   static const String baseUrl = '10.46.1.6:8088';//PROD
//static const String baseUrl = '10.7.13.20:8080';//LOCAL
// static const String baseUrl = '10.0.92.8:8080';//LOCAL colono
  
  static const String tipoEncabezado = 'application/json';

//**********************************************Despachos***************************************************/
  static const String obtenerFacturasDespachos = 'api/despacho/ObtenerFacturasDespachos';

  static const String obtenerFacturasConsolidar = 'api/despacho/ObtenerFacturasConsolidar';

  static const String obtenerBultosConsolidar = 'api/despacho/ObtenerBultosConsolidar';

  static const String consultarGuia = "api/despacho/ObtenerInfoDespachoGuia";
  static const String actualizarDespachoGuia = "api/Despacho/DespacharGuia";
//**********************************************Super Bultos***************************************************/
  static const String obtenerListadoSuperBultoEncabezado = 'api/superBulto/ObtenerSuperBultoEncabezado';

  static const String obtenerListaSuperBultoDetalle = 'api/superBulto/ObtenerSuperBultoDetalle';

  static const String obtenerValidacionesSuperBulto = 'api/superBulto/ObtenerValidacionesSuperBulto';

  static const String insertarSuperBultoEncabezado = 'api/superBulto/InsertarSuperBultoEncabezado';

  static const String actualizarSuperBultoEncabezado = 'api/superBulto/ActualizarSuperBultoEncabezado';

  static const String eliminarSuperBultoDetalle = 'api/superBulto/EliminarSuperBultoDetalle';

  static const String obtenerSBEncabezadoNumero = 'api/superBulto/ObtenerSBEncabezadoNumero';

  static const String validarExistenciaBulto = 'api/superBulto/ValidarExistenciaBulto';

  static const String insertarBultoSuperBulto = 'api/superBulto/InsertarBultoSuperBulto';

  static const String obtenerTotalBultos = 'api/superBulto/ObtenerTotalBultos';

//**********************************************Impresion***************************************************/
  static const String imprimirEtiquetas = 'api/impresion/ImprimirEtiquetas';

  static const String imprimirReporte = 'api/impresion/ImprimirReporte';

  static const String obtenerUsuario = 'api/impresion/ObtenerUsuario';

//**********************************************Consolidacion Cargas***************************************************/
  static const String listaRutas = 'api/consolidacionCarga/ObtenerListaRutas';

  static const String obtenerTiposEmpaque = 'api/consolidacionCarga/ObtenerTiposEmpaque';

  static const String obtenerCargaFactura = 'api/consolidacionCarga/ObtenerCargaFactura';

  static const String obtenerCargaEncabezado = 'api/consolidacionCarga/ObtenerCargaEncabezado';

  static const String obtenerCargaDetalle = 'api/consolidacionCarga/ObtenerCargaDetalle';

  static const String obtenerValidacionesFacturas = 'api/consolidacionCarga/ObtenerValidacionesFacturas';

  static const String obtenerValidacionesBultos = 'api/consolidacionCarga/ObtenerValidacionesBultos';

  static const String obtenerConsecutivo = 'api/consolidacionCarga/ObtenerConsecutivo';

  static const String obtenerFacturasBultosFaltantes = 'api/consolidacionCarga/ObtenerFacturasBultosFaltantes';

  static const String insertarConsolidacionCarga = 'api/consolidacionCarga/InsertarConsolidacionCarga';

  static const String actualizarCargaEncabezado = 'api/consolidacionCarga/ActualizarCargaEncabezado';

  static const String insertarFacturaConsolidacion = 'api/consolidacionCarga/InsertarFacturaConsolidacion';

  static const String insertaBultoConsolidacion = 'api/consolidacionCarga/InsertaBultoConsolidacion';

  static const String eliminarCargaDetalle = 'api/consolidacionCarga/EliminarCargaDetalle';

  static const String eliminarCargaFacturas = 'api/consolidacionCarga/EliminarCargaFacturas';

  static const String eliminarCargaFacturasDetalleBultos = 'api/consolidacionCarga/EliminarCargaFacturasDetalleBultos';

  static const String obtenerCargaEncabezadoNumero = 'api/consolidacionCarga/ObtenerCargaEncabezadoNumero';

  static const String validarExistenciaFactura = 'api/consolidacionCarga/ValidarExistenciaFactura';

  static const String validarExistenciaBultoFactura = 'api/consolidacionCarga/ValidarExistenciaBultoFactura';

  static const String obtenerTotalFacturas = 'api/consolidacionCarga/ObtenerTotalFacturas';

  static const String obtenerTotalBultosFacturas = 'api/consolidacionCarga/ObtenerTotalBultosFacturas';

  static const String validarExistenciaSuperBultoFactura = 'api/consolidacionCarga/ValidarExistenciaSuperBultoFactura';

  static const String obtenerValidacionesSuperBultosCarga = 'api/consolidacionCarga/ObtenerValidacionesSuperBultos';

  static const String insertarSuperBultoConsolidacion = 'api/consolidacionCarga/InsertarSuperBultoConsolidacion';

  static const String obtenerDetalleFacturasBultosFaltantes = 'api/consolidacionCarga/ObtenerDetalleFacturasBultosFaltantes';

  //**********************************************Reapertura***************************************************/
  static const String obtenerDatosReaperturas = 'api/reapertura/ObtenerDatosReaperturas';

  static const String obtenerValidacionesReaperturas = 'api/reapertura/ObtenerValidacionesReaperturas';

  static const String insertarReaperturas = 'api/reapertura/InsertarReaperturas';
}

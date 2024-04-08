class TextConstants {
  static const String appName = 'Despachos';

  static const String titulo1 = 'Menu Principal';

  static const String title1 = 'Super Bultos';
  static const String title2 = 'Consolidacion Cargas';

  static const String inicioSesion = 'Iniciar sesión';
  static const String usuarioHint = 'Nombre usuario';
  static const String usuarioLabel = 'Usuario';
  static const String claveHint = '******';
  static const String claveLabel = 'Contraseña';
  static const String espere = 'Espere...';
  static const String ingresar = 'Ingresar';
  static const String correoNoValido = 'El correo no es válido';
  static const String claveTamanio = 'La clave debe de ser de 6 caracteres';
  static const String requerido = 'Requerido';
  static const String loginIncorrecto = 'Revise sus credenciales nuevamente';
  static const String loginIncorrectoTitulo = 'Credenciales incorrectas';

  static const String si = 'Si';
  static const String no = 'No';
  static const String ok = 'Ok';
  static const String aceptar = 'Aceptar';
  static const String cerrar = 'Cerrar';
  static const String cancelar = 'Cancelar';
  static const String regresar = 'Regresar';

  static const String eliminar = 'Eliminar';
  static const String cerrarSesion = 'Cerrar sesión';

  static const String borrarBulto = 'Borrar Bulto';
  static const String borrarBultoConfirmar = '¿Desea eliminar este bulto?';

  static const String validaciones = 'Validaciones';

  static const String empresa = 'Empresa';
  static const String division = 'División';

  static const String error = "Error";
  static const String alerta = "Alerta";
  static const String info = "Aviso";

  static const String sinDatos = "No se encontraron datos";

  ///401 y 403
  static const String hdrSesionExpirada = 'Sesión expirada';

  ///401 y 403
  static const String msjSesionExpirada = '¡Por favor inicie sesión nuevamente!';

  ///400: bad request
  static const String hdrSolicitudMala = 'Solicitud errónea';

  ///400: bad request
  static const String msjSolicitudMala = 'Favor comunicar error a TI';

  ///402 payment required
  static const String hdrPagoRequerido = "Pago requerido";

  ///402 payment required
  static const String msjPagoRequerido = 'Sistema de pagos digital requiere pago que no ha sido provisto';

  ///404 Not found
  static const String hdrNoEncontrado = 'No encontrado';

  ///404 Not found
  static const String msjNoEncontrado = 'El servidor del API está apagado o se le cambió la url o ya no existe. Favor comunicarse con TI';

  /// 408 timeout
  static const String hdrExpirado = 'Tiempo Expirado';

  /// 408 timeout
  static const String msjExpirado = 'El servidor del API tardó demasiado tiempo en responder';

  /// 414 uri too long
  static const String hdrUriLarga = 'URI demasiado larga';

  /// 414 Uri too long
  static const String msjUriLarga = 'La URI enviada es más larga de lo que el servidor está dispuesto a interpretar';

  ///429 demasiadasConsultas
  static const String hdrMuyOcupado = 'Demasiadas solicitudes';
  static const String msjMuyOcupado = 'Se han enviado demasiadas solicitudes';

  static const String msjError400 = 'Error en la solicitud enviada al Servidor';
  static const String msjError500 = 'Error interno en el servidor del API. Favor reportar a TI';
  static const String imgCodigoBarras = "assets/barcode.png";
}

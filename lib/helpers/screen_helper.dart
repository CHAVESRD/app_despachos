import 'dart:io';

import 'package:despachos_app/models/error_validacion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:despachos_app/constants/text_constants.dart';

class ScreenHelper {
  static const String hdValidacion = 'Validaciones';
  static showAlertDialog(BuildContext context, String titulo, String mensaje, IconData icon) {
    // set up the buttons
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(
              title: Text(titulo),
              content: Column(
                children: [
                  const SizedBox(height: 10),
                  SingleChildScrollView(child: Text(mensaje)),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(TextConstants.si, style: TextStyle(color: Colors.red))),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(TextConstants.cancelar))
              ],
            );
          } else {
            return AlertDialog(
              title: Text(titulo),
              content: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                child: SingleChildScrollView(child: Text(mensaje)),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(TextConstants.si, style: TextStyle(color: Colors.red))),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(TextConstants.cancelar))
              ],
            );
          }
        });
  }

  static Future<void> showInfoDialog(BuildContext context, String titulo, String mensaje, String textoBoton, IconData icon) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(
              title: Text(titulo),
              content: Column(
                children: [
                  const SizedBox(height: 10),
                  SingleChildScrollView(child: Text(mensaje)),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(textoBoton))
              ],
            );
          } else {
            return AlertDialog(
              title: Text(titulo),
              content: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                child: SingleChildScrollView(child: Text(mensaje)),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(textoBoton))
              ],
            );
          }
        });
  }

  static Future<void> showLeftTextInfoDialog(BuildContext context, String titulo, String mensaje, String textoBoton, IconData icon) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(
              title: Text(titulo),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SingleChildScrollView(child: Text(mensaje)),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(textoBoton))
              ],
            );
          } else {
            return AlertDialog(
              title: Text(titulo),
              content: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                child: SingleChildScrollView(child: Text(mensaje)),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(textoBoton))
              ],
            );
          }
        });
  }
}

///Para pasar un valor por referencia
class Referencia<T> {
  T valor;
  Referencia(this.valor);
}

BErrorValidacion msjHttp(int codigoEstadoHttp) {
  BErrorValidacion msjError = BErrorValidacion(mensaje: "", gravedad: Severidad.info);
   // var sesionExpirada = codigoEstadoHttp == 401 || codigoEstadoHttp == 403;
  if (codigoEstadoHttp >= 400 && codigoEstadoHttp < 500) {
    msjError.id = codigoEstadoHttp.toString();
    msjError.gravedad = Severidad.error;

    switch (codigoEstadoHttp) {
      case 401:
      case 403:
        msjError.codigo = TextConstants.hdrSesionExpirada;
        msjError.mensaje = TextConstants.msjSesionExpirada;
        break;
      case 400:
        msjError.codigo = TextConstants.hdrSolicitudMala;
        msjError.mensaje = TextConstants.msjSolicitudMala;
        break;
      case 402:
        msjError.codigo = TextConstants.hdrPagoRequerido;
        msjError.mensaje = TextConstants.msjPagoRequerido;
        break;
      case 404:
        msjError.codigo = TextConstants.hdrNoEncontrado;
        msjError.mensaje = TextConstants.msjNoEncontrado;
        break;
      case 408:
        msjError.codigo = TextConstants.hdrExpirado;
        msjError.mensaje = TextConstants.msjExpirado;
        break;
      case 414:
        msjError.codigo = TextConstants.hdrUriLarga;
        msjError.mensaje = TextConstants.msjUriLarga;
        break;
      case 429:
        msjError.codigo = TextConstants.hdrMuyOcupado;
        msjError.mensaje = TextConstants.msjMuyOcupado;
        break;
      default:
        msjError.codigo = 'Error $codigoEstadoHttp';
        msjError.mensaje = TextConstants.msjError400;
    }
  } else if (codigoEstadoHttp >= 500) {
    msjError.codigo = 'Error $codigoEstadoHttp';
    msjError.mensaje = TextConstants.msjError500;
  }
  return msjError;
}
//25198014 soporte
//25198230 cancelacion
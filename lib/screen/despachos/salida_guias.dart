// ignore_for_file: file_names, use_build_context_synchronously

import 'package:despachos_app/colors/colors.dart';
import 'package:despachos_app/constants/constants.dart';
import 'package:despachos_app/models/models.dart';
import 'package:despachos_app/providers/despacho/despacho_guia_provider.dart';
import 'package:despachos_app/screen/screens.dart';
import 'package:despachos_app/shared/preferences.dart';
import 'package:despachos_app/widgets/flexible_space.dart';
import 'package:despachos_app/helpers/screen_helper.dart';
import 'package:despachos_app/widgets/form_circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class DespachoGuias extends StatefulWidget {
  const DespachoGuias({super.key});

  static String routeName = 'despachoGuias';

  @override
  State<DespachoGuias> createState() => _DespachoGuiasState();
}

class _DespachoGuiasState extends State<DespachoGuias> with WidgetsBindingObserver implements ScannerCallback {
  static const int btnIniciarEscanner = 0,
      btnDetenerEscaner = 1,
      // ignore: constant_identifier_names
      btnIniciandoEscaneo = 2,
      // ignore: constant_identifier_names
      btnDeteniendoEscaneo = 3;

  HoneywellScanner escanerHoneywell = HoneywellScanner();
  ScannedData? datosEscaneados;
  String? mensajError;
  bool escanerHabilitado = false;
  bool formatoEscaneo1D = true;
  bool formatoEscaneo2D = true;
  Referencia<bool> dispositivoEstaSoportado = Referencia(false);

  late TextEditingController _controladorGuia;
  late TextEditingController _controladorObservaciones;
  late FocusNode _focusNode;
  late ProveedorDespachoGuia proveedor;
  BEInfoGuiaDespacho datos = BEInfoGuiaDespacho(idGuia: 0, guia: 0, placa: "", chofer: "");
  final _idFormularioDespacho = GlobalKey<FormState>();
  late bool _despachoHabilitado;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _despachoHabilitado = false;
    WidgetsBinding.instance.addObserver(this);
    escanerHoneywell.scannerCallback = this;
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    _controladorGuia = TextEditingController();
    _controladorObservaciones = TextEditingController();

    iniciarEscaner(escanerHoneywell, dispositivoEstaSoportado, formatoEscaneo1D, formatoEscaneo2D);
    if (mounted) setState(() {});
  }

  static InputDecoration decoracionTextoEntrada(String etiqueta, String hint) {
    return InputDecoration(
      border: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primaryColor, width: 2), borderRadius: BorderRadius.circular(10.0)),
      enabledBorder:
          OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primaryColor, width: 2), borderRadius: BorderRadius.circular(10.0)),
      fillColor: AppColors.primaryColor,
      labelStyle: const TextStyle(fontSize: 16, color: Colors.black),
      labelText: etiqueta,
      hintText: hint,
    );
  }

  @override
  Widget build(BuildContext context) {
    const String consulteGuia = "Consulte una guía",
        guia = "Guía",
        numGuia = "Número de Guía",
        placa = "Placa:",
        chofer = "Chofer:",
        estado = "Estado:",
        comentario = "Observaciones",
        txtBotonDespacho = 'Despachar',
        despachado = "Ya despachado",
        noDespachado = "No despachado";
    proveedor = Provider.of<ProveedorDespachoGuia>(context);
    datos = proveedor.datos;

    // proveedor.addListener(() {
    //   _controladorObservaciones.text = datos.observaciones ?? "";
    // });
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MenuPermisosScreen()), (Route<dynamic> route) => false);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: const FlexibleSpace(),
            title: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(Preferences.nombre, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _limpiar();
                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => const MenuPermisosScreen()), (Route<dynamic> route) => false);
              },
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                width: double.infinity,
                height: 300,
                child: Form(
                    key: _idFormularioDespacho,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        height: 80,
                        width: double.infinity,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 15),

                        //Texto de numero de guia y boton para el lector de barras
                        child: Table(
                          columnWidths: const {0: FractionColumnWidth(0.8), 1: FractionColumnWidth(0.2)},
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: TextFormField(
                                style: const TextStyle(fontSize: 16),
                                controller: _controladorGuia,
                                decoration: decoracionTextoEntrada(guia, numGuia),
                                validator: _validarEntradaGuia,
                                // onEditingComplete: _edicionNumeroGuiaCompletada,
                                onFieldSubmitted: _guiaEnviada,
                                onSaved: (newValue) {},
                                textAlignVertical: TextAlignVertical.top,
                              )),
                              TableCell(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5),
                                    decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    border: Border.all(color: AppColors.primaryColor, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: GestureDetector(
                                  // onTap: _leerCodigoBarras,
                                  child: const Image(
                                    image: AssetImage(TextConstants.imgCodigoBarras),
                                    alignment: Alignment.center,
                                    fit: BoxFit.fitHeight,
                                    height: 40,
                                  ),
                                ),
                              ))
                            ])
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        width: 350,
                        child: proveedor.cargando
                            ? const Center(
                                child: FormCircularProgressIndicator(),
                              )
                            : datos.guia == 0
                                ? const Center(
                                    child: Text(consulteGuia),
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Table(
                                            columnWidths: const {0: FractionColumnWidth(0.25), 1: FractionColumnWidth(0.75)},
                                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                            children: [
                                              TableRow(children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.only(bottom: 5),
                                                  child: Text(placa, style: TextStyle(fontWeight: FontWeight.bold)),
                                                )),
                                                TableCell(child: Text(datos.idGuia > 0 ? datos.placa : ""))
                                              ]),
                                              TableRow(children: [
                                                const TableCell( verticalAlignment: TableCellVerticalAlignment.top,
                                                    child: Padding(
                                                        padding: EdgeInsets.only(bottom: 5),
                                                        child: Text(chofer, style: TextStyle(fontWeight: FontWeight.bold)))),
                                                TableCell(child: Text(datos.idGuia > 0 ? datos.chofer : ""),verticalAlignment: TableCellVerticalAlignment.top,)
                                              ]),
                                              TableRow(children: [
                                                const TableCell(child: Text(estado, style: TextStyle(fontWeight: FontWeight.bold))),
                                                TableCell(
                                                    child: (proveedor.resultado.validaciones?.any((v) => (v.codigo ?? "") == "0") ?? false)
                                                        ? const Text(
                                                            despachado,
                                                            style: TextStyle(color: AppColors.rojo, fontWeight: FontWeight.bold),
                                                          )
                                                        : const Text(noDespachado))
                                              ])
                                            ]),
                                      ),
                                      Container(
                                          alignment: Alignment.topLeft,
                                          padding: const EdgeInsets.only(top: 5, left: 5),
                                          child: const Text(
                                            comentario,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          )),
                                      Container(
                                          height: 120,
                                          width: 350,
                                          alignment: Alignment.topLeft,
                                          padding: const EdgeInsets.only(left: 5, right: 5),
                                          child: TextFormField(
                                            controller: _controladorObservaciones,
                                            // onChanged: _guiaEnviada ,
                                            maxLines: 5,
                                            maxLength: 2048,
                                            keyboardType: TextInputType.multiline,
                                            style: const TextStyle(fontSize: 16),
                                            decoration: decoracionTextoEntrada("", "Ingrese sus observaciones"),

                                            // initialValue: (datos.observaciones ?? "").isNotEmpty ? datos.observaciones : "",
                                          ))
                                    ],
                                  ),
                      ),
                    ])),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: MaterialButton(
                  minWidth: 60.0,
                  height: 50.0,
                  onPressed: !proveedor.cargando && _despachoHabilitado ? _despachar : null,
                  color: AppColors.primaryColor,
                  textColor: Colors.white,
                  disabledColor: AppColors.secundaryColor,
                  disabledTextColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    child: const Text(txtBotonDespacho, style: TextStyle(fontSize: 16, color: Colors.white), textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // void _leerCodigoBarras() async {
  //   String codigoBarras = await FlutterBarcodeScanner.scanBarcode(AppColors.colorLineaCB, TextConstants.cancelar, true, ScanMode.BARCODE);
  //   _controladorGuia.text = _validarEntradaGuia(codigoBarras) == null ? codigoBarras : "";
  //   if (_controladorGuia.text.isNotEmpty) _guiaEnviada(_controladorGuia.text);
  // }

  void _guiaEnviada(value) async {
    BERespuesta<BEInfoGuiaDespacho> respuesta = await proveedor.consultarGuia(int.parse(value));
    datos = proveedor.datos;
    if (respuesta.estado == EstadoResultado.errorHttp) {
      _reaccionError(respuesta);
    } else if (respuesta.validaciones != null && (respuesta.validaciones?.isNotEmpty ?? false)) {
      if (respuesta.validaciones!.any((v) => v.gravedad == Severidad.error)) {
        ScreenHelper.showInfoDialog(context, TextConstants.error, respuesta.validaciones!.firstWhere((v) => v.gravedad == Severidad.error).mensaje,
            TextConstants.aceptar, Icons.error_outline);
        setState(() {
          _despachoHabilitado = false;
        });
      } else if (respuesta.tieneResultado && (respuesta.objeto?.idGuia ?? 0) > 0) {
        BErrorValidacion alerta = respuesta.validaciones![0];
        if (alerta.codigo != "0") ScreenHelper.showInfoDialog(context, TextConstants.alerta, alerta.mensaje, TextConstants.ok, Icons.info_outline);

        setState(() {
          _despachoHabilitado = true;
        });
      } else {
        ScreenHelper.showInfoDialog(context, TextConstants.info, respuesta.validaciones![0].mensaje, TextConstants.ok, Icons.info_outline);
        setState(() {
          _despachoHabilitado = false;
        });
      }
    } else if (datos.idGuia > 0) {
      setState(() {
        _despachoHabilitado = true;
      });
    } else if (respuesta.estado == EstadoResultado.noEncontrado) {
      ScreenHelper.showInfoDialog(context, TextConstants.info, TextConstants.sinDatos, TextConstants.ok, Icons.info_outline);
      setState(() {
        _limpiar();
      });
    } else {
      if (respuesta.tieneErrores) {
        _reaccionError(respuesta);
      } else {
        _limpiar();
      }
    }
  }

  void _reaccionError(BERespuesta resultado) {
    const String noAutorizado = "401", prohibido = "403";
    if (resultado.estado == EstadoResultado.errorHttp) {
      BErrorValidacion error = resultado.errores as BErrorValidacion;
      ScreenHelper.showInfoDialog(context, error.codigo ?? "", error.mensaje, TextConstants.aceptar, Icons.error_outline);
      if (error.id == noAutorizado || error.id == prohibido) {
        Preferences.usuario = '';
        Preferences.compania = 0;
        Preferences.nombre = '';
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
      }
    } else {
      ScreenHelper.showInfoDialog(context, TextConstants.error, resultado.errores["mensaje"], TextConstants.aceptar, Icons.error_outlined);
    }
  }

  String? _validarEntradaGuia(value) {
    int? valor;
    if (value == null || value.isEmpty || (valor = int.tryParse(value)) == null || (valor ?? 0) <= 0) return "Ingrese un número de Guía válido";
    return null;
  }

  // void _edicionNumeroGuiaCompletada() async {
  //   // await proveedor.consultarGuia(context, int.parse(_controladorGuia.text));
  //   // _controladorObservaciones.text = datos.observaciones ?? "";
  // }

  void _despachar() async {
    BERespuesta<void> respuesta = await proveedor.despacharGuia(datos.idGuia, Preferences.usuario, _controladorObservaciones.text);
    if (respuesta.exitoso) {
      ScreenHelper.showInfoDialog(
          context, TextConstants.info, respuesta.mensaje ?? "Guía despachada exitosamente", TextConstants.ok, Icons.check_circle_outline);
      setState(() {
        _limpiar();
      });
    } else if (respuesta.tieneErrores) {
      _reaccionError(respuesta);
    } else if (respuesta.estado == EstadoResultado.noEncontrado) {
      ScreenHelper.showInfoDialog(context, TextConstants.error, TextConstants.sinDatos, TextConstants.aceptar, Icons.check_circle_outline);
    }
  }

  _limpiar() {
    proveedor.limpiar();
    _controladorGuia.text = "";
    _controladorGuia.text = "";
    _despachoHabilitado = false;
  }

  @override
  void onDecoded(ScannedData? scannedData) {
    setState(() {
      datosEscaneados = scannedData;
      _controladorGuia.text = scannedData!.code!;
    });
  }

  @override
  void onError(Exception error) {
    mensajError = error.toString();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controladorGuia.dispose();
    _controladorObservaciones.dispose();
    escanerHoneywell.stopScanner();
    super.dispose();
  }

  Future<void> onClick(int id) async {
    try {
      mensajError = null;
      switch (id) {
        case btnIniciarEscanner:
          if (await escanerHoneywell.startScanner()) {
            setState(() {
              escanerHabilitado = true;
            });
          }
          break;
        case btnDetenerEscaner:
          if (await escanerHoneywell.stopScanner()) {
            setState(() {
              escanerHabilitado = false;
            });
          }
          break;
        case btnIniciandoEscaneo:
          await escanerHoneywell.startScanning();
          break;
        case btnDeteniendoEscaneo:
          await escanerHoneywell.stopScanning();
          break;
      }
    } catch (e) {
      setState(() {
        mensajError = e.toString();
      });
    }
  }
}

Future<void> iniciarEscaner(HoneywellScanner escaner, Referencia<bool> dispositivoSoportado, bool formato1D, formato2D) async {
  actualizarPropiedadEscaner(escaner, formato1D, formato2D);
  dispositivoSoportado.valor = await escaner.isSupported();
}

void actualizarPropiedadEscaner(HoneywellScanner escaner, bool formato1D, bool formato2D) {
  List<CodeFormat> codigosFormatos = [];
  if (formato1D) codigosFormatos.addAll(CodeFormatUtils.ALL_1D_FORMATS);
  if (formato2D) codigosFormatos.addAll(CodeFormatUtils.ALL_2D_FORMATS);

  Map<String, dynamic> propiedades = {
    ...CodeFormatUtils.getAsPropertiesComplement(codigosFormatos),
    'DEC_CODABAR_START_STOP_TRANSMIT': true,
    'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true
  };
  escaner.setProperties(propiedades);
}

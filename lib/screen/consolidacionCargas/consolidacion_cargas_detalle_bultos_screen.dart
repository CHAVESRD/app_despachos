// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:core';
import 'package:despachos_app/shared/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../constants/consolidacionCargas/text_constants_consolidacion_cargas.dart';
import '../../constants/text_constants.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

class ConsolidacionCargasDetalleBultosScreen extends StatefulWidget {
  const ConsolidacionCargasDetalleBultosScreen({Key? key}) : super(key: key);

  static String routeName = 'consolidacionCargasDetalleBultos';

  @override
  State<ConsolidacionCargasDetalleBultosScreen> createState() =>
      _ConsolidacionCargasDetalleBultosScreenState();
}

class _ConsolidacionCargasDetalleBultosScreenState
    extends State<ConsolidacionCargasDetalleBultosScreen>
    with WidgetsBindingObserver
    implements ScannerCallback {
  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;
  late bool _estaProcesando;

  late TextEditingController _controllerBultos;
  late FocusNode _focusNodeBultos;

  // ignore: constant_identifier_names
  static const BTN_START_SCANNER = 0,
      // ignore: constant_identifier_names
      BTN_STOP_SCANNER = 1,
      // ignore: constant_identifier_names
      BTN_START_SCANNING = 2,
      // ignore: constant_identifier_names
      BTN_STOP_SCANNING = 3;

  @override
  void initState() {
    super.initState();
    _estaProcesando = false;
    WidgetsBinding.instance.addObserver(this);
    honeywellScanner.scannerCallback = this;
    _focusNodeBultos = FocusNode();
    _focusNodeBultos.requestFocus();
    _controllerBultos = TextEditingController();
    init();
  }

  Future<void> init() async {
    updateScanProperties();
    isDeviceSupported = await honeywellScanner.isSupported();
    if (mounted) setState(() {});
  }

  void updateScanProperties() {
    List<CodeFormat> codeFormats = [];
    if (scan1DFormats) codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
    if (scan2DFormats) codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);

    Map<String, dynamic> properties = {
      ...CodeFormatUtils.getAsPropertiesComplement(codeFormats),
      'DEC_CODABAR_START_STOP_TRANSMIT': true,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    };
    honeywellScanner.setProperties(properties);
  }

  @override
  void onDecoded(ScannedData? scannedData) {
    setState(() {
      this.scannedData = scannedData;
      _controllerBultos.text = scannedData!.code!;
    });
  }

  @override
  void onError(Exception error) {
    setState(() {
      errorMessage = error.toString();
    });
  }

  Future<void> onClick(int id) async {
    try {
      errorMessage = null;
      switch (id) {
        case BTN_START_SCANNER:
          if (await honeywellScanner.startScanner()) {
            setState(() {
              scannerEnabled = true;
            });
          }
          break;
        case BTN_STOP_SCANNER:
          if (await honeywellScanner.stopScanner()) {
            setState(() {
              scannerEnabled = false;
            });
          }
          break;
        case BTN_START_SCANNING:
          await honeywellScanner.startScanning();
          break;
        case BTN_STOP_SCANNING:
          await honeywellScanner.stopScanning();
          break;
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _focusNodeBultos.dispose();
    _controllerBultos.dispose();
    honeywellScanner.stopScanner();
    super.dispose();
  }

  void requestFocusWithoutKeyboard() {
    setState(() {
      if (_focusNodeBultos.hasFocus) {
        _focusNodeBultos.unfocus();
      } else {
        FocusScope.of(context).requestFocus(_focusNodeBultos);
      }
    });
  }

  List<BECargaDetalle> detalle = [];

  BECargaDetalle cargaSeleccionado = BECargaDetalle(
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

  BECargaEncabezado modelo = BECargaEncabezado(
    idCarga: 0,
    numeroCarga: 0,
    nombreUsuario: '',
    fechaHoraInicio: DateTime.now(),
    fechaHoraFin: DateTime.now(),
    /*codigoRuta: 0,
    ruta: '', DCR(20231005): wi47301*/
    estado: 'A',
    detalle: [],
    facturas: [],
  );

  List<BECargaFacturas> facturas = [];

  late DespachoProvider providerDespacho;
  late ConsolidacionCargasProvider provider;

  String numero = '';

  bool printedCorrectly = false;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ConsolidacionCargasProvider>(context);
    modelo = provider.cargaSeleccionado!;

    facturas = provider.facturas;
    detalle = provider.listaDetalle;

    return WillPopScope(
      onWillPop: () async {
        Provider.of<ConsolidacionCargasProvider>(context, listen: false)
            .obtenerCargaFactura(context, modelo.idCarga, Preferences.usuario);

        Navigator.of(context).pop();
        return true;
      },
      child: GestureDetector(
        onTap: requestFocusWithoutKeyboard,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: const FlexibleSpace(),
            title: const FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                TextConstantsConsolidacionCargas.title2,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Provider.of<ConsolidacionCargasProvider>(context, listen: false)
                    .obtenerCargaFactura(
                        context, modelo.idCarga, Preferences.usuario);

                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                height: 122,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                      child: Text(
                        'Número carga: ${modelo.numeroCarga.toString()}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Table(
                        columnWidths: const {
                          0: FractionColumnWidth(0.45),
                          1: FractionColumnWidth(0.35),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                  child: Container(
                                padding: const EdgeInsets.only(left: 5),
                                alignment: Alignment.topLeft,
                                child: const Text(
                                  TextConstantsConsolidacionCargas.tipo,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                              TableCell(
                                child: Container(
                                  padding:
                                      const EdgeInsets.only(right: 5, left: 5),
                                  width: 300.0,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: provider.isLoadingEmpaques
                                        ? const Center(
                                            child:
                                                FormCircularProgressIndicator())
                                        : DropdownButton(
                                            isExpanded: true,
                                            value: 1,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                textDirection:
                                                    TextDirection.rtl,
                                                color: AppColors.primaryColor),
                                            underline: Container(
                                              height: 2,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                            items:
                                                provider.tipoEmpaques.map((e) {
                                              return DropdownMenuItem(
                                                value: e.codigoTipoEmpaque,
                                                child: Text(
                                                    e.nombreTipoEmpaque
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16)),
                                              );
                                            }).toList(),
                                            onChanged: <int>(value) {
                                              provider.codigoContenedor = value;
                                            }),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ]),
                    Container(
                      padding:
                          const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                      alignment: Alignment.bottomCenter,
                      height: 50,
                      width: 350,
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        focusNode: _focusNodeBultos,
                        controller: _controllerBultos,
                        onEditingComplete: _handleEditingComplete,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: AppColors.primaryColor,
                          labelText: TextConstantsConsolidacionCargas.bultoSB,
                          labelStyle: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: provider.isLoadingDetalle
                      ? const Center(child: FormCircularProgressIndicator())
                      : LisCargasBultos(
                          detalle: provider.listaDetalle,
                          provider: provider,
                          objeto: cargaSeleccionado,
                        )),
              Container(
                alignment: Alignment.bottomCenter,
                child:
                    ButtonBar(alignment: MainAxisAlignment.center, children: [
                  MaterialButton(
                    minWidth: 60.0,
                    height: 50.0,
                    onPressed: () async {
                      _controllerBultos.clear();
                      _focusNodeBultos.unfocus();
                      await provider.obtenerListaRutas(
                          context, Preferences.compania);

                      await provider.obtenerCargaFactura(
                          context,
                          modelo.idCarga == 0
                              ? int.parse(provider.insertado)
                              : modelo.idCarga,
                          Preferences.usuario);

                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: AppColors.primaryColor,
                    child: const Text(
                      TextConstantsConsolidacionCargas.facturas,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  MaterialButton(
                    minWidth: 60.0,
                    height: 50.0,
                    onPressed: () async {
                      _controllerBultos.clear();
                      _focusNodeBultos.unfocus();

                      await provider.obtenerFacturasBultosFaltantes(
                          context, modelo.idCarga, Preferences.compania);

                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ConsolidacionRutasFaltantesScreen()),
                      );*/

                      Navigator.pushNamed(
                          context, ConsolidacionRutasFaltantesScreen.routeName);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: AppColors.primaryColor,
                    child: const Text(
                      TextConstantsConsolidacionCargas.faltantes,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  MaterialButton(
                    minWidth: 60.0,
                    height: 50.0,
                    onPressed: _estaProcesando
                        ? null
                        : () async {
                            setState(() {
                              _estaProcesando = true;
                            });
                            _controllerBultos.clear();
                            _focusNodeBultos.unfocus();

                            await provider.obtenerFacturasBultosFaltantes(
                                context, modelo.idCarga, Preferences.compania);

                            if (provider.faltantes.isEmpty) {
                              provider.cargaSeleccionado!.nombreUsuario =
                                  Preferences.usuario;
                              provider.cargaSeleccionado!.estado = 'C';

                              String result = await Provider.of<
                                          ConsolidacionCargasProvider>(context,
                                      listen: false)
                                  .actualizarCargaEncabezado(
                                      context, provider.cargaSeleccionado!, 2);

                              if (result.isNotEmpty) {
                                if (detalle.isNotEmpty) {
                                  printedCorrectly = false;
                                  _showPrintConfirmationDialog(1);
                                } else {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Impresión'),
                                        content: const Text(
                                            'La impresión del reporte no se puede llevar a cabo porque no hay bultos para mostrar'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text(TextConstants.ok),
                                            onPressed: () {
                                              setState(() {
                                                printedCorrectly = true;
                                              });
                                              _controllerBultos.clear();
                                              _focusNodeBultos.unfocus();

                                              Provider.of<ConsolidacionCargasProvider>(
                                                      context,
                                                      listen: false)
                                                  .obtenerCargaEncabezado(
                                                      Preferences.usuario,
                                                      context);

                                              /*Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ConsolidacionCargasScreen()),
                                        );*/
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  ConsolidacionCargasScreen
                                                      .routeName);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            } else {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'No se puede finalizar la Consolidación de Cargas'),
                                    content: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: const SingleChildScrollView(
                                          child: Text(
                                              'Existen bultos y facturas faltantes a consolidar, por favor verifique e intente nuevamente')),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _estaProcesando = false;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(TextConstants.ok),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    disabledColor: AppColors.secundaryColor,
                    disabledTextColor: Colors.black,
                    color: AppColors.primaryColor,
                    child: _estaProcesando
                        ? const FormCircularProgressIndicator()
                        : const Text(
                            TextConstantsConsolidacionCargas.finalizar,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ]),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Future<void> _handleEditingComplete() async {
    // const String msjRetira = 'El bulto pertenece a un pedido cliente-Retira';
    if (_controllerBultos.text.isNotEmpty) {
      if (_controllerBultos.text.length > 18) {
        _controllerBultos.text = _controllerBultos.text.substring(2);
      }

      //Consulta un bulto o  super bultopara hacer una lista y despues insertar
      List<BEBultoConsolidar> obj =
          await consultarBulto(modelo, _controllerBultos.text);

      if (obj.isNotEmpty) {
        // if ((obj.first.tipoRetiro ?? 1) > 1) {
        //   ScreenHelper.showInfoDialog(
        //       context,
        //       TextConstants.validaciones,
        //       msjRetira,
        //       TextConstants.ok,
        //       Icons.error_outline);

        //   setState(() {
        //     _controllerBultos.text = '';
        //     numero = '';
        //   });
        // } else {
        if (_controllerBultos.text.length < 18) {
          agregarSuperBultosCreate(
              modelo, obj, provider, _controllerBultos.text, context);
        } else {
          agregarDetalleCreate(
              modelo, obj, provider, _controllerBultos.text, context);
        }
        //      }
      } else {
        if (_controllerBultos.text.length < 18) {
          ScreenHelper.showInfoDialog(
              context,
              TextConstants.validaciones,
              'El Super Bulto no existe o no ha sido cerrado',
              TextConstants.ok,
              Icons.error_outline);

          setState(() {
            _controllerBultos.text = '';
            numero = '';
          });
        } else {
          ScreenHelper.showInfoDialog(
              context,
              TextConstants.validaciones,
              'El Bulto no existe o no pertenece a la ruta',
              TextConstants.ok,
              Icons.error_outline);

          setState(() {
            _controllerBultos.text = '';
            numero = '';
          });
        }
      }
    } else {
      ScreenHelper.showInfoDialog(
          context,
          'Validaciones',
          'Debe ingresar un número de bulto',
          TextConstants.ok,
          Icons.error_outline);
    }
  }

  Future<List<BEBultoConsolidar>> consultarBulto(
      BECargaEncabezado encabezado, String numero) async {
    final provedorDespachos =
        Provider.of<DespachoProvider>(context, listen: false);

    List<BEBultoConsolidar> obj =
        await provedorDespachos.obtenerBultosConsolidar(
            context,
            Preferences.compania,
            numero); //, encabezado.codigoRuta DCR(20231005): wi47301

    return obj;
  }

  void agregarSuperBultosCreate(
      BECargaEncabezado encabezado,
      List<BEBultoConsolidar> bultos, //Detalle de bultos.
      ConsolidacionCargasProvider prov,
      String numero,
      BuildContext context) async {
    bool dialogShown = false;

    // Valida si un super bulto ya es parte de la consolidacion de carga.
    BECargaDetalle? beDetalle = await prov.validarExistenciaSuperBultoFactura(
        context, encabezado.idCarga, numero);
    if (beDetalle.idCarga! < 0) {
      dialogShown = true;
    
    // // if (beDetalle.idCarga != 0 && beDetalle.numeroSuperBulto == numero) {
    // // ScreenHelper.showInfoDialog(
    // //     context,
    // //     'Validaciones',
    // //     '¡El super bulto $numero ya se encuentra en la consolidación!',
    // //     TextConstants.ok,
    // //     Icons.error_outline);

    // // setState(() {
    // //   _controllerBultos.text = '';
    // //   numero = '';
    // // });
    }  else {
            List<String> validacionesSuperBultos = [];

      await prov.obtenerValidacionesSuperBulto(context, encabezado.idCarga,
          bultos[0].idSuperBulto!); //Codigo Ruta no se usa
      //,encabezado.codigoRuta DCR(20231005): wi47301

      if (prov.validacionesSuperBultos.isNotEmpty) {
        validacionesSuperBultos.addAll(prov.validacionesSuperBultos);
      } else {
        await Provider.of<ConsolidacionCargasProvider>(context, listen: false)
            .insertarSuperBultoConsolidacion(
                context,
                encabezado.idCarga,
                bultos[0].idSuperBulto,
                Preferences.usuario,
                prov.codigoContenedor);
        //  setState(() {
        _existeSuperBulto =
            (beDetalle.idCarga ?? -1) > 0 && beDetalle.numeroSuperBulto == numero;
        _controllerBultos.text = '';
        numero = '';
        // });
      }

      if (validacionesSuperBultos.isNotEmpty && !dialogShown) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(TextConstants.validaciones),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: validacionesSuperBultos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Text(validacionesSuperBultos[index]);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _controllerBultos.text = '';
                      numero = '';
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(TextConstants.ok),
                ),
              ],
            );
          },
        );

        dialogShown = true;
      } else {
        dialogShown = false;
      }

    }
  }

  void agregarDetalleCreate(
      BECargaEncabezado encabezado,
      List<BEBultoConsolidar> bultos,
      ConsolidacionCargasProvider prov,
      String numero,
      BuildContext context) async {
    bool existe = false;
    bool dialogShown = false;

    if (bultos.isNotEmpty) {
      //para cuando hay detalles pero lo escaneado se encuentra en el detalle
      BECargaDetalle? beDetalle = await prov.validarExistenciaBultoFactura(
          context, encabezado.idCarga, numero);

      if (beDetalle.idCarga != 0) {
        existe = true;

        pintarFila(existe, beDetalle);

        await Provider.of<ConsolidacionCargasProvider>(context, listen: false)
            .insertaBultoConsolidacion(context, beDetalle);

        // setState(() {
        _controllerBultos.text = '';
        numero = '';
        // });
      } else {
        //para cuando no hay detalles agregados

        existe = false;

        List<String> validacionesBultos = [];

        BECargaDetalle beDetalle = BECargaDetalle(
          idCarga: encabezado.idCarga,
          idSuperBulto: bultos[0].idSuperBulto!,
          codigoFactura: bultos[0].codigoFactura!,
          numeroFactura: bultos[0].numeroFactura!,
          numeroBulto: bultos[0].numeroBulto!,
          fechaHora: DateTime.now(),
          nombreUsuario: Preferences.usuario,
          nombreCliente: bultos[0].cliente,
          sucursal: bultos[0].sucursal,
          codigoPedido: bultos[0].codigoPedido,
          numeroOrdenCompra: bultos[0].numeroOrdenCompra,
          numeroBoleta: bultos[0].numeroBoleta,
          numeroPedido: bultos[0].numeroPedido,
          numeroBodega: bultos[0].bodega,
          codigoTipoEmpaque: prov.codigoContenedor,
          numeroSuperBulto: bultos[0].numeroSuperBulto,
        );

        await prov.obtenerValidacionesBultos(
            context,
            encabezado.idCarga,
            bultos[0].codigoFactura!,
            bultos[0].numeroFactura!,
            bultos[0].numeroBulto!);

        if (prov.validacionesBultos.isNotEmpty) {
          validacionesBultos.addAll(prov.validacionesBultos);
        } else {
          pintarFila(existe, beDetalle);

          await Provider.of<ConsolidacionCargasProvider>(context, listen: false)
              .insertaBultoConsolidacion(context, beDetalle);

          // setState(() {
          _controllerBultos.text = '';
          numero = '';
          // });

          //}
        }

        if (validacionesBultos.isNotEmpty && !dialogShown) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(TextConstants.validaciones),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: validacionesBultos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(validacionesBultos[index]);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _controllerBultos.text = '';
                        numero = '';
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text(TextConstants.ok),
                  ),
                ],
              );
            },
          );
          dialogShown = true;
        } else {
          dialogShown = false;
        }
      }
    }
  }

  void pintarFila(bool encontrado, BECargaDetalle detalle) {
    if (encontrado) {
      setState(() {
        cargaSeleccionado = detalle;
        cargaSeleccionado.nombreUsuario = Preferences.usuario;
      });
    } else {
      setState(() {
        cargaSeleccionado = BECargaDetalle(
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
            numeroSuperBulto: '');
      });
    }
  }

  Future<void> _showPrintConfirmationDialog(int copias) async {
    String res = await Provider.of<ImpresionProvider>(context, listen: false)
        .imprimirReporteConsolidacion(context, Preferences.idUsuario,
            provider.cargaSeleccionado!.numeroCarga, 4, copias);
    if (res == "Se imprimió la etiqueta") {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Impresión'),
            content: const Text(
                '¿El reporte y su copia se imprimieron correctamente?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Sí'),
                onPressed: () {
                  setState(() {
                    _estaProcesando = false;
                  });
                  _controllerBultos.clear();
                  _focusNodeBultos.unfocus();

                  Provider.of<ConsolidacionCargasProvider>(context,
                          listen: false)
                      .obtenerCargaEncabezado(Preferences.usuario, context);

                  Navigator.pushReplacementNamed(
                      context, ConsolidacionCargasScreen.routeName);
                },
              ),
              TextButton(
                child: const Text('No'),
                onPressed: () async {
                  setState(() {
                    _estaProcesando = true;
                  });
                  Navigator.of(context).pop();
                  _showPrintConfirmationDialog(1);
                },
              ),
            ],
          );
        },
      );
    } else {
      ScreenHelper.showInfoDialog(
          context, 'Impresión', res, TextConstants.ok, Icons.error_outline);
    }
  }
}

bool _existeSuperBulto = false;

class LisCargasBultos extends StatelessWidget {
  const LisCargasBultos(
      {super.key,
      required this.detalle,
      required this.provider,
      required this.objeto});

  final List<BECargaDetalle> detalle;
  final ConsolidacionCargasProvider provider;
  final BECargaDetalle objeto;

  @override
  Widget build(BuildContext context) {
    bool pintarSuperBulto = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 5),
              height: 20,
              width: 250,
              child: Text(
                'Últimos ${detalle.length <= 3 ? detalle.length : 3} bultos de ${provider.totalBultos}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        const Divider(color: AppColors.primaryColor, height: 1),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 5),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: detalle.take(3).length,
          itemBuilder: (context, index) {
            pintarSuperBulto = _existeSuperBulto;
            _existeSuperBulto = false;
            return Card(
                color: detalle[index].numeroBulto == objeto.numeroBulto ||
                        pintarSuperBulto
                    ? Colors.lightGreen
                    : Colors.white,
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  side:
                      const BorderSide(color: AppColors.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Table(
                      columnWidths: const {
                        0: FractionColumnWidth(0.90),
                        1: FractionColumnWidth(0.10),
                        // 2: FractionColumnWidth(0.25),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  detalle[index].idSuperBulto! > 0
                                      ? ' ${detalle[index].numeroBulto} '
                                          '>'
                                          ' ${detalle[index].numeroSuperBulto} '
                                      : '  ${detalle[index].numeroBulto} ',
                                ),
                              ),
                            ),
                            // TableCell(
                            //   child: Container(
                            //     decoration: detalle[index].idSuperBulto! > 0
                            //         ? const BoxDecoration(
                            //             border: Border(
                            //               left: BorderSide(
                            //                 color: AppColors.primaryColor,
                            //                 width: 2.0,
                            //               ),
                            //             ),
                            //           )
                            //         : null,
                            //     alignment: Alignment.centerLeft,
                            //     child: Text(
                            //       detalle[index].idSuperBulto! > 0
                            //           ? ' ${detalle[index].numeroSuperBulto} '
                            //           : ' ',
                            //     ),
                            //   ),
                            // ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () async {
                                    return showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: const Text(
                                                TextConstants.borrarBulto),
                                            content: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              child: const SingleChildScrollView(
                                                  child: Text(TextConstants
                                                      .borrarBultoConfirmar)),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    int idC =
                                                        detalle[index].idCarga!;
                                                    await provider
                                                        .eliminarCargaDetalle(
                                                            context,
                                                            detalle[index]);
                                                    if (provider.eliminado
                                                            .isNotEmpty &&
                                                        provider.eliminado ==
                                                            "Eliminar exitosamente") {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await provider
                                                          .obtenerCargaDetalle(
                                                              context,
                                                              idC,
                                                              Preferences
                                                                  .usuario);
                                                    }
                                                  },
                                                  child: const Text(
                                                      TextConstants.si,
                                                      style: TextStyle(
                                                          color: Colors.red))),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                      TextConstants.cancelar))
                                            ],
                                          );
                                        });
                                  },
                                  child: const Icon(
                                      Icons.delete_forever_rounded,
                                      semanticLabel: TextConstants.eliminar,
                                      color: AppColors.primaryColor,
                                      size: 30),
                                ),
                              ),
                            ),
                          ],
                        )
                      ]),
                ));
          },
        ),
      ],
    );
  }
}

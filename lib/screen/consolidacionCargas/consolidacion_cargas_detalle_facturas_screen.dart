// ignore_for_file: use_build_context_synchronously

import 'dart:core';
import 'package:despachos_app/screen/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../constants/consolidacionCargas/text_constants_consolidacion_cargas.dart';
import '../../constants/text_constants.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../shared/preferences.dart';
import '../../widgets/widgets.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

class ConsolidacionCargasDetalleFacturasScreen extends StatefulWidget {
  const ConsolidacionCargasDetalleFacturasScreen({Key? key}) : super(key: key);

  static String routeName = 'consolidacionCargasDetalleFacturas';

  @override
  State<ConsolidacionCargasDetalleFacturasScreen> createState() =>
      _ConsolidacionCargasDetalleFacturasScreenState();
}

class _ConsolidacionCargasDetalleFacturasScreenState
    extends State<ConsolidacionCargasDetalleFacturasScreen>
    with WidgetsBindingObserver
    implements ScannerCallback {
  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  late TextEditingController _controllerFacturas;
  late FocusNode _focusNodeFacturas;

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
    WidgetsBinding.instance.addObserver(this);
    honeywellScanner.scannerCallback = this;
    _focusNodeFacturas = FocusNode();
    _focusNodeFacturas.requestFocus();
    _controllerFacturas = TextEditingController();
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
      _controllerFacturas.text = scannedData!.code!;
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
    _focusNodeFacturas.dispose();
    _controllerFacturas.dispose();
    honeywellScanner.stopScanner();
    super.dispose();
  }

  void requestFocusWithoutKeyboard() {
    setState(() {
      if (_focusNodeFacturas.hasFocus) {
        _focusNodeFacturas.unfocus();
      } else {
        FocusScope.of(context).requestFocus(_focusNodeFacturas);
      }
    });
  }

  BECargaFacturas cargaSeleccionado = BECargaFacturas(
    idCarga: 0,
    codigoFactura: 0,
    numeroFactura: '',
    fechaHora: DateTime.now(),
    nombreUsuario: '',
  );

  List<BECargaFacturas> facturas = [];

  BECargaEncabezado? modelo = BECargaEncabezado(
      idCarga: 0,
      numeroCarga: 0,
      nombreUsuario: '',
      fechaHoraInicio: DateTime.now(),
      fechaHoraFin: DateTime.now(),
/*      codigoRuta: 0,
      ruta: '', DCR(20231005): wi47301 */
      estado: 'A',
      detalle: [],
      facturas: []);

  late DespachoProvider provDespachos;
  late ConsolidacionCargasProvider provider;

  String numero = '';

  @override
  Widget build(BuildContext context) {
    provDespachos = Provider.of<DespachoProvider>(context);
    provider = Provider.of<ConsolidacionCargasProvider>(context);
    modelo = provider.cargaSeleccionado;

    facturas = provider.facturas;

    return WillPopScope(
      onWillPop: () async {
        Provider.of<ConsolidacionCargasProvider>(context, listen: false)
            .obtenerCargaEncabezado(Preferences.usuario, context);

        Navigator.of(context).pop();
        return true;

        /*Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ConsolidacionCargasScreen()),
        );
        return true;*/
      },
      child: GestureDetector(
        onTap: requestFocusWithoutKeyboard,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: const FlexibleSpace(),
            title: const FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                TextConstantsConsolidacionCargas.title1,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Provider.of<ConsolidacionCargasProvider>(context, listen: false)
                    .obtenerCargaEncabezado(Preferences.usuario, context);

                Navigator.of(context).pop();
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConsolidacionCargasScreen()),
                );*/
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  height: 125,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 5, left: 5),
                        child: Text(
                          'Número carga: ${modelo!.numeroCarga}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      /* Table(
                          columnWidths: const {
                            0: FractionColumnWidth(0.15),
                            1: FractionColumnWidth(0.85),
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
                                    TextConstantsConsolidacionCargas.ruta,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                                TableCell(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10),
                                    width: 350.0,
                                    child: SizedBox(
                                      width: double
                                          .infinity, // hace que el SizedBox ocupe todo el ancho disponible
                                      child: provider.isLoadingRutas
                                          ? const Center(
                                              child:
                                                  FormCircularProgressIndicator())
                                          : DropdownButton(
                                              isExpanded: true,
                                              value: modelo!.codigoRuta == 0
                                                  ? provider.codigoRuta
                                                  : modelo!.codigoRuta,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                              icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color:
                                                      AppColors.primaryColor),
                                              underline: Container(
                                                height: 2,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              items: provider.rutas.map((e) {
                                                return DropdownMenuItem(
                                                  value: e.codigo,
                                                  child: Text(
                                                      e.nombre.toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14)),
                                                );
                                              }).toList(),
                                              onChanged: <int>(value) {
                                                provider.codigoRuta = value;
                                              }),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]),*/
                      Container(
                        padding:
                            const EdgeInsets.only(top: 5, left: 5, right: 5),
                        alignment: Alignment.bottomCenter,
                        height: 50,
                        width: 350,
                        child: TextField(
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          focusNode: _focusNodeFacturas,
                          controller: _controllerFacturas,
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
                            labelText: TextConstantsConsolidacionCargas.factura,
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
                    child: provider.isLoadingFacturas
                        ? const Center(child: FormCircularProgressIndicator())
                        : LisCargas(
                            detalle: facturas,
                            provider: provider,
                            objeto: cargaSeleccionado,
                          )),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  alignment: Alignment.bottomCenter,
                  child: MaterialButton(
                    minWidth: 60.0,
                    height: 50.0,
                    onPressed: () async {
                      _controllerFacturas.clear();
                      _focusNodeFacturas.unfocus();

                      await provider.obtenerTiposEmpaque(context);

                      await provider.obtenerCargaDetalle(
                          context, modelo!.idCarga, Preferences.usuario);

                      await provider.obtenerTotalBultosFacturas(
                          context, modelo!.idCarga);

                      Navigator.pushNamed(context,
                          ConsolidacionCargasDetalleBultosScreen.routeName);

                      /*Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ConsolidacionCargasDetalleBultosScreen()),
                      );*/
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: AppColors.primaryColor,
                    child: const Text(
                      TextConstantsConsolidacionCargas.detalle,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleEditingComplete() {
    if (_controllerFacturas.text.isNotEmpty) {
      agregarFacturaDetalleConsolidacion(
          modelo!, provider, provDespachos, _controllerFacturas.text, context);
    } else {
      ScreenHelper.showInfoDialog(
          context,
          'Validaciones',
          'Debe ingresar un número de factura',
          TextConstants.ok,
          Icons.error_outline);
    }
  }

  void agregarFacturaDetalleConsolidacion(
      BECargaEncabezado encabezado,
      ConsolidacionCargasProvider prov,
      DespachoProvider provedorDespachos,
      String numero,
      BuildContext context) async {
    bool existe = false;

    BEFacturaConsolidar obj = await provedorDespachos.obtenerFacturasConsolidar(
        context, Preferences.compania, numero);

    // encabezado.ruta = '';DCR(20231005):wi47301

    if (obj.codigoFactura != 0) {
      BECargaFacturas? beFactura = await prov.validarExistenciaFactura(
          context, encabezado.idCarga, numero);

      if (beFactura.idCarga != 0) {
        existe = true;

        await prov.eliminarCargaFacturas(context, beFactura);

        if (prov.eliminado.isNotEmpty &&
            prov.eliminado == "Eliminar exitosamente") {
          /* encabezado.codigoRuta = encabezado.codigoRuta == 0  ? prov.codigoRuta : encabezado.codigoRuta;
          encabezado.ruta = ''; DCR(20231005):wi47301*/

          pintarFila(existe, beFactura);

          Provider.of<ConsolidacionCargasProvider>(context, listen: false)
              .actualizarCargaEncabezado(context, encabezado, 1);

          setState(() {
            _controllerFacturas.text = '';
            numero = '';
          });
        }
      } else {
        existe = false;

        BECargaFacturas beFactura = BECargaFacturas(
          idCarga: encabezado.idCarga,
          codigoFactura: obj.codigoFactura == null ? 0 : obj.codigoFactura!,
          numeroFactura: obj.codigoFactura == null ? '' : obj.numeroFactura!,
          fechaHora: DateTime.now(),
          nombreUsuario: Preferences.usuario,
        );

        await prov.obtenerValidacionesFacturas(context, Preferences.compania,
            obj.codigoFactura!); /*,
            encabezado.codigoRuta == 0
                ? provider.codigoRuta
                : encabezado.codigoRuta DCR(20231005):wi47301 */

        if (prov.validacionesFacturas.isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(TextConstants.validaciones),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: prov.validacionesFacturas.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(prov.validacionesFacturas[index]);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _controllerFacturas.text = '';
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
        } else {
          /*if (encabezado.codigoRuta == 0) {
            encabezado.codigoRuta = encabezado.codigoRuta == 0
                ? prov.codigoRuta
                : encabezado.codigoRuta; DCR(20230510):wi47301
            Provider.of<ConsolidacionCargasProvider>(context, listen: false)
                .actualizarCargaEncabezado(context, encabezado, 1);
          }*/

          pintarFila(existe, beFactura);

          Provider.of<ConsolidacionCargasProvider>(context, listen: false)
              .insertaFacturaConsolidacion(context, beFactura);

          setState(() {
            _controllerFacturas.text = '';
            numero = '';
          });
        }
      }
    } else {
      ScreenHelper.showInfoDialog(context, TextConstants.validaciones,
          'Factura no existe', TextConstants.ok, Icons.error_outline);

      setState(() {
        _controllerFacturas.text = '';
        numero = '';
      });
    }
  }

  void pintarFila(bool encontrado, BECargaFacturas detalle) {
    if (encontrado) {
      setState(() {
        cargaSeleccionado = detalle;
      });
    } else {
      setState(() {
        cargaSeleccionado = BECargaFacturas(
          idCarga: 0,
          codigoFactura: 0,
          numeroFactura: '',
          fechaHora: DateTime.now(),
          nombreUsuario: '',
        );
      });
    }
  }
}

class LisCargas extends StatelessWidget {
  const LisCargas(
      {super.key,
      required this.detalle,
      required this.provider,
      required this.objeto});

  final List<BECargaFacturas> detalle;
  final ConsolidacionCargasProvider provider;
  final BECargaFacturas objeto;

  @override
  Widget build(BuildContext context) {
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
                'Últimas ${detalle.length <= 3 ? detalle.length : 3} facturas de ${provider.totalFacturas}',
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
            return Card(
              elevation: 0,
              color: detalle[index].numeroFactura == objeto.numeroFactura
                  ? Colors.lightGreen
                  : Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                title: Table(
                    columnWidths: const {
                      0: FractionColumnWidth(0.9),
                      1: FractionColumnWidth(0.1),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                detalle[index].numeroFactura.toString(),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () async {
                                  int id = detalle[index].idCarga!;
                                  await provider
                                      .eliminarCargaFacturasDetalleBultos(
                                          context, detalle[index]);

                                  return showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Facturas',
                                          ),
                                          content: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child: SingleChildScrollView(
                                                child: Text(
                                                    provider.eliminadoFactura)),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();

                                                  await provider
                                                      .obtenerCargaFactura(
                                                          context,
                                                          id,
                                                          Preferences.usuario);
                                                },
                                                child: const Text(
                                                  TextConstants.ok,
                                                )),
                                          ],
                                        );
                                      });
                                },
                                child: const Icon(Icons.delete_forever_rounded,
                                    semanticLabel: TextConstants.eliminar,
                                    color: AppColors.primaryColor,
                                    size: 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            );
          },
        ),
      ],
    );
  }
}

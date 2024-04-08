// ignore_for_file: use_build_context_synchronously, constant_identifier_names

import 'dart:core';

import 'package:despachos_app/constants/superBultos/text_constants_super_bultos.dart';
import 'package:despachos_app/screen/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../constants/text_constants.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../shared/preferences.dart';
import '../../widgets/widgets.dart';

import 'package:honeywell_scanner/honeywell_scanner.dart';

class MantenimientoSuperBultosScreen extends StatefulWidget {
  const MantenimientoSuperBultosScreen({Key? key}) : super(key: key);

  static String routeName = 'mantenimientoSuperBultos';

  @override
  State<MantenimientoSuperBultosScreen> createState() =>
      _MantenimientoSuperBultosScreenState();
}

class _MantenimientoSuperBultosScreenState
    extends State<MantenimientoSuperBultosScreen>
    with WidgetsBindingObserver
    implements ScannerCallback {
  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  bool _estaProcesando = false;
  bool _txtBultoHabilitado = true; //Semáforos para control de estados
  bool _estaImprimiendo = false;

  late TextEditingController _controller;
  late FocusNode _focusNode;

  static const BTN_START_SCANNER = 0,
      BTN_STOP_SCANNER = 1,
      BTN_START_SCANNING = 2,
      BTN_STOP_SCANNING = 3;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    _controller = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    honeywellScanner.scannerCallback = this;

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
      _controller.text = scannedData!.code!;
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
              FocusScope.of(context).requestFocus(_focusNode);
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
    _focusNode.dispose();
    _controller.dispose();
    honeywellScanner.stopScanner();
    super.dispose();
  }

  void requestFocusWithoutKeyboard() {
    setState(() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      } else {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  List<BESuperBultoDetalle> detalle = [];

  BESuperBultoEncabezado encabezado = BESuperBultoEncabezado(
      idSuperBulto: 0,
      numeroSuperBulto: 0,
      nombreUsuario: '',
      fechaHoraInicio: DateTime.now(),
      fechaHoraFin: DateTime.now(),
      nombreCliente: '',
      nombreSucursal: '',
      estado: '',
      detalle: []);

  BESuperBultoDetalle bultoSeleccionado = BESuperBultoDetalle(
      idSuperBulto: 0,
      codigoFactura: 0,
      numeroFactura: '',
      numeroBulto: '',
      fechaHora: DateTime.now(),
      nombreUsuario: '');

  // late List<BESuperBultoDetalle> listaDetalles;
  late SuperBultoProvider prov;
  late DespachoProvider provDespacho;

  bool printedCorrectly = false;

  @override
  Widget build(BuildContext context) {
    final providerDespacho = Provider.of<DespachoProvider>(context);
    final provider = Provider.of<SuperBultoProvider>(context);
    final modelo = provider.superBultoSeleccionado;

    detalle = provider.listaDetalle;

    provDespacho = providerDespacho;
    // listaDetalles = detalle;
    prov = provider;
    //Revisar esta asignacion, porque superBultoSeleccionado se asigna a modelo y modelo a encabezado
    encabezado = modelo!;

    return WillPopScope(
      onWillPop: () async {
        Provider.of<SuperBultoProvider>(context, listen: false)
            .obtenerListadoSuperBultoEncabezado(context, Preferences.usuario);

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
                TextConstantsSuperBultos.title1,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Provider.of<SuperBultoProvider>(context, listen: false)
                    .obtenerListadoSuperBultoEncabezado(
                        context, Preferences.usuario);
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      height: 110,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 5, right: 5),
                                alignment: Alignment.topRight,
                                height: 20,
                                width: 150,
                                child: Text(
                                  Preferences.usuario,
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 5, left: 5),
                                alignment: Alignment.topLeft,
                                height: 25,
                                width: 150,
                                child: Text(
                                  'Número bulto: ${modelo.numeroSuperBulto}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  alignment: Alignment.bottomCenter,
                                  height: 60,
                                  width: 300,
                                  child: TextField(
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    focusNode: _focusNode,
                                    controller: _controller,
                                    onEditingComplete: _txtBultoHabilitado
                                        ? _handleEditingComplete
                                        : null,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      fillColor: AppColors.primaryColor,
                                      labelText: 'Numero Bulto',
                                      labelStyle: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: provider.isLoadingDetalle
                            ? const Center(
                                child: FormCircularProgressIndicator())
                            : LisBultosEdit(
                                listDespachos: detalle,
                                provider: provider,
                                objeto: bultoSeleccionado,
                              )),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: [
                            MaterialButton(
                              minWidth: 60.0,
                              height: 50.0,
                              onPressed: _estaImprimiendo
                                  ? null
                                  : () {
                                      if (!_estaImprimiendo) {
                                        finalizarSuperBulto(
                                            provider.superBultoSeleccionado!);
                                      }
                                    },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: AppColors.primaryColor,
                              child: _estaImprimiendo
                                  ? const FormCircularProgressIndicator()
                                  : const Text(
                                      'Finalizar',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                            ),
                            MaterialButton(
                              minWidth: 60.0,
                              height: 50.0,
                              onPressed: () {
                                _controller.clear();
                                _focusNode.unfocus();
                                Provider.of<SuperBultoProvider>(context,
                                        listen: false)
                                    .obtenerListadoSuperBultoEncabezado(
                                        context, Preferences.usuario);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SuperBultosScreen()),
                                );
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: AppColors.primaryColor,
                              child: const Text(
                                'Salir',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              if (_estaProcesando)
                Container(
                  color: Colors.black
                      .withOpacity(0.5), // opcional, para oscurecer el fondo
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  finalizarSuperBulto(BESuperBultoEncabezado superbulto) async {
    setState(() {
      _estaImprimiendo = true;
      _estaProcesando = true;
    });
    _controller.clear();
    _focusNode.unfocus();
    superbulto.nombreUsuario = Preferences.usuario;
    superbulto.estado = 'C';

    String result =
        await Provider.of<SuperBultoProvider>(context, listen: false)
            .actualizarSuperBultoEncabezado(context, superbulto);

    setState(() {
      _estaImprimiendo = false;
      _estaProcesando = _estaImprimiendo || !_txtBultoHabilitado;
    });
    if (result.isNotEmpty) {
      printedCorrectly = false;

      _showPrintConfirmationDialog(1);
    }
  }

  bool _reimprimiendo = false;
  Future<void> _showPrintConfirmationDialog(int copias) async {
    String res = await Provider.of<ImpresionProvider>(context, listen: false)
        .imprimirEtiquetaSuperBultos(context, Preferences.idUsuario,
            prov.superBultoSeleccionado!.numeroSuperBulto!, 3, copias);

    if (res == "Se imprimió la etiqueta") {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Impresión'),
            content: const Text(
                '¿La etiqueta y su compia se imprimieron correctamente?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Sí'),
                onPressed: () {
                  setState(() {
                    printedCorrectly = true;
                    _estaImprimiendo = false;
                  });
                  _controller.clear();
                  _focusNode.unfocus();
                  Provider.of<SuperBultoProvider>(context, listen: false)
                      .obtenerListadoSuperBultoEncabezado(
                          context, Preferences.usuario);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SuperBultosScreen()),
                  );
                },
              ),
              TextButton(
                onPressed: _reimprimiendo
                    ? null
                    : () async {
                        setState(() {
                          printedCorrectly = false;
                          _reimprimiendo = true;
                        });
                        Navigator.of(context).pop();
                        _showPrintConfirmationDialog(1);
                        setState(() {
                          _reimprimiendo = false;
                        });
                      },
                child: const Text('No'),
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

  void _handleEditingComplete() {
    setState(() {
      _txtBultoHabilitado = false;
      _estaProcesando = true;
    });
    if (_controller.text.isNotEmpty) {
      _controller.text = _controller.text.substring(2);
      agregarBultoSuperBulto(encabezado.idSuperBulto, prov, provDespacho,
          _controller.text, context);
    } else {
      ScreenHelper.showInfoDialog(
          context,
          'Validaciones',
          'Debe ingresar un número de bulto',
          TextConstants.ok,
          Icons.error_outline);
    }
    setState(() {
      _txtBultoHabilitado = true;
      _estaProcesando = !_txtBultoHabilitado || _estaImprimiendo;
    });
  }

  void agregarBultoSuperBulto(
      int? codigoSuperBulto,
      SuperBultoProvider prov,
      DespachoProvider provDespacho,
      String numero,
      BuildContext context) async {
    const msjBultoNofacturado = 'Bulto no facturado'; //,
    //   msjRetira = 'El bulto pertenece a un pedido cliente-Retira';
    bool existe = false;
    //Valida que un bulto exista asociados a una factura
    BEFacturaDespacho obj = await provDespacho.obtenerFacturasDespachos(
        context, Preferences.compania, numero);

    if (obj.codigoFactura != 0) {
      //if (obj.tipoRetiro == 1) {
      // valida si el bulto ya existe en el detalle de super bulto para eliminar
      BESuperBultoDetalle? beDetalle =
          await prov.validarExistenciaBulto(context, codigoSuperBulto!, numero);

      if (beDetalle.idSuperBulto != 0) {
        existe = true;

        await prov.eliminarSuperBultoDetalle(context, beDetalle.numeroBulto!);

        if (prov.eliminado.isNotEmpty &&
            prov.eliminado == "Eliminar exitosamente") {
          if (beDetalle.codigoFactura != 0) {
            beDetalle.nombreUsuario = Preferences.usuario;

            pintarFila(existe, beDetalle);
            // encabezado.detalle!.add(beDetalle);

            await prov.insertarBultoSuperBulto(context, beDetalle);

            setState(() {
              _controller.text = '';
              numero = '';
            });
          }
        }
      } else {
        bool existe = false;
        BESuperBultoDetalle beDetalle = BESuperBultoDetalle(
            idSuperBulto: codigoSuperBulto,
            codigoFactura: obj.codigoFactura!,
            numeroFactura: obj.numeroFactura!,
            numeroBulto: obj.numeroBulto!,
            fechaHora: DateTime.now(),
            nombreUsuario: Preferences.usuario);

        //Valida si el bulto pertenece a otro cliente o esta en otro super bulto
        bool respuesta = await prov.obtenerValidacionesSuperBulto(
            context,
            beDetalle.idSuperBulto,
            beDetalle.numeroBulto!,
            obj.nombreCliente!,
            obj.nombreSucursal!);

        if (respuesta) {
          if (prov.validaciones.isNotEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Validaciones'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: prov.validaciones.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(prov.validaciones[index]);
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _controller.text = '';
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
            if (beDetalle.codigoFactura != 0) {
              pintarFila(existe, beDetalle);
              // encabezado.detalle?.clear();
              // encabezado.detalle!.add(beDetalle);

              //Cuando es una insercion de un bulto si no tiene cliente asiganado se le asigna uno
              if (encabezado.nombreCliente!.isEmpty) {
                encabezado.nombreCliente = obj.nombreCliente;
                encabezado.nombreSucursal = obj.nombreSucursal;
                await prov.actualizarSuperBultoEncabezado(context, encabezado);
              }

              await prov.insertarBultoSuperBulto(context, beDetalle);

              setState(() {
                _controller.text = '';
                numero = '';
              });
            }
          }
        }
      }
      //} else {
      //   ScreenHelper.showInfoDialog(context, ScreenHelper.hdValidacion,
      //       msjRetira, TextConstants.ok, Icons.error_outline);
      //   setState(() {
      //     _controller.text = '';
      //     numero = '';
      //   });
      //}
    } else {
      ScreenHelper.showInfoDialog(context, ScreenHelper.hdValidacion,
          msjBultoNofacturado, TextConstants.ok, Icons.error_outline);

      setState(() {
        _controller.text = '';
        numero = '';
      });
    }
  }

  void pintarFila(bool encontrado, BESuperBultoDetalle detalle) {
    if (encontrado) {
      setState(() {
        bultoSeleccionado = detalle;
      });
    } else {
      setState(() {
        bultoSeleccionado = BESuperBultoDetalle(
            idSuperBulto: 0,
            codigoFactura: 0,
            numeroFactura: '',
            numeroBulto: '',
            fechaHora: DateTime.now(),
            nombreUsuario: Preferences.usuario);
      });
    }
  }
}

class LisBultosEdit extends StatelessWidget {
  const LisBultosEdit(
      {super.key,
      required this.listDespachos,
      required this.provider,
      required this.objeto});

  final List<BESuperBultoDetalle> listDespachos;
  final SuperBultoProvider provider;
  final BESuperBultoDetalle objeto;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      verticalDirection: VerticalDirection.down,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 5),
              height: 30,
              width: 250,
              child: Text(
                'Detalle de bultos ${listDespachos.length} de ${listDespachos.isNotEmpty ? listDespachos[0].totalBultos : 0}',
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
          itemCount: listDespachos.length,
          itemBuilder: (context, index) {
            return Card(
                elevation: 0,
                color: listDespachos[index].numeroBulto == objeto.numeroBulto
                    ? Colors.lightGreen
                    : null,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  side:
                      const BorderSide(color: AppColors.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Table(
                      columnWidths: const {
                        0: FractionColumnWidth(0.9),
                        1: FractionColumnWidth(0.1),
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
                                listDespachos[index].numeroBulto.toString(),
                              ),
                            )),
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
                                                    await provider
                                                        .eliminarSuperBultoDetalle(
                                                            context,
                                                            listDespachos[index]
                                                                .numeroBulto!);

                                                    if (provider.eliminado
                                                            .isNotEmpty &&
                                                        provider.eliminado ==
                                                            "Eliminar exitosamente") {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await provider
                                                          .obtenerListaSuperBultoDetalle(
                                                              context,
                                                              listDespachos[
                                                                      index]
                                                                  .idSuperBulto,
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

// ignore_for_file: use_build_context_synchronously

import 'package:despachos_app/models/models.dart';
import 'package:despachos_app/shared/preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../colors/colors.dart';
import '../../constants/constants.dart';
import '../../helpers/helpers.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';

import 'package:honeywell_scanner/honeywell_scanner.dart';

class ReaperturaScreen extends StatefulWidget {
  const ReaperturaScreen({Key? key}) : super(key: key);

  static String routeName = 'reapertura';

  @override
  State<ReaperturaScreen> createState() => _ReaperturaScreenState();
}

class _ReaperturaScreenState extends State<ReaperturaScreen>
    with WidgetsBindingObserver
    implements ScannerCallback {
  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  late TextEditingController _controller;
  late FocusNode _focusNode;

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
    initializeDateFormatting('es');
    WidgetsBinding.instance.addObserver(this);
    honeywellScanner.scannerCallback = this;
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    _controller = TextEditingController();
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

  var numero = '';
  var texto = '';

  BEDataReapertura data = BEDataReapertura();

  late ReaperturaProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ReaperturaProvider>(context);
    data = provider.data;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MenuPermisosScreen()),
          (Route<dynamic> route) => false,
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const FlexibleSpace(),
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              Preferences.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              provider.data = BEDataReapertura();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const MenuPermisosScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                        columnWidths: const {
                          0: FractionColumnWidth(0.25),
                          1: FractionColumnWidth(0.75),
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
                                  'Proceso: ',
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
                                    child: provider.isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator
                                                .adaptive())
                                        : DropdownButton(
                                            isExpanded: true,
                                            value: provider.codigo,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: AppColors.primaryColor),
                                            underline: Container(
                                              height: 2,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                            items: provider.procesos.map((e) {
                                              return DropdownMenuItem(
                                                value: e.codigo,
                                                child: Text(
                                                    e.proceso.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16)),
                                              );
                                            }).toList(),
                                            onChanged: <int>(value) {
                                              provider.codigo = value;
                                            }),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ]),
                    Container(
                      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                      alignment: Alignment.bottomCenter,
                      height: 50,
                      width: 350,
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        focusNode: _focusNode,
                        controller: _controller,
                        onEditingComplete: _handleEditingComplete,
                        onSubmitted: (value) async {
                          numero = value;

                          if (numero.isNotEmpty) {
                            await provider.obtenerDatosReaperturas(
                                context, provider.codigo, int.parse(numero));

                            if (provider.data.codigo == 0) {
                              ScreenHelper.showInfoDialog(
                                  context,
                                  'Información',
                                  provider.codigo == 1
                                      ? '¡El super bulto no existe o esta en estado abierto, debe cerrarlo para poder reaperturarlo!'
                                      : '¡La consolidación de cargas no existe o esta en estado abierto, debe cerrarla para poder reaperturarla!',
                                  TextConstants.ok,
                                  Icons.error_outline);

                              setState(() {
                                _controller.text = '';
                                numero = '';
                              });
                            }
                          } else {
                            ScreenHelper.showInfoDialog(
                                context,
                                'Información',
                                '¡Debe ingresar un numero de super bulto o consolidacion de carga para continuar!',
                                TextConstants.ok,
                                Icons.error_outline);

                            setState(() {
                              _controller.text = '';
                              numero = '';
                            });
                          }
                        },
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
                          labelText: 'Código',
                          labelStyle: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      padding:
                          const EdgeInsets.only(top: 10, left: 5, right: 5),
                      child: provider.isLoadingData
                          ? const Center(child: FormCircularProgressIndicator())
                          : data.usuario == null
                              ? const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Center(
                                          child:
                                              Text('No hay datos disponibles'))
                                    ])
                              : Data(objeto: data),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 5),
                          alignment: Alignment.topLeft,
                          child: const Text(
                            'Motivo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                      alignment: Alignment.bottomCenter,
                      width: 350,
                      child: TextField(
                        maxLength: 150,
                        maxLines:
                            null, // Esto permite que el campo de texto tenga múltiples líneas, similar a un textarea
                        keyboardType: TextInputType
                            .multiline, // Indica que el teclado debe admitir múltiples líneas de texto
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
                          labelStyle: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                        onChanged: (value) {
                          texto = value;
                          provider.motivo = value;

                          setState(() {
                            texto = '';
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      alignment: Alignment.bottomCenter,
                      child: MaterialButton(
                        minWidth: 60.0,
                        height: 50.0,
                        onPressed: provider.isLoadingInsert
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();

                                if (provider.data.codigo == null ||
                                    provider.data.codigo == 0) {
                                  ScreenHelper.showInfoDialog(
                                      context,
                                      'Información',
                                      'Debe seleccionar un proceso para realizar la reapertura',
                                      TextConstants.ok,
                                      Icons.error_outline);
                                } else if (provider.motivo.isEmpty) {
                                  ScreenHelper.showInfoDialog(
                                      context,
                                      'Información',
                                      'Debe ingresar un motivo para realizar la reapertura',
                                      TextConstants.ok,
                                      Icons.error_outline);
                                } else {
                                  BEReapertura reapertura = BEReapertura(
                                      idRegistro: 0,
                                      nombreUsuario: provider.data.usuario!,
                                      nombreProceso: provider.codigo.toString(),
                                      codigoReferencia: provider.data.codigo!,
                                      motivo: provider.motivo);

                                  if (provider.codigo == 1) {
                                    await provider
                                        .obtenerValidacionesReaperturas(
                                            context, provider.data.codigo!);

                                    if (provider.validaciones.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                TextConstants.validaciones),
                                            content: SizedBox(
                                              width: double.maxFinite,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: provider
                                                    .validaciones.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Text(provider
                                                      .validaciones[index]);
                                                },
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                    TextConstants.ok),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      await provider.insertarReaperturas(
                                          context, reapertura);

                                      if (provider.resultado ==
                                          "Registrado exitosamente") {
                                        provider.motivo = '';
                                        texto = '';

                                        _controller.clear();
                                        _focusNode.unfocus();

                                        provider.data = BEDataReapertura();

                                        Fluttertoast.showToast(
                                            gravity: ToastGravity.CENTER,
                                            msg: provider.resultado,
                                            fontSize: 14);

                                        Navigator.of(context).pop();
                                      } else {
                                        ScreenHelper.showInfoDialog(
                                            context,
                                            'Reapertura',
                                            provider.resultado,
                                            TextConstants.ok,
                                            Icons.error_outline);

                                        Navigator.of(context).pop();
                                      }
                                    }
                                  } else {
                                    BEReapertura reapertura = BEReapertura(
                                        idRegistro: 0,
                                        nombreUsuario: provider.data.usuario!,
                                        nombreProceso:
                                            provider.codigo.toString(),
                                        codigoReferencia: provider.data.codigo!,
                                        motivo: provider.motivo);

                                    await provider.insertarReaperturas(
                                        context, reapertura);

                                    if (provider.resultado ==
                                        "Registrado exitosamente") {
                                      provider.motivo = '';
                                      texto = '';

                                      _controller.clear();
                                      _focusNode.unfocus();

                                      provider.data = BEDataReapertura();

                                      Fluttertoast.showToast(
                                          gravity: ToastGravity.CENTER,
                                          msg: provider.resultado,
                                          fontSize: 14);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MenuPermisosScreen()),
                                      );
                                    } else {
                                      ScreenHelper.showInfoDialog(
                                          context,
                                          'Reapertura',
                                          provider.resultado,
                                          TextConstants.ok,
                                          Icons.error_outline);

                                      Navigator.of(context).pop();
                                    }
                                  }
                                }
                              },
                        disabledColor: AppColors.secundaryColor,
                        disabledTextColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: AppColors.primaryColor,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 15),
                          child: provider.isLoadingInsert
                              ? const Row(
                                  children: [
                                    SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: FormCircularProgressIndicator()),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(TextConstants.espere,
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                )
                              : const Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Aceptar',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _handleEditingComplete() {
    provider.obtenerDatosReaperturas(
        context, provider.codigo, int.parse(_controller.text));
  }
}

class Data extends StatelessWidget {
  const Data({super.key, required this.objeto});

  final BEDataReapertura objeto;

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy hh:mm');
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
        children: [
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Container(
                  alignment: Alignment.topCenter,
                  child: Text(
                      objeto.fecha == null
                          ? ''
                          : formatoFecha.format(objeto.fecha!).toString(),
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black))),
              subtitle: Container(
                alignment: Alignment.bottomCenter,
                child: Text(objeto.usuario == null ? '' : objeto.usuario!,
                    style: const TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ),
          ),
        ]);
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:despachos_app/models/models.dart';
import 'package:despachos_app/providers/providers.dart';
import 'package:despachos_app/screen/screens.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors/colors.dart';
import '../../shared/preferences.dart';
import '../../widgets/widgets.dart';

class ConsolidacionCargasScreen extends StatefulWidget {
  const ConsolidacionCargasScreen({Key? key}) : super(key: key);

  static String routeName = 'consolidacionCargas';

  @override
  State<ConsolidacionCargasScreen> createState() =>
      _ConsolidacionCargasScreenState();
}

class _ConsolidacionCargasScreenState extends State<ConsolidacionCargasScreen> {
  late bool _isButtonDisabled;

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = false;
    initializeDateFormatting('es');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConsolidacionCargasProvider>(context);
    final listado = provider.listaCargas;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MenuPermisosScreen()),
          (Route<dynamic> route) => false,
        );
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MenuPermisosScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () async {
                    await provider.obtenerCargaEncabezado(
                        Preferences.usuario, context);
                  },
                  child: const Icon(Icons.sync),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 5, right: 5),
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
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 5),
                          height: 20,
                          width: 250,
                          child: const Text(
                            'Existentes',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.primaryColor, height: 1),
                    const SizedBox(
                      height: 5,
                    ),
                    provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive())
                        : listado.isEmpty
                            ? const Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Center(
                                        child: Text('No hay datos disponibles'))
                                  ])
                            : LisConsolidacionCargas(listCargas: listado),
                  ],
                ),
              ),
            ]),
          ),
          floatingActionButton: MaterialButton(
            minWidth: 15,
            height: 55,
            onPressed: _isButtonDisabled
                ? null
                : () async {
                    setState(() {
                      _isButtonDisabled = true;
                    });

                    final providerConsolidacion =
                        Provider.of<ConsolidacionCargasProvider>(context,
                            listen: false);

                    await providerConsolidacion.insertarConsolidacionCarga(
                        context,
                        1,
                        BECargaEncabezado(
                            idCarga: 0,
                            numeroCarga: 0,
                            nombreUsuario: Preferences.usuario,
                            fechaHoraInicio: DateTime.now(),
                            fechaHoraFin: DateTime.now(),
                            /*codigoRuta: 0,
                            ruta: '',DCR(20231005): wi47301*/
                            estado: 'A',
                            detalle: [],
                            facturas: []));

                    await providerConsolidacion.obtenerCargaEncabezadoNumero(
                        context,
                        int.parse(providerConsolidacion.consecutivo),
                        Preferences.usuario);

                    await providerConsolidacion.obtenerCargaFactura(
                        context,
                        providerConsolidacion.cargaSeleccionado!.idCarga,
                        Preferences.usuario);

                    /*await provider.obtenerListaRutas(
                        context, Preferences.compania);*/

                    await provider.obtenerTotalFacturas(context,
                        providerConsolidacion.cargaSeleccionado!.idCarga);

                    setState(() {
                      _isButtonDisabled = false;

                      Navigator.pushNamed(context,
                          ConsolidacionCargasDetalleFacturasScreen.routeName);

                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ConsolidacionCargasDetalleFacturasScreen()),
                      );*/
                    });
                  },
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            disabledColor: AppColors.primaryColor,
            elevation: 1,
            color: AppColors.primaryColor,
            child: _isButtonDisabled
                ? const FormCircularProgressIndicator()
                : const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}

class LisConsolidacionCargas extends StatelessWidget {
  const LisConsolidacionCargas({super.key, required this.listCargas});

  final List<BECargaEncabezado> listCargas;

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy hh:mm');
    return Column(
      children: <Widget>[
        Scrollbar(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: listCargas.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                child: ListTile(
                  onTap: () async {
                    final provider = Provider.of<ConsolidacionCargasProvider>(
                        context,
                        listen: false);

                    await provider.obtenerListaRutas(
                        context, Preferences.compania);

                    provider.cargaSeleccionado = null;
                    provider.cargaSeleccionado = listCargas[index];

                    await provider.obtenerCargaFactura(context,
                        listCargas[index].idCarga, Preferences.usuario);

                    await provider.obtenerTotalFacturas(
                        context, listCargas[index].idCarga);

                    Navigator.pushNamed(context,
                        ConsolidacionCargasDetalleFacturasScreen.routeName);

                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ConsolidacionCargasDetalleFacturasScreen()),
                    );*/
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Table(
                      columnWidths: const {
                        0: FractionColumnWidth(0.4),
                        1: FractionColumnWidth(0.6),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                                child: Container(
                              alignment: Alignment.centerLeft,
                              child: const Text('Número carga:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            )),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    listCargas[index].numeroCarga.toString(),
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                                child: Container(
                              alignment: Alignment.centerLeft,
                              child: const Text('Fecha:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            )),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    formatoFecha
                                        .format(
                                            listCargas[index].fechaHoraInicio!)
                                        .toString(),
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        /*TableRow(
                          children: [
                            TableCell(
                                child: Container(
                              alignment: Alignment.centerLeft,
                              child: const Text('Ruta:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            )),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(listCargas[index].ruta,
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ), DCR(20231005): wi47301*/
                        TableRow(
                          children: [
                            TableCell(
                                child: Container(
                              alignment: Alignment.centerLeft,
                              child: const Text('Usuario:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            )),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(listCargas[index].nombreUsuario,
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        )
                      ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
